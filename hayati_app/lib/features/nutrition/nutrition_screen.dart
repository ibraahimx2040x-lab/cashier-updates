import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/nutrition.dart';
import '../../domain/nutrition/summary.dart';
import '../../l10n/app_localizations.dart';
import '../../services/food_recognizer.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_surface.dart';
import '../../widgets/motion.dart';
import 'portion_sheet.dart';

/// Screen 36 — a day's food and water: totals, meals, and ways to add.
class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  /// Days back from today (0 = today); no future days.
  int _ago = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final now = ref.watch(clockProvider)();
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final h = d.settings.health;
    final date = dateOnly(now).subtract(Duration(days: _ago));
    final day = dayKey(date);
    final n = nutritionDay(d, day);
    final camera = ref.watch(foodRecognizerProvider).available;
    final meal = _ago == 0 ? mealFor(now) : MealType.lunch;
    final goal = h.kcalGoal;

    final sections = <Widget>[
      Row(children: [
        IconButton(tooltip: l.previousDay, onPressed: _ago >= 60 ? null : () => setState(() => _ago++), icon: const Icon(Icons.chevron_left)),
        Expanded(
          child: Text(
            _ago == 0 ? l.today : (_ago == 1 ? l.yesterday : fmt.weekdayDate(date)),
            textAlign: TextAlign.center,
            style: t.titleMedium,
          ),
        ),
        IconButton(tooltip: l.nextDay, onPressed: _ago == 0 ? null : () => setState(() => _ago--), icon: const Icon(Icons.chevron_right)),
      ]),
      HeroSurface(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.restaurant, color: AppColors.gold, size: 28),
            const SizedBox(width: Space.s),
            Text(l.caloriesToday, style: t.labelMedium?.copyWith(color: Colors.white70)),
          ]),
          const SizedBox(height: Space.s),
          Text(
            goal == null ? l.kcalN(fmt.number(n.total.kcal.round())) : l.kcalOfGoal(fmt.number(n.total.kcal.round()), fmt.number(goal)),
            style: t.headlineSmall?.copyWith(color: Colors.white),
          ),
          if (goal != null) ...[
            const SizedBox(height: Space.s),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: (n.total.kcal / goal).clamp(0, 1).toDouble()),
                duration: Motion.slow,
                curve: Motion.curve,
                builder: (_, v, _) => LinearProgressIndicator(value: v, minHeight: 6, color: AppColors.gold, backgroundColor: Colors.white24),
              ),
            ),
          ],
          const SizedBox(height: Space.m),
          Row(children: [
            for (final (label, g) in [(l.protein, n.total.protein), (l.carbs, n.total.carbs), (l.fat, n.total.fat)])
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: t.labelSmall?.copyWith(color: Colors.white70)),
                  Text(l.gramsN(fmt.number(g.round())), style: t.titleMedium?.copyWith(color: Colors.white)),
                ]),
              ),
          ]),
        ]),
      ),
      Wrap(spacing: Space.s, runSpacing: Space.s, children: [
        FilledButton.icon(
          onPressed: () => context.push(Routes.nutritionAdd(day: day, meal: meal.name)),
          icon: const Icon(Icons.search),
          label: Text(l.addFood),
        ),
        OutlinedButton.icon(
          onPressed: () => context.push(Routes.nutritionScan(day: day, meal: meal.name)),
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(l.scanBarcode),
        ),
        if (camera)
          OutlinedButton.icon(
            onPressed: () => context.push(Routes.nutritionPhoto(day: day, meal: meal.name)),
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(l.mealPhoto),
          ),
      ]),
      _WaterCard(day: day, ml: n.waterMl, goal: h.waterGoalMl, fmt: fmt),
      for (final m in MealType.values)
        _MealSection(meal: m, items: n.byMeal[m]!, day: day, fmt: fmt),
      AppCard(
        onTap: () => context.push(Routes.nutritionWeek),
        child: Row(children: [
          const IconBadge(Icons.insights_outlined),
          const SizedBox(width: Space.m),
          Expanded(child: Text(l.weekReport, style: t.titleSmall)),
          const Icon(Icons.chevron_right),
        ]),
      ),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline, size: 18, color: context.status.info),
        const SizedBox(width: Space.s),
        Expanded(child: Text(l.nutritionNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary))),
      ]),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.navNutrition), actions: [
        IconButton(tooltip: l.healthSetup, icon: const Icon(Icons.tune), onPressed: () => context.push(Routes.healthSetup)),
      ]),
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

class _WaterCard extends ConsumerWidget {
  const _WaterCard({required this.day, required this.ml, required this.goal, required this.fmt});
  final String day;
  final int ml;
  final int goal;
  final Fmt fmt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = ref.read(dataProvider.notifier);
    return AppCard(
      child: Row(children: [
        const IconBadge(Icons.water_drop_outlined, color: Color(0xFF0F9BA8)),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.waterOfGoal(fmt.number(ml), fmt.number(goal)), style: t.titleSmall),
            const SizedBox(height: Space.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: (ml / goal).clamp(0, 1).toDouble(), minHeight: 6, color: const Color(0xFF0F9BA8)),
            ),
          ]),
        ),
        IconButton(tooltip: l.removeCup, onPressed: ml == 0 ? null : () => c.addWater(day, -250), icon: const Icon(Icons.remove_circle_outline)),
        IconButton.filledTonal(tooltip: l.addCup, onPressed: () => c.addWater(day, 250), icon: const Icon(Icons.add)),
      ]),
    );
  }
}

class _MealSection extends ConsumerWidget {
  const _MealSection({required this.meal, required this.items, required this.day, required this.fmt});
  final MealType meal;
  final List<FoodLog> items;
  final String day;
  final Fmt fmt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final kcal = items.fold(0.0, (a, f) => a + f.total.kcal);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text(l.mealType(meal), style: t.titleMedium)),
        if (items.isNotEmpty) Text(l.kcalN(fmt.number(kcal.round())), style: t.labelMedium?.copyWith(color: context.status.textSecondary)),
        IconButton(
          tooltip: l.addTo(l.mealType(meal)),
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => context.push(Routes.nutritionAdd(day: day, meal: meal.name)),
        ),
      ]),
      if (items.isEmpty)
        Text(l.nothingLogged, style: t.bodySmall?.copyWith(color: context.status.textSecondary))
      else
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            for (final f in items)
              ListTile(
                title: Text(f.name),
                subtitle: Text(
                  '${f.portions == 1 ? '' : '${l.portionsN(fmt.number(f.portions))} · '}${macroLine(l, fmt, f.total)}',
                  style: t.bodySmall,
                ),
                trailing: IconButton(
                  tooltip: l.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    ref.read(dataProvider.notifier).deleteFoodLog(f.id);
                    showSnack(context, l.foodRemoved);
                  },
                ),
              ),
          ]),
        ),
    ]);
  }
}
