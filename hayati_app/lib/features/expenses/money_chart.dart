import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../domain/money.dart';
import '../../l10n/app_localizations.dart';

/// Income and expenses side by side for each month, in one currency.
class MoneyBars extends StatelessWidget {
  const MoneyBars({super.key, required this.months, required this.currency, required this.fmt});
  final List<MoneySummary> months;
  final String currency;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final top = months.fold<int>(1, (a, s) => math.max(a, math.max(s.income[currency] ?? 0, s.expenses[currency] ?? 0)));
    Widget legend(Color c, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Text(label, style: t.labelSmall),
        ]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Semantics(
        label: [
          for (final s in months)
            '${fmt.monthYear(s.from)}: ${l.moneyTabIncome} ${fmt.money(s.income[currency] ?? 0, currency)}، '
                '${l.moneyTabExpenses} ${fmt.money(s.expenses[currency] ?? 0, currency)}',
        ].join('. '),
        child: ExcludeSemantics(
          child: SizedBox(
            height: 150,
            child: LayoutBuilder(builder: (context, c) {
              final h = c.maxHeight - 20;
              Widget bar(int v, Color color) => Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: h * v / top),
                      duration: Motion.slow,
                      curve: Motion.curve,
                      builder: (_, x, _) => Container(
                        height: math.max(x, v > 0 ? 3 : 0),
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  );
              return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                for (final s in months)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          bar(s.income[currency] ?? 0, AppColors.gold),
                          bar(s.expenses[currency] ?? 0, scheme.primary),
                        ]),
                        SizedBox(
                          height: 20,
                          child: Text(fmt.monthShort(s.from),
                              style: t.labelSmall?.copyWith(color: context.status.textSecondary), maxLines: 1, overflow: TextOverflow.clip),
                        ),
                      ]),
                    ),
                  ),
              ]);
            }),
          ),
        ),
      ),
      const SizedBox(height: Space.s),
      Wrap(spacing: Space.l, runSpacing: Space.xs, children: [
        legend(AppColors.gold, l.moneyTabIncome),
        legend(scheme.primary, l.moneyTabExpenses),
        Text(l.chartCurrencyNote(currency), style: t.labelSmall?.copyWith(color: context.status.textSecondary)),
      ]),
    ]);
  }
}
