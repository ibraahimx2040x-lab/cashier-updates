import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/misc.dart';
import '../../domain/metrics.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../auth/onboarding_screen.dart' show currencies;

/// Screen 16 — manual expenses and a simple monthly budget. Amounts are
/// never summed across currencies; there is no bank linking in v1.
class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  String? _category;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final t = Theme.of(context).textTheme;
    final next = DateTime(_month.year, _month.month + 1);
    final prev = DateTime(_month.year, _month.month - 1);
    bool inMonth(Expense e, DateTime m) =>
        !e.spentAt.isBefore(m) && e.spentAt.isBefore(DateTime(m.year, m.month + 1));
    final month = d.expenses.where((e) => inMonth(e, _month)).toList()..sort((a, b) => b.spentAt.compareTo(a.spentAt));
    final totals = totalsByCurrency(month);
    final prevTotals = totalsByCurrency(d.expenses.where((e) => inMonth(e, prev)));
    final shown = _category == null ? month : month.where((e) => e.category == _category).toList();
    final byCat = <String, Map<String, int>>{};
    for (final e in month) {
      final m = byCat.putIfAbsent(e.category, () => {});
      m[e.currency] = (m[e.currency] ?? 0) + e.amountMinor;
    }
    final c = ref.read(dataProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navExpenses),
        actions: [
          IconButton(tooltip: l.budget, icon: const Icon(Icons.savings_outlined), onPressed: () => _budgetDialog(context)),
          IconButton(tooltip: l.addExpense, icon: const Icon(Icons.add), onPressed: () => showExpenseEditor(context, ref)),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 820,
        child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [
          Row(children: [
            IconButton(tooltip: l.previous, onPressed: () => setState(() => _month = prev), icon: const Icon(Icons.chevron_left)),
            Expanded(child: Text(fmt.monthYear(_month), textAlign: TextAlign.center, style: t.titleMedium)),
            IconButton(
              tooltip: l.nextPeriod,
              onPressed: next.isAfter(DateTime.now()) ? null : () => setState(() => _month = next),
              icon: const Icon(Icons.chevron_right),
            ),
          ]),
          const SizedBox(height: Space.m),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.totalSpent, style: t.labelMedium),
              const SizedBox(height: Space.s),
              if (totals.isEmpty) Text(l.noExpensesPeriod, style: t.bodyMedium),
              for (final e in totals.entries) ...[
                Text(fmt.money(e.value, e.key), style: t.displaySmall?.copyWith(fontSize: 28)),
                if (prevTotals[e.key] != null)
                  Text(
                    l.vsLastMonth(fmt.money(prevTotals[e.key]!, e.key)),
                    style: t.bodySmall?.copyWith(color: context.status.textSecondary),
                  ),
              ],
              if (totals.length > 1) ...[
                const SizedBox(height: Space.s),
                Text(l.multiCurrencyNote, style: t.bodySmall),
              ],
            ]),
          ),
          for (final b in d.budgets) ...[
            const SizedBox(height: Space.m),
            Builder(builder: (_) {
              final spent = month
                  .where((e) => e.currency == b.currency && (b.category == null || e.category == b.category))
                  .fold<int>(0, (s, e) => s + e.amountMinor);
              final pct = (spent * 100 / b.limitMinor).round();
              final over = spent > b.limitMinor;
              return AppCard(
                onTap: () => _budgetDialog(context, existing: b),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(b.category == null ? l.monthlyBudget : '${l.monthlyBudget} · ${l.expenseCategory(b.category!)}', style: t.titleSmall)),
                    if (over) Pill(label: l.overBudget, color: Theme.of(context).colorScheme.error, icon: Icons.warning_amber),
                  ]),
                  const SizedBox(height: Space.s),
                  AppProgress(percent: pct > 100 ? 100 : pct),
                  const SizedBox(height: 4),
                  Text(l.budgetUsed(fmt.money(spent, b.currency), fmt.money(b.limitMinor, b.currency)), style: t.bodySmall),
                ]),
              );
            }),
          ],
          if (byCat.isNotEmpty) ...[
            const SizedBox(height: Space.xl),
            SectionHeader(l.byCategory),
            Wrap(spacing: Space.s, runSpacing: Space.s, children: [
              ChoiceChip(label: Text(l.filterAll), selected: _category == null, onSelected: (_) => setState(() => _category = null)),
              for (final e in byCat.entries)
                ChoiceChip(
                  label: Text('${l.expenseCategory(e.key)} · ${e.value.entries.map((x) => fmt.money(x.value, x.key)).join(' + ')}'),
                  selected: _category == e.key,
                  onSelected: (_) => setState(() => _category = e.key),
                ),
            ]),
          ],
          const SizedBox(height: Space.xl),
          SectionHeader(l.expenseList),
          if (shown.isEmpty)
            EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: l.noExpensesPeriod,
              message: l.expensesManualNote,
              action: l.addExpense,
              onAction: () => showExpenseEditor(context, ref),
            )
          else
            for (final e in shown)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.s),
                child: ExpenseCard(
                  expense: e,
                  fmt: fmt,
                  onDelete: () async {
                    if (await confirmDialog(context, title: l.deleteExpenseTitle, message: l.deleteExpenseBody, confirmLabel: l.delete)) {
                      c.deleteExpense(e.id);
                      if (context.mounted) showSnack(context, l.deleted, actionLabel: l.undo, onAction: () => c.addExpense(e));
                    }
                  },
                ),
              ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Future<void> _budgetDialog(BuildContext context, {Budget? existing}) async {
    final l = AppLocalizations.of(context);
    final s = ref.read(settingsProvider);
    final amount = TextEditingController(text: existing == null ? '' : (existing.limitMinor / 100).toStringAsFixed(2));
    var currency = existing?.currency ?? s.currency;
    String? category = existing?.category;
    final key = GlobalKey<FormState>();
    final r = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
            title: Text(l.monthlyBudget),
            content: Form(
              key: key,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l.limit),
                  validator: (v) => (parseAmountMinor(v ?? '') ?? 0) <= 0 ? l.errPositiveAmount : null,
                ),
                const SizedBox(height: Space.m),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: currency,
                  decoration: InputDecoration(labelText: l.currency),
                  items: [for (final c in currencies) DropdownMenuItem(value: c, child: Text(c))],
                  onChanged: (v) => set(() => currency = v ?? currency),
                ),
                const SizedBox(height: Space.m),
                DropdownButtonFormField<String?>(
                  isExpanded: true,
                  initialValue: category,
                  decoration: InputDecoration(labelText: l.categoryOptional),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l.allCategories)),
                    for (final c in defaultExpenseCategories) DropdownMenuItem(value: c, child: Text(l.expenseCategory(c))),
                  ],
                  onChanged: (v) => set(() => category = v),
                ),
              ]),
            ),
            actions: [
              if (existing != null)
                TextButton(onPressed: () => Navigator.pop(ctx, 'delete'), child: Text(l.delete)),
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
              FilledButton(
                onPressed: () {
                  if (key.currentState!.validate()) Navigator.pop(ctx, 'save');
                },
                child: Text(l.save),
              ),
            ],
          )),
    );
    final c = ref.read(dataProvider.notifier);
    if (r == 'save') {
      c.saveBudget(Budget(id: existing?.id ?? newId(), currency: currency, limitMinor: parseAmountMinor(amount.text)!, category: category));
    } else if (r == 'delete' && existing != null) {
      c.deleteBudget(existing.id);
    }
    amount.dispose();
  }
}

