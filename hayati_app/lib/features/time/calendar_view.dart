import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../data/app_data.dart';
import '../../data/data_controller.dart';
import '../../data/models/task.dart';
import '../../domain/day_schedule.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import 'day_overview.dart';

enum CalMode { day, week, month }

/// Screen 8 — events and timed tasks on one timeline. Fixed events and
/// flexible tasks are distinguished by icon *and* colour.
class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  CalMode _mode = CalMode.day;
  late DateTime _day = dateOnly(ref.read(clockProvider)());

  void _shift(int dir) => setState(() {
        _day = switch (_mode) {
          CalMode.day => _day.add(Duration(days: dir)),
          CalMode.week => _day.add(Duration(days: 7 * dir)),
          CalMode.month => DateTime(_day.year, _day.month + dir, 1),
        };
      });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final weekStart = startOfWeek(_day, d.settings.weekStart);
    final title = switch (_mode) {
      CalMode.day => fmt.fullDate(_day),
      CalMode.week => '${fmt.dateShort(weekStart)} – ${fmt.dateShort(weekStart.add(const Duration(days: 6)))}',
      CalMode.month => fmt.monthYear(_day),
    };
    return ResponsiveContainer(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.m, Space.gutter, 0),
          child: SegmentedButton<CalMode>(
            segments: [
              ButtonSegment(value: CalMode.day, label: Text(l.day)),
              ButtonSegment(value: CalMode.week, label: Text(l.week)),
              ButtonSegment(value: CalMode.month, label: Text(l.month)),
            ],
            selected: {_mode},
            onSelectionChanged: (v) => setState(() => _mode = v.first),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.s, vertical: Space.s),
          child: Row(children: [
            IconButton(tooltip: l.previous, onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left)),
            Expanded(child: Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall)),
            IconButton(tooltip: l.nextPeriod, onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right)),
            TextButton(onPressed: () => setState(() => _day = dateOnly(DateTime.now())), child: Text(l.today)),
            IconButton.filledTonal(
              tooltip: l.addEvent,
              onPressed: () => context.push('${Routes.event('new')}?date=${dayKey(_day)}'),
              icon: const Icon(Icons.add),
            ),
          ]),
        ),
        Expanded(
          child: switch (_mode) {
            CalMode.day => _DayTimeline(day: _day, data: d, fmt: fmt),
            CalMode.week => _WeekList(start: weekStart, data: d, fmt: fmt, onDay: (x) => setState(() {
                  _day = x;
                  _mode = CalMode.day;
                })),
            CalMode.month => _MonthGrid(month: _day, data: d, weekStart: d.settings.weekStart, onDay: (x) => setState(() {
                  _day = x;
                  _mode = CalMode.day;
                })),
          },
        ),
      ]),
    );
  }
}

List<CalendarEvent> eventsOn(AppData d, DateTime day) {
  final s = dateOnly(day), e = s.add(const Duration(days: 1));
  return d.events.where((x) => x.overlaps(s, e)).toList()..sort((a, b) => a.start.compareTo(b.start));
}

/// Tasks with a time on [day]: planned start, else deadline time.
List<(Task, DateTime)> timedTasksOn(AppData d, DateTime day) {
  final out = <(Task, DateTime)>[];
  for (final t in d.tasks) {
    if (t.archived || t.status == TaskStatus.cancelled) continue;
    final at = t.plannedStart ?? (t.dueTime != null ? t.dueAt : null);
    if (at != null && isSameDay(at, day)) out.add((t, at));
  }
  return out..sort((a, b) => a.$2.compareTo(b.$2));
}

class _DayTimeline extends ConsumerWidget {
  const _DayTimeline({required this.day, required this.data, required this.fmt});
  final DateTime day;
  final AppData data;
  final Fmt fmt;

