import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/dates.dart';
import '../core/utils/format.dart';
import '../core/utils/labels.dart';
import '../data/models/goal.dart';
import '../data/models/misc.dart';
import '../data/models/task.dart';
import '../domain/metrics.dart';
import '../l10n/app_localizations.dart';
import 'common.dart';

class PriorityBadge extends StatelessWidget {
  const PriorityBadge(this.priority, {super.key});
  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final s = context.status;
    final (color, icon) = switch (priority) {
      Priority.high => (Theme.of(context).colorScheme.error, Icons.keyboard_double_arrow_up),
      Priority.medium => (s.warning, Icons.drag_handle),
      Priority.low => (s.inactive, Icons.keyboard_arrow_down),
    };
    return Pill(label: AppLocalizations.of(context).priority(priority), color: color, icon: icon);
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final s = context.status;
    final (color, icon) = switch (status) {
      GoalStatus.active => (s.success, Icons.play_circle_outline),
      GoalStatus.paused => (s.warning, Icons.pause_circle_outline),
      GoalStatus.completed => (s.info, Icons.check_circle_outline),
      GoalStatus.archived => (s.inactive, Icons.inventory_2_outlined),
    };
    return Pill(label: AppLocalizations.of(context).goalStatus(status), color: color, icon: icon);
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.fmt,
    required this.now,
    required this.onToggle,
    required this.onOpen,
    this.goalTitle,
    this.onArchive,
    this.onDelete,
    this.compact = false,
  });

  final Task task;
  final Fmt fmt;
  final DateTime now;
  final VoidCallback onToggle;
  final VoidCallback onOpen;
  final String? goalTitle;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final overdue = task.isOverdue(now);
    final meta = <Widget>[];
    if (task.plannedStart != null && !task.isDone) {
      meta.add(_Meta(Icons.schedule, fmt.dateTime(task.plannedStart!)));
    } else if (task.dueDate != null) {
      final due = parseDayKey(task.dueDate!);
      final label = task.dueTime == null ? fmt.dateShort(due) : fmt.dateTime(task.dueAt!);
      meta.add(_Meta(Icons.event, '${l.due} $label', color: overdue ? Theme.of(context).colorScheme.error : null));
    }
    if (task.estimatedMinutes != null) meta.add(_Meta(Icons.timelapse, l.durationShort(task.estimatedMinutes!)));
    if (goalTitle != null) meta.add(_Meta(Icons.flag_outlined, goalTitle!));

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: Space.s, vertical: Space.s),
      onTap: onOpen,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: l.markDone(task.title),
            child: Checkbox(
              value: task.isDone,
              onChanged: task.status == TaskStatus.cancelled ? null : (_) => onToggle(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: t.titleSmall?.copyWith(
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                      color: task.isDone ? context.status.textSecondary : null,
                    ),
                  ),
                  if (meta.isNotEmpty || !compact) const SizedBox(height: Space.xs),
                  Wrap(spacing: Space.m, runSpacing: Space.xs, children: [
                    if (!compact || task.priority == Priority.high) PriorityBadge(task.priority),
                    if (overdue) Pill(label: l.overdue, color: Theme.of(context).colorScheme.error, icon: Icons.warning_amber),
                    if (task.status == TaskStatus.cancelled) Pill(label: l.statusCancelled, color: context.status.inactive),
                    ...meta,
                  ]),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: l.moreOptions,
            onSelected: (v) {
              if (v == 'open') onOpen();
              if (v == 'archive') onArchive?.call();
              if (v == 'delete') onDelete?.call();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'open', child: Text(l.edit)),
              if (onArchive != null) PopupMenuItem(value: 'archive', child: Text(task.archived ? l.unarchive : l.archive)),
              if (onDelete != null) PopupMenuItem(value: 'delete', child: Text(l.delete)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text, {this.color});
  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.status.textSecondary;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: c),
      const SizedBox(width: 4),
      Flexible(child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c))),
    ]);
  }
}

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal, required this.progress, required this.fmt, required this.onTap, this.compact = false});
  final Goal goal;
  final GoalProgress progress;
  final Fmt fmt;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return AppCard(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(goal.title, style: t.titleMedium)),
          if (!compact) StatusBadge(goal.status),
        ]),
        if (!compact && goal.description.isNotEmpty) ...[
          const SizedBox(height: Space.xs),
          Text(goal.description, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: t.bodyMedium?.copyWith(color: context.status.textSecondary)),
        ],
        const SizedBox(height: Space.m),
        AppProgress(percent: progress.percent, label: goal.title),
        const SizedBox(height: Space.s),
        Wrap(spacing: Space.m, children: [
          if (progress.mode == ProgressMode.milestones)
            _Meta(Icons.flag_outlined, l.milestonesDone(progress.done, progress.total))
          else
            _Meta(Icons.tune, l.progressManual),
          if (goal.targetDate != null) _Meta(Icons.event, l.targetOn(fmt.day(goal.targetDate!))),
          if (!compact) _Meta(Icons.label_outline, l.goalCategory(goal.category)),
        ]),
      ]),
    );
  }
}

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.doneToday,
    required this.dueToday,
    required this.onToggle,
    this.onOpen,
    this.subtitle,
  });
  final Habit habit;
  final bool doneToday;
  final bool dueToday;
  final VoidCallback onToggle;
  final VoidCallback? onOpen;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = context.status;
    return AppCard(
      onTap: onOpen,
      padding: const EdgeInsets.symmetric(horizontal: Space.l, vertical: Space.m),
      child: Row(children: [
        Icon(doneToday ? Icons.check_circle : Icons.radio_button_unchecked,
            color: doneToday ? s.success : s.inactive),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(habit.name, style: Theme.of(context).textTheme.titleSmall),
            Text(
              subtitle ?? (dueToday ? (doneToday ? l.habitDoneToday : l.habitDueToday) : l.habitNotDueToday),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: s.textSecondary),
            ),
          ]),
        ),
        if (dueToday)
          doneToday
              ? TextButton(onPressed: onToggle, child: Text(l.undo))
              : FilledButton.tonal(
                  onPressed: onToggle,
                  style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
                  child: Text(l.habitDone),
                ),
      ]),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.fmt, this.onTap, this.conflict = false});
  final CalendarEvent event;
  final Fmt fmt;
  final VoidCallback? onTap;
  final bool conflict;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      color: context.status.highlight,
      padding: const EdgeInsets.all(Space.m),
      child: Row(children: [
        Icon(Icons.event, color: scheme.primary),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(event.title, style: Theme.of(context).textTheme.titleSmall),
            Text(
              '${fmt.time(event.start)} – ${fmt.time(event.end)} · ${l.durationShort(event.duration.inMinutes)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (event.location.isNotEmpty)
              Text(event.location, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.status.textSecondary)),
          ]),
        ),
        if (conflict) Pill(label: l.conflict, color: context.status.warning, icon: Icons.warning_amber),
      ]),
    );
  }
}

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({super.key, required this.expense, required this.fmt, this.onDelete});
  final Expense expense;
  final Fmt fmt;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: Space.l, vertical: Space.s),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: context.status.highlight,
          child: Icon(_icon(expense.category), color: Theme.of(context).colorScheme.primary, size: 20),
        ),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(expense.description.isEmpty ? l.expenseCategory(expense.category) : expense.description,
                style: Theme.of(context).textTheme.titleSmall),
            Text('${l.expenseCategory(expense.category)} · ${fmt.dateShort(expense.spentAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.status.textSecondary)),
          ]),
        ),
        Text(fmt.money(expense.amountMinor, expense.currency), style: Theme.of(context).textTheme.titleSmall),
        if (onDelete != null)
          IconButton(tooltip: l.delete, icon: const Icon(Icons.delete_outline), onPressed: onDelete),
      ]),
    );
  }

  static IconData _icon(String c) => switch (c) {
        'food' => Icons.restaurant,
        'transport' => Icons.directions_car_outlined,
        'shopping' => Icons.shopping_bag_outlined,
        'education' => Icons.school_outlined,
        'bills' => Icons.receipt_long_outlined,
        'entertainment' => Icons.movie_outlined,
        _ => Icons.category_outlined,
      };
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.n, required this.fmt, required this.onTap, required this.onMarkRead});
  final AppNotification n;
  final Fmt fmt;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final icon = switch (n.type) {
      NotificationType.task => Icons.check_box_outlined,
      NotificationType.event => Icons.event,
      NotificationType.habit => Icons.repeat,
      NotificationType.plan => Icons.view_timeline_outlined,
      NotificationType.assistant => Icons.auto_awesome_outlined,
      NotificationType.billing => Icons.workspace_premium_outlined,
    };
    return AppCard(
      onTap: onTap,
      color: n.read ? null : context.status.highlight,
      padding: const EdgeInsets.all(Space.m),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(n.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: n.read ? FontWeight.w500 : FontWeight.w700)),
            if (n.body.isNotEmpty) Text(n.body, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 2),
            Text('${l.notificationType(n.type)} · ${fmt.dateTime(n.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.status.textSecondary)),
          ]),
        ),
        if (!n.read)
          IconButton(tooltip: l.markRead, icon: const Icon(Icons.done_all), onPressed: onMarkRead),
      ]),
    );
  }
}