/// "12.5" / "12,50" / "١٢٫٥" → 1250. Null if invalid.
int? parseAmountMinor(String raw) {
  var s = raw.trim().replaceAllMapped(RegExp('[٠-٩]'), (m) => '${m[0]!.codeUnitAt(0) - 0x660}');
  s = s.replaceAll('٫', '.').replaceAll(',', '.');
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(s)) return null;
  final parts = s.split('.');
  final whole = int.parse(parts[0]);
  final frac = parts.length > 1 ? int.parse(parts[1].padRight(2, '0')) : 0;
  return whole * 100 + frac;
}

Future<void> showExpenseEditor(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => const _ExpenseEditor());
}

class _ExpenseEditor extends ConsumerStatefulWidget {
  const _ExpenseEditor();

  @override
  ConsumerState<_ExpenseEditor> createState() => _ExpenseEditorState();
}

class _ExpenseEditorState extends ConsumerState<_ExpenseEditor> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _desc = TextEditingController();
  late String _currency = ref.read(settingsProvider).currency;
  String _category = 'food';
  DateTime _date = DateTime.now();
  int _time = DateTime.now().hour * 60 + DateTime.now().minute;
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _save() {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final at = DateTime(_date.year, _date.month, _date.day).add(Duration(minutes: _time));
    ref.read(dataProvider.notifier).addExpense(Expense(
          id: newId(),
          amountMinor: parseAmountMinor(_amount.text)!,
          currency: _currency,
          category: _category,
          spentAt: at,
          description: _desc.text.trim(),
        ));
    Navigator.pop(context);
    showSnack(context, AppLocalizations.of(context).saved);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context, use24h: ref.read(settingsProvider).use24h);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Form(
          key: _form,
          child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.l), children: [
            Text(l.addExpense, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Space.l),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                flex: 2,
                child: AppTextField(
                  label: l.amount,
                  controller: _amount,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final m = parseAmountMinor(v ?? '');
                    return m == null || m <= 0 ? l.errPositiveAmount : null;
                  },
                ),
              ),
              const SizedBox(width: Space.m),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(l.currency, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: Space.s),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _currency,
                    items: [for (final c in currencies) DropdownMenuItem(value: c, child: Text(c))],
                    onChanged: (v) => setState(() => _currency = v ?? _currency),
                  ),
                ]),
              ),
            ]),
            const SizedBox(height: Space.l),
            Text(l.category, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Space.s),
            Wrap(spacing: Space.s, runSpacing: Space.s, children: [
              for (final c in defaultExpenseCategories)
                ChoiceChip(label: Text(l.expenseCategory(c)), selected: _category == c, onSelected: (_) => setState(() => _category = c)),
            ]),
            const SizedBox(height: Space.l),
            Row(children: [
              Expanded(child: DatePickerField(label: l.date, value: _date, fmt: fmt, clearable: false, onChanged: (v) => setState(() => _date = v ?? _date))),
              const SizedBox(width: Space.m),
              Expanded(child: TimePickerField(label: l.time, minutes: _time, fmt: fmt, clearable: false, onChanged: (v) => setState(() => _time = v ?? _time))),
            ]),
            const SizedBox(height: Space.l),
            AppTextField(label: l.descriptionOptional, controller: _desc),
            const SizedBox(height: Space.l),
            PrimaryButton(label: l.save, loading: _saving, onPressed: _save),
          ]),
        ),
      ),
    );
  }
}
