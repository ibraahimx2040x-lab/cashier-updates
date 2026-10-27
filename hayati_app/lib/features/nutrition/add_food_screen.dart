import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/nutrition.dart';
import '../../domain/nutrition/foods.dart';
import '../../domain/nutrition/summary.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import 'portion_sheet.dart';

/// Screen 36b — find something to add: recent, saved, or the built-in list.
class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key, required this.day, required this.meal, this.query = ''});
  final String day;
  final MealType meal;
  final String query;

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  late final _search = TextEditingController(text: widget.query);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pick(String name, String portion, Nutrients per, String? ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showPortionSheet(context, this.ref, name: name, portion: portion, per: per, day: widget.day, meal: widget.meal, foodRef: ref);
    if (ok && mounted) {
      showSnack(context, l.foodAdded(name));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context);
    final lang = l.localeName;
    final q = _search.text.trim();
    final qn = q.toLowerCase();
    final builtin = searchBuiltin(q);
    final mine = d.customFoods.where((f) => qn.isEmpty || f.name.toLowerCase().contains(qn)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final recent = q.isEmpty ? recentFoods(d) : const <FoodLog>[];

    Widget tile(String name, String sub, VoidCallback onTap, {Widget? trailing}) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: Space.s),
          title: Text(name),
          subtitle: Text(sub, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
          trailing: trailing ?? const Icon(Icons.add_circle_outline),
          onTap: onTap,
        );

    final groups = <FoodGroup, List<BuiltinFood>>{};
    for (final f in builtin) {
      (groups[f.group] ??= []).add(f);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.addTo(l.mealType(widget.meal)))),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl), children: [
          SearchField(controller: _search, hint: l.searchFoods, onChanged: (_) => setState(() {})),
          const SizedBox(height: Space.m),
          Wrap(spacing: Space.s, runSpacing: Space.s, children: [
            OutlinedButton.icon(
              onPressed: () => context.push(Routes.customFood(day: widget.day, meal: widget.meal.name)),
              icon: const Icon(Icons.edit_note),
              label: Text(l.addMyOwnFood),
            ),
            OutlinedButton.icon(
              onPressed: () => context.pushReplacement(Routes.nutritionScan(day: widget.day, meal: widget.meal.name)),
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l.scanBarcode),
            ),
          ]),
          if (recent.isNotEmpty) ...[
            const SizedBox(height: Space.l),
            SectionHeader(l.recentFoods),
            for (final f in recent)
              tile(f.name, macroLine(l, fmt, f.total.times(1 / f.portions)),
                  () => _pick(f.name, '', f.total.times(1 / f.portions), f.foodRef)),
          ],
          if (mine.isNotEmpty) ...[
            const SizedBox(height: Space.l),
            SectionHeader(l.myFoods),
            for (final f in mine)
              tile(
                f.name,
                '${f.portion.isEmpty ? '' : '${f.portion} · '}${macroLine(l, fmt, f.per)}',
                () => _pick(f.name, f.portion, f.per, f.id),
                trailing: IconButton(
                  tooltip: l.edit,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push(Routes.customFood(id: f.id, day: widget.day, meal: widget.meal.name)),
                ),
              ),
          ],
          for (final g in FoodGroup.values)
            if (groups[g] case final items?) ...[
              const SizedBox(height: Space.l),
              SectionHeader(l.foodGroup(g)),
              for (final f in items)
                tile(f.name(lang), '${f.portion(lang)} · ${macroLine(l, fmt, f.per)}', () => _pick(f.name(lang), f.portion(lang), f.per, f.id)),
            ],
          if (builtin.isEmpty && mine.isEmpty) ...[
            const SizedBox(height: Space.xl),
            EmptyState(
              icon: Icons.search_off,
              title: l.noFoodFound,
              message: l.noFoodFoundBody,
              action: l.addMyOwnFood,
              onAction: () => context.push(Routes.customFood(day: widget.day, meal: widget.meal.name)),
            ),
          ],
          const SizedBox(height: Space.l),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline, size: 18, color: AppColors.goldDeep),
            const SizedBox(width: Space.s),
            Expanded(child: Text(l.builtinNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary))),
          ]),
        ]),
      ),
    );
  }
}
