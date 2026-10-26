import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/app_data.dart';
import '../../data/data_controller.dart';
import '../../data/models/goal.dart';
import '../../data/models/settings.dart';
import '../../data/models/task.dart';
import '../../domain/metrics.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../shell/quick_add.dart';

/// Tasks relevant "today": due today, overdue, or planned for today.
List<Task> todaysTasks(AppData d, DateTime now) {
  final today = dayKey(now);
  return d.tasks.where((t) {
    if (t.archived || t.status == TaskStatus.cancelled) return false;
    final planned = t.plannedStart != null && isSameDay(t.plannedStart!, now);
    final due = t.dueDate == today;
    final completedToday = t.isDone && t.completedAt != null && isSameDay(t.completedAt!, now);
    if (t.isDone) return (due || planned) || completedToday;
    return due || planned || t.isOverdue(now);
  }).toList();
}

/// Screen 5 — "My day": answers "what should I do now?"
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final s = d.settings;
    final now = ref.watch(clockProvider)();
    final fmt = Fmt.of(context, use24h: s.use24h);
    final data = ref.read(dataProvider.notifier);
    final t = Theme.of(context).textTheme;
    final wide = isWide(context);

    final today = todaysTasks(d, now);
    final open = today.where((x) => x.isOpen).toList();
    final doneCount = today.where((x) => x.isDone).length;
    final priorities = [...open]
      ..sort((a, b) {
        final o = (a.isOverdue(now) ? 0 : 1).compareTo(b.isOverdue(now) ? 0 : 1);
        if (o != 0) return o;
        final p = b.priority.index.compareTo(a.priority.index);
        if (p != 0) return p;
        return (a.plannedStart ?? a.dueAt ?? DateTime(9999)).compareTo(b.plannedStart ?? b.dueAt ?? DateTime(9999));
      });
    final top3 = priorities.take(3).toList();
    final upcoming = d.events.where((e) => e.end.isAfter(now)).toList()..sort((a, b) => a.start.compareTo(b.start));
    final habits = d.habits.where((h) => h.isDueOn(now)).toList();
    final goals = d.goals.where((g) => g.status == GoalStatus.active).take(3).toList();
    final isNew = d.tasks.isEmpty && d.goals.isEmpty && d.events.isEmpty;
    final name = s.showNameInGreeting && s.displayName.isNotEmpty ? s.displayName : null;

    final planCard = AppCard(
      color: AppColors.deepGreen,
      child: Theme(
        data: Theme.of(context).copyWith(
          textTheme: t.apply(bodyColor: Colors.white, displayColor: Colors.white),
        ),
        child: Builder(builder: (context) {
          final tt = Theme.of(context).textTheme;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.view_timeline_outlined, color: Colors.white),
              const SizedBox(width: Space.s),
              Expanded(child: Text(l.todayPlan, style: tt.titleMedium)),
              IconButton(
                tooltip: l.askAssistantReplan,
                color: Colors.white,
                icon: const Icon(Icons.auto_awesome),
                onPressed: () => context.go('${Routes.assistant}?q=${Uri.encodeComponent(l.aiChipPlanDay)}'),
              ),
            ]),
            const SizedBox(height: Space.s),
            Text(
              today.isEmpty ? l.planEmptyToday : l.planSummary(doneCount, today.length),
              style: tt.bodyMedium?.copyWith(color: Colors.white70),
            ),
            if (today.isNotEmpty) ...[
              const SizedBox(height: Space.m),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: doneCount / today.length,
                  minHeight: 8,
                  color: AppColors.lightGreen,
                  backgroundColor: Colors.white24,
                ),
              ),
            ],
            const SizedBox(height: Space.l),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                minimumSize: const Size(64, 44),
              ),
              onPressed: () => context.go(Routes.timeTab('planner')),
              child: Text(l.reviewMyPlan),
            ),
          ]);
        }),
      ),
    );

    final prioritySection = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.topPriorities, action: l.allTasks, onAction: () => context.go(Routes.timeTab('tasks'))),
      if (top3.isEmpty)
        AppCard(
          child: Row(children: [
            Icon(doneCount > 0 ? Icons.celebration_outlined : Icons.add_task, color: context.status.success),
            const SizedBox(width: Space.m),
            Expanded(child: Text(doneCount > 0 ? l.allDoneToday : l.noTasksToday)),
            if (doneCount == 0) TextButton(onPressed: () => context.push(Routes.task('new')), child: Text(l.addTask)),
          ]),
        )
      else
        for (final task in top3)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s),
            child: TaskCard(
              task: task,
              fmt: fmt,
              now: now,
              compact: true,
              goalTitle: d.goal(task.goalId)?.title,
              onToggle: () => data.toggleTaskDone(task.id),
              onOpen: () => context.push(Routes.task(task.id)),
            ),
          ),
    ]);

    final eventsSection = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.upcoming, action: l.viewCalendar, onAction: () => context.go(Routes.timeTab('calendar'))),
      if (upcoming.isEmpty)
        AppCard(child: Text(l.noUpcoming))
      else
        for (final e in upcoming.take(2))
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s),
            child: EventCard(
              event: e,
              fmt: Fmt.of(context, use24h: s.use24h),
              onTap: () => context.push(Routes.event(e.id)),
            ),
          ),
      if (upcoming.isNotEmpty && !isSameDay(upcoming.first.start, now))
        Text(fmt.weekdayDate(upcoming.first.start), style: t.bodySmall),
    ]);

    final habitsSection = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.todaysHabits, action: l.viewAll, onAction: () => context.push(Routes.habits)),
      if (habits.isEmpty)
        AppCard(child: Text(d.habits.isEmpty ? l.noHabitsYet : l.noHabitsDueToday))
      else ...[
        Text(l.habitsDoneOf(habits.where((h) => d.habitDoneOn(h.id, dayKey(now))).length, habits.length),
            style: t.bodySmall),
        const SizedBox(height: Space.s),
        for (final h in habits)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s),
            child: HabitCard(
              habit: h,
              dueToday: true,
              doneToday: d.habitDoneOn(h.id, dayKey(now)),
              onToggle: () => data.setHabitDone(h.id, dayKey(now), !d.habitDoneOn(h.id, dayKey(now))),
            ),
          ),
      ],
    ]);

    final goalsSection = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.goalsSummary, action: l.viewAllGoals, onAction: () => context.go(Routes.goals)),
      if (goals.isEmpty)
        AppCard(
          child: Row(children: [
            Expanded(child: Text(l.noGoalsYet)),
            TextButton(onPressed: () => context.push(Routes.goal('new')), child: Text(l.addGoal)),
          ]),
        )
      else
        for (final g in goals)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s),
            child: GoalCard(
              goal: g,
              compact: true,
              fmt: fmt,
              progress: GoalProgress.of(g, d.milestonesOf(g.id)),
              onTap: () => context.push(Routes.goal(g.id)),
            ),
          ),
    ]);

    final sections = <Widget>[
      if (isNew) _NewUserCard(onAddTask: () => context.push(Routes.task('new')), onAddGoal: () => context.push(Routes.goal('new')), onPlan: () => context.go('${Routes.assistant}?q=${Uri.encodeComponent(l.aiChipPlanDay)}')),
      planCard,
      if (wide)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: prioritySection),
          const SizedBox(width: Space.xl),
          Expanded(child: s.homeShowEvents ? eventsSection : const SizedBox()),
        ])
      else ...[
        prioritySection,
        if (s.homeShowEvents) eventsSection,
      ],
      if (s.homeShowHabits && s.has(AppModule.habits)) habitsSection,
      if (s.homeShowGoals) goalsSection,
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name == null ? l.greeting(now.hour) : l.greetingName(now.hour, name), style: t.titleLarge),
          Text(fmt.fullDate(now), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
        ]),
        actions: [
          IconButton(
            tooltip: l.navNotifications,
            onPressed: () => context.push(Routes.notifications),
            icon: Badge(
              isLabelVisible: d.unreadNotifications > 0,
              label: Text('${d.unreadNotifications}'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          if (!wide) _MoreMenu(settings: s),
          const SizedBox(width: Space.s),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 1100,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, 96),
          itemCount: sections.length,
          separatorBuilder: (_, _) => const SizedBox(height: Space.xl),
          itemBuilder: (_, i) => sections[i],
        ),
      ),
    );
  }
}

