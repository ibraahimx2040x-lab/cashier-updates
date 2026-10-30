import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/task.dart';
import '../../domain/day_schedule.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/home_logo.dart';
import '../../widgets/device_notifications_card.dart';
import 'day_overview.dart';

/// Screen 7 — create or edit a task.
class TaskEditScreen extends ConsumerStatefulWidget {
  const TaskEditScreen({super.key, this.taskId, this.goalId, this.dueDate});
  final String? taskId;
  final String? goalId;
  final String? dueDate;

  @override
  ConsumerState<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends ConsumerState<TaskEditScreen> {
  final _form = GlobalKey<FormState>();
  late final Task? _orig = ref.read(dataProvider).task(widget.taskId);
  late final _title = TextEditingController(text: _orig?.title ?? '');
  late final _desc = TextEditingController(text: _orig?.description ?? '');
  late final _minutes = TextEditingController(text: _orig?.estimatedMinutes?.toString() ?? '');
  late DateTime? _due = _orig?.dueDate != null
      ? parseDayKey(_orig!.dueDate!)
      : (widget.dueDate != null ? parseDayKey(widget.dueDate!) : null);
  late int? _dueTime = _orig?.dueTime;
  late DateTime? _plannedDay = _orig?.plannedStart;
  late int? _plannedTime = _orig?.plannedStart == null ? null : _orig!.plannedStart!.hour * 60 + _orig.plannedStart!.minute;
  late Priority _priority = _orig?.priority ?? Priority.medium;
  late TaskStatus _status = _orig?.status ?? TaskStatus.todo;
  late String? _goalId = _orig?.goalId ?? widget.goalId;
  late String? _milestoneId = _orig?.milestoneId;
  late int? _reminderBefore = _initialReminder();
  bool _isDirty = false;
  bool get _dirty => _isDirty;
  set _dirty(bool v) {
    _isDirty = v;
    UnsavedGuard.mark(this, v);
  }
  bool _saving = false;

  int? _initialReminder() {
    final o = _orig;
    if (o?.reminderAt == null) return null;
    final ref = o!.plannedStart ?? o.dueAt;
    if (ref == null) return 0;
    return ref.difference(o.reminderAt!).inMinutes;
  }

  @override
  void dispose() {
    UnsavedGuard.mark(this, false);
    _title.dispose();
    _desc.dispose();
    _minutes.dispose();
    super.dispose();
  }

  void _touch() => _dirty = true;

  DateTime? get _plannedStart =>
      _plannedDay == null || _plannedTime == null ? null : atMinutes(_plannedDay!, _plannedTime!);

  DateTime? get _anchor => _plannedStart ?? (_due == null ? null : atMinutes(_due!, _dueTime ?? 9 * 60));

  List<DaySlot> get _clashes => _plannedStart == null
      ? const []
      : clashesFor(ref.read(dataProvider), _plannedStart!, _plannedStart!.add(Duration(minutes: int.tryParse(_minutes.text) ?? 30)),
          DateTime.now(), exceptId: _orig?.id);

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) return;
    if (_reminderBefore != null && _anchor == null) {
      showSnack(context, l.reminderNeedsTime);
      return;
    }
    final clash = _clashes.firstOrNull;
    if (clash != null &&
        !await confirmDialog(context, title: l.conflict, message: l.clashSave(slotLabel(l, clash)), confirmLabel: l.saveAnyway, danger: false)) {
      return;
    }
    if (!mounted) return;
    setState(() => _saving = true);
    final data = ref.read(dataProvider.notifier);
    final minutes = int.tryParse(_minutes.text.trim());
    final base = _orig ?? data.newTask(title: _title.text.trim());
    final reminderAt = _reminderBefore == null ? null : _anchor!.subtract(Duration(minutes: _reminderBefore!));
    try {
      data.saveTask(base.copyWith(
        title: _title.text.trim(),
        description: _desc.text.trim(),
        dueDate: () => _due == null ? null : dayKey(_due!),
        dueTime: () => _due == null ? null : _dueTime,
        estimatedMinutes: () => minutes,
        priority: _priority,
        goalId: () => _goalId,
        milestoneId: () => _goalId == null ? null : _milestoneId,
        plannedStart: () => _plannedStart,
        reminderAt: () => reminderAt,
      ));
      if (_orig != null && _status != _orig.status) data.setTaskStatus(base.id, _status);
      _dirty = false;
      showSnack(context, l.saved);
      if (reminderAt != null) askForNotificationsIfUnknown(context);
      context.pop();
    } on ArgumentError {
      showSnack(context, l.errSave);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final milestones = _goalId == null ? const [] : d.milestonesOf(_goalId!);
    final plannedConflicts = _clashes;

    Widget group(String title, List<Widget> children) => Padding(
          padding: const EdgeInsets.only(bottom: Space.xl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: context.status.textSecondary)),
            const SizedBox(height: Space.m),
            ...children.expand((w) => [w, const SizedBox(height: Space.l)]).toList()..removeLast(),
          ]),
        );

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
          title: Text(_orig == null ? l.newTask : l.editTask),
          actions: [
            if (_orig != null)
              IconButton(
                tooltip: l.delete,
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  if (await confirmDialog(context, title: l.deleteTaskTitle, message: l.deleteTaskBody(_orig.title), confirmLabel: l.delete)) {
                    ref.read(dataProvider.notifier).deleteTask(_orig.id);
                    if (context.mounted) context.pop();
                  }
                },
              ), const HomeLogoButton()],
        ),
        body: Form(
          key: _form,
          onChanged: _touch,
          child: ResponsiveContainer(
            maxWidth: 640,
            child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [
              group(l.details, [
                AppTextField(
                  label: l.taskTitleRequired,
                  controller: _title,
                  autofocus: _orig == null,
                  maxLength: 200,
                  validator: (v) => (v ?? '').trim().isEmpty ? l.errRequired : null,
                ),
                AppTextField(label: l.descriptionOptional, controller: _desc, maxLines: 4),
                Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(l.priorityLabel, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: Space.s),
                  SegmentedButton<Priority>(
                    segments: [for (final p in Priority.values) ButtonSegment(value: p, label: Text(l.priority(p)))],
                    selected: {_priority},
                    onSelectionChanged: (v) => setState(() {
                      _priority = v.first;
                      _touch();
                    }),
                  ),
                ]),
                if (_orig != null)
                  Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text(l.statusLabel, style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: Space.s),
                    DropdownButtonFormField<TaskStatus>(
                      isExpanded: true,
                      initialValue: _status,
                      items: [for (final s in TaskStatus.values) DropdownMenuItem(value: s, child: Text(l.taskStatus(s)))],
                      onChanged: (v) => setState(() => _status = v ?? _status),
                    ),
                  ]),
              ]),
              group(l.scheduleGroup, [
                Text(l.deadlineVsPlanned, style: Theme.of(context).textTheme.bodySmall),
                Row(children: [
                  Expanded(child: DatePickerField(label: l.deadlineDate, value: _due, fmt: fmt, onChanged: (v) => setState(() {
                    _due = v;
                    if (v == null) _dueTime = null;
                    _touch();
                  }))),
                  const SizedBox(width: Space.m),
                  Expanded(child: TimePickerField(label: l.deadlineTime, minutes: _dueTime, fmt: fmt, onChanged: (v) => setState(() {
                    _dueTime = v;
                    _due ??= DateTime.now();
                    _touch();
                  }))),
                ]),
                Row(children: [
                  Expanded(child: DatePickerField(label: l.plannedDate, value: _plannedDay, fmt: fmt, onChanged: (v) => setState(() {
                    _plannedDay = v;
                    if (v == null) _plannedTime = null;
                    _touch();
                  }))),
                  const SizedBox(width: Space.m),
                  Expanded(child: TimePickerField(label: l.plannedTime, minutes: _plannedTime, fmt: fmt, onChanged: (v) => setState(() {
                    _plannedTime = v;
                    _plannedDay ??= _due ?? DateTime.now();
                    _touch();
                  }))),
                ]),
                if (plannedConflicts.isNotEmpty)
                  Pill(label: l.conflictWith(slotLabel(l, plannedConflicts.first)), color: context.status.warning, icon: Icons.warning_amber),
                AppTextField(
                  label: l.estimatedMinutes,
                  controller: _minutes,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return null;
                    final n = int.tryParse(v!.trim());
                    return n == null || n <= 0 || n > 1440 ? l.errPositiveMinutes : null;
                  },
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(l.reminder, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: Space.s),
                  DropdownButtonFormField<int?>(
                    isExpanded: true,
                    initialValue: _reminderBefore,
                    items: [
                      DropdownMenuItem(value: null, child: Text(l.noReminder)),
                      DropdownMenuItem(value: 0, child: Text(l.atTime)),
                      for (final m in const [10, 30, 60, 1440]) DropdownMenuItem(value: m, child: Text(l.beforeMinutes(l.durationShort(m)))),
                    ],
                    onChanged: (v) => setState(() {
                      _reminderBefore = v;
                      _touch();
                    }),
                  ),
                ]),
              ]),
              group(l.organizeGroup, [
                Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(l.linkedGoalOptional, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: Space.s),
                  DropdownButtonFormField<String?>(
                    isExpanded: true,
                    initialValue: d.goal(_goalId) == null ? null : _goalId,
                    items: [
                      DropdownMenuItem(value: null, child: Text(l.none)),
                      for (final g in d.goals) DropdownMenuItem(value: g.id, child: Text(g.title, overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) => setState(() {
                      _goalId = v;
                      _milestoneId = null;
                      _touch();
                    }),
                  ),
                ]),
                if (milestones.isNotEmpty)
                  Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text(l.linkedMilestoneOptional, style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: Space.s),
                    DropdownButtonFormField<String?>(
                      isExpanded: true,
                      key: ValueKey(_goalId),
                      initialValue: milestones.any((m) => m.id == _milestoneId) ? _milestoneId : null,
                      items: [
                        DropdownMenuItem(value: null, child: Text(l.none)),
                        for (final m in milestones) DropdownMenuItem(value: m.id, child: Text(m.title, overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) => setState(() {
                        _milestoneId = v;
                        _touch();
                      }),
                    ),
                  ]),
              ]),
            ]),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Space.l),
            child: ResponsiveContainer(maxWidth: 640, child: PrimaryButton(label: l.saveTask, loading: _saving, onPressed: _save)),
          ),
        ),
      ),
    );
  }
}
