import 'dart:async';

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
import '../../data/models/fitness.dart';
import '../../data/models/goal.dart';
import '../../data/models/health.dart';
import '../../data/models/settings.dart';
import '../../data/models/task.dart';
import '../../data/models/womens.dart';
import '../../domain/activity.dart';
import '../../domain/day_timeline.dart';
import '../../domain/fitness/today.dart';
import '../../domain/learning/curriculum.dart';
import '../../domain/learning/path.dart';
import '../../domain/metrics.dart';
import '../../domain/nutrition/summary.dart';
import '../../domain/planner.dart';
import '../../domain/prayer_times.dart';
import '../../domain/womens/cycle.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_surface.dart';
import '../../widgets/motion.dart';
import '../shell/quick_add.dart';
import '../womens/womens_gate.dart';

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

enum HomeView { today, week, goals }

/// Screen 5 — "My day": what to do now, what's next, and how the week and
/// long-term goals look.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  HomeView _view = HomeView.today;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // "Now" and countdowns move with the clock.
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final s = d.settings;
    final now = ref.watch(clockProvider)();
    final fmt = Fmt.of(context, use24h: s.use24h);
    final t = Theme.of(context).textTheme;
    final wide = isWide(context);
    final name = s.showNameInGreeting && s.displayName.isNotEmpty ? s.displayName : null;

    final body = switch (_view) {
      HomeView.today => _TodayView(d: d, now: now, fmt: fmt, wide: wide),
      HomeView.week => _WeekView(d: d, now: now, fmt: fmt),
      HomeView.goals => _GoalsView(d: d, fmt: fmt),
    };

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.xs, Space.gutter, 112),
          children: [
            SegmentedButton<HomeView>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: HomeView.today, label: Text(l.homeViewToday), icon: const Icon(Icons.wb_sunny_outlined)),
                ButtonSegment(value: HomeView.week, label: Text(l.homeViewWeek), icon: const Icon(Icons.view_week_outlined)),
                ButtonSegment(value: HomeView.goals, label: Text(l.homeViewGoals), icon: const Icon(Icons.flag_outlined)),
              ],
              selected: {_view},
              onSelectionChanged: (v) => setState(() => _view = v.first),
            ),
            const SizedBox(height: Space.l),
            SmoothSwitcher(childKey: _view, child: body),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- today

class _TodayView extends ConsumerWidget {
  const _TodayView({required this.d, required this.now, required this.fmt, required this.wide});
  final AppData d;
  final DateTime now;
  final Fmt fmt;
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = d.settings;
    final data = ref.read(dataProvider.notifier);
    final t = Theme.of(context).textTheme;

    final timeline = buildTimeline(d, now);
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
    final movable = timeline.plan.unscheduled.length;
    final habits = d.habits.where((h) => h.isDueOn(now)).toList();
    final isNew = d.tasks.isEmpty && d.goals.isEmpty && d.events.isEmpty;

