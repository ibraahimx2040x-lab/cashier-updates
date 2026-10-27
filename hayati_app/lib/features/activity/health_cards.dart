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
import '../../data/models/health.dart';
import '../../domain/sleep.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';

/// Last night's sleep, the week's average and the source it came from.
class SleepCard extends ConsumerWidget {
  const SleepCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final now = ref.watch(clockProvider)();
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final week = sleepSeries(d, now, 7);
    final last = week.lastWhere((s) => s.hasData, orElse: () => week.last);
    final avg = averageSleepMinutes(week);

    return _MetricCard(
      icon: Icons.bedtime_outlined,
      title: l.hkSleep,
      empty: !last.hasData,
      emptyText: l.noSleepYet,
      value: last.hasData ? l.durationText(last.minutes) : null,
      lines: [
        if (last.main case final m?) l.sleepWindow(fmt.time(m.start), fmt.time(m.end)),
        if (last.hasData && last.day != dayKey(now)) fmt.weekdayDate(parseDayKey(last.day)),
        if (avg > 0) l.weekAverage(l.durationText(avg)),
      ],
      source: last.source,
      bars: [for (final s in week) s.minutes.toDouble()],
    );
  }
}

/// Resting heart rate: the latest value and the week's average.
class HeartCard extends ConsumerWidget {
  const HeartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final now = ref.watch(clockProvider)();
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final (latest, avg) = restingHeartSummary(d, now);

    return _MetricCard(
      icon: Icons.favorite_border,
      title: l.restingHeartRate,
      empty: latest == null,
      emptyText: l.noHeartYet,
      value: latest == null ? null : l.bpmN(latest.value.round()),
      lines: [
        if (latest != null) fmt.weekdayDate(latest.measuredAt),
        if (avg != null) l.weekAverage(l.bpmN(avg)),
      ],
      source: latest?.source,
      footnote: latest == null ? null : l.heartNote,
    );
  }
}

/// Workouts a watch or another app recorded.
class DeviceWorkoutsCard extends ConsumerWidget {
  const DeviceWorkoutsCard({super.key, this.limit = 3});
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final list = recentDeviceWorkouts(d, limit: limit);
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.fromYourDevices),
      for (final w in list)
        Padding(
          padding: const EdgeInsets.only(bottom: Space.s),
          child: DeviceWorkoutTile(workout: w, data: d),
        ),
    ]);
  }
}

class DeviceWorkoutTile extends StatelessWidget {
  const DeviceWorkoutTile({super.key, required this.workout, required this.data});
  final DeviceWorkout workout;
  final AppData data;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context, use24h: data.settings.use24h);
    final w = workout;
    return AppCard(
      child: Row(children: [
        const IconBadge(Icons.watch_outlined),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.workoutActivity(w.activity), style: t.titleSmall),
            Text(
              [
                '${fmt.weekdayDate(w.start)} ${fmt.time(w.start)}',
                l.unitMinutes(w.minutes),
                if (w.distanceM != null) l.distanceKm((w.distanceM! / 1000).toStringAsFixed(1)),
                if (w.kcal != null) l.kcalN(fmt.number(w.kcal!)),
              ].join(' · '),
              style: t.bodySmall?.copyWith(color: context.status.textSecondary),
            ),
          ]),
        ),
        const SizedBox(width: Space.s),
        Pill(label: l.activitySource(w.source), color: AppColors.goldDeep),
      ]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.empty,
    required this.emptyText,
    this.value,
    this.lines = const [],
    this.source,
    this.bars,
    this.footnote,
  });
  final IconData icon;
  final String title;
  final bool empty;
  final String emptyText;
  final String? value;
  final List<String> lines;
  final ActivitySource? source;
  final List<double>? bars;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final top = bars == null || bars!.isEmpty ? 0.0 : bars!.reduce((a, b) => a > b ? a : b);
    return AppCard(
      onTap: empty ? () => context.push(Routes.devices) : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconBadge(icon),
          const SizedBox(width: Space.m),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: t.labelMedium?.copyWith(color: context.status.textSecondary)),
              if (empty) ...[
                Text(emptyText, style: t.bodyMedium),
                const SizedBox(height: Space.xs),
                Text(l.connectInDevices, style: t.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
              ] else ...[
                Text(value!, style: t.headlineSmall),
                for (final x in lines) Text(x, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
              ],
            ]),
          ),
          if (source != null) Pill(label: l.activitySource(source!), color: AppColors.goldDeep),
        ]),
        if (!empty && top > 0) ...[
          const SizedBox(height: Space.m),
          SizedBox(
            height: 36,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (final (i, v) in bars!.indexed)
                Expanded(
                  child: Container(
                    height: v <= 0 ? 3 : 36 * v / top,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == bars!.length - 1 ? AppColors.gold : Theme.of(context).colorScheme.primary.withValues(alpha: v <= 0 ? 0.15 : 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ]),
          ),
        ],
        if (footnote != null) ...[
          const SizedBox(height: Space.s),
          Text(footnote!, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
        ],
      ]),
    );
  }
}
