import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../domain/progress_series.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';

/// One section's figure for the period, its change from the period before,
/// and its trend as bars. With too few records it says so instead of
/// drawing a chart that would mislead.
class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.series, required this.fmt, required this.currency});
  final ProgressSeries series;
  final Fmt fmt;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final s = series;
    final (icon, title) = switch (s.metric) {
      ProgressMetric.tasks => (Icons.task_alt, l.metricTasks),
      ProgressMetric.habits => (Icons.repeat, l.metricHabits),
      ProgressMetric.steps => (Icons.directions_walk, l.metricSteps),
      ProgressMetric.workouts => (Icons.fitness_center, l.metricWorkouts),
      ProgressMetric.lessons => (Icons.translate, l.metricLessons),
      ProgressMetric.spending => (Icons.north_east, l.metricSpending),
      ProgressMetric.income => (Icons.south_west, l.metricIncome),
    };
    String value(double? v) => v == null
        ? '—'
        : switch (s.metric) {
            ProgressMetric.habits => '${(v * 100).round()}%',
            ProgressMetric.spending || ProgressMetric.income => fmt.money((v * 100).round(), currency),
            _ => fmt.number(v.round()),
          };
    final ch = s.change;
    // Spending going up is not good news; everything else is.
    final good = ch == null || ch == 0 ? null : (s.metric == ProgressMetric.spending ? ch < 0 : ch > 0);
    final changeText = s.total == null
        ? l.noRecordsPeriod
        : ch == null
            ? l.noPreviousPeriod
            : ch == 0
                ? l.changeSame
                : (ch > 0 ? l.changeUp(ch) : l.changeDown(-ch));

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconBadge(icon),
          const SizedBox(width: Space.m),
          Expanded(child: Text(title, style: t.titleSmall)),
          Text(value(s.total), style: t.titleLarge),
        ]),
        const SizedBox(height: Space.xs),
        Row(children: [
          if (good != null) ...[
            Icon(ch! > 0 ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: good ? context.status.success : context.status.warning),
            const SizedBox(width: 2),
          ],
          Flexible(
            child: Text(
              s.total == null || ch == null ? changeText : '$changeText · ${l.vsPreviousPeriod}',
              style: t.bodySmall?.copyWith(color: good == null ? context.status.textSecondary : (good ? context.status.success : context.status.warning)),
            ),
          ),
        ]),
        const SizedBox(height: Space.m),
        Expanded(
          child: s.enough
              ? _Bars(series: s, value: value, fmt: fmt)
              : Center(child: Text(l.notEnoughForChart, style: t.bodySmall?.copyWith(color: context.status.textSecondary), textAlign: TextAlign.center)),
        ),
        if (s.enough && s.weekly) Text(l.eachBarWeek, style: t.labelSmall?.copyWith(color: context.status.textSecondary)),
      ]),
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars({required this.series, required this.value, required this.fmt});
  final ProgressSeries series;
  final String Function(double?) value;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final b = series.buckets;
    final top = series.metric == ProgressMetric.habits ? 1.0 : math.max(series.max, 1e-9);
    final labelEvery = b.length > 14 ? (b.length / 6).ceil() : (b.length > 8 ? 2 : 1);
    return Semantics(
      label: [for (final x in b) '${fmt.dateShort(x.start)}: ${value(x.value)}'].join('، '),
      child: ExcludeSemantics(
        child: LayoutBuilder(builder: (context, c) {
          final h = c.maxHeight - 16;
          return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (final (i, x) in b.indexed)
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: x.value == null ? 0 : h * (x.value! / top).clamp(0, 1)),
                    duration: Motion.slow,
                    curve: Motion.curve,
                    builder: (_, v, _) => Container(
                      height: x.value == null ? 2 : math.max(v, 3),
                      margin: EdgeInsets.symmetric(horizontal: b.length > 20 ? 1 : 3),
                      decoration: BoxDecoration(
                        color: x.value == null ? scheme.outlineVariant : scheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                    child: i % labelEvery == 0
                        ? Text(series.weekly || b.length > 8 ? '${x.start.day}' : fmt.weekdayShort(x.start),
                            style: t.labelSmall?.copyWith(fontSize: 10, color: context.status.textSecondary), maxLines: 1, overflow: TextOverflow.clip)
                        : null,
                  ),
                ]),
              ),
          ]);
        }),
      ),
    );
  }
}