    void ask(String q) => context.go('${Routes.assistant}?q=${Uri.encodeComponent(q)}');

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
      if (movable > 0)
        AppCard(
          color: context.status.highlight,
          onTap: () => context.go(Routes.timeTab('planner')),
          child: Row(children: [
            Icon(Icons.low_priority, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: Space.m),
            Expanded(child: Text(l.canMoveCount(movable))),
            const Icon(Icons.chevron_right),
          ]),
        ),
    ]);

    final scheduleSection = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.daySchedule, action: l.reviewMyPlan, onAction: () => context.go(Routes.timeTab('planner'))),
      if (timeline.items.isEmpty)
        AppCard(child: Text(l.planEmptyToday))
      else
        _Timeline(items: timeline.items, now: now, fmt: fmt),
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

    final sections = <Widget>[
      _NowCard(
        timeline: timeline,
        now: now,
        fmt: fmt,
        done: doneCount,
        total: today.length,
        onReplan: () => ask(l.aiChipLate),
      ),
      if (isNew)
        _NewUserCard(
          onAddTask: () => context.push(Routes.task('new')),
          onAddGoal: () => context.push(Routes.goal('new')),
          onPlan: () => ask(l.aiChipPlanDay),
        ),
      _PrayerStrip(d: d, now: now, fmt: fmt),
      if (d.settings.health.has(HealthModule.activity)) _StepsStrip(day: activityDay(d, dayKey(now)), goal: d.settings.health.stepGoal, fmt: fmt),
      if (d.settings.health.has(HealthModule.nutrition)) _FoodStrip(day: nutritionDay(d, dayKey(now)), fmt: fmt),
      if (womensVisible(d.settings) && !d.settings.health.hideFromHome) _CycleStrip(d: d, now: now),
      if (appointmentsVisible(d.settings))
        if (nextAppointment(d, now) case final a? when a.at.difference(now).inDays < 7) _AppointmentStrip(a: a, fmt: fmt),
      if (d.learningPath != null)
        _EnglishStrip(lesson: nextLesson(d), done: lessonDoneToday(d, now), due: dueReviews(d, now).length),
      if (todaysWorkout(d, now) case (final plan, final day))
        _WorkoutStrip(done: d.sessionsOn(dayKey(now)).isNotEmpty, focus: day.focus, minutes: day.minutes, place: plan.place),
      _AskChips(onAsk: ask),
      if (wide)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: scheduleSection),
          const SizedBox(width: Space.xl),
          Expanded(child: prioritySection),
        ])
      else ...[
        prioritySection,
        scheduleSection,
      ],
      if (s.homeShowHabits && s.has(AppModule.habits)) habitsSection,
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (var i = 0; i < sections.length; i++)
        Padding(
          padding: EdgeInsets.only(bottom: i == sections.length - 1 ? 0 : Space.xl),
          child: FadeSlideIn(index: i, child: sections[i]),
        ),
    ]);
  }
}

/// The hero card: what's happening now and what comes next.
class _NowCard extends StatelessWidget {
  const _NowCard({
    required this.timeline,
    required this.now,
    required this.fmt,
    required this.done,
    required this.total,
    required this.onReplan,
  });
  final DayTimeline timeline;
  final DateTime now;
  final Fmt fmt;
  final int done;
  final int total;
  final VoidCallback onReplan;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cur = timeline.current;
    final next = timeline.next;
    const fg = Colors.white;
    const dim = Colors.white70;

    final String headline;
    final String detail;
    double? elapsed;
    if (cur != null) {
      headline = itemTitle(l, cur);
      detail = l.nowUntil(fmt.time(cur.end));
      elapsed = now.difference(cur.start).inSeconds / cur.end.difference(cur.start).inSeconds;
    } else if (next != null) {
      headline = l.freeTimeNow;
      detail = l.nowUntil(fmt.time(next.start));
    } else {
      headline = timeline.items.isEmpty ? l.nothingScheduledNow : l.dayScheduleDone;
      detail = l.restOfDayFree;
    }

    return Semantics(
      container: true,
      label: '${l.nowLabel}: $headline, $detail',
      child: HeroSurface(
        padding: const EdgeInsets.fromLTRB(Space.xl, Space.l, Space.l, Space.l),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                  child: SizedBox.square(dimension: 8),
                ),
                const SizedBox(width: 6),
                Text('${l.nowLabel} · ${fmt.time(now)}', style: t.labelMedium?.copyWith(color: fg)),
              ]),
            ),
            const Spacer(),
            IconButton(
              tooltip: l.aiChipLate,
              color: fg,
              icon: const Icon(Icons.auto_awesome, color: AppColors.gold),
              onPressed: onReplan,
            ),
          ]),
          const SizedBox(height: Space.m),
          AnimatedSwitcher(
            duration: Motion.medium,
            child: Text(
              headline,
              key: ValueKey(headline),
              style: t.headlineSmall?.copyWith(color: fg),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: Space.xs),
          Text(detail, style: t.bodyMedium?.copyWith(color: dim)),
          if (elapsed != null) ...[
            const SizedBox(height: Space.m),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: elapsed.clamp(0, 1)),
                duration: Motion.slow,
                curve: Motion.curve,
                builder: (_, v, _) =>
                    LinearProgressIndicator(value: v, minHeight: 6, color: AppColors.gold, backgroundColor: Colors.white24),
              ),
            ),
          ],
          if (next != null && next != cur) ...[
            const SizedBox(height: Space.l),
            Container(
              padding: const EdgeInsets.all(Space.m),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(Radii.button)),
              child: Row(children: [
                Icon(iconFor(next), color: fg, size: 20),
                const SizedBox(width: Space.m),
                Expanded(
                  child: Text('${l.nextUp}: ${itemTitle(l, next)}', style: t.bodyMedium?.copyWith(color: fg), overflow: TextOverflow.ellipsis),
                ),
                Text(fmt.time(next.start), style: t.labelMedium?.copyWith(color: dim)),
              ]),
            ),
          ],
          if (total > 0) ...[
            const SizedBox(height: Space.m),
            Text(l.planSummary(done, total), style: t.bodySmall?.copyWith(color: dim)),
          ],
        ]),
      ),
    );
  }
}

