import '../core/utils/dates.dart';
import '../data/app_data.dart';
import 'prayer_times.dart';

/// What fills a stretch of the day. [sleep] is everything outside the
/// user's waking hours: it is never counted as free.
enum SlotKind { sleep, work, event, prayer, rest, task, free, past }

class DaySlot {
  const DaySlot(this.start, this.end, this.kind, {this.label, this.refId});
  final DateTime start;
  final DateTime end;
  final SlotKind kind;
  final String? label;
  final String? refId;
  int get minutes => end.difference(start).inMinutes;

  bool overlaps(DateTime s, DateTime e) => start.isBefore(e) && s.isBefore(end);
}

/// Two commitments at the same time.
class Clash {
  const Clash(this.a, this.b);
  final DaySlot a;
  final DaySlot b;
}

/// One day measured in real time (section 11 of the v4 change list): the 24
/// hours split into sleep, fixed commitments, tasks planned for a time, and
/// what is actually free. A long task list does not make a day busy; only
/// time that is taken does.
class DaySchedule {
  const DaySchedule({
    required this.day,
    required this.slots,
    required this.commitments,
    required this.clashes,
    required this.dueMinutes,
    required this.unplannedDue,
  });

  final DateTime day;

  /// The whole day from midnight to midnight, in order, without overlaps.
  final List<DaySlot> slots;

  /// Every fixed or planned commitment as entered (may overlap; see [clashes]).
  final List<DaySlot> commitments;
  final List<Clash> clashes;

  /// Open tasks due on this day (or overdue, for today) with no time set:
  /// the time they still need.
  final int dueMinutes;
  final int unplannedDue;

  int _sum(bool Function(SlotKind) f) => slots.where((s) => f(s.kind)).fold(0, (a, s) => a + s.minutes);

  int get sleepMinutes => _sum((k) => k == SlotKind.sleep);
  int get freeMinutes => _sum((k) => k == SlotKind.free);
  int get busyMinutes => _sum((k) => k != SlotKind.sleep && k != SlotKind.free && k != SlotKind.past);

  /// Waking time still ahead (busy + free).
  int get awakeAhead => busyMinutes + freeMinutes;

  /// Free stretches of at least [min] minutes.
  List<DaySlot> freeSlots({int min = 15}) => slots.where((s) => s.kind == SlotKind.free && s.minutes >= min).toList();

  /// Share of the waking time ahead that is taken, 0–1.
  double get load => awakeAhead == 0 ? 0 : busyMinutes / awakeAhead;

  /// Busy only when the time is really taken, or the tasks due can't fit in
  /// what is left.
  bool get isBusy => load > 0.85 || dueMinutes > freeMinutes;

  bool get fitsDue => dueMinutes <= freeMinutes;

  static const _priority = {
    SlotKind.event: 0,
    SlotKind.task: 1,
    SlotKind.prayer: 2,
    // A break inside work hours is a break.
    SlotKind.rest: 3,
    SlotKind.work: 4,
  };

