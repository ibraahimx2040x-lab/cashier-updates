import '../core/utils/dates.dart';
import '../data/models/settings.dart';
import '../data/models/task.dart';
import 'prayer_times.dart';

/// Deterministic, explainable day planner (section 18).
///
/// It never invents a duration silently: tasks without an estimate get
/// [defaultEstimate] and are flagged `estimated` so the UI can say so.
/// When the day is full it does not squeeze tasks in; they are returned in
/// [DayPlan.unscheduled] with a reason.
class Planner {
  const Planner({
    this.defaultEstimate = 30,
    this.gapMinutes = 10,
    this.slackRatio = 0.15,
  });

  final int defaultEstimate;

  /// Breathing room left after each task.
  final int gapMinutes;

  /// Share of free time kept unplanned for interruptions and rest.
  final double slackRatio;

  DayPlan plan({
    required DateTime day,
    required DateTime now,
    required List<Task> tasks,
    required List<CalendarEvent> events,
    required UserSettings settings,
    List<String>? manualOrder,
    Set<String> exclude = const {},
  }) {
    final d = dateOnly(day);
    final today = isSameDay(d, now);

    // 1. Fixed blocks: events, prayers, work/study block, breaks.
    final fixed = <Block>[];
    final dayStart = atMinutes(d, settings.dayStart);
    final dayEnd = atMinutes(d, settings.dayEnd);
    for (final e in events) {
      if (e.start.isBefore(dayEnd) && e.end.isAfter(dayStart)) {
        fixed.add(Block(e.start, e.end, BlockKind.event, label: e.title, refId: e.id));
      }
    }
    final work = settings.work;
    if (work != null && settings.workDays.contains(d.weekday)) {
      fixed.add(Block(atMinutes(d, work.start), atMinutes(d, work.end), BlockKind.work));
    }
    for (final b in settings.breaks) {
      fixed.add(Block(atMinutes(d, b.start), atMinutes(d, b.end), BlockKind.rest));
    }
    final prayers = prayerDay(settings.prayer, d);
    if (prayers != null) {
      for (final e in prayers.times.entries) {
        final end = e.value.add(Duration(minutes: settings.prayer.blockMinutes));
        if (e.value.isBefore(dayEnd) && end.isAfter(dayStart)) {
          fixed.add(Block(e.value, end, BlockKind.prayer, refId: e.key.name));
        }
      }
    }
    fixed.sort((a, b) => a.start.compareTo(b.start));

    // 2. Free windows inside [dayStart, dayEnd], starting from "now" if today.
    var cursor = dayStart;
    if (today && now.isAfter(cursor)) cursor = _roundUp(now);
    final free = <Block>[];
    for (final b in fixed) {
      if (b.start.isAfter(cursor)) {
        final end = b.start.isBefore(dayEnd) ? b.start : dayEnd;
        if (end.isAfter(cursor)) free.add(Block(cursor, end, BlockKind.free));
      }
      if (b.end.isAfter(cursor)) cursor = b.end;
    }
    if (dayEnd.isAfter(cursor)) free.add(Block(cursor, dayEnd, BlockKind.free));

    final freeMinutes = free.fold<int>(0, (s, b) => s + b.minutes);
    final budget = (freeMinutes * (1 - slackRatio)).floor();

    // 3. Candidates: open, unarchived, due on/before this day or undated.
    final candidates = tasks.where((t) {
      if (!t.isOpen || t.archived || exclude.contains(t.id)) return false;
      if (t.dueDate == null) return true;
      return !parseDayKey(t.dueDate!).isAfter(d);
    }).toList()
      ..sort((a, b) => _rank(a, d).compareTo(_rank(b, d)));
    if (manualOrder != null) {
      int pos(Task t) {
        final i = manualOrder.indexOf(t.id);
        return i < 0 ? manualOrder.length : i;
      }
      // Stable: unknown tasks keep their ranked order after ordered ones.
      final ranked = [...candidates];
      candidates.sort((a, b) {
        final c = pos(a).compareTo(pos(b));
        return c != 0 ? c : ranked.indexOf(a).compareTo(ranked.indexOf(b));
      });
    }

    // 4. Greedy placement into free windows.
    final windows = [...free];
    final placed = <PlannedTask>[];
    final unscheduled = <UnscheduledTask>[];
    var used = 0;
    for (final t in candidates) {
      final minutes = t.estimatedMinutes ?? defaultEstimate;
      if (used + minutes > budget) {
        unscheduled.add(UnscheduledTask(t, UnscheduledReason.noTime));
        continue;
      }
      final i = windows.indexWhere((w) => w.minutes >= minutes);
      if (i < 0) {
        unscheduled.add(UnscheduledTask(t, UnscheduledReason.noSlotLongEnough));
        continue;
      }
      final w = windows[i];
      final start = w.start;
      final end = start.add(Duration(minutes: minutes));
      // Do not plan past a hard deadline time on the same day.
      final due = t.dueAt;
      if (due != null && t.dueTime != null && isSameDay(due, d) && end.isAfter(due)) {
        unscheduled.add(UnscheduledTask(t, UnscheduledReason.afterDeadline));
        continue;
      }
      placed.add(PlannedTask(t, start, end, estimated: t.estimatedMinutes == null));
      used += minutes;
      final nextStart = end.add(Duration(minutes: gapMinutes));
      if (nextStart.isBefore(w.end)) {
        windows[i] = Block(nextStart, w.end, BlockKind.free);
      } else {
        windows.removeAt(i);
      }
    }

    placed.sort((a, b) => a.start.compareTo(b.start));
    return DayPlan(
      day: d,
      fixed: fixed,
      planned: placed,
      unscheduled: unscheduled,
      freeMinutes: freeMinutes,
      // Only tasks due by this day need the time; undated ones are filler
      // suggestions and don't make a day look full.
      neededMinutes: candidates.where((t) => t.dueDate != null).fold(0, (s, t) => s + (t.estimatedMinutes ?? defaultEstimate)),
    );
  }