/// Next prayer, or an invitation to set prayer times up.
class _PrayerStrip extends ConsumerWidget {
  const _PrayerStrip({required this.d, required this.now, required this.fmt});
  final AppData d;
  final DateTime now;
  final Fmt fmt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ps = d.settings.prayer;
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    if (!ps.active) {
      if (ps.setupDismissed) return const SizedBox.shrink();
      return AppCard(
        onTap: () => context.push(Routes.prayerSettings),
        child: Row(children: [
          const IconBadge(Icons.mosque_outlined, color: AppColors.gold, circle: true),
          const SizedBox(width: Space.m),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.prayerSetupTitle, style: t.titleSmall),
              Text(l.prayerSetupBody, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
            ]),
          ),
          IconButton(
            tooltip: l.dismiss,
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => ref.read(dataProvider.notifier).updateSettings((s) => s.copyWith(prayer: s.prayer.copyWith(setupDismissed: true))),
          ),
        ]),
      );
    }
    final next = nextPrayer(ps, now)!;
    final left = next.$2.difference(now).inMinutes + 1;
    return AppCard(
      onTap: () => context.push(Routes.prayer),
      child: Row(children: [
        const IconBadge(Icons.mosque_outlined, color: AppColors.gold, circle: true),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.nextPrayerIs(l.prayerName(next.$1)), style: t.titleSmall),
            Text(l.inDuration(l.durationText(left)), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
          ]),
        ),
        Text(fmt.time(next.$2), style: t.titleMedium?.copyWith(color: scheme.primary)),
        const SizedBox(width: Space.xs),
        const Icon(Icons.chevron_right),
      ]),
    );
  }
}

/// Today's steps against the goal.
/// Where the cycle is, in a line. With the lock on it says nothing more
/// than the section's name.
class _CycleStrip extends StatelessWidget {
  const _CycleStrip({required this.d, required this.now});
  final AppData d;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final locked = d.settings.health.lockEnabled;
    final st = cycleStatus(d, now);
    final String text;
    if (locked) {
      text = l.navWomens;
    } else if (st.last == null) {
      text = l.cycleStartTitle;
    } else if (st.inPeriod) {
      text = l.periodDayN(st.periodDay!);
    } else if (!st.canPredict) {
      text = l.cycleDayN(st.dayOfCycle!);
    } else if (st.daysLate > 0) {
      text = l.periodLateBy(st.daysLate);
    } else {
      final days = st.nextStart!.difference(dateOnly(now)).inDays;
      text = days <= 0 ? l.periodDueAbout : l.nextPeriodIn(days);
    }
    return AppCard(
      onTap: () => context.push(Routes.womens),
      child: Row(children: [
        IconBadge(locked ? Icons.lock_outline : Icons.water_drop_outlined, circle: true),
        const SizedBox(width: Space.m),
        Expanded(child: Text(text, style: t.titleSmall)),
        const Icon(Icons.chevron_right),
      ]),
    );
  }
}

/// A health appointment in the coming week.
class _AppointmentStrip extends StatelessWidget {
  const _AppointmentStrip({required this.a, required this.fmt});
  final HealthAppointment a;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      onTap: () => context.push(Routes.appointment(a.id)),
      child: Row(children: [
        const IconBadge(Icons.event_note, circle: true),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.title, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(fmt.dateTime(a.at), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
          ]),
        ),
        const Icon(Icons.chevron_right),
      ]),
    );
  }
}

