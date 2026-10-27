import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/accountability.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_surface.dart';
import '../../widgets/motion.dart';

/// Screen 22 — commitments: the rules the user agreed to, late tasks that
/// need their answer, and what happened before.
class AccountabilityScreen extends ConsumerWidget {
  const AccountabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final pending = d.accountabilityEvents.where((e) => e.pending).toList();
    final history = d.accountabilityEvents.where((e) => !e.pending).toList()
      ..sort((a, b) => (b.resolvedAt ?? DateTime(0)).compareTo(a.resolvedAt ?? DateTime(0)));

    final sections = <Widget>[
      HeroSurface(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.handshake_outlined, color: AppColors.gold, size: 32),
          const SizedBox(height: Space.m),
          Text(l.accTitle, style: t.headlineSmall?.copyWith(color: Colors.white)),
          const SizedBox(height: Space.s),
          for (final p in [l.accPrinciple1, l.accPrinciple2, l.accPrinciple3, l.accPrinciple4])
            Padding(
              padding: const EdgeInsets.only(bottom: Space.xs),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check, color: Colors.white70, size: 18),
                const SizedBox(width: Space.s),
                Expanded(child: Text(p, style: t.bodyMedium?.copyWith(color: Colors.white70))),
              ]),
            ),
          const SizedBox(height: Space.m),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy),
            onPressed: () => context.push(Routes.accountabilityRule()),
            icon: const Icon(Icons.add),
            label: Text(l.accAddRule),
          ),
        ]),
      ),
      if (pending.isNotEmpty)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionHeader(l.accNeedsAnswer),
          for (final e in pending)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s),
              child: AppCard(
                color: context.status.highlight,
                onTap: () => context.push(Routes.accountabilityEvent(e.id)),
                child: Row(children: [
                  Icon(Icons.hourglass_bottom, color: context.status.warning),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(d.task(e.taskId)?.title ?? l.itemGone, style: t.titleSmall),
                      Text(l.accMissedOn(fmt.day(e.dueDate)), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                    ]),
                  ),
                  const Icon(Icons.chevron_right),
                ]),
              ),
            ),
        ]),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeader(l.accRules),
        if (d.accountabilityRules.isEmpty)
          AppCard(child: Text(l.accNoRules, style: t.bodyMedium))
        else
          for (final r in d.accountabilityRules)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s),
              child: AppCard(
                onTap: () => context.push(Routes.accountabilityRule(ruleId: r.id)),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(d.task(r.taskId)?.title ?? l.itemGone, style: t.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        l.accRuleSummary(r.graceDays, l.consequence(r.consequence, custom: r.customText)),
                        style: t.bodySmall?.copyWith(color: context.status.textSecondary),
                      ),
                      if (d.task(r.taskId)?.dueDate case final due?)
                        Text(l.accDue(fmt.day(due)), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                    ]),
                  ),
                  Switch(
                    value: r.active,
                    onChanged: (v) => ref.read(dataProvider.notifier).saveRule(r.copyWith(active: v)),
                  ),
                ]),
              ),
            ),
      ]),
      if (history.isNotEmpty)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionHeader(l.accHistory),
          for (final e in history.take(10))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(switch (e.outcome) {
                EventOutcome.consequenceAccepted => Icons.handshake_outlined,
                EventOutcome.rescheduled => Icons.event_repeat,
                EventOutcome.dropped => Icons.remove_circle_outline,
                EventOutcome.pending => Icons.hourglass_bottom,
              }, color: scheme.primary),
              title: Text(d.task(e.taskId)?.title ?? l.itemGone),
              subtitle: Text([
                l.delayReason(e.reason!),
                l.eventOutcome(e.outcome),
                if (e.newDueDate != null) l.accNewDue(fmt.day(e.newDueDate!)),
              ].join(' · ')),
            ),
        ]),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.navAccountability)),
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
