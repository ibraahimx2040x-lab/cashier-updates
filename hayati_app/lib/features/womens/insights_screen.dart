import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../domain/womens/cycle.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import 'cycle_screen.dart' show periodColor;
import 'womens_gate.dart';

/// Screen 43 — how cycle length changed over the months, and the symptoms
/// logged most often with the cycle day they usually come on. Descriptive
/// only; a general nudge to see a doctor when cycles vary a lot.
class CycleInsightsScreen extends ConsumerWidget {
  const CycleInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final d = ref.watch(dataProvider);
    if (!womensVisible(d.settings)) return const WomensUnavailable();
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final e = estimateCycle(d);
    final history = cycleHistory(d);
    final recent = history.length > 12 ? history.sublist(history.length - 12) : history;
    final symptoms = symptomStats(d);
    final top = recent.isEmpty ? 1 : recent.map((x) => x.$2).reduce(math.max);

    final children = <Widget>[
      if (e == null || e.lengths.isEmpty)
        AppCard(
          color: context.status.highlight,
          child: Row(children: [
            const IconBadge(Icons.hourglass_empty, color: AppColors.goldDeep),
            const SizedBox(width: Space.m),
            Expanded(child: Text(l.needMoreData, style: t.bodyMedium)),
          ]),
        )
      else
        AppCard(
          child: Wrap(spacing: Space.xl, runSpacing: Space.m, children: [
            _Stat(l.averageCycle, l.daysN(e.cycleLength)),
            _Stat(l.cycleRange, l.daysRange(e.lengths.reduce(math.min), e.lengths.reduce(math.max))),
            _Stat(l.averagePeriod, l.daysN(e.periodLength)),
            _Stat(l.cyclesCounted, '${e.lengths.length}'),
          ]),
        ),
      if (irregular(e))
        AppCard(
          color: context.status.highlight,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const IconBadge(Icons.medical_services_outlined, color: AppColors.goldDeep),
            const SizedBox(width: Space.m),
            Expanded(child: Text(l.irregularNote, style: t.bodyMedium)),
          ]),
        ),
      if (recent.isNotEmpty)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionHeader(l.cycleLengthOverTime),
          AppCard(
            child: Column(children: [
              for (final (start, n) in recent.reversed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Space.xs),
                  child: Row(children: [
                    SizedBox(width: 72, child: Text(fmt.dateShort(parseDayKey(start)), style: t.labelSmall)),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (_, c) => Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(
                            height: 14,
                            width: c.maxWidth * n / top,
                            decoration: BoxDecoration(color: periodColor.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(7)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Space.s),
                    SizedBox(width: 56, child: Text(l.daysN(n), style: t.labelMedium, textAlign: TextAlign.end)),
                  ]),
                ),
            ]),
          ),
        ]),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeader(l.commonSymptoms),
        if (symptoms.isEmpty)
          AppCard(child: Text(l.noSymptomsYet, style: t.bodyMedium))
        else
          AppCard(
            child: Column(children: [
              for (final x in symptoms.take(8))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.symptom(x.symptom)),
                  subtitle: x.typicalDay == null ? null : Text(l.usuallyOnDay(x.typicalDay!)),
                  trailing: Text(l.timesN(x.count), style: t.labelMedium),
                ),
            ]),
          ),
      ]),
      Text(l.cycleDisclaimer, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.cycleInsights)),
      body: HealthLockGate(
        child: ResponsiveContainer(
          maxWidth: 720,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl),
            itemCount: children.length,
            separatorBuilder: (_, _) => const SizedBox(height: Space.l),
            itemBuilder: (_, i) => children[i],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: t.labelSmall?.copyWith(color: context.status.textSecondary)),
      Text(value, style: t.titleMedium),
    ]);
  }
}