class _NewUserCard extends StatelessWidget {
  const _NewUserCard({required this.onAddTask, required this.onAddGoal, required this.onPlan});
  final VoidCallback onAddTask;
  final VoidCallback onAddGoal;
  final VoidCallback onPlan;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppCard(
      color: context.status.highlight,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.newUserTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: Space.s),
        Text(l.newUserBody),
        const SizedBox(height: Space.m),
        Wrap(spacing: Space.s, runSpacing: Space.s, children: [
          FilledButton.icon(onPressed: onAddTask, icon: const Icon(Icons.add_task), label: Text(l.addFirstTask)),
          OutlinedButton.icon(onPressed: onAddGoal, icon: const Icon(Icons.flag_outlined), label: Text(l.addFirstGoal)),
          TextButton.icon(onPressed: onPlan, icon: const Icon(Icons.auto_awesome), label: Text(l.createFirstPlan)),
        ]),
      ]),
    );
  }
}

/// Avatar menu: secondary destinations on phones.
class _MoreMenu extends ConsumerWidget {
  const _MoreMenu({required this.settings});
  final UserSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final initial = settings.displayName.isNotEmpty ? settings.displayName.characters.first : null;
    return PopupMenuButton<String>(
      tooltip: l.menu,
      onSelected: (r) => r == 'add' ? showQuickAdd(context, ref) : context.push(r),
      itemBuilder: (_) => [
        if (settings.has(AppModule.habits)) _item(Routes.habits, Icons.repeat, l.navHabits),
        if (settings.has(AppModule.notes)) _item(Routes.notes, Icons.sticky_note_2_outlined, l.navNotes),
        if (settings.has(AppModule.expenses)) _item(Routes.expenses, Icons.account_balance_wallet_outlined, l.navExpenses),
        const PopupMenuDivider(),
        _item(Routes.settings, Icons.settings_outlined, l.navSettings),
        _item(Routes.profile, Icons.person_outline, l.profileTitle),
      ],
      child: Padding(
        padding: const EdgeInsets.all(Space.xs),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: context.status.highlight,
          child: initial == null
              ? Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary)
              : Text(initial, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
      ),
    );
  }

  PopupMenuItem<String> _item(String route, IconData icon, String label) =>
      PopupMenuItem(value: route, child: ListTile(contentPadding: EdgeInsets.zero, leading: Icon(icon), title: Text(label)));
}