class _StepsStrip extends StatelessWidget {
  const _StepsStrip({required this.day, required this.goal, required this.fmt});
  final ActivityDay day;
  final int goal;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final reached = day.steps >= goal;
    return AppCard(
      onTap: () => context.push(Routes.activity),
      child: Row(children: [
        IconBadge(reached ? Icons.emoji_events_outlined : Icons.directions_walk, color: reached ? AppColors.gold : null, circle: true),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.stepsOfGoal(fmt.number(day.steps), fmt.number(goal)), style: t.titleSmall),
            const SizedBox(height: Space.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: (day.steps / goal).clamp(0, 1).toDouble()),
                duration: Motion.slow,
                curve: Motion.curve,
                builder: (_, v, _) => LinearProgressIndicator(value: v, minHeight: 6, color: reached ? AppColors.gold : null),
              ),
            ),
            if (!day.hasData) ...[
              const SizedBox(height: Space.xs),
              Text(l.stepsNoData, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
            ],
          ]),
        ),
        const SizedBox(width: Space.xs),
        const Icon(Icons.chevron_right),
      ]),
    );
  }
}

/// Today's food and water.
class _FoodStrip extends StatelessWidget {
  const _FoodStrip({required this.day, required this.fmt});
  final NutritionDay day;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return AppCard(
      onTap: () => context.push(Routes.nutrition),
      child: Row(children: [
        const IconBadge(Icons.restaurant_outlined, circle: true),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(day.hasFood ? l.kcalN(fmt.number(day.total.kcal.round())) : l.foodNoneYet, style: t.titleSmall),
            Text(l.waterMl(fmt.number(day.waterMl)), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
          ]),
        ),
        const Icon(Icons.chevron_right),
      ]),
    );
  }
}

/// Today's English: the next lesson and words due for review.
class _EnglishStrip extends StatelessWidget {
  const _EnglishStrip({required this.lesson, required this.done, required this.due});
  final Lesson? lesson;
  final bool done;
  final int due;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final title = done
        ? l.lessonDoneToday
        : lesson == null
            ? l.levelCheckReady
            : l.englishLessonItem(lesson!.title(l.localeName));
    return AppCard(
      onTap: () => context.push(done || lesson == null ? Routes.english : Routes.lesson(lesson!.id)),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: context.status.highlight,
          child: Icon(done ? Icons.check : Icons.translate, color: done ? context.status.success : scheme.primary),
        ),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: t.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (due > 0) Text(l.reviewDue(due), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
          ]),
        ),
        const Icon(Icons.chevron_right),
      ]),
    );
  }
}

/// Today's training, if today is a workout day.
class _WorkoutStrip extends StatelessWidget {
  const _WorkoutStrip({required this.done, required this.focus, required this.minutes, required this.place});
  final bool done;
  final DayFocus focus;
  final int minutes;
  final WorkoutPlace place;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: () => context.push(Routes.fitness),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: context.status.highlight,
          child: Icon(done ? Icons.check : Icons.fitness_center, color: done ? context.status.success : scheme.primary),
        ),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(done ? l.workoutDoneToday : l.todaysWorkout(l.dayFocus(focus)), style: t.titleSmall),
            Text('${l.workoutPlace(place)} · ${l.unitMinutes(minutes)}',
                style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
          ]),
        ),
        const Icon(Icons.chevron_right),
      ]),
    );
  }
}

class _AskChips extends StatelessWidget {
  const _AskChips({required this.onAsk});
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.askHayati, style: t.titleMedium),
      const SizedBox(height: Space.s),
      Wrap(spacing: Space.s, runSpacing: Space.s, children: [
        for (final q in [l.aiChipLate, l.aiChipFreeTime, l.aiChipPlanDay])
          ActionChip(
            avatar: const Icon(Icons.auto_awesome, size: 16),
            label: Text(q),
            onPressed: () => onAsk(q),
          ),
      ]),
    ]);
  }
}

