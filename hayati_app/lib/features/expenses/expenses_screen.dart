import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/misc.dart';
import '../../data/models/money.dart';
import '../../domain/metrics.dart';
import '../../domain/money.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../auth/onboarding_screen.dart' show currencies;
import 'money_chart.dart';
import 'money_editors.dart';
import '../../widgets/home_logo.dart';

export 'money_editors.dart' show parseAmountMinor, showExpenseEditor;

/// Screen 16 — money: what came in, what went out and what is left, per
/// currency (never added across currencies). Manual only; no bank linking.
class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTimeRange? _range;
  String? _category;

  @override
  void initState() {
    super.initState();
    // A monthly item may have fallen due since the app was opened.
    Future.microtask(() => ref.read(dataProvider.notifier).runRecurringDue());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTab,
      child: Builder(builder: (context) {
        final tabs = DefaultTabController.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(l.navExpenses),
            actions: [
              IconButton(tooltip: l.budget, icon: const Icon(Icons.savings_outlined), onPressed: () => _budgetDialog(context)),
              IconButton(
                tooltip: l.quickAdd,
                icon: const Icon(Icons.add),
                onPressed: () => switch (tabs.index) {
                  1 => showExpenseEditor(context, ref),
                  2 => showIncomeEditor(context),
                  _ => _addChoice(context),
                },
              ), const HomeLogoButton()],
            bottom: TabBar(tabs: [Tab(text: l.moneyTabSummary), Tab(text: l.moneyTabExpenses), Tab(text: l.moneyTabIncome)]),
          ),
          body: TabBarView(children: [_summary(context), _expenses(context), _income(context)]),
        );
      }),
    );
  }

  Future<void> _addChoice(BuildContext context) {
    final l = AppLocalizations.of(context);
    return showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.south_west),
            title: Text(l.addIncome),
            onTap: () {
              Navigator.pop(ctx);
              showIncomeEditor(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.north_east),
            title: Text(l.addExpense),
            onTap: () {
              Navigator.pop(ctx);
              showExpenseEditor(context, ref);
            },
          ),
        ]),
      ),
    );
  }

  Widget _page(List<Widget> children) => ResponsiveContainer(
        maxWidth: 820,
        child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [...children, const SizedBox(height: 80)]),
      );

  Widget _monthSwitcher(BuildContext context, Fmt fmt) {
    final l = AppLocalizations.of(context);
    final next = DateTime(_month.year, _month.month + 1);
    return Row(children: [
      IconButton(tooltip: l.previous, onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)), icon: const Icon(Icons.chevron_left)),
      Expanded(child: Text(fmt.monthYear(_month), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium)),
      IconButton(
        tooltip: l.nextPeriod,
        onPressed: next.isAfter(DateTime.now()) ? null : () => setState(() => _month = next),
        icon: const Icon(Icons.chevron_right),
      ),
    ]);
  }

  /// The user's currency first, then the rest alphabetically.
  List<String> _ordered(Iterable<String> cs, String main) => [...cs]..sort((a, b) => a == main ? -1 : b == main ? 1 : a.compareTo(b));

  // ------------------------------------------------------------------ summary

  Widget _summary(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final t = Theme.of(context).textTheme;
    final now = DateTime.now();
    final s = MoneySummary.month(d, _month, now);
    final prev = MoneySummary.month(d, DateTime(_month.year, _month.month - 1), now);
    final main = d.settings.currency;
    final cs = _ordered(s.currencies, main);
    final chartCurrency = cs.firstOrNull ?? main;
    final history = monthHistory(d, _month, now);
    final withData = history.where((h) => (h.income[chartCurrency] ?? 0) + (h.expenses[chartCurrency] ?? 0) > 0).length;
    final upcoming = salaryPays(d, _month, DateTime(_month.year, _month.month + 1), now).where((p) => !p.received);
    final cats = byCategory(expensesIn(d, _month, DateTime(_month.year, _month.month + 1)));

    String change(int cur, int? before) {
      final p = percentChange(cur, before);
      if (p == null) return l.notEnoughToCompare;
      if (p == 0) return l.changeSame;
      return p > 0 ? l.changeUp(p) : l.changeDown(-p);
    }

    return _page([
      _monthSwitcher(context, fmt),
      const SizedBox(height: Space.m),
      if (s.isEmpty)
        EmptyState(
          icon: Icons.account_balance_wallet_outlined,
          title: l.noMoneyYet,
          message: l.noMoneyYetBody,
          action: l.addIncome,
          onAction: () => DefaultTabController.of(context).animateTo(2),
        ),
      for (final c in cs) ...[
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(l.remaining, style: t.labelMedium)),
              Text(l.remainingFormula, style: t.labelSmall?.copyWith(color: context.status.textSecondary)),
            ]),
            const SizedBox(height: Space.xs),
            Text(
              fmt.money(s.remaining(c), c),
              style: t.displaySmall?.copyWith(fontSize: 30, color: s.remaining(c) < 0 ? Theme.of(context).colorScheme.error : null),
            ),
            if (s.remaining(c) < 0) Text(l.spentMoreThanIncome, style: t.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: Space.m),
            Row(children: [
              Expanded(child: _Stat(icon: Icons.south_west, color: AppColors.gold, label: l.totalIncome, value: fmt.money(s.income[c] ?? 0, c))),
              Expanded(
                child: _Stat(icon: Icons.north_east, color: Theme.of(context).colorScheme.primary, label: l.totalSpent, value: fmt.money(s.expenses[c] ?? 0, c)),
              ),
            ]),
            if ((s.salary[c] ?? 0) > 0 && (s.otherIncome[c] ?? 0) > 0) ...[
              const SizedBox(height: Space.s),
              Text('${l.salaryLabel}: ${fmt.money(s.salary[c]!, c)} · ${l.otherIncome}: ${fmt.money(s.otherIncome[c]!, c)}', style: t.bodySmall),
            ],
          ]),
        ),
        const SizedBox(height: Space.m),
      ],
      for (final p in upcoming) ...[
        AppCard(
          child: Row(children: [
            const IconBadge(Icons.event_available_outlined),
            const SizedBox(width: Space.m),
            Expanded(child: Text(l.upcomingSalary(fmt.money(p.amountMinor, p.currency), fmt.dateShort(p.on)), style: t.bodyMedium)),
          ]),
        ),
        const SizedBox(height: Space.m),
      ],
      if (cs.isNotEmpty) ...[
        SectionHeader(l.compareLastMonth),
        AppCard(
          child: Column(children: [
            for (final c in cs) ...[
              _CompareRow(label: '${l.moneyTabIncome} ($c)', text: change(s.income[c] ?? 0, prev.income[c])),
              _CompareRow(label: '${l.moneyTabExpenses} ($c)', text: change(s.expenses[c] ?? 0, prev.expenses[c])),
            ],
          ]),
        ),
        const SizedBox(height: Space.l),
        SectionHeader(l.sixMonths),
        AppCard(
          child: withData >= 2
              ? MoneyBars(months: history, currency: chartCurrency, fmt: fmt)
              : Text(l.chartNeedsData, style: t.bodyMedium?.copyWith(color: context.status.textSecondary)),
        ),
      ],
      for (final b in d.budgets) ...[
        const SizedBox(height: Space.m),
        Builder(builder: (_) {
          final spent = expensesIn(d, _month, DateTime(_month.year, _month.month + 1), category: b.category)
              .where((e) => e.currency == b.currency)
              .fold<int>(0, (s, e) => s + e.amountMinor);
          final pct = (spent * 100 / b.limitMinor).round();
          return AppCard(
            onTap: () => _budgetDialog(context, existing: b),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(b.category == null ? l.monthlyBudget : '${l.monthlyBudget} · ${l.expenseCategory(b.category!)}', style: t.titleSmall)),
                if (spent > b.limitMinor) Pill(label: l.overBudget, color: Theme.of(context).colorScheme.error, icon: Icons.warning_amber),
              ]),
              const SizedBox(height: Space.s),
              AppProgress(percent: pct > 100 ? 100 : pct),
              const SizedBox(height: 4),
              Text(l.budgetUsed(fmt.money(spent, b.currency), fmt.money(b.limitMinor, b.currency)), style: t.bodySmall),
            ]),
          );
        }),
      ],
      if (cats.isNotEmpty) ...[
        const SizedBox(height: Space.l),
        SectionHeader(l.byCategory),
        AppCard(
          child: Column(children: [
            for (final (cat, amounts) in cats)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.xs),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(l.expenseCategory(cat), style: t.bodyMedium)),
                    Text(_ordered(amounts.keys, main).map((c) => fmt.money(amounts[c]!, c)).join(' + '), style: t.titleSmall),
                  ]),
                  if (amounts[chartCurrency] != null && (s.expenses[chartCurrency] ?? 0) > 0) ...[
                    const SizedBox(height: 4),
                    AppProgress(percent: (amounts[chartCurrency]! * 100 / s.expenses[chartCurrency]!).round()),
                  ],
                ]),
              ),
          ]),
        ),
      ],
    ]);
  }

  // ----------------------------------------------------------------- expenses

  Widget _expenses(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final t = Theme.of(context).textTheme;
    final from = _range?.start ?? _month;
    final to = _range == null ? DateTime(_month.year, _month.month + 1) : dateOnly(_range!.end).add(const Duration(days: 1));
    final all = expensesIn(d, from, to);
    final shown = _category == null ? all : all.where((e) => e.category == _category).toList();
    final totals = totalsByCurrency(shown);
    final monthly = d.recurring.where((r) => r.kind == RecurringKind.expense).toList();
    final c = ref.read(dataProvider.notifier);

    return _page([
      SegmentedButton<bool>(
        segments: [
          ButtonSegment(value: false, label: Text(l.byMonth), icon: const Icon(Icons.calendar_month_outlined)),
          ButtonSegment(value: true, label: Text(l.customRange), icon: const Icon(Icons.date_range_outlined)),
        ],
        selected: {_range != null},
        onSelectionChanged: (v) => v.single ? _pickRange(context) : setState(() => _range = null),
      ),
      const SizedBox(height: Space.m),
      if (_range == null)
        _monthSwitcher(context, fmt)
      else
        Center(
          child: ActionChip(
            avatar: const Icon(Icons.edit_calendar_outlined, size: 18),
            label: Text('${fmt.date(_range!.start)} – ${fmt.date(_range!.end)}'),
            onPressed: () => _pickRange(context),
          ),
        ),
      const SizedBox(height: Space.m),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_category == null ? l.filteredTotal : '${l.filteredTotal} · ${l.expenseCategory(_category!)}', style: t.labelMedium),
          const SizedBox(height: Space.s),
          if (totals.isEmpty) Text(l.noExpensesPeriod, style: t.bodyMedium),
          for (final c in _ordered(totals.keys, d.settings.currency)) Text(fmt.money(totals[c]!, c), style: t.displaySmall?.copyWith(fontSize: 26)),
          if (totals.length > 1) ...[const SizedBox(height: Space.s), Text(l.multiCurrencyNote, style: t.bodySmall)],
        ]),
      ),
      const SizedBox(height: Space.m),
      Wrap(spacing: Space.s, runSpacing: Space.s, children: [
        ChoiceChip(label: Text(l.filterAll), selected: _category == null, onSelected: (_) => setState(() => _category = null)),
        for (final cat in {...defaultExpenseCategories, ...all.map((e) => e.category)})
          ChoiceChip(label: Text(l.expenseCategory(cat)), selected: _category == cat, onSelected: (_) => setState(() => _category = _category == cat ? null : cat)),
      ]),
      const SizedBox(height: Space.xl),
      _MonthlySection(title: l.monthlyExpenses, items: monthly, fmt: fmt, kind: RecurringKind.expense, addLabel: l.addMonthlyExpense),
      const SizedBox(height: Space.l),
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
              onTap: () => showExpenseEditor(context, ref, existing: e),
              onDelete: () async {
                if (await confirmDialog(context, title: l.deleteExpenseTitle, message: l.deleteExpenseBody, confirmLabel: l.delete)) {
                  c.deleteExpense(e.id);
                  if (context.mounted) showSnack(context, l.deleted, actionLabel: l.undo, onAction: () => c.addExpense(e));
                }
              },
            ),
          ),
    ]);
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: dateOnly(now),
      initialDateRange: _range ?? DateTimeRange(start: _month, end: dateOnly(now).isBefore(DateTime(_month.year, _month.month + 1)) ? dateOnly(now) : DateTime(_month.year, _month.month + 1, 0)),
    );
    if (r != null) setState(() => _range = r);
  }

  // ------------------------------------------------------------------- income

  Widget _income(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final t = Theme.of(context).textTheme;
    final now = DateTime.now();
    final cur = currentSalary(d, now);
    final end = DateTime(_month.year, _month.month + 1);
    final pays = salaryPays(d, _month, end, now);
    final received = incomesIn(d, _month, end);
    final monthly = d.recurring.where((r) => r.kind == RecurringKind.income).toList();
    final history = salaryHistory(d);
    final c = ref.read(dataProvider.notifier);

    return _page([
      SectionHeader(l.incomeType),
      SegmentedButton<bool>(
        segments: [
          ButtonSegment(value: true, label: Text(l.incomeFixed), icon: const Icon(Icons.work_outline)),
          ButtonSegment(value: false, label: Text(l.incomeVariable), icon: const Icon(Icons.trending_up)),
        ],
        selected: {cur != null},
        onSelectionChanged: (v) => v.single ? showSalaryDialog(context, ref) : showSwitchToVariable(context, ref),
      ),
      const SizedBox(height: Space.m),
      if (cur != null)
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.currentSalary, style: t.labelMedium),
            const SizedBox(height: Space.xs),
            Text(fmt.money(cur.amountMinor, cur.currency), style: t.displaySmall?.copyWith(fontSize: 28)),
            Text('${l.paidOnDay(cur.payDay)} · ${l.salarySince('', fmt.day(cur.effectiveFrom)).trim()}',
                style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
            const SizedBox(height: Space.m),
            OutlinedButton.icon(onPressed: () => showSalaryDialog(context, ref), icon: const Icon(Icons.edit_outlined), label: Text(l.changeSalary)),
          ]),
        )
      else
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.salaryRates.isEmpty ? l.noSalaryYet : l.incomeVariable, style: t.titleSmall),
            const SizedBox(height: Space.xs),
            Text(l.incomeVariableSub, style: t.bodySmall),
            const SizedBox(height: Space.m),
            Wrap(spacing: Space.s, runSpacing: Space.s, children: [
              FilledButton.icon(onPressed: () => showIncomeEditor(context), icon: const Icon(Icons.add), label: Text(l.addIncome)),
              OutlinedButton(onPressed: () => showSalaryDialog(context, ref), child: Text(l.setSalary)),
            ]),
          ]),
        ),
      const SizedBox(height: Space.l),
      _monthSwitcher(context, fmt),
      SectionHeader(l.receivedThisMonth),
      if (pays.isEmpty && received.isEmpty) Text(l.noIncomeMonth, style: t.bodyMedium?.copyWith(color: context.status.textSecondary)),
      for (final p in pays)
        Padding(
          padding: const EdgeInsets.only(bottom: Space.s),
          child: _IncomeTile(
            icon: Icons.work_outline,
            title: l.salaryLabel,
            subtitle: fmt.dateShort(p.on),
            amount: fmt.money(p.amountMinor, p.currency),
            pill: p.received ? null : l.expectedLabel,
          ),
        ),
      for (final i in received)
        Padding(
          padding: const EdgeInsets.only(bottom: Space.s),
          child: _IncomeTile(
            icon: i.kind == IncomeKind.pay ? Icons.payments_outlined : Icons.add_card_outlined,
            title: i.source.isEmpty ? (i.kind == IncomeKind.pay ? l.incomeKindPay : l.incomeKindExtra) : i.source,
            subtitle: [fmt.dateShort(i.receivedAt), if (i.recurringId != null) l.monthlyLabel].join(' · '),
            amount: fmt.money(i.amountMinor, i.currency),
            onTap: () => showIncomeEditor(context, existing: i),
            onDelete: () async {
              if (await confirmDialog(context, title: l.deleteIncomeTitle, message: l.deleteIncomeBody, confirmLabel: l.delete)) {
                c.deleteIncome(i.id);
                if (context.mounted) showSnack(context, l.deleted, actionLabel: l.undo, onAction: () => c.saveIncome(i));
              }
            },
          ),
        ),
      const SizedBox(height: Space.l),
      _MonthlySection(title: l.monthlyIncome, items: monthly, fmt: fmt, kind: RecurringKind.income, addLabel: l.addMonthlyIncome),
      if (history.isNotEmpty) ...[
        const SizedBox(height: Space.l),
        SectionHeader(l.salaryHistory),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: Space.xs),
          child: Column(children: [
            for (final r in history)
              ListTile(
                leading: Icon(r.isStop ? Icons.trending_up : Icons.work_outline),
                title: Text(r.isStop ? l.salaryStoppedSince(fmt.day(r.effectiveFrom)) : l.salarySince(fmt.money(r.amountMinor, r.currency), fmt.day(r.effectiveFrom))),
                subtitle: r.isStop && r.note.isEmpty ? null : Text([if (!r.isStop) l.paidOnDay(r.payDay), if (r.note.isNotEmpty) r.note].join(' · ')),
                trailing: IconButton(
                  tooltip: l.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (await confirmDialog(context, title: l.deleteSalaryTitle, message: l.deleteSalaryBody, confirmLabel: l.delete)) {
                      c.deleteSalaryRate(r.id);
                    }
                  },
                ),
              ),
          ]),
        ),
      ],
    ]);
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

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.color, required this.label, required this.value});
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: Space.s),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: t.labelSmall?.copyWith(color: context.status.textSecondary)),
          Text(value, style: t.titleSmall),
        ]),
      ),
    ]);
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({required this.label, required this.text});
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.xs),
        child: Row(children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Flexible(child: Text(text, textAlign: TextAlign.end, style: Theme.of(context).textTheme.titleSmall)),
        ]),
      );
}

