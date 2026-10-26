import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/task.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

enum TaskFilter { all, today, upcoming, overdue, completed, archived }

/// Screen 6 — all tasks with filters, search, priority and goal filters.
class TasksView extends ConsumerStatefulWidget {
  const TasksView({super.key});

  @override
  ConsumerState<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends ConsumerState<TasksView> {
  TaskFilter _filter = TaskFilter.today;
  String _q = '';
  Priority? _priority;
  String? _goalId;

  bool _match(Task t, DateTime now) {
    final today = dayKey(now);
    final f = switch (_filter) {
      TaskFilter.all => !t.archived,
      TaskFilter.today => !t.archived &&
          t.isOpen &&
          (t.dueDate == today || (t.plannedStart != null && isSameDay(t.plannedStart!, now))),
      TaskFilter.upcoming => !t.archived && t.isOpen && t.dueDate != null && t.dueDate!.compareTo(today) > 0,
      TaskFilter.overdue => t.isOverdue(now),
      TaskFilter.completed => !t.archived && t.isDone,
      TaskFilter.archived => t.archived,
    };
    if (!f) return false;
    if (_priority != null && t.priority != _priority) return false;
    if (_goalId != null && t.goalId != _goalId) return false;
    if (_q.isNotEmpty) {
      final q = _q.toLowerCase();
      return t.title.toLowerCase().contains(q) || t.description.toLowerCase().contains(q);
    }
    return true;
  }

  (String, String?) _empty(AppLocalizations l, bool anyToday) => switch (_filter) {
        TaskFilter.today when anyToday => (l.emptyTodayDone, null),
        TaskFilter.today => (l.emptyToday, l.addTask),
        TaskFilter.upcoming => (l.emptyUpcoming, l.addTask),
        TaskFilter.overdue => (l.emptyOverdue, null),
        TaskFilter.completed => (l.emptyCompleted, null),
        TaskFilter.archived => (l.emptyArchived, null),
        TaskFilter.all => (l.emptyAll, l.addTask),
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final data = ref.read(dataProvider.notifier);
    final now = ref.watch(clockProvider)();
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final list = d.tasks.where((t) => _match(t, now)).toList()
      ..sort((a, b) {
        if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
        final da = a.plannedStart ?? a.dueAt, db = b.plannedStart ?? b.dueAt;
        if (da != null && db != null) return da.compareTo(db);
        if (da != null) return -1;
        if (db != null) return 1;
        return b.priority.index.compareTo(a.priority.index);
      });
    final anyToday = d.tasks.any((t) => t.dueDate == dayKey(now) && t.isDone);
    final labels = {
      TaskFilter.all: l.filterAll,
      TaskFilter.today: l.filterToday,
      TaskFilter.upcoming: l.filterUpcoming,
      TaskFilter.overdue: l.filterOverdue,
      TaskFilter.completed: l.filterCompleted,
      TaskFilter.archived: l.filterArchived,
    };

    return ResponsiveContainer(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.m, Space.gutter, Space.s),
          child: Row(children: [
            Expanded(child: SearchField(onChanged: (v) => setState(() => _q = v.trim()))),
            const SizedBox(width: Space.s),
            PopupMenuButton<Object>(
              tooltip: l.moreFilters,
              icon: Badge(
                isLabelVisible: _priority != null || _goalId != null,
                child: const Icon(Icons.tune),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(enabled: false, child: Text(l.priorityLabel)),
                CheckedPopupMenuItem(value: 'p:any', checked: _priority == null, child: Text(l.any)),
                for (final p in Priority.values.reversed)
                  CheckedPopupMenuItem(value: p, checked: _priority == p, child: Text(l.priority(p))),
                if (d.goals.isNotEmpty) ...[
                  const PopupMenuDivider(),
                  PopupMenuItem(enabled: false, child: Text(l.linkedGoal)),
                  CheckedPopupMenuItem(value: 'g:any', checked: _goalId == null, child: Text(l.any)),
                  for (final g in d.goals) CheckedPopupMenuItem(value: 'g:${g.id}', checked: _goalId == g.id, child: Text(g.title)),
                ],
              ],
              onSelected: (v) => setState(() {
                if (v == 'p:any') {
                  _priority = null;
                } else if (v is Priority) {
                  _priority = v;
                } else if (v == 'g:any') {
                  _goalId = null;
                } else if (v is String && v.startsWith('g:')) {
                  _goalId = v.substring(2);
                }
              }),
            ),
            IconButton.filledTonal(
              tooltip: l.addTask,
              onPressed: () => context.push(Routes.task('new')),
              icon: const Icon(Icons.add),
            ),
          ]),
        ),
        FilterChips<TaskFilter>(
          values: TaskFilter.values,
          selected: _filter,
          label: (f) => labels[f]!,
          onSelected: (f) => setState(() => _filter = f),
        ),
        const SizedBox(height: Space.s),
        Expanded(
          child: list.isEmpty
              ? Builder(builder: (_) {
                  final (msg, action) = _empty(l, anyToday);
                  return EmptyState(
                    icon: _filter == TaskFilter.today && anyToday ? Icons.celebration_outlined : Icons.checklist,
                    title: msg,
                    action: action,
                    onAction: () => context.push(Routes.task('new')),
                  );
                })
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, 96),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: Space.s),
                  itemBuilder: (_, i) {
                    final t = list[i];
                    return TaskCard(
                      task: t,
                      fmt: fmt,
                      now: now,
                      goalTitle: d.goal(t.goalId)?.title,
                      onToggle: () => data.toggleTaskDone(t.id),
                      onOpen: () => context.push(Routes.task(t.id)),
                      onArchive: () {
                        data.archiveTask(t.id, archived: !t.archived);
                        showSnack(context, t.archived ? l.unarchived : l.archived,
                            actionLabel: l.undo, onAction: () => data.archiveTask(t.id, archived: t.archived));
                      },
                      onDelete: () async {
                        if (await confirmDialog(context, title: l.deleteTaskTitle, message: l.deleteTaskBody(t.title), confirmLabel: l.delete)) {
                          data.deleteTask(t.id);
                        }
                      },
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