/// Read-only field that opens a date picker.
class DatePickerField extends StatelessWidget {
  const DatePickerField({super.key, required this.label, required this.value, required this.onChanged, this.fmt, this.clearable = true, this.firstDate});
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final Fmt? fmt;
  final bool clearable;
  final DateTime? firstDate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = fmt ?? Fmt.of(context);
    return _PickerShell(
      label: label,
      icon: Icons.calendar_today_outlined,
      text: value == null ? l.notSet : f.date(value!),
      onClear: clearable && value != null ? () => onChanged(null) : null,
      onTap: () async {
        final now = DateTime.now();
        final r = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: firstDate ?? DateTime(now.year - 5),
          lastDate: DateTime(now.year + 10),
        );
        if (r != null) onChanged(r);
      },
    );
  }
}

class TimePickerField extends StatelessWidget {
  const TimePickerField({super.key, required this.label, required this.minutes, required this.onChanged, required this.fmt, this.clearable = true});
  final String label;
  final int? minutes;
  final ValueChanged<int?> onChanged;
  final Fmt fmt;
  final bool clearable;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _PickerShell(
      label: label,
      icon: Icons.access_time,
      text: minutes == null ? l.notSet : fmt.minutesOfDay(minutes!),
      onClear: clearable && minutes != null ? () => onChanged(null) : null,
      onTap: () async {
        final init = minutes == null ? TimeOfDay.now() : TimeOfDay(hour: minutes! ~/ 60, minute: minutes! % 60);
        final r = await showTimePicker(
          context: context,
          initialTime: init,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: fmt.use24h),
            child: child!,
          ),
        );
        if (r != null) onChanged(r.hour * 60 + r.minute);
      },
    );
  }
}

class _PickerShell extends StatelessWidget {
  const _PickerShell({required this.label, required this.icon, required this.text, required this.onTap, this.onClear});
  final String label;
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: Space.s),
      InkWell(
        borderRadius: BorderRadius.circular(Radii.button),
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: onClear == null
                ? null
                : IconButton(tooltip: l.clear, icon: const Icon(Icons.close, size: 18), onPressed: onClear),
          ),
          child: Text(text),
        ),
      ),
    ]);
  }
}
