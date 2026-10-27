import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../data/data_controller.dart';
import '../../domain/nutrition/summary.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_surface.dart';
import '../../widgets/motion.dart';

/// Screen 39 — the last seven days, described rather than judged.
class NutritionWeekScreen extends ConsumerWidget {
  const NutritionWeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final now = ref.watch(clockProvider)();
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context);
    final series = nutritionSeries(d, now, 7);
    final w = nutritionWeek(d, now);
    final (p, c, f) = w.split;
    final maxKcal = math.max(1.0, series.fold<double>(0, (a, x) => math.max(a, x.total.kcal)));
    final goal = d.settings.health.kcalGoal;
    final scheme = Theme.of(context).colorScheme;

    final sections = <Widget>[
      HeroSurface(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.lastSevenDays, style: t.labelMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: Space.xs),
          Text(w.daysLogged == 0 ? l.nothingThisWeek : l.avgKcalPerDay(fmt.number(w.average.kcal.round())),
              style: t.headlineSmall?.copyWith(color: Colors.white)),
          const SizedBox(height: Space.xs),
          Text(l.daysLoggedN(w.daysLogged), style: t.bodyMedium?.copyWith(color: Colors.white70)),
        ]),
      ),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.caloriesByDay, style: t.titleSmall),
          const SizedBox(height: Space.m),
          SizedBox(
            height: 140,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (final x in series)
                Expanded(
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 110 * x.total.kcal / maxKcal),
                      duration: Motion.slow,
                      curve: Motion.curve,
                      builder: (_, v, _) => Container(
                        height: math.max(v, x.hasFood ? 3 : 0),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: goal != null && x.total.kcal > goal ? AppColors.gold : scheme.primary.withValues(alpha: x.hasFood ? 0.85 : 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(fmt.weekdayShort(parseDayKey(x.day)), style: t.labelSmall?.copyWith(color: context.status.textSecondary), maxLines: 1),
                  ]),
                ),
            ]),
          ),
        ]),
      ),
      if (w.daysLogged > 0)
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.energySplit, style: t.titleSmall),
            const SizedBox(height: Space.m),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 14,
                child: Row(children: [
                  for (final (v, col) in [(p, const Color(0xFF4F63D2)), (c, AppColors.gold), (f, const Color(0xFFD6567B))])
                    if (v > 0) Expanded(flex: (v * 1000).round(), child: ColoredBox(color: col)),
                ]),
              ),
            ),
            const SizedBox(height: Space.s),
            Wrap(spacing: Space.l, children: [
              Text('${l.protein} ${(p * 100).round()}% · ${l.gramsN(fmt.number(w.average.protein.round()))}', style: t.bodySmall),
              Text('${l.carbs} ${(c * 100).round()}% · ${l.gramsN(fmt.number(w.average.carbs.round()))}', style: t.bodySmall),
              Text('${l.fat} ${(f * 100).round()}% · ${l.gramsN(fmt.number(w.average.fat.round()))}', style: t.bodySmall),
            ]),
          ]),
        ),
      AppCard(
        child: Row(children: [
          const IconBadge(Icons.water_drop_outlined, color: Color(0xFF0F9BA8)),
          const SizedBox(width: Space.m),
          Expanded(child: Text(l.waterAverage(fmt.number(w.waterAverage)), style: t.titleSmall)),
        ]),
      ),
      if (w.top.isNotEmpty)
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.mostLogged, style: t.titleSmall),
            const SizedBox(height: Space.s),
            for (final (name, n) in w.top)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.xs),
                child: Row(children: [
                  Expanded(child: Text(name)),
                  Text(l.timesN(n), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                ]),
              ),
          ]),
        ),
      Text(l.weekReportNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.weekReport)),
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
