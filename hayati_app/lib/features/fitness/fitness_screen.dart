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
import '../../data/models/fitness.dart';
import '../../domain/fitness/exercises.dart';
import '../../domain/fitness/plan_generator.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';

/// Screen 12 — the fitness hub: today's workout, the week's plan, recent
/// sessions and the plan version being followed.
class FitnessScreen extends ConsumerWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final now = ref.watch(clockProvider)();
    final profile = d.settings.fitness;
    final t = Theme.of(context).textTheme;

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.navFitness)),
        body: ResponsiveContainer(
          maxWidth: 720,
          child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [
            FadeSlideIn(
              child: _Hero(
                icon: Icons.fitness_center,
                title: l.fitnessIntroTitle,
                body: l.fitnessIntroBody,
                action: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.deepGreen),
                  onPressed: () => context.push(Routes.fitnessSetup),
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(l.createMyPlan),
                ),
              ),
            ),
            const SizedBox(height: Space.l),
            _SafetyNote(),
          ]),
        ),
      );
    }

    final place = d.activePlan(profile.preferredPlace) != null
        ? profile.preferredPlace
        : WorkoutPlace.values.firstWhere((p) => d.activePlan(p) != null, orElse: () => profile.preferredPlace);
    final plan = d.activePlan(place);
    final both = WorkoutPlace.values.every((p) => d.activePlan(p) != null);
    final today = dayKey(now);
    final todayDay = plan?.dayFor(now.weekday);
    final doneToday = d.sessionsOn(today);
    final canGoHome = place == WorkoutPlace.gym && profile.places.contains(WorkoutPlace.home);

    // This week (from the user's week start): planned vs done.
    final weekStart = dateOnly(now).subtract(Duration(days: (now.weekday - d.settings.weekStart + 7) % 7));
    final weekKeys = {for (var i = 0; i < 7; i++) dayKey(weekStart.add(Duration(days: i)))};
    final doneThisWeek = d.workoutSessions.where((s) => weekKeys.contains(s.day)).map((s) => s.day).toSet().length;
    final planned = plan?.days.length ?? 0;
    final recent = [...d.workoutSessions]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final sections = <Widget>[
      if (both)
        SegmentedButton<WorkoutPlace>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: WorkoutPlace.home, label: Text(l.placeHome), icon: const Icon(Icons.home_outlined)),
            ButtonSegment(value: WorkoutPlace.gym, label: Text(l.placeGym), icon: const Icon(Icons.fitness_center)),
          ],
          selected: {place},
          onSelectionChanged: (v) => ref
              .read(dataProvider.notifier)
              .updateSettings((s) => s.copyWith(fitness: () => s.fitness!.copyWith(preferredPlace: v.first))),
        ),
      if (todayDay == null)
        _Hero(
          icon: Icons.self_improvement,
          title: l.restDayTitle,
          body: l.restDayBody,
        )
      else if (doneToday.isNotEmpty)
        _Hero(
          icon: Icons.check_circle_outline,
          title: l.workoutDoneToday,
          body: '${l.dayFocus(doneToday.first.focus)} · ${doneToday.first.status == SessionStatus.completed ? l.sessionCompleted : l.sessionPartial}',
        )
      else
        _Hero(
          icon: Icons.fitness_center,
          title: l.todaysWorkout(l.dayFocus(todayDay.focus)),
          body: '${l.workoutPlace(place)} · ${l.unitMinutes(todayDay.minutes)} · ${l.exerciseCount(todayDay.exercises.length)}',
          action: Wrap(spacing: Space.s, runSpacing: Space.s, children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.deepGreen),
              onPressed: () => context.push(Routes.workout(place.name, now.weekday)),
              icon: const Icon(Icons.play_arrow),
              label: Text(l.startWorkout),
            ),
            if (canGoHome)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                onPressed: () => context.push(Routes.workout(place.name, now.weekday, atHome: true)),
                icon: const Icon(Icons.home_outlined),
                label: Text(l.cantGoToGym),
              ),
          ]),
        ),
      AppCard(
        child: Row(children: [
          Icon(Icons.insights_outlined, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: Space.m),
          Expanded(child: Text(l.weekWorkouts(doneThisWeek, planned))),
        ]),
      ),
      if (plan != null)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionHeader(l.weeklyPlan, action: l.editPlan, onAction: () => context.push(Routes.fitnessSetup)),
          for (final day in plan.days)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s),
              child: _DayTile(day: day, today: day.weekday == now.weekday, place: place),
            ),
          Text(
            l.planVersion(plan.version, Fmt.of(context).date(plan.createdAt)),
            style: t.bodySmall?.copyWith(color: context.status.textSecondary),
          ),
          if (PlanGenerator.needsMoreRecovery(plan.days)) ...[
            const SizedBox(height: Space.s),
            Text(l.recoveryWarning, style: t.bodySmall?.copyWith(color: context.status.warning)),
          ],
        ]),
      if (recent.isNotEmpty)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionHeader(l.recentWorkouts),
          for (final s in recent.take(6))
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s),
              child: AppCard(
                child: Row(children: [
                  Icon(s.status == SessionStatus.completed ? Icons.check_circle : Icons.timelapse,
                      color: s.status == SessionStatus.completed ? context.status.success : context.status.warning),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.dayFocus(s.focus), style: t.titleSmall),
                      Text(
                        [
                          Fmt.of(context).day(s.day),
                          l.workoutPlace(s.place),
                          l.setsLogged(s.sets.length),
                          if (s.difficulty != null) l.feltLike(l.effort('${s.difficulty}')),
                          if (s.substituted) l.homeInstead,
                        ].join(' · '),
                        style: t.bodySmall?.copyWith(color: context.status.textSecondary),
                      ),
                    ]),
                  ),
                  IconButton(
                    tooltip: l.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      if (await confirmDialog(context, title: l.deleteWorkoutTitle, message: l.deleteWorkoutBody, confirmLabel: l.delete)) {
                        ref.read(dataProvider.notifier).deleteWorkout(s.id);
                      }
                    },
                  ),
                ]),
              ),
            ),
        ]),
      _SafetyNote(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.navFitness)),
      body: ResponsiveContainer(
        maxWidth: 760,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl),
          itemCount: sections.length,
          separatorBuilder: (_, _) => const SizedBox(height: Space.l),
          itemBuilder: (_, i) => FadeSlideIn(index: i, child: sections[i]),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.icon, required this.title, required this.body, this.action});
  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(Space.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.sheet),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppColors.deepGreen, AppColors.midGreen],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: Space.m),
        Text(title, style: t.headlineSmall?.copyWith(color: Colors.white)),
        const SizedBox(height: Space.xs),
        Text(body, style: t.bodyMedium?.copyWith(color: Colors.white70)),
        if (action != null) ...[const SizedBox(height: Space.l), action!],
      ]),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.day, required this.today, required this.place});
  final WorkoutDay day;
  final bool today;
  final WorkoutPlace place;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = l.localeName;
    // Any date with this weekday, just for its localized name.
    final date = DateTime(2026, 1, 5).add(Duration(days: day.weekday - 1));
    return Card(
      color: today ? context.status.highlight : null,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        leading: CircleAvatar(
          backgroundColor: today ? Theme.of(context).colorScheme.primary : context.status.highlight,
          foregroundColor: today ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
          child: Icon(focusIcon(day.focus), size: 20),
        ),
        title: Text('${Fmt.of(context).weekdayShort(date)} · ${l.dayFocus(day.focus)}', style: t.titleSmall),
        subtitle: Text('${l.unitMinutes(day.minutes)} · ${l.exerciseCount(day.exercises.length)}'),
        children: [
          for (final x in day.exercises)
            ListTile(
              dense: true,
              title: Text(exerciseById(x.exerciseId)!.name(lang)),
              trailing: Text(l.prescription(x)),
              onTap: () => context.push(Routes.exercise(x.exerciseId)),
            ),
        ],
      ),
    );
  }
}

IconData focusIcon(DayFocus f) => switch (f) {
      DayFocus.fullBody => Icons.accessibility_new,
      DayFocus.upper => Icons.sports_gymnastics,
      DayFocus.lower => Icons.directions_walk,
      DayFocus.conditioning => Icons.directions_run,
      DayFocus.mobility => Icons.self_improvement,
    };

class _SafetyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.health_and_safety_outlined, size: 18, color: context.status.info),
      const SizedBox(width: Space.s),
      Expanded(
        child: Text(l.fitnessSafety, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.status.textSecondary)),
      ),
    ]);
  }
}