  Future<void> _move(BuildContext context, WidgetRef ref, Task t, int hour) async {
    final l = AppLocalizations.of(context);
    final c = ref.read(dataProvider.notifier);
    final start = DateTime(day.year, day.month, day.day, hour);
    final end = start.add(Duration(minutes: t.estimatedMinutes ?? 30));
    final clash = clashesFor(ref.read(dataProvider), start, end, DateTime.now(), exceptId: t.id);
    if (clash.isNotEmpty &&
        !await confirmDialog(context,
            title: l.conflict, message: l.conflictKeep(slotLabel(l, clash.first)), confirmLabel: l.keepAnyway, danger: false)) {
      return;
    }
    final before = ref.read(dataProvider).task(t.id)!;
    c.saveTask(before.copyWith(plannedStart: () => start));
    if (context.mounted) {
      showSnack(context, l.movedTo(fmt.time(start)), actionLabel: l.undo, onAction: () => c.restoreTasks([before]));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final events = eventsOn(data, day);
    final timed = timedTasksOn(data, day);
    final unscheduled = data.tasks
        .where((t) => t.isOpen && !t.archived && t.dueDate == dayKey(day) && t.plannedStart == null && t.dueTime == null)
        .toList();
    final s = data.settings;
    final firstHour = [s.dayStart ~/ 60, ...events.map((e) => isSameDay(e.start, day) ? e.start.hour : 0), ...timed.map((t) => t.$2.hour)]
        .reduce((a, b) => a < b ? a : b);
    final lastHour = [((s.dayEnd - 1) ~/ 60).clamp(0, 23), ...events.map((e) => isSameDay(e.end, day) ? e.end.hour : 23), ...timed.map((t) => t.$2.hour)]
        .reduce((a, b) => a > b ? a : b);
    final scheme = Theme.of(context).colorScheme;

    bool conflicted(CalendarEvent e) => events.any((o) => o.id != e.id && o.overlaps(e.start, e.end));

    return ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, 96), children: [
      if (unscheduled.isNotEmpty) ...[
        SectionHeader(l.unscheduled),
        Text(l.dragHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: Space.s),
        Wrap(spacing: Space.s, runSpacing: Space.s, children: [
          for (final t in unscheduled)
            LongPressDraggable<Task>(
              data: t,
              feedback: Material(color: Colors.transparent, child: Chip(label: Text(t.title))),
              child: ActionChip(
                avatar: const Icon(Icons.drag_indicator, size: 16),
                label: Text(t.title),
                onPressed: () => context.push(Routes.task(t.id)),
              ),
            ),
        ]),
        const SizedBox(height: Space.l),
      ],
      for (var h = firstHour; h <= lastHour; h++)
        DragTarget<Task>(
          onAcceptWithDetails: (det) => _move(context, ref, det.data, h),
          builder: (context, cand, _) {
            final hourEvents = events.where((e) => (isSameDay(e.start, day) ? e.start.hour : firstHour) == h).toList();
            final hourTasks = timed.where((t) => t.$2.hour == h).toList();
            return Container(
              constraints: const BoxConstraints(minHeight: 52),
              decoration: BoxDecoration(
                color: cand.isNotEmpty ? context.status.highlight : null,
                border: Border(top: BorderSide(color: scheme.outlineVariant)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: 64,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(fmt.minutesOfDay(h * 60), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.status.textSecondary)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      for (final e in hourEvents)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: EventCard(event: e, fmt: fmt, conflict: conflicted(e), onTap: () => context.push(Routes.event(e.id))),
                        ),
                      for (final (t, at) in hourTasks)
                        LongPressDraggable<Task>(
                          data: t,
                          feedback: Material(color: Colors.transparent, child: Chip(label: Text(t.title))),
                          child: _TaskSlot(task: t, at: at, fmt: fmt),
                        ),
                    ]),
                  ),
                ),
              ]),
            );
          },
        ),
    ]);
  }
}