/// Vertical timeline of today's items; past ones fade back.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.items, required this.now, required this.fmt});
  final List<TimelineItem> items;
  final DateTime now;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: Space.s),
      child: Column(children: [
        for (var i = 0; i < items.length; i++)
          Builder(builder: (context) {
            final it = items[i];
            final current = it.isNow(now);
            final past = it.isPast(now);
            final color = switch (it.kind) {
              TimelineKind.prayer => scheme.primary,
              TimelineKind.event => context.status.info,
              TimelineKind.task => scheme.secondary,
              TimelineKind.workout => context.status.success,
              TimelineKind.lesson => context.status.info,
              TimelineKind.walk => context.status.success,
              TimelineKind.work => context.status.warning,
              TimelineKind.rest => context.status.inactive,
            };
            return AnimatedOpacity(
              duration: Motion.medium,
              opacity: past ? 0.45 : 1,
              child: InkWell(
                onTap: switch (it.kind) {
                  TimelineKind.task => () => context.push(Routes.task(it.refId!)),
                  TimelineKind.workout => () => context.push(Routes.fitness),
                  TimelineKind.lesson => () => context.push(Routes.lesson(it.refId!)),
                  TimelineKind.walk => () => context.push(Routes.activity),
                  TimelineKind.event => () => context.push(Routes.event(it.refId!)),
                  TimelineKind.prayer => () => context.push(Routes.prayer),
                  _ => null,
                },
                child: Container(
                  color: current ? context.status.highlight : null,
                  padding: const EdgeInsets.symmetric(horizontal: Space.l, vertical: Space.s),
                  child: IntrinsicHeight(
                    child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      SizedBox(
                        width: 64,
                        child: Text(fmt.time(it.start), style: t.labelMedium?.copyWith(color: context.status.textSecondary)),
                      ),
                      Column(children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: current ? color : Colors.transparent,
                            border: Border.all(color: color, width: 2),
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (i < items.length - 1)
                          Expanded(child: Container(width: 2, color: scheme.outlineVariant, margin: const EdgeInsets.only(top: 2))),
                      ]),
                      const SizedBox(width: Space.m),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: Space.s),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Icon(iconFor(it), size: 16, color: color),
                              const SizedBox(width: Space.xs),
                              Expanded(
                                child: Text(itemTitle(l, it),
                                    style: t.bodyMedium?.copyWith(fontWeight: current ? FontWeight.w700 : FontWeight.w500),
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ]),
                            const SizedBox(height: 2),
                            Wrap(spacing: Space.s, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
                              Text('${fmt.time(it.start)} – ${fmt.time(it.end)}', style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                              if (it.suggested) Pill(label: l.suggestedPill, color: context.status.info),
                              if (it.kind == TimelineKind.task && it.estimated) Pill(label: l.estimatedPill, color: context.status.inactive),
                            ]),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            );
          }),
      ]),
    );
  }
}

IconData iconFor(TimelineItem it) => switch (it.kind) {
      TimelineKind.prayer => Icons.mosque_outlined,
      TimelineKind.event => Icons.event,
      TimelineKind.task => Icons.check_circle_outline,
      TimelineKind.workout => Icons.fitness_center,
      TimelineKind.lesson => Icons.translate,
      TimelineKind.walk => Icons.directions_walk,
      TimelineKind.work => Icons.work_outline,
      TimelineKind.rest => Icons.free_breakfast_outlined,
    };

String itemTitle(AppLocalizations l, TimelineItem it) => switch (it.kind) {
      TimelineKind.prayer => l.prayerName(it.prayer!),
      TimelineKind.workout => l.todaysWorkout(l.dayFocus(it.focus!)),
      TimelineKind.lesson => l.englishLessonItem(lessonById(it.refId!)?.title(l.localeName) ?? ''),
      TimelineKind.walk => l.walkItem(walkMinutes),
      TimelineKind.work => l.workBlock,
      TimelineKind.rest => l.restBlock,
      _ => it.title ?? '',
    };

// ------------------------------------------------------------------ week

