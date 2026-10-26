import '../core/utils/dates.dart';
import '../data/app_data.dart';
import '../data/models/prayer.dart';
import '../data/models/task.dart';
import 'planner.dart';
import 'prayer_times.dart';

enum TimelineKind { prayer, event, task, work, rest }

/// One row of "today's schedule" on the home screen.
class TimelineItem {
  const TimelineItem({
    required this.kind,
    required this.start,
    required this.end,
    this.title,
    this.refId,
    this.prayer,
    this.task,
    this.suggested = false,
    this.estimated = false,
  });

  final TimelineKind kind;
  final DateTime start;
  final DateTime end;

  /// Event title; other kinds are named by the UI.
  final String? title;
  final String? refId;
  final Prayer? prayer;
  final Task? task;

  /// Placed by the planner, not by the user.
  final bool suggested;

  /// Duration was assumed (task without an estimate).
  final bool estimated;

  bool isNow(DateTime now) => !start.isAfter(now) && end.isAfter(now);
  bool isPast(DateTime now) => !end.isAfter(now);
  int get minutes => end.difference(start).inMinutes;
}

class DayTimeline {
  const DayTimeline({required this.items, required this.plan, this.current, this.next});
  final List<TimelineItem> items;
  final DayPlan plan;

  /// What is happening now, if anything.
  final TimelineItem? current;

  /// The first thing that starts after now.
  final TimelineItem? next;
}

/// Today's schedule: fixed commitments (events, prayers, work, breaks),
/// tasks the user planned for a time, and the planner's suggestions for the
/// remaining open tasks in the free time left.
DayTimeline buildTimeline(AppData d, DateTime now, {Planner planner = const Planner()}) {
  final today = dateOnly(now);
  // Tasks the user (or an approved assistant plan) already put at a time
  // today keep that time; the planner places only the rest.
  final userPlanned = d.tasks
      .where((t) => t.isOpen && !t.archived && t.plannedStart != null && isSameDay(t.plannedStart!, today))
      .toList();
  final plan = planner.plan(
    day: today,
    now: now,
    tasks: d.tasks,
    events: [
      ...d.events,
      // Treat user-planned tasks as busy time so suggestions don't overlap.
      for (final t in userPlanned)
        CalendarEvent(
          id: 'task:${t.id}',
          title: t.title,
          start: t.plannedStart!,
          end: t.plannedStart!.add(Duration(minutes: t.estimatedMinutes ?? planner.defaultEstimate)),
          updatedAt: now,
        ),
    ],
    settings: d.settings,
    exclude: {for (final t in userPlanned) t.id},
  );

  final items = <TimelineItem>[
    for (final b in plan.fixed)
      if (b.refId?.startsWith('task:') ?? false)
        _taskItem(d.task(b.refId!.substring(5))!, b.start, b.end, suggested: false)
      else
        TimelineItem(
          kind: switch (b.kind) {
            BlockKind.event => TimelineKind.event,
            BlockKind.prayer => TimelineKind.prayer,
            BlockKind.work => TimelineKind.work,
            BlockKind.rest || BlockKind.free => TimelineKind.rest,
          },
          start: b.start,
          end: b.end,
          title: b.label,
          refId: b.refId,
          prayer: b.kind == BlockKind.prayer ? Prayer.values.byName(b.refId!) : null,
        ),
    for (final p in plan.planned) _taskItem(p.task, p.start, p.end, suggested: true, estimated: p.estimated),
  ];
  // Prayers outside the planning hours (often Fajr) still belong on the
  // day's schedule; they just don't affect planning.
  final prayers = prayerDay(d.settings.prayer, today);
  if (prayers != null) {
    for (final e in prayers.times.entries) {
      if (items.any((i) => i.prayer == e.key)) continue;
      items.add(TimelineItem(
        kind: TimelineKind.prayer,
        start: e.value,
        end: e.value.add(Duration(minutes: d.settings.prayer.blockMinutes)),
        refId: e.key.name,
        prayer: e.key,
      ));
    }
  }
  items.sort((a, b) => a.start.compareTo(b.start));

  // Prefer a real commitment over a break when they overlap.
  final nowItems = items.where((i) => i.isNow(now)).toList()
    ..sort((a, b) => (a.kind == TimelineKind.rest ? 1 : 0).compareTo(b.kind == TimelineKind.rest ? 1 : 0));
  final current = nowItems.firstOrNull;
  final next = items.where((i) => i.start.isAfter(now)).firstOrNull;
  return DayTimeline(items: items, plan: plan, current: current, next: next);
}

TimelineItem _taskItem(Task t, DateTime start, DateTime end, {required bool suggested, bool estimated = false}) =>
    TimelineItem(
      kind: TimelineKind.task,
      start: start,
      end: end,
      title: t.title,
      refId: t.id,
      task: t,
      suggested: suggested,
      estimated: estimated || t.estimatedMinutes == null,
    );
