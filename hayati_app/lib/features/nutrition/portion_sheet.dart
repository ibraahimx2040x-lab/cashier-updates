import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/nutrition.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';

/// "520 kcal · P 30 · C 60 · F 18" in the user's language.
String macroLine(AppLocalizations l, Fmt fmt, Nutrients n) => l.macroLine(
      fmt.number(n.kcal.round()),
      fmt.number(n.protein.round()),
      fmt.number(n.carbs.round()),
      fmt.number(n.fat.round()),
    );

/// Choose how much and which meal, then log it. Returns true when logged.
Future<bool> showPortionSheet(
  BuildContext context,
  WidgetRef ref, {
  required String name,
  required String portion,
  required Nutrients per,
  required String day,
  required MealType meal,
  String? foodRef,
}) async {
  final logged = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _PortionSheet(name: name, portion: portion, per: per, day: day, meal: meal, foodRef: foodRef),
  );
  return logged ?? false;
}

class _PortionSheet extends ConsumerStatefulWidget {
  const _PortionSheet({required this.name, required this.portion, required this.per, required this.day, required this.meal, this.foodRef});
  final String name;
  final String portion;
  final Nutrients per;
  final String day;
  final MealType meal;
  final String? foodRef;

  @override
  ConsumerState<_PortionSheet> createState() => _PortionSheetState();
}

class _PortionSheetState extends ConsumerState<_PortionSheet> {
  double _portions = 1;
  late MealType _meal = widget.meal;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context);
    final total = widget.per.times(_portions);
    String amount(double v) => v == v.roundToDouble() ? fmt.number(v.round()) : fmt.number(v);
    return Padding(
      padding: EdgeInsets.fromLTRB(Space.xl, 0, Space.xl, Space.xl + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(widget.name, style: t.titleLarge),
        if (widget.portion.isNotEmpty)
          Text(l.perPortion(widget.portion), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
        const SizedBox(height: Space.l),
        Text(l.howMuch, style: t.titleSmall),
        const SizedBox(height: Space.s),
        Row(children: [
          IconButton.filledTonal(
            tooltip: l.less,
            onPressed: _portions <= 0.5 ? null : () => setState(() => _portions -= 0.5),
            icon: const Icon(Icons.remove),
          ),
          Expanded(
            child: Text(l.portionsN(amount(_portions)), textAlign: TextAlign.center, style: t.headlineSmall),
          ),
          IconButton.filledTonal(
            tooltip: l.more,
            onPressed: _portions >= FoodLog.maxPortions ? null : () => setState(() => _portions += 0.5),
            icon: const Icon(Icons.add),
          ),
        ]),
        const SizedBox(height: Space.m),
        Wrap(spacing: Space.s, runSpacing: Space.s, children: [
          for (final m in MealType.values)
            ChoiceChip(label: Text(l.mealType(m)), selected: _meal == m, onSelected: (_) => setState(() => _meal = m)),
        ]),
        const SizedBox(height: Space.l),
        AppCard(
          color: context.status.highlight,
          child: Row(children: [
            const IconBadge(Icons.local_fire_department_outlined, color: AppColors.goldDeep),
            const SizedBox(width: Space.m),
            Expanded(child: Text(macroLine(l, fmt, total), style: t.titleSmall)),
          ]),
        ),
        const SizedBox(height: Space.xs),
        Text(l.estimateNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
        const SizedBox(height: Space.l),
        PrimaryButton(
          label: l.addToDay,
          onPressed: () {
            ref.read(dataProvider.notifier).logFood(
                  day: widget.day,
                  meal: _meal,
                  name: widget.name,
                  per: widget.per,
                  portions: _portions,
                  foodRef: widget.foodRef,
                );
            Navigator.pop(context, true);
          },
        ),
      ]),
    );
  }
}