class _WeekView extends StatelessWidget {
  const _WeekView({required this.d, required this.now, required this.fmt});
  final AppData d;
  final DateTime now;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final today = dateOnly(now);
    const planner = Planner();
    final days = [for (var i = 0; i < 7; i++) today.add(Duration(days: i))];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l.weekAhead, style: t.titleMedium),
      const SizedBox(height: Space.s),
      for (var i = 0; i < days.length; i++)
        Builder(builder: (context) {
          final day = days[i];
          final key = dayKey(day);
          final plan = planner.plan(day: day, now: now, tasks: d.tasks, events: d.events, settings: d.settings);
          final events = d.events.where((e) => isSameDay(e.start, day)).length;
          final due = d.tasks.where((x) => x.isOpen && !x.archived && x.dueDate == key).length;
          final load = plan.freeMinutes == 0 ? (plan.neededMinutes > 0 ? 1.0 : 0.0) : plan.neededMinutes / plan.freeMinutes;
          final busy = load > 0.85;
          return Padding(
            padding: const EdgeInsets.only(bottom: Space.s),
            child: FadeSlideIn(
              index: i,
              child: AppCard(
                color: i == 0 ? context.status.highlight : null,
                onTap: () => context.go(Routes.timeTab('calendar')),
                child: Row(children: [
                  SizedBox(
                    width: 56,
                    child: Column(children: [
                      Text(fmt.weekdayShort(day), style: t.labelMedium?.copyWith(color: context.status.textSecondary)),
                      Text('${day.day}', style: t.headlineSmall),
                    ]),
                  ),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Wrap(spacing: Space.s, runSpacing: Space.xs, children: [
                        Pill(label: l.weekEvents(events), color: context.status.info, icon: Icons.event),
                        Pill(label: l.weekTasks(due), color: Theme.of(context).colorScheme.secondary, icon: Icons.check_circle_outline),
                        if (busy) Pill(label: l.weekBusy, color: context.status.warning, icon: Icons.warning_amber),
                      ]),
                      const SizedBox(height: Space.s),
                      Semantics(
                        label: l.weekLoad,
                        value: '${(load.clamp(0, 1) * 100).round()}%',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: load.clamp(0, 1).toDouble()),
                            duration: Motion.slow,
                            curve: Motion.curve,
                            builder: (_, v, _) => LinearProgressIndicator(
                              value: v,
                              minHeight: 6,
                              color: busy ? context.status.warning : null,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
          );
        }),
    ]);
  }
}

// ----------------------------------------------------------------- goals

class _GoalsView extends StatelessWidget {
  const _GoalsView({required this.d, required this.fmt});
  final AppData d;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final goals = d.goals.where((g) => g.status == GoalStatus.active).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.goalsSummary, action: l.viewAllGoals, onAction: () => context.go(Routes.goals)),
      if (goals.isEmpty)
        EmptyState(icon: Icons.flag_outlined, title: l.noGoalsYet, action: l.addGoal, onAction: () => context.push(Routes.goal('new')))
      else
        for (var i = 0; i < goals.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s),
            child: FadeSlideIn(
              index: i,
              child: GoalCard(
                goal: goals[i],
                fmt: fmt,
                progress: GoalProgress.of(goals[i], d.milestonesOf(goals[i].id)),
                onTap: () => context.push(Routes.goal(goals[i].id)),
              ),
            ),
          ),
    ]);
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
        _item(Routes.prayer, Icons.mosque_outlined, l.navPrayer),
        _item(Routes.fitness, Icons.fitness_center, l.navFitness),
        _item(Routes.english, Icons.translate, l.navEnglish),
        if (settings.health.has(HealthModule.activity)) _item(Routes.activity, Icons.directions_walk, l.navActivity),
        if (settings.health.has(HealthModule.nutrition)) _item(Routes.nutrition, Icons.restaurant_outlined, l.navNutrition),
        if (womensVisible(settings)) _item(Routes.womens, Icons.water_drop_outlined, l.navWomens),
        if (appointmentsVisible(settings)) _item(Routes.appointments, Icons.event_note, l.appointments),
        _item(Routes.vitals, Icons.monitor_heart_outlined, l.vitals),
        if (settings.health.has(HealthModule.sleep)) _item(Routes.sleep, Icons.bedtime_outlined, l.sleepAndRecovery),
        _item(Routes.learn, Icons.menu_book_outlined, l.healthLearn),
        _item(Routes.accountability, Icons.handshake_outlined, l.navAccountability),
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
      PopupMenuItem(value: route, child: ListTile(contentPadding: EdgeInsets.zero, leading: IconBadge(icon, size: 18), title: Text(label)));
}