  static DaySchedule build(AppData d, DateTime day, DateTime now, {int defaultEstimate = 30}) {
    final s = d.settings;
    final dayStart = dateOnly(day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final wake = atMinutes(dayStart, s.dayStart);
    // Bedtime after midnight is stored past 24:00 (e.g. 25:00 = 1 am).
    final bed = atMinutes(dayStart, s.dayEnd);

    final c = <DaySlot>[];
    void add(DateTime a, DateTime b, SlotKind k, {String? label, String? refId}) {
      final st = a.isBefore(dayStart) ? dayStart : a;
      final en = b.isAfter(dayEnd) ? dayEnd : b;
      if (en.isAfter(st)) c.add(DaySlot(st, en, k, label: label, refId: refId));
    }

    for (final e in d.events) {
      add(e.start, e.end, SlotKind.event, label: e.title, refId: e.id);
    }
    for (final t in d.tasks) {
      final p = t.plannedStart;
      if (p == null || !t.isOpen || t.archived) continue;
      add(p, p.add(Duration(minutes: t.estimatedMinutes ?? defaultEstimate)), SlotKind.task, label: t.title, refId: t.id);
    }
    final work = s.work;
    if (work != null && s.workDays.contains(dayStart.weekday)) {
      add(atMinutes(dayStart, work.start), atMinutes(dayStart, work.end), SlotKind.work);
    }
    for (final b in s.breaks) {
      add(atMinutes(dayStart, b.start), atMinutes(dayStart, b.end), SlotKind.rest);
    }
    final prayers = prayerDay(s.prayer, dayStart);
    if (prayers != null) {
      for (final e in prayers.times.entries) {
        add(e.value, e.value.add(Duration(minutes: s.prayer.blockMinutes)), SlotKind.prayer, refId: e.key.name);
      }
    }
    c.sort((a, b) => a.start.compareTo(b.start));

    // Clashes: things that can't both happen. Work, breaks and prayers are
    // routine; an appointment inside them is still worth flagging, but two
    // routine blocks overlapping (a prayer during work) is not.
    bool routine(SlotKind k) => k == SlotKind.work || k == SlotKind.rest || k == SlotKind.prayer;
    final clashes = <Clash>[
      for (var i = 0; i < c.length; i++)
        for (var j = i + 1; j < c.length && c[j].start.isBefore(c[i].end); j++)
          if (!(routine(c[i].kind) && routine(c[j].kind)) && c[i].overlaps(c[j].start, c[j].end)) Clash(c[i], c[j]),
    ];

    // Lay the 24 hours out minute-accurately: sleep outside waking hours,
    // the past (today only) is gone, then the highest-priority commitment
    // wins each stretch, and only what remains is free.
    final cuts = <DateTime>{dayStart, dayEnd};
    void cut(DateTime t) {
      if (t.isAfter(dayStart) && t.isBefore(dayEnd)) cuts.add(t);
    }

    cut(wake);
    cut(bed);
    final today = isSameDay(dayStart, now);
    if (today) cut(now);
    for (final x in c) {
      cut(x.start);
      cut(x.end);
    }
    final points = cuts.toList()..sort();
    final raw = <DaySlot>[];
    for (var i = 0; i + 1 < points.length; i++) {
      final a = points[i], b = points[i + 1];
      final awake = !a.isBefore(wake) && !b.isAfter(bed);
      DaySlot slot;
      final over = c.where((x) => x.overlaps(a, b)).toList()..sort((x, y) => _priority[x.kind]!.compareTo(_priority[y.kind]!));
      if (over.isNotEmpty && (awake || over.first.kind == SlotKind.event || over.first.kind == SlotKind.task)) {
        // An appointment at 3 am still takes that time.
        final top = over.first;
        slot = DaySlot(a, b, top.kind, label: top.label, refId: top.refId);
      } else if (!awake) {
        slot = DaySlot(a, b, SlotKind.sleep);
      } else if (today && b.isAfter(dayStart) && !b.isAfter(now)) {
        slot = DaySlot(a, b, SlotKind.past);
      } else {
        slot = DaySlot(a, b, SlotKind.free);
      }
      raw.add(slot);
    }
    // Merge neighbours of the same kind and source.
    final slots = <DaySlot>[];
    for (final x in raw) {
      final last = slots.isEmpty ? null : slots.last;
      if (last != null && last.kind == x.kind && last.refId == x.refId && last.end == x.start) {
        slots[slots.length - 1] = DaySlot(last.start, x.end, x.kind, label: last.label, refId: last.refId);
      } else {
        slots.add(x);
      }
    }

    final key = dayKey(dayStart);
    final due = d.tasks.where((t) {
      if (!t.isOpen || t.archived || t.plannedStart != null || t.dueDate == null) return false;
      return t.dueDate == key || (today && t.dueDate!.compareTo(key) < 0);
    }).toList();
    return DaySchedule(
      day: dayStart,
      slots: slots,
      commitments: c,
      clashes: clashes,
      dueMinutes: due.fold(0, (a, t) => a + (t.estimatedMinutes ?? defaultEstimate)),
      unplannedDue: due.length,
    );
  }
}

/// What a new or moved item at [start, end) would collide with, excluding
/// the item itself ([exceptId]). Sleep counts: planning into it is flagged.
List<DaySlot> clashesFor(AppData d, DateTime start, DateTime end, DateTime now, {String? exceptId}) {
  final out = <DaySlot>[];
  for (var day = dateOnly(start); day.isBefore(end); day = day.add(const Duration(days: 1))) {
    final s = DaySchedule.build(d, day, now);
    out.addAll(s.commitments.where((x) => x.refId != exceptId && x.overlaps(start, end) && x.kind != SlotKind.rest));
    out.addAll(s.slots.where((x) => x.kind == SlotKind.sleep && x.overlaps(start, end)));
  }
  return out;
}
