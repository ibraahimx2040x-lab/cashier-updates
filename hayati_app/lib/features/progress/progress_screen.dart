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
import '../../domain/health_report.dart';
import '../../domain/metrics.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';

enum Period { thisWeek, lastWeek, thisMonth }

/// Screen 17 — progress and weekly report, computed only from recorded
/// data. Every chart also has its numbers as text.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  Period _p = Period.thisWeek;

  (DateTime, DateTime) _range(DateTime now, int weekStart) {
    final w = startOfWeek(now, weekStart);
    return switch (_p) {
      Period.thisWeek => (w, w.add(const Duration(days: 7))),
      Period.lastWeek => (w.subtract(const Duration(days: 7)), w),
      Period.thisMonth => (DateTime(now.year, now.month), DateTime(now.year, now.month + 1)),
    };
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
      appBar: AppBar(title: Text(l.navProgress)),
      body: ResponsiveContainer(
        child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.xxl), children: [
          SegmentedButton<Period>(
            segments: [
              ButtonSegment(value: Period.thisWeek, label: Text(l.thisWeek)),
              ButtonSegment(value: Period.lastWeek, label: Text(l.lastWeek)),
              ButtonSegment(value: Period.thisMonth, label: Text(l.thisMonth)),
            ],
            selected: {_p},
            onSelectionChanged: (v) => setState(() => _p = v.first),
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
            SectionHeader(l.completedPerDay),
            AppCard(child: _DailyBars(data: d, from: from, to: to, fmt: fmt)),
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

class _DailyBars extends StatelessWidget {
  const _DailyBars({required this.data, required this.from, required this.to, required this.fmt});
  final AppData data;
  final DateTime from;
  final DateTime to;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final days = <DateTime>[];
    for (var d = from; d.isBefore(to); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    final counts = [
      for (final d in days) data.tasks.where((t) => t.isDone && t.completedAt != null && isSameDay(t.completedAt!, d)).length,
    ];
    final max = counts.fold<int>(1, (a, b) => a > b ? a : b);
    final color = Theme.of(context).colorScheme.secondary;
    final labelEvery = days.length > 10 ? 5 : 1;
    return SizedBox(
      height: 150,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (var i = 0; i < days.length; i++)
          Expanded(
            child: Semantics(
              label: '${fmt.date(days[i])}: ${counts[i]}',
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                if (days.length <= 10) Text('${counts[i]}', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 2),
                Container(
                  height: 100 * counts[i] / max + 2,
                  margin: EdgeInsets.symmetric(horizontal: days.length > 10 ? 1 : 6),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(height: 4),
                Text(i % labelEvery == 0 ? (days.length > 10 ? '${days[i].day}' : fmt.weekdayShort(days[i])) : '',
                    style: Theme.of(context).textTheme.labelSmall, maxLines: 1),
              ]),
            ),
          ),
      ]),
    );
  }
}
