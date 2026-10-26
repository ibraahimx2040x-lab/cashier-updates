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
import '../../data/models/goal.dart';
import '../../domain/metrics.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

/// Screen 11 — create/edit a goal, its milestones and linked tasks.
class GoalEditScreen extends ConsumerStatefulWidget {
  const GoalEditScreen({super.key, this.goalId});
  final String? goalId;

  @override
  ConsumerState<GoalEditScreen> createState() => _GoalEditScreenState();
}

class _GoalEditScreenState extends ConsumerState<GoalEditScreen> {
  final _form = GlobalKey<FormState>();
  late final Goal? _orig = ref.read(dataProvider).goal(widget.goalId);
  late final _title = TextEditingController(text: _orig?.title ?? '');
  late final _desc = TextEditingController(text: _orig?.description ?? '');
  late final _why = TextEditingController(text: _orig?.why ?? '');
  late GoalCategory _cat = _orig?.category ?? GoalCategory.personal;
  late DateTime? _start = _orig?.startDate == null ? DateTime.now() : parseDayKey(_orig!.startDate!);
  late DateTime? _target = _orig?.targetDate == null ? null : parseDayKey(_orig!.targetDate!);
  late ProgressMode _mode = _orig?.progressMode ?? ProgressMode.milestones;
  late double _manual = (_orig?.manualProgress ?? 0).toDouble();
  late List<Milestone> _milestones = _orig == null ? [] : ref.read(dataProvider).milestonesOf(_orig.id);
  late final String _id = _orig?.id ?? newId();
  bool _dirty = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _why.dispose();
    super.dispose();
  }

  Goal _build() {
    final now = DateTime.now();
    return Goal(
      id: _id,
      title: _title.text.trim(),
      description: _desc.text.trim(),
      why: _why.text.trim(),
      category: _cat,
      startDate: _start == null ? null : dayKey(_start!),
      targetDate: _target == null ? null : dayKey(_target!),
      progressMode: _mode,
      manualProgress: _manual.round(),
      status: _orig?.status ?? GoalStatus.active,
      createdAt: _orig?.createdAt ?? now,
      updatedAt: now,
    );
  }

  void _save({bool pop = true}) {
    final l = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) return;
    if (_start != null && _target != null && _target!.isBefore(_start!)) {
      showSnack(context, l.errTargetBeforeStart);
      return;
    }
    ref.read(dataProvider.notifier).saveGoal(_build(), _milestones);
    _dirty = false;
    if (pop) {
      showSnack(context, l.saved);
      context.pop();
    }
  }

  Future<void> _addMilestone({Milestone? existing}) async {
    final l = AppLocalizations.of(context);
    final c = TextEditingController(text: existing?.title ?? '');
    final r = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? l.addMilestone : l.editMilestone),
        content: TextField(controller: c, autofocus: true, decoration: InputDecoration(hintText: l.milestoneHint)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: Text(l.save)),
        ],
      ),
    );
    c.dispose();
    if (r == null || r.isEmpty) return;
    setState(() {
      _dirty = true;
      if (existing == null) {
        _milestones = [..._milestones, Milestone(id: newId(), goalId: _id, title: r, order: _milestones.length)];
      } else {
        _milestones = _milestones.map((m) => m.id == existing.id ? m.copyWith(title: r) : m).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final saved = d.goal(_id);
    final linked = d.tasksOfGoal(_id);
    final progress = GoalProgress.of(_build(), _milestones);
    final t = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!_dirty || await confirmDiscard(context)) {
          if (context.mounted) context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_orig == null ? l.newGoal : l.editGoal),
          actions: [
            if (saved != null)
              PopupMenuButton<String>(
                tooltip: l.moreOptions,
                onSelected: (v) async {
                  final c = ref.read(dataProvider.notifier);
                  switch (v) {
                    case 'pause':
                      c.setGoalStatus(_id, GoalStatus.paused);
                    case 'resume':
                      c.setGoalStatus(_id, GoalStatus.active);
                    case 'complete':
                      c.setGoalStatus(_id, GoalStatus.completed);
                    case 'archive':
                      c.setGoalStatus(_id, GoalStatus.archived);
                    case 'delete':
                      if (await confirmDialog(context, title: l.deleteGoalTitle, message: l.deleteGoalBody, confirmLabel: l.delete)) {
                        c.deleteGoal(_id);
                        if (context.mounted) context.pop();
                      }
                  }
                },
                itemBuilder: (_) => [
                  if (saved.status == GoalStatus.active) PopupMenuItem(value: 'pause', child: Text(l.pauseGoal)),
                  if (saved.status != GoalStatus.active) PopupMenuItem(value: 'resume', child: Text(l.resumeGoal)),
                  if (saved.status != GoalStatus.completed) PopupMenuItem(value: 'complete', child: Text(l.markGoalComplete)),
                  if (saved.status != GoalStatus.archived) PopupMenuItem(value: 'archive', child: Text(l.archiveGoal)),
                  PopupMenuItem(value: 'delete', child: Text(l.delete)),
                ],
              ),
          ],
        ),
        body: Form(
          key: _form,
          onChanged: () => _dirty = true,
          child: ResponsiveContainer(
            maxWidth: 720,
            child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [
              if (saved != null) ...[
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Expanded(child: Text(l.progress, style: t.titleSmall)), StatusBadge(saved.status)]),
                    const SizedBox(height: Space.m),
                    AppProgress(percent: progress.percent, label: saved.title),
                    if (progress.mode == ProgressMode.milestones && progress.total > 0 && progress.done == progress.total && saved.status == GoalStatus.active) ...[
                      const SizedBox(height: Space.m),
                      Text(l.allMilestonesDone),
                      const SizedBox(height: Space.s),
                      SecondaryButton(
                        label: l.markGoalComplete,
                        icon: Icons.check,
                        onPressed: () => ref.read(dataProvider.notifier).setGoalStatus(_id, GoalStatus.completed),
                      ),
                    ],
                  ]),
                ),
                const SizedBox(height: Space.xl),
              ],
              AppTextField(
                label: l.goalTitle,
                controller: _title,
                autofocus: _orig == null,
                hint: l.goalTitleHint,
                validator: (v) => (v ?? '').trim().isEmpty ? l.errRequired : null,
              ),
              const SizedBox(height: Space.l),
              AppTextField(label: l.descriptionOptional, controller: _desc, maxLines: 3),
              const SizedBox(height: Space.l),
              Text(l.category, style: t.labelMedium),
              const SizedBox(height: Space.s),
              Wrap(spacing: Space.s, runSpacing: Space.s, children: [
                for (final c in GoalCategory.values)
                  ChoiceChip(label: Text(l.goalCategory(c)), selected: _cat == c, onSelected: (_) => setState(() {
                    _cat = c;
                    _dirty = true;
                  })),
              ]),
              const SizedBox(height: Space.l),
              Row(children: [
                Expanded(child: DatePickerField(label: l.startDate, value: _start, fmt: fmt, onChanged: (v) => setState(() {
                  _start = v;
                  _dirty = true;
                }))),
                const SizedBox(width: Space.m),
                Expanded(child: DatePickerField(label: l.targetDate, value: _target, fmt: fmt, onChanged: (v) => setState(() {
                  _target = v;
                  _dirty = true;
                }))),
              ]),
              const SizedBox(height: Space.l),
              AppTextField(label: l.whyOptional, controller: _why, maxLines: 2),
              const SizedBox(height: Space.xl),
              Text(l.progressMethod, style: t.titleSmall),
              const SizedBox(height: Space.s),
              SegmentedButton<ProgressMode>(
                segments: [
                  ButtonSegment(value: ProgressMode.milestones, label: Text(l.byMilestones)),
                  ButtonSegment(value: ProgressMode.manual, label: Text(l.manual)),
                ],
                selected: {_mode},
                onSelectionChanged: (v) => setState(() {
                  _mode = v.first;
                  _dirty = true;
                }),
              ),
              const SizedBox(height: Space.s),
              Text(_mode == ProgressMode.milestones ? l.byMilestonesHint : l.manualHint, style: t.bodySmall),
              if (_mode == ProgressMode.manual)
                Slider(
                  value: _manual,
                  max: 100,
                  divisions: 20,
                  label: '${_manual.round()}%',
                  onChanged: (v) => setState(() {
                    _manual = v;
                    _dirty = true;
                  }),
                ),
              const SizedBox(height: Space.xl),
              SectionHeader(l.milestones, action: l.addMilestone, onAction: _addMilestone),
              if (_milestones.isEmpty)
                Text(l.noMilestones, style: t.bodySmall)
              else
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  onReorderItem: (a, b) => setState(() {
                    final list = [..._milestones];
                    list.insert(b, list.removeAt(a));
                    _milestones = list;
                    _dirty = true;
                  }),
                  children: [
                    for (var i = 0; i < _milestones.length; i++)
                      ListTile(
                        key: ValueKey(_milestones[i].id),
                        contentPadding: EdgeInsets.zero,
                        leading: Checkbox(
                          value: _milestones[i].done,
                          onChanged: (v) => setState(() {
                            _milestones = _milestones.map((m) => m.id == _milestones[i].id ? m.copyWith(done: v ?? false) : m).toList();
                            _dirty = true;
                          }),
                        ),
                        title: Text(_milestones[i].title,
                            style: TextStyle(decoration: _milestones[i].done ? TextDecoration.lineThrough : null)),
                        subtitle: Builder(builder: (_) {
                          final n = linked.where((x) => x.milestoneId == _milestones[i].id).toList();
                          return n.isEmpty ? const SizedBox.shrink() : Text(l.tasksDoneOf(n.where((x) => x.isDone).length, n.length));
                        }),
                        onTap: () => _addMilestone(existing: _milestones[i]),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                            tooltip: l.delete,
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              _milestones = [..._milestones]..removeAt(i);
                              _dirty = true;
                            }),
                          ),
                          ReorderableDragStartListener(index: i, child: Icon(Icons.drag_handle, semanticLabel: l.reorder)),
                        ]),
                      ),
                  ],
                ),
              const SizedBox(height: Space.xl),
              SectionHeader(
                l.linkedTasks,
                action: l.linkTask,
                onAction: () {
                  // The goal must exist before a task can reference it.
                  if (_title.text.trim().isEmpty) {
                    _form.currentState!.validate();
                    return;
                  }
                  _save(pop: false);
                  context.push('${Routes.task('new')}?goal=$_id');
                },
              ),
              if (linked.isEmpty)
                Text(l.noLinkedTasks, style: t.bodySmall)
              else
                for (final task in linked)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(task.isDone ? Icons.check_box : Icons.check_box_outline_blank,
                        color: task.isDone ? context.status.success : null),
                    title: Text(task.title),
                    subtitle: task.milestoneId == null
                        ? null
                        : Text(_milestones.where((m) => m.id == task.milestoneId).firstOrNull?.title ?? ''),
                    onTap: () => context.push(Routes.task(task.id)),
                  ),
              const SizedBox(height: Space.xl),
            ]),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Space.l),
            child: ResponsiveContainer(maxWidth: 720, child: PrimaryButton(label: l.saveGoal, onPressed: _save)),
          ),
        ),
      ),
    );
  }
}
