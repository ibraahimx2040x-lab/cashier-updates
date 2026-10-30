import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/task.dart';
import '../../domain/day_schedule.dart';
import '../../domain/planner.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import 'day_overview.dart';

/// Screen 9 — decide what to do and when. The plan is a suggestion: the
/// user reorders, drops or defers items, reviews, then applies it.
class PlannerView extends ConsumerStatefulWidget {
  const PlannerView({super.key});

  @override
  ConsumerState<PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends ConsumerState<PlannerView> {
  late DateTime _day = dateOnly(ref.read(clockProvider)());
  List<String>? _order;
  final Set<String> _excluded = {};

  void _setDay(DateTime d) => setState(() {
        _day = dateOnly(d);
        _order = null;
        _excluded.clear();
      });

  Future<void> _apply(DayPlan plan) async {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context, use24h: ref.read(settingsProvider).use24h);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.reviewChanges),
        content: SizedBox(
          width: 420,
          child: ListView(shrinkWrap: true, children: [
            Text(l.applyPlanBody(plan.planned.length)),
            const SizedBox(height: Space.m),
            for (final p in plan.planned)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule, size: 18),
                title: Text(p.task.title),
                subtitle: Text(p.task.plannedStart == null
                    ? fmt.time(p.start)
                    : '${fmt.dateTime(p.task.plannedStart!)} → ${fmt.time(p.start)}'),
              ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.applyPlan)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final c = ref.read(dataProvider.notifier);
    final before = [for (final p in plan.planned) ref.read(dataProvider).task(p.task.id)!];
    c.transaction(() {
      for (final p in plan.planned) {
        c.saveTask(ref.read(dataProvider).task(p.task.id)!.copyWith(plannedStart: () => p.start));
      }
    });
    showSnack(context, l.planApplied, actionLabel: l.undo, onAction: () => c.restoreTasks(before));
  }

