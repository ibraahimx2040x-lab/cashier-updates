import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/fitness.dart';
import '../../domain/fitness/exercises.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_surface.dart';
import '../../widgets/motion.dart';
import '../../widgets/home_logo.dart';

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
    final home = ref.watch(dataProvider).settings.fitness?.homeEquipment ?? const <Equipment>{};
    final steps = e.steps(lang);

    return Scaffold(
      appBar: AppBar(title: Text(e.name(lang)), actions: const [HomeLogoButton()]),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl),
          children: [
            FadeSlideIn(
              child: HeroSurface(
                height: 160,
                child: Center(child: Icon(muscleIcon(e.muscle), size: 72, color: AppColors.gold)),
              ),
            ),
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
            const SizedBox(height: Space.l),
            AppCard(
              color: context.status.highlight,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.health_and_safety_outlined, color: scheme.primary),
                const SizedBox(width: Space.m),
                Expanded(child: Text(e.tip(lang))),
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
                        Icon(muscleIcon(a.muscle), color: scheme.primary),
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
