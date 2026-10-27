import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../data/data_controller.dart';
import '../../domain/fitness/exercises.dart';
import '../../domain/fitness/progress.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import 'exercise_screen.dart' show muscleIcon;

/// Screen 15b — how each exercise has gone over time, from logged sets.
class ExerciseProgressScreen extends ConsumerWidget {
  const ExerciseProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context);
    final lang = l.localeName;
    final list = exerciseProgress(d);

    String value(ExerciseProgress p, ProgressPoint x) => switch (p.kind) {
          ProgressKind.weight => l.kgTimesReps(fmt.number(x.value), x.reps ?? 0),
          ProgressKind.reps => l.repsN(x.value.round()),
          ProgressKind.seconds => l.secondsN(x.value.round()),
        };

    return Scaffold(
      appBar: AppBar(title: Text(l.progressLog)),
      body: ResponsiveContainer(
        maxWidth: 760,
        child: list.isEmpty
            ? EmptyState(icon: Icons.show_chart, title: l.noProgressYet, message: l.noProgressYetBody)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl),
                itemCount: list.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: Space.m),
                itemBuilder: (_, i) {
                  if (i == 0) return Text(l.progressNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary));
                  final p = list[i - 1];
                  final e = exerciseById(p.exerciseId);
                  final recent = p.points.length > 8 ? p.points.sublist(p.points.length - 8) : p.points;
                  final top = recent.fold<double>(0, (a, x) => math.max(a, x.value));
                  return FadeSlideIn(
                    index: i,
                    child: AppCard(
                      onTap: e == null ? null : () => context.push(Routes.exercise(e.id)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Row(children: [
                          IconBadge(e == null ? Icons.fitness_center : muscleIcon(e.muscle)),
                          const SizedBox(width: Space.m),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(e?.name(lang) ?? p.exerciseId, style: t.titleSmall),
                              Text(
                                '${l.bestLabel}: ${value(p, p.best)} · ${l.lastLabel}: ${value(p, p.last)} (${fmt.dateShort(parseDayKey(p.last.day))})',
                                style: t.bodySmall?.copyWith(color: context.status.textSecondary),
                              ),
                            ]),
                          ),
                          if (p.change != 0)
                            Icon(p.change > 0 ? Icons.trending_up : Icons.trending_down,
                                color: p.change > 0 ? context.status.success : context.status.textSecondary),
                        ]),
                        if (recent.length > 1) ...[
                          const SizedBox(height: Space.m),
                          SizedBox(
                            height: 48,
                            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              for (final x in recent)
                                Expanded(
                                  child: Container(
                                    height: math.max(4, 48 * x.value / top),
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    decoration: BoxDecoration(
                                      color: x == p.best ? AppColors.gold : Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                            ]),
                          ),
                        ],
                      ]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
