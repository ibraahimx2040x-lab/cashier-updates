import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/data_controller.dart';
import '../../domain/assistant/assistant_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';

/// Screen 22 — plans and entitlement. Paid features are never unlocked
/// from a client-side value: in local mode the plan is always Free, and
/// upgrading is disabled until server-verified store billing is live.
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final used = ref.watch(dataProvider.notifier).assistantUsageToday();
    Widget feature(String s, {bool included = true}) => Padding(
          padding: const EdgeInsets.only(bottom: Space.s),
          child: Row(children: [
            Icon(included ? Icons.check : Icons.remove, size: 18, color: included ? context.status.success : context.status.inactive),
            const SizedBox(width: Space.s),
            Expanded(child: Text(s)),
          ]),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l.subscriptionTitle)),
      body: ResponsiveContainer(
        maxWidth: 760,
        child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [
          AppCard(
            color: context.status.highlight,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.currentPlan, style: t.labelMedium),
              Text(l.planFree, style: t.headlineSmall),
              const SizedBox(height: Space.s),
              Text(l.assistantUsage(used, freeAssistantDailyLimit)),
            ]),
          ),
          const SizedBox(height: Space.xl),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.planFree, style: t.titleMedium),
              const SizedBox(height: Space.m),
              feature(l.featCore),
              feature(l.featBasicReports),
              feature(l.featAssistantLimited(freeAssistantDailyLimit)),
            ]),
          ),
          const SizedBox(height: Space.m),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(l.planPro, style: t.titleMedium)),
                Pill(label: l.comingSoon, color: context.status.info),
              ]),
              const SizedBox(height: Space.m),
              feature(l.featCore),
              feature(l.featSmartPlanning),
              feature(l.featMoreAssistant),
              feature(l.featAdvancedReports),
              feature(l.featTemplates),
              const SizedBox(height: Space.m),
              Text(l.pricingNotSet, style: t.bodySmall),
              const SizedBox(height: Space.m),
              PrimaryButton(label: l.upgrade, onPressed: null),
              const SizedBox(height: Space.s),
              SecondaryButton(label: l.restorePurchases, onPressed: null),
            ]),
          ),
          const SizedBox(height: Space.l),
          Text(l.billingNote, style: t.bodySmall),
        ]),
      ),
    );
  }
}
