import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/data_controller.dart';
import '../../data/models/nutrition.dart';
import '../../l10n/app_localizations.dart';
import '../../services/barcode_lookup.dart';
import '../../widgets/common.dart';
import 'portion_sheet.dart';

/// Screen 37 — a food of the user's own: typed in, or a scanned product to
/// check before saving. Saving can also log it straight away.
class CustomFoodScreen extends ConsumerStatefulWidget {
  const CustomFoodScreen({super.key, this.foodId, this.barcode, this.product, required this.day, required this.meal});
  final String? foodId;
  final String? barcode;
  final ProductInfo? product;
  final String day;
  final MealType meal;

  @override
  ConsumerState<CustomFoodScreen> createState() => _CustomFoodScreenState();
}

class _CustomFoodScreenState extends ConsumerState<CustomFoodScreen> {
  final _form = GlobalKey<FormState>();
  late final CustomFood? _existing = ref.read(dataProvider).customFood(widget.foodId);
  late final _name = TextEditingController(text: _existing?.name ?? widget.product?.name ?? '');
  late final _portion = TextEditingController(text: _existing?.portion ?? widget.product?.portion ?? '');
  late final _grams = TextEditingController(text: _num(_existing?.grams ?? widget.product?.grams));
  late final _kcal = TextEditingController(text: _num(_existing?.per.kcal ?? widget.product?.per.kcal));
  late final _protein = TextEditingController(text: _num(_existing?.per.protein ?? widget.product?.per.protein));
  late final _carbs = TextEditingController(text: _num(_existing?.per.carbs ?? widget.product?.per.carbs));
  late final _fat = TextEditingController(text: _num(_existing?.per.fat ?? widget.product?.per.fat));

  static String _num(double? v) => v == null ? '' : (v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1));

  @override
  void dispose() {
    for (final c in [_name, _portion, _grams, _kcal, _protein, _carbs, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  double _v(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;

  Future<void> _save({required bool log}) async {
    if (!_form.currentState!.validate()) return;
    final l = AppLocalizations.of(context);
    final food = ref.read(dataProvider.notifier).saveCustomFood(CustomFood(
          id: _existing?.id ?? newId(),
          name: _name.text.trim(),
          portion: _portion.text.trim(),
          grams: _grams.text.trim().isEmpty ? null : _v(_grams),
          per: Nutrients(kcal: _v(_kcal), protein: _v(_protein), carbs: _v(_carbs), fat: _v(_fat)),
          barcode: _existing?.barcode ?? widget.barcode,
          createdAt: _existing?.createdAt ?? ref.read(clockProvider)(),
        ));
    if (!log) {
      showSnack(context, l.foodSaved);
      context.pop();
      return;
    }
    final ok = await showPortionSheet(context, ref,
        name: food.name, portion: food.portion, per: food.per, day: widget.day, meal: widget.meal, foodRef: food.id);
    if (ok && mounted) {
      showSnack(context, l.foodAdded(food.name));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final numberInput = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')), LengthLimitingTextInputFormatter(7)];
    String? range(String? v, double max, {bool required = false}) {
      final s = (v ?? '').trim();
      if (s.isEmpty) return required ? l.errRequired : null;
      final n = double.tryParse(s.replaceAll(',', '.'));
      return n == null || n < 0 || n > max ? l.errRange(max.round()) : null;
    }

    Widget field(TextEditingController c, String label, double max, {bool required = false}) => TextFormField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: numberInput,
          decoration: InputDecoration(labelText: label),
          validator: (v) => range(v, max, required: required),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? l.addMyOwnFood : l.editFood),
        actions: [
          if (_existing != null)
            IconButton(
              tooltip: l.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (await confirmDialog(context, title: l.deleteFood, message: l.deleteFoodBody, confirmLabel: l.delete) && context.mounted) {
                  ref.read(dataProvider.notifier).deleteCustomFood(_existing.id);
                  context.pop();
                }
              },
            ),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 640,
        child: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [
            if (widget.product != null) ...[
              AppCard(
                color: context.status.highlight,
                child: Row(children: [
                  const IconBadge(Icons.qr_code_2),
                  const SizedBox(width: Space.m),
                  Expanded(child: Text(l.productFound, style: t.bodyMedium)),
                ]),
              ),
              const SizedBox(height: Space.l),
            ],
            TextFormField(
              controller: _name,
              maxLength: 120,
              decoration: InputDecoration(labelText: l.foodName),
              validator: (v) => (v ?? '').trim().isEmpty ? l.errRequired : null,
            ),
            const SizedBox(height: Space.s),
            Row(children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _portion,
                  maxLength: 60,
                  decoration: InputDecoration(labelText: l.portionName, hintText: l.portionHint),
                ),
              ),
              const SizedBox(width: Space.m),
              Expanded(flex: 2, child: field(_grams, l.gramsOptional, 5000)),
            ]),
            const SizedBox(height: Space.m),
            Text(l.perOnePortion, style: t.titleSmall),
            const SizedBox(height: Space.s),
            field(_kcal, l.calories, Nutrients.maxKcal, required: true),
            const SizedBox(height: Space.m),
            Row(children: [
              Expanded(child: field(_protein, l.proteinG, Nutrients.maxGrams)),
              const SizedBox(width: Space.s),
              Expanded(child: field(_carbs, l.carbsG, Nutrients.maxGrams)),
              const SizedBox(width: Space.s),
              Expanded(child: field(_fat, l.fatG, Nutrients.maxGrams)),
            ]),
            if ((_existing?.barcode ?? widget.barcode) case final code?) ...[
              const SizedBox(height: Space.m),
              Text(l.barcodeN(code), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
            ],
            const SizedBox(height: Space.xl),
            PrimaryButton(label: l.saveAndAdd, onPressed: () => _save(log: true)),
            const SizedBox(height: Space.s),
            SecondaryButton(label: l.saveOnly, onPressed: () => _save(log: false)),
          ]),
        ),
      ),
    );
  }
}
