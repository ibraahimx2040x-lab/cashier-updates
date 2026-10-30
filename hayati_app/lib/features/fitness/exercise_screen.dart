import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/fitness.dart';
import '../../domain/fitness/exercise_info.dart';
import '../../domain/fitness/exercises.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import '../../widgets/home_logo.dart';
import 'exercise_media.dart';

IconData muscleIcon(Muscle m) => switch (m) {
      Muscle.chest || Muscle.shoulders || Muscle.arms => Icons.sports_gymnastics,
      Muscle.back => Icons.rowing,
      Muscle.legs || Muscle.glutes => Icons.directions_walk,
      Muscle.core => Icons.accessibility_new,
      Muscle.fullBody => Icons.fitness_center,
      Muscle.cardio => Icons.directions_run,
      Muscle.mobility => Icons.self_improvement,
      Muscle.balance => Icons.accessibility,
      Muscle.pelvicFloor => Icons.spa_outlined,
    };

/// Screen 14 — how to do one exercise, safely, and what can replace it.
class ExerciseScreen extends ConsumerWidget {
  const ExerciseScreen({super.key, required this.exerciseId});
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final e = exerciseById(exerciseId);
    if (e == null) {
      return Scaffold(appBar: AppBar(actions: const [HomeLogoButton()]), body: EmptyState(icon: Icons.search_off, title: l.itemGone));
    }
    final lang = l.localeName;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final settings = ref.watch(dataProvider).settings;
    final fitness = settings.fitness;
    final home = fitness?.homeEquipment ?? const <Equipment>{};
    final goal = fitness?.goal ?? FitnessGoal.general;
    final steps = e.steps(lang);
    final (main, helpers) = targetsOf(e);
    final dosage = dosageOf(e, goal);

    return Scaffold(
      appBar: AppBar(title: Text(e.name(lang)), actions: const [HomeLogoButton()]),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl),
          children: [
            FadeSlideIn(child: ExercisePhotos(exercise: e)),
            const SizedBox(height: Space.l),
            Wrap(spacing: Space.s, runSpacing: Space.s, children: [
              Pill(label: l.muscle(e.muscle), color: scheme.primary, icon: Icons.track_changes),
              Pill(label: l.difficulty(e.difficulty), color: context.status.warning, icon: Icons.speed),
              if (e.gymOnly.isNotEmpty)
                Pill(label: l.placeGym, color: context.status.info, icon: Icons.fitness_center)
              else if (e.equipment.isEmpty)
                Pill(label: l.bodyweight, color: context.status.success, icon: Icons.accessibility_new)
              else
                for (final q in e.equipment) Pill(label: l.equipment(q), color: context.status.info, icon: Icons.handyman_outlined),
            ]),
            if (main.isNotEmpty) ...[
              const SizedBox(height: Space.xl),
              SectionHeader(l.targetMuscles),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _TargetRow(label: l.mainTargets, targets: main, color: scheme.primary),
                  if (helpers.isNotEmpty) ...[
                    const SizedBox(height: Space.m),
                    _TargetRow(label: l.helperTargets, targets: helpers, color: context.status.textSecondary),
                  ],
                ]),
              ),
            ],
            const SizedBox(height: Space.xl),
            SectionHeader(l.howTo),
            AppCard(
              child: Column(children: [
                for (var i = 0; i < steps.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : Space.m),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: context.status.highlight,
                        child: Text('${i + 1}', style: t.labelMedium?.copyWith(color: scheme.primary)),
                      ),
                      const SizedBox(width: Space.m),
                      Expanded(child: Text(steps[i], style: t.bodyLarge)),
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: Space.xl),
            SectionHeader(l.suggestedDosage),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.dosageForGoal(l.fitnessGoal(goal)), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                const SizedBox(height: Space.s),
                for (final MapEntry(key: level, value: x) in dosage.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.xs),
                    child: Row(children: [
                      Expanded(child: Text(l.fitnessLevel(level), style: t.bodyMedium?.copyWith(fontWeight: level == fitness?.level ? FontWeight.w700 : null))),
                      Text(l.prescription(x), style: t.titleSmall),
                      if (x.restSeconds > 0) ...[
                        const SizedBox(width: Space.s),
                        Text(l.restSeconds(x.restSeconds), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                      ],
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: Space.xl),
            SectionHeader(l.safetyAndWarnings),
            AppCard(
              color: context.status.highlight,
              child: Column(children: [
                for (final (i, text) in [e.tip(lang), for (final c in cautionsOf(e, sex: settings.sex)) l.caution(c)].indexed)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : Space.m),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(i == 0 ? Icons.health_and_safety_outlined : Icons.warning_amber_rounded,
                          size: 20, color: i == 0 ? scheme.primary : context.status.warning),
                      const SizedBox(width: Space.m),
                      Expanded(child: Text(text)),
                    ]),
                  ),
              ]),
            ),
            if (e.alternatives.isNotEmpty) ...[
              const SizedBox(height: Space.xl),
              SectionHeader(l.alternatives),
              for (final id in e.alternatives)
                if (exerciseById(id) case final a?)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.s),
                    child: AppCard(
                      onTap: () => context.push(Routes.exercise(a.id)),
                      child: Row(children: [
                        ExerciseThumb(exercise: a, size: 44),
                        const SizedBox(width: Space.m),
                        Expanded(child: Text(a.name(lang), style: t.titleSmall)),
                        if (a.availableAt(WorkoutPlace.home, home))
                          Pill(label: l.placeHome, color: context.status.success, icon: Icons.home_outlined),
                        const Icon(Icons.chevron_right),
                      ]),
                    ),
                  ),
            ],
            const SizedBox(height: Space.l),
            Text(l.fitnessSafety, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  const _TargetRow({required this.label, required this.targets, required this.color});
  final String label;
  final List<Target> targets;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: context.status.textSecondary)),
      const SizedBox(height: Space.xs),
      Wrap(spacing: Space.s, runSpacing: Space.s, children: [for (final x in targets) Pill(label: l.target(x), color: color)]),
    ]);
  }
}