class _TaskSlot extends ConsumerWidget {
  const _TaskSlot({required this.task, required this.at, required this.fmt});
  final Task task;
  final DateTime at;
  final Fmt fmt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: Space.s, vertical: 2),
        onTap: () => context.push(Routes.task(task.id)),
        child: Row(children: [
          Checkbox(value: task.isDone, onChanged: (_) => ref.read(dataProvider.notifier).toggleTaskDone(task.id)),
          const Icon(Icons.check_box_outlined, size: 16),
          const SizedBox(width: Space.xs),
          Expanded(
            child: Text(task.title,
                style: TextStyle(decoration: task.isDone ? TextDecoration.lineThrough : null), overflow: TextOverflow.ellipsis),
          ),
          Text(
            '${task.plannedStart != null ? l.plannedShort : l.dueShort} ${fmt.time(at)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ]),
      ),
    );
  }
}

class _WeekList extends StatelessWidget {
  const _WeekList({required this.start, required this.data, required this.fmt, required this.onDay});
  final DateTime start;
  final AppData data;
  final Fmt fmt;
  final ValueChanged<DateTime> onDay;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, 96), children: [
      for (var i = 0; i < 7; i++)
        Builder(builder: (context) {
          final day = start.add(Duration(days: i));
          final ev = eventsOn(data, day);
          final tasks = timedTasksOn(data, day);
          final today = isSameDay(day, DateTime.now());
          return Padding(
            padding: const EdgeInsets.only(bottom: Space.s),
            child: AppCard(
              onTap: () => onDay(day),
              color: today ? context.status.highlight : null,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(fmt.weekdayDate(day), style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: Space.xs),
                if (ev.isEmpty && tasks.isEmpty)
                  Text(l.nothingScheduled, style: Theme.of(context).textTheme.bodySmall)
                else ...[
                  for (final e in ev.take(4))
                    Row(children: [
                      const Icon(Icons.event, size: 14),
                      const SizedBox(width: 6),
                      Expanded(child: Text('${fmt.time(e.start)}  ${e.title}', overflow: TextOverflow.ellipsis)),
                    ]),
                  for (final (t, at) in tasks.take(4))
                    Row(children: [
                      Icon(t.isDone ? Icons.check_box : Icons.check_box_outline_blank, size: 14),
                      const SizedBox(width: 6),
                      Expanded(child: Text('${fmt.time(at)}  ${t.title}', overflow: TextOverflow.ellipsis)),
                    ]),
                ],
              ]),
            ),
          );
        }),
    ]);
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month, required this.data, required this.weekStart, required this.onDay});
  final DateTime month;
  final AppData data;
  final int weekStart;
  final ValueChanged<DateTime> onDay;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final gridStart = startOfWeek(first, weekStart);
    final fmt = Fmt.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, 96), children: [
      Row(children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Center(
              child: Text(fmt.weekdayShort(gridStart.add(Duration(days: i))), style: Theme.of(context).textTheme.labelSmall),
            ),
          ),
      ]),
      const SizedBox(height: Space.s),
      for (var w = 0; w < 6; w++)
        Row(children: [
          for (var i = 0; i < 7; i++)
            Builder(builder: (context) {
              final day = gridStart.add(Duration(days: w * 7 + i));
              final inMonth = day.month == month.month;
              final count = eventsOn(data, day).length + timedTasksOn(data, day).length +
                  data.tasks.where((t) => t.isOpen && t.dueDate == dayKey(day) && t.dueTime == null && t.plannedStart == null).length;
              final today = isSameDay(day, DateTime.now());
              return Expanded(
                child: Semantics(
                  button: true,
                  label: '${fmt.date(day)}, $count',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Radii.button),
                    onTap: () => onDay(day),
                    child: Container(
                      height: 52,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: today ? context.status.highlight : null,
                        borderRadius: BorderRadius.circular(Radii.button),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('${day.day}',
                            style: TextStyle(
                              color: inMonth ? null : scheme.onSurfaceVariant.withValues(alpha: 0.5),
                              fontWeight: today ? FontWeight.w700 : null,
                            )),
                        if (count > 0)
                          Text('•' * (count > 3 ? 3 : count), style: TextStyle(color: scheme.secondary, height: 1)),
                      ]),
                    ),
                  ),
                ),
              );
            }),
        ]),
    ]);
  }
}