  /// Lower sorts first: overdue, then due today, then priority, then
  /// earliest deadline, then shortest.
  static List<num> _rankParts(Task t, DateTime d) {
    final due = t.dueDate == null ? null : parseDayKey(t.dueDate!);
    final urgency = due == null ? 2 : (due.isBefore(d) ? 0 : 1);
    return [
      urgency,
      2 - t.priority.index,
      due?.millisecondsSinceEpoch ?? 1 << 52,
      t.estimatedMinutes ?? 30,
    ];
  }

  static _Rank _rank(Task t, DateTime d) => _Rank(_rankParts(t, d), t.id);

  static DateTime _roundUp(DateTime t) {
    final m = t.minute % 5 == 0 && t.second == 0 ? t.minute : (t.minute ~/ 5 + 1) * 5;
    return DateTime(t.year, t.month, t.day, t.hour).add(Duration(minutes: m));
  }
}

class _Rank implements Comparable<_Rank> {
  _Rank(this.parts, this.tie);
  final List<num> parts;
  final String tie;
  @override
  int compareTo(_Rank o) {
    for (var i = 0; i < parts.length; i++) {
      final c = parts[i].compareTo(o.parts[i]);
      if (c != 0) return c;
    }
    return tie.compareTo(o.tie);
  }
}

enum BlockKind { event, prayer, work, rest, free }

class Block {
  const Block(this.start, this.end, this.kind, {this.label, this.refId});
  final DateTime start;
  final DateTime end;
  final BlockKind kind;
  final String? label;
  final String? refId;
  int get minutes => end.difference(start).inMinutes;
}

class PlannedTask {
  const PlannedTask(this.task, this.start, this.end, {this.estimated = false});
  final Task task;
  final DateTime start;
  final DateTime end;

  /// Duration was not set by the user; [Planner.defaultEstimate] was used.
  final bool estimated;
}

enum UnscheduledReason { noTime, noSlotLongEnough, afterDeadline }

class UnscheduledTask {
  const UnscheduledTask(this.task, this.reason);
  final Task task;
  final UnscheduledReason reason;
}

class DayPlan {
  const DayPlan({
    required this.day,
    required this.fixed,
    required this.planned,
    required this.unscheduled,
    required this.freeMinutes,
    required this.neededMinutes,
  });

  final DateTime day;
  final List<Block> fixed;
  final List<PlannedTask> planned;
  final List<UnscheduledTask> unscheduled;
  final int freeMinutes;
  final int neededMinutes;

  bool get overCapacity => neededMinutes > freeMinutes;
  bool get isEmpty => planned.isEmpty && unscheduled.isEmpty;
}