  void _defer(Task t) {
    final l = AppLocalizations.of(context);
    final c = ref.read(dataProvider.notifier);
    final before = t;
    c.saveTask(t.copyWith(
      dueDate: () => dayKey(_day.add(const Duration(days: 1))),
      plannedStart: () => null,
    ));
    showSnack(context, l.movedTomorrow, actionLabel: l.undo, onAction: () => c.restoreTasks([before]));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final now = ref.watch(clockProvider)();
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final plan = const Planner().plan(
      day: _day,
      now: now,
      tasks: d.tasks,
      events: d.events,
      settings: d.settings,
      manualOrder: _order,
      exclude: _excluded,
    );
    final t = Theme.of(context).textTheme;
    final isPast = _day.isBefore(dateOnly(now));

    String reason(UnscheduledReason r) => switch (r) {
          UnscheduledReason.noTime => l.reasonNoTime,
          UnscheduledReason.noSlotLongEnough => l.reasonNoSlot,
          UnscheduledReason.afterDeadline => l.reasonDeadline,
        };

    return ResponsiveContainer(
      child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.m, Space.gutter, 96), children: [
        Wrap(spacing: Space.s, runSpacing: Space.s, crossAxisAlignment: WrapCrossAlignment.center, children: [
          ChoiceChip(label: Text(l.today), selected: isSameDay(_day, now), onSelected: (_) => _setDay(now)),
          ChoiceChip(
            label: Text(l.tomorrow),
            selected: isSameDay(_day, now.add(const Duration(days: 1))),
            onSelected: (_) => _setDay(now.add(const Duration(days: 1))),
          ),
          ActionChip(
            avatar: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(fmt.weekdayDate(_day)),
            onPressed: () async {
              final r = await showDatePicker(context: context, initialDate: _day, firstDate: dateOnly(now), lastDate: now.add(const Duration(days: 365)));
              if (r != null) _setDay(r);
            },
          ),
        ]),
        const SizedBox(height: Space.l),
        // Capacity summary
        AppCard(
          child: Row(children: [
            _Stat(label: l.freeTime, value: l.durationShort(plan.freeMinutes)),
            _Stat(label: l.neededTime, value: l.durationShort(plan.neededMinutes)),
            _Stat(label: l.fixedBlocks, value: '${plan.fixed.length}'),
          ]),
        ),
        const SizedBox(height: Space.m),
        DayOverviewCard(schedule: DaySchedule.build(d, _day, now), fmt: fmt),
        if (plan.overCapacity) ...[
          const SizedBox(height: Space.m),
          _Banner(icon: Icons.warning_amber, color: context.status.warning, text: l.overCapacity),
        ],
        const SizedBox(height: Space.m),
        _Banner(icon: Icons.info_outline, color: context.status.info, text: l.planIsEstimate),
        const SizedBox(height: Space.xl),
        if (plan.fixed.isNotEmpty) ...[
          SectionHeader(l.fixedCommitments),
          for (final b in plan.fixed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(switch (b.kind) {
                BlockKind.event => Icons.event,
                BlockKind.prayer => Icons.mosque_outlined,
                BlockKind.work => Icons.work_outline,
                BlockKind.rest => Icons.free_breakfast_outlined,
                BlockKind.free => Icons.circle_outlined,
              }),
              title: Text(b.label ?? blockLabel(l, b)),
              subtitle: Text('${fmt.time(b.start)} – ${fmt.time(b.end)}'),
            ),
          const SizedBox(height: Space.l),
        ],
        SectionHeader(l.suggestedPlan, action: l.planWithAssistant, onAction: () => context.go('${Routes.assistant}?q=${Uri.encodeComponent(l.aiChipPlanDay)}')),
        if (isPast)
          AppCard(child: Text(l.pastDay))
        else if (plan.planned.isEmpty)
          EmptyState(icon: Icons.view_timeline_outlined, title: l.nothingToPlan, action: l.addTask, onAction: () => context.push('${Routes.task('new')}?date=${dayKey(_day)}'))
        else ...[
          Text(l.reorderHint, style: t.bodySmall),
          const SizedBox(height: Space.s),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorderItem: (a, b) => setState(() {
              final ids = plan.planned.map((p) => p.task.id).toList();
              ids.insert(b, ids.removeAt(a));
              _order = ids;
            }),
            children: [
              for (var i = 0; i < plan.planned.length; i++)
                Padding(
                  key: ValueKey(plan.planned[i].task.id),
                  padding: const EdgeInsets.only(bottom: Space.s),
                  child: _PlanRow(
                    index: i,
                    item: plan.planned[i],
                    fmt: fmt,
                    onRemove: () => setState(() => _excluded.add(plan.planned[i].task.id)),
                    onDefer: () => _defer(plan.planned[i].task),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.m),
          PrimaryButton(label: l.applyPlan, icon: Icons.check, onPressed: () => _apply(plan)),
        ],
        if (plan.unscheduled.isNotEmpty || _excluded.isNotEmpty) ...[
          const SizedBox(height: Space.xl),
          SectionHeader(l.couldNotFit),
          for (final u in plan.unscheduled)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s),
              child: AppCard(
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(u.task.title, style: t.titleSmall),
                      Text(reason(u.reason), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                    ]),
                  ),
                  TextButton(onPressed: () => _defer(u.task), child: Text(l.moveTomorrow)),
                ]),
              ),
            ),
          for (final id in _excluded)
            if (d.task(id) != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.remove_circle_outline),
                title: Text(d.task(id)!.title),
                subtitle: Text(l.removedFromPlan),
                trailing: TextButton(onPressed: () => setState(() => _excluded.remove(id)), child: Text(l.restore)),
              ),
        ],
      ]),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.index, required this.item, required this.fmt, required this.onRemove, required this.onDefer});
  final int index;
  final PlannedTask item;
  final Fmt fmt;
  final VoidCallback onRemove;
  final VoidCallback onDefer;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: Space.s, vertical: Space.s),
      child: Row(children: [
        ReorderableDragStartListener(
          index: index,
          child: Padding(
            padding: const EdgeInsets.all(Space.s),
            child: Icon(Icons.drag_indicator, semanticLabel: l.reorder),
          ),
        ),
        SizedBox(
          width: 72,
          child: Text('${fmt.time(item.start)}\n${fmt.time(item.end)}', style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.task.title, style: Theme.of(context).textTheme.titleSmall),
            Wrap(spacing: Space.s, children: [
              PriorityBadge(item.task.priority),
              if (item.estimated) Pill(label: l.estimatedDuration, color: context.status.info, icon: Icons.help_outline),
            ]),
          ]),
        ),
        PopupMenuButton<String>(
          tooltip: l.moreOptions,
          onSelected: (v) => v == 'remove' ? onRemove() : onDefer(),
          itemBuilder: (_) => [
            PopupMenuItem(value: 'remove', child: Text(l.removeFromPlan)),
            PopupMenuItem(value: 'defer', child: Text(l.moveTomorrow)),
          ],
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.status.textSecondary), textAlign: TextAlign.center),
        ]),
      );
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(Space.m),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(Radii.button)),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: Space.s),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
        ]),
      );
}