class _IncomeTile extends StatelessWidget {
  const _IncomeTile({required this.icon, required this.title, required this.subtitle, required this.amount, this.pill, this.onTap, this.onDelete});
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final String? pill;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: Space.l, vertical: Space.s),
      child: Row(children: [
        CircleAvatar(backgroundColor: context.status.highlight, child: Icon(icon, color: AppColors.gold, size: 20)),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: t.titleSmall),
            Text(subtitle, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
          ]),
        ),
        if (pill != null) ...[Pill(label: pill!, color: context.status.warning), const SizedBox(width: Space.s)],
        Text(amount, style: t.titleSmall),
        if (onDelete != null) IconButton(tooltip: l.delete, icon: const Icon(Icons.delete_outline), onPressed: onDelete),
      ]),
    );
  }
}

/// Monthly items of one kind, each opening its editor.
class _MonthlySection extends StatelessWidget {
  const _MonthlySection({required this.title, required this.items, required this.fmt, required this.kind, required this.addLabel});
  final String title;
  final List<RecurringItem> items;
  final Fmt fmt;
  final RecurringKind kind;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(title),
      for (final r in items)
        Padding(
          padding: const EdgeInsets.only(bottom: Space.s),
          child: AppCard(
            onTap: () => showRecurringEditor(context, existing: r, kind: kind),
            padding: const EdgeInsets.symmetric(horizontal: Space.l, vertical: Space.m),
            child: Row(children: [
              Icon(Icons.autorenew, color: r.active ? Theme.of(context).colorScheme.primary : context.status.textSecondary),
              const SizedBox(width: Space.m),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.title.isNotEmpty ? r.title : (kind == RecurringKind.expense ? l.expenseCategory(r.category) : l.monthlyIncome), style: t.titleSmall),
                  Text(l.dayOfMonthLabel(r.dayOfMonth), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                ]),
              ),
              if (!r.active) ...[Pill(label: l.pausedLabel, color: context.status.textSecondary), const SizedBox(width: Space.s)],
              Text(fmt.money(r.amountMinor, r.currency), style: t.titleSmall),
            ]),
          ),
        ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(onPressed: () => showRecurringEditor(context, kind: kind), icon: const Icon(Icons.add), label: Text(addLabel)),
      ),
    ]);
  }
}
