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
import '../../data/models/settings.dart';
import '../../domain/health_report.dart';
import '../../domain/metrics.dart';
import '../../domain/progress_series.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/home_logo.dart';
import 'metric_card.dart';

enum Period { today, thisWeek, thisMonth, custom }

/// Screen 17 — progress and weekly report, computed only from recorded
/// data. Every chart also has its numbers as text.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  Period _p = Period.thisWeek;
  DateTimeRange? _custom;

  (DateTime, DateTime) _range(DateTime now, int weekStart) {
    final w = startOfWeek(now, weekStart);
    final today = dateOnly(now);
    return switch (_p) {
      Period.today => (today, today.add(const Duration(days: 1))),
      Period.thisWeek => (w, w.add(const Duration(days: 7))),
      Period.thisMonth => (DateTime(now.year, now.month), DateTime(now.year, now.month + 1)),
      Period.custom => _custom == null
          ? (w, w.add(const Duration(days: 7)))
          : (dateOnly(_custom!.start), dateOnly(_custom!.end).add(const Duration(days: 1))),
    };
  }

  Future<void> _pickRange(DateTime now) async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: dateOnly(now),
      initialDateRange: _custom ?? DateTimeRange(start: dateOnly(now).subtract(const Duration(days: 29)), end: dateOnly(now)),
    );
    if (r != null) {
      setState(() {
        _custom = r;
        _p = Period.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final now = ref.watch(clockProvider)();
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final (from, to) = _range(now, d.settings.weekStart);
    final r = PeriodReport.build(d, from, to, now);
    final t = Theme.of(context).textTheme;
    final wide = isWide(context);

    final stats = [
      _StatCard(icon: Icons.task_alt, label: l.tasksCompleted, value: '${r.completed}'),
      _StatCard(
        icon: Icons.percent,
        label: l.completionRate,
        value: r.completionRate == null ? '—' : '${(r.completionRate! * 100).round()}%',
        note: l.completionRateDef(r.dueCompleted, r.dueInPeriod),
      ),
      _StatCard(icon: Icons.warning_amber, label: l.overdueTasks, value: '${r.overdue}', note: l.overdueDef),
      _StatCard(
        icon: Icons.repeat,
        label: l.habitAdherence,
        value: r.habitRate == null ? '—' : '${(r.habitRate! * 100).round()}%',
        note: l.habitAdherenceDef(r.habitDone, r.habitDue),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.navProgress), actions: const [HomeLogoButton()]),
      body: ResponsiveContainer(
        child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.xxl), children: [
          SegmentedButton<Period>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: Period.today, label: Text(l.today)),
              ButtonSegment(value: Period.thisWeek, label: Text(l.thisWeek)),
              ButtonSegment(value: Period.thisMonth, label: Text(l.thisMonth)),
              ButtonSegment(value: Period.custom, icon: const Icon(Icons.date_range_outlined), tooltip: l.customRange),
            ],
            selected: {_p},
            onSelectionChanged: (v) => v.first == Period.custom ? _pickRange(now) : setState(() => _p = v.first),
          ),
          const SizedBox(height: Space.s),
          Text(l.periodCovers(fmt.date(from), fmt.date(to.subtract(const Duration(days: 1)))), style: t.bodySmall),
          const SizedBox(height: Space.l),
          if (!r.hasData)
            EmptyState(icon: Icons.insights_outlined, title: l.reportNoData)
          else ...[
            GridView.count(
              crossAxisCount: wide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: Space.m,
              crossAxisSpacing: Space.m,
              childAspectRatio: wide ? 1.3 : 1.05,
              children: stats,
            ),
            const SizedBox(height: Space.xl),
            SectionHeader(l.chartsTitle),
            GridView.count(
              crossAxisCount: wide ? 2 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: Space.m,
              crossAxisSpacing: Space.m,
              childAspectRatio: wide ? 1.9 : 1.75,
              children: [
                for (final m in ProgressMetric.values)
                  if (_shown(d, m)) MetricCard(series: ProgressSeries.build(d, m, from, to, now), fmt: fmt, currency: d.settings.currency),
              ],
            ),
            if (r.goals.isNotEmpty) ...[
              const SizedBox(height: Space.xl),
              SectionHeader(l.goalsProgress),
              for (final (g, p) in r.goals)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.m),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(g.title, style: t.titleSmall),
                    const SizedBox(height: 4),
                    AppProgress(percent: p.percent, label: g.title),
                  ]),
                ),
            ],
            if (r.spending.isNotEmpty) ...[
              const SizedBox(height: Space.xl),
              SectionHeader(l.spending),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (final e in r.spending.entries) Text(fmt.money(e.value, e.key), style: t.titleMedium),
                ]),
              ),
            ],
            if (HealthReport.build(d, from, to, now) case final hr when !hr.isEmpty) ...[
              const SizedBox(height: Space.xl),
              SectionHeader(l.healthThisPeriod),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (hr.goalDays != null) _HealthLine(Icons.directions_walk, l.reportStepGoal(hr.goalDays!, hr.stepDays)),
                  if (hr.sleepAvg != null) _HealthLine(Icons.bedtime_outlined, l.reportSleep(l.durationText(hr.sleepAvg!), hr.sleepNights)),
                  if (hr.foodDays > 0) _HealthLine(Icons.restaurant_outlined, l.reportFood(hr.foodDays, fmt.number(hr.kcalAvg ?? 0))),
                  if (hr.waterAvg != null) _HealthLine(Icons.water_drop_outlined, l.waterAverage(fmt.number(hr.waterAvg!))),
                ]),
              ),
            ],
            if (r.highlights.isNotEmpty) ...[
              const SizedBox(height: Space.xl),
              SectionHeader(l.highlights),
              for (final h in r.highlights)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.emoji_events_outlined, color: context.status.success),
                  title: Text(h.title),
                ),
            ],
            const SizedBox(height: Space.xl),
            AppCard(
              color: context.status.highlight,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.observations, style: t.titleSmall),
                const SizedBox(height: Space.s),
                Text(_observation(l, r)),
                const SizedBox(height: Space.m),
                SecondaryButton(
                  label: l.askAssistantReview,
                  icon: Icons.auto_awesome,
                  expand: false,
                  onPressed: () => context.go('${Routes.assistant}?q=${Uri.encodeComponent(l.aiChipReview)}'),
                ),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  /// Sections the user has turned off stay off the charts.
  bool _shown(AppData d, ProgressMetric m) => switch (m) {
        ProgressMetric.habits => d.settings.has(AppModule.habits),
        ProgressMetric.steps => d.settings.health.has(HealthModule.activity),
        ProgressMetric.workouts => d.workoutPlans.isNotEmpty || d.workoutSessions.isNotEmpty || d.deviceWorkouts.isNotEmpty,
        ProgressMetric.lessons => d.learningPath != null,
        ProgressMetric.spending || ProgressMetric.income => d.settings.has(AppModule.expenses),
        ProgressMetric.tasks => true,
      };

  /// Descriptive only — never causal claims.
  String _observation(AppLocalizations l, PeriodReport r) {
    final rate = r.completionRate;
    if (rate == null) return l.obsNoDeadlines(r.completed);
    if (rate >= 0.8) return l.obsMost;
    if (rate >= 0.5) return l.obsHalf;
    return l.obsFew;
  }
}

class _HealthLine extends StatelessWidget {
  const _HealthLine(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.xs),
        child: Row(children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: Space.m),
          Expanded(child: Text(text)),
        ]),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, this.note});
  final IconData icon;
  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Theme.of(context).colorScheme.secondary),
        const Spacer(),
        Text(value, style: t.displaySmall?.copyWith(fontSize: 28)),
        Text(label, style: t.labelMedium),
        if (note != null)
          Text(note!, style: t.bodySmall?.copyWith(color: context.status.textSecondary, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}
