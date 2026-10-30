import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/misc.dart';
import '../../data/models/money.dart';
import '../../domain/money.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../auth/onboarding_screen.dart' show currencies;

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

String _amountText(int minor) => (minor / 100).toStringAsFixed(minor % 100 == 0 ? 0 : 2);

Future<T?> _sheet<T>(BuildContext context, Widget child) =>
    showModalBottomSheet<T>(context: context, isScrollControlled: true, builder: (_) => child);

/// New or existing expense. A new one can repeat every month.
Future<void> showExpenseEditor(BuildContext context, WidgetRef ref, {Expense? existing}) =>
    _sheet(context, _EntryEditor(expense: existing, kind: RecurringKind.expense));

/// New or existing money received.
Future<void> showIncomeEditor(BuildContext context, {Income? existing}) =>
    _sheet(context, _EntryEditor(income: existing, kind: RecurringKind.income));

Future<void> showRecurringEditor(BuildContext context, {RecurringItem? existing, required RecurringKind kind}) =>
    _sheet(context, _RecurringEditor(existing: existing, kind: kind));

/// Amount with its currency, shared by the editors below.
class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.controller, required this.currency, required this.onCurrency, this.autofocus = false, this.label});
  final TextEditingController controller;
  final String currency;
  final ValueChanged<String> onCurrency;
  final bool autofocus;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        flex: 2,
        child: AppTextField(
          label: label ?? l.amount,
          controller: controller,
          autofocus: autofocus,
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
            initialValue: currency,
            items: [for (final c in {...currencies, currency}) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) => onCurrency(v ?? currency),
          ),
        ]),
      ),
    ]);
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.form, required this.title, required this.children});
  final GlobalKey<FormState> form;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
          child: Form(
            key: form,
            child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.l), children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: Space.l),
              ...children,
            ]),
          ),
        ),
      );
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.category, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: Space.s),
      Wrap(spacing: Space.s, runSpacing: Space.s, children: [
        for (final c in {...defaultExpenseCategories, value})
          ChoiceChip(label: Text(l.expenseCategory(c)), selected: value == c, onSelected: (_) => onChanged(c)),
      ]),
    ]);
  }
}

/// One expense or one income: amount, what it was, when.
class _EntryEditor extends ConsumerStatefulWidget {
  const _EntryEditor({this.expense, this.income, required this.kind});
  final Expense? expense;
  final Income? income;
  final RecurringKind kind;

  @override
  ConsumerState<_EntryEditor> createState() => _EntryEditorState();
}

class _EntryEditorState extends ConsumerState<_EntryEditor> {
  final _form = GlobalKey<FormState>();
  late final _amount = TextEditingController(
      text: switch ((widget.expense, widget.income)) {
    (final Expense e, _) => _amountText(e.amountMinor),
    (_, final Income i) => _amountText(i.amountMinor),
    _ => '',
  });
  late final _text = TextEditingController(text: widget.expense?.description ?? widget.income?.source ?? '');
  late String _currency = widget.expense?.currency ?? widget.income?.currency ?? ref.read(settingsProvider).currency;
  late String _category = widget.expense?.category ?? 'food';
  late IncomeKind _incomeKind = widget.income?.kind ?? IncomeKind.extra;
  late DateTime _date = widget.expense?.spentAt ?? widget.income?.receivedAt ?? DateTime.now();
  late int _time = _date.hour * 60 + _date.minute;
  bool _repeat = false;
  bool _saving = false;

  bool get _isExpense => widget.kind == RecurringKind.expense;
  bool get _isNew => widget.expense == null && widget.income == null;

  @override
  void dispose() {
    _amount.dispose();
    _text.dispose();
    super.dispose();
  }

  void _save() {
    final l = AppLocalizations.of(context);
    if (_saving || !_form.currentState!.validate()) return;
    final c = ref.read(dataProvider.notifier);
    final at = atMinutes(_date, _time);
    final amount = parseAmountMinor(_amount.text)!;
    try {
      if (_repeat) {
        c.saveRecurring(RecurringItem(
          id: newId(),
          kind: widget.kind,
          amountMinor: amount,
          currency: _currency,
          category: _category,
          title: _text.text.trim(),
          dayOfMonth: _date.day,
          startsOn: dayKey(_date),
          updatedAt: DateTime.now(),
        ));
      } else if (_isExpense) {
        c.addExpense(Expense(
          id: widget.expense?.id ?? newId(),
          amountMinor: amount,
          currency: _currency,
          category: _category,
          spentAt: at,
          description: _text.text.trim(),
          recurringId: widget.expense?.recurringId,
        ));
      } else {
        c.saveIncome(Income(
          id: widget.income?.id ?? newId(),
          amountMinor: amount,
          currency: _currency,
          kind: _incomeKind,
          source: _text.text.trim(),
          receivedAt: at,
          recurringId: widget.income?.recurringId,
          note: widget.income?.note ?? '',
        ));
      }
    } on ArgumentError {
      showSnack(context, l.errFutureIncome);
      return;
    }
    setState(() => _saving = true);
    Navigator.pop(context);
    showSnack(context, l.saved);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context, use24h: ref.read(settingsProvider).use24h);
    final title = _isExpense ? (_isNew ? l.addExpense : l.editExpense) : (_isNew ? l.addIncome : l.editIncome);
    return _SheetFrame(form: _form, title: title, children: [
      _AmountRow(controller: _amount, currency: _currency, autofocus: _isNew, onCurrency: (v) => setState(() => _currency = v)),
      const SizedBox(height: Space.l),
      if (_isExpense)
        _CategoryChips(value: _category, onChanged: (v) => setState(() => _category = v))
      else
        SegmentedButton<IncomeKind>(
          segments: [
            ButtonSegment(value: IncomeKind.extra, label: Text(l.incomeKindExtra)),
            ButtonSegment(value: IncomeKind.pay, label: Text(l.incomeKindPay)),
          ],
          selected: {_incomeKind},
          onSelectionChanged: (v) => setState(() => _incomeKind = v.single),
        ),
      const SizedBox(height: Space.l),
      Row(children: [
        Expanded(child: DatePickerField(label: l.date, value: _date, fmt: fmt, clearable: false, onChanged: (v) => setState(() => _date = v ?? _date))),
        if (!_repeat) ...[
          const SizedBox(width: Space.m),
          Expanded(child: TimePickerField(label: l.time, minutes: _time, fmt: fmt, clearable: false, onChanged: (v) => setState(() => _time = v ?? _time))),
        ],
      ]),
      const SizedBox(height: Space.l),
      AppTextField(
        label: _isExpense ? l.descriptionOptional : l.incomeSource,
        hint: _isExpense ? null : l.incomeSourceHint,
        controller: _text,
        maxLength: 120,
      ),
      if (_isNew) ...[
        const SizedBox(height: Space.s),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.repeatMonthly),
          subtitle: Text(l.repeatMonthlySub),
          value: _repeat,
          onChanged: (v) => setState(() => _repeat = v),
        ),
      ],
      const SizedBox(height: Space.l),
      PrimaryButton(label: l.save, loading: _saving, onPressed: _save),
    ]);
  }
}

/// A monthly expense or income: what changes here applies to months to come.
class _RecurringEditor extends ConsumerStatefulWidget {
  const _RecurringEditor({this.existing, required this.kind});
  final RecurringItem? existing;
  final RecurringKind kind;

  @override
  ConsumerState<_RecurringEditor> createState() => _RecurringEditorState();
}

class _RecurringEditorState extends ConsumerState<_RecurringEditor> {
  final _form = GlobalKey<FormState>();
  late final RecurringItem? _e = widget.existing;
  late final _amount = TextEditingController(text: _e == null ? '' : _amountText(_e.amountMinor));
  late final _title = TextEditingController(text: _e?.title ?? '');
  late String _currency = _e?.currency ?? ref.read(settingsProvider).currency;
  late String _category = _e?.category ?? 'bills';
  late int _day = _e?.dayOfMonth ?? DateTime.now().day;
  late DateTime _start = _e == null ? dateOnly(DateTime.now()) : parseDayKey(_e.startsOn);
  late DateTime? _end = _e?.endsOn == null ? null : parseDayKey(_e!.endsOn!);
  late bool _active = _e?.active ?? true;

  bool get _isExpense => widget.kind == RecurringKind.expense;

  @override
  void dispose() {
    _amount.dispose();
    _title.dispose();
    super.dispose();
  }

  void _save() {
    final l = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) return;
    if (_end != null && _end!.isBefore(_start)) {
      showSnack(context, l.errEndDateBeforeStart);
      return;
    }
    final base = _e ??
        RecurringItem(
          id: newId(),
          kind: widget.kind,
          amountMinor: 1,
          currency: _currency,
          startsOn: dayKey(_start),
          updatedAt: DateTime.now(),
        );
    ref.read(dataProvider.notifier).saveRecurring(base.copyWith(
          amountMinor: parseAmountMinor(_amount.text),
          currency: _currency,
          category: _category,
          title: _title.text.trim(),
          dayOfMonth: _day,
          startsOn: dayKey(_start),
          endsOn: () => _end == null ? null : dayKey(_end!),
          active: _active,
        ));
    Navigator.pop(context);
    showSnack(context, l.saved);
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    if (await confirmDialog(context, title: l.deleteMonthlyTitle, message: l.deleteMonthlyBody, confirmLabel: l.delete)) {
      ref.read(dataProvider.notifier).deleteRecurring(_e!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context, use24h: ref.read(settingsProvider).use24h);
    return _SheetFrame(form: _form, title: _isExpense ? l.monthlyExpenses : l.monthlyIncome, children: [
      if (_e != null) ...[
        Text(l.monthlyEditNote, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: Space.l),
      ],
      _AmountRow(controller: _amount, currency: _currency, autofocus: _e == null, onCurrency: (v) => setState(() => _currency = v)),
      const SizedBox(height: Space.l),
      if (_isExpense) ...[
        _CategoryChips(value: _category, onChanged: (v) => setState(() => _category = v)),
        const SizedBox(height: Space.l),
      ],
      AppTextField(
        label: _isExpense ? l.descriptionOptional : l.incomeSource,
        hint: _isExpense ? null : l.incomeSourceHint,
        controller: _title,
        maxLength: 120,
      ),
      const SizedBox(height: Space.l),
      DropdownButtonFormField<int>(
        isExpanded: true,
        initialValue: _day,
        decoration: InputDecoration(labelText: l.dayOfMonth),
        items: [for (var d = 1; d <= 31; d++) DropdownMenuItem(value: d, child: Text(fmt.number(d)))],
        onChanged: (v) => setState(() => _day = v ?? _day),
      ),
      const SizedBox(height: Space.l),
      Row(children: [
        Expanded(child: DatePickerField(label: l.effectiveFrom, value: _start, fmt: fmt, clearable: false, onChanged: (v) => setState(() => _start = v ?? _start))),
        const SizedBox(width: Space.m),
        Expanded(child: DatePickerField(label: l.endDateOptional, value: _end, fmt: fmt, onChanged: (v) => setState(() => _end = v))),
      ]),
      if (_e != null)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.recurringActive),
          value: _active,
          onChanged: (v) => setState(() => _active = v),
        ),
      const SizedBox(height: Space.l),
      PrimaryButton(label: l.save, onPressed: _save),
      if (_e != null) ...[
        const SizedBox(height: Space.s),
        TextButton.icon(
          onPressed: _delete,
          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
          label: Text(l.delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ],
    ]);
  }
}

/// Sets a new salary from a date on; the months before it keep theirs.
Future<void> showSalaryDialog(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final r = await showDialog<_SalaryInput>(context: context, builder: (_) => const _SalaryDialog());
  if (r == null) return;
  ref.read(dataProvider.notifier).setSalary(amountMinor: r.amount, currency: r.currency, from: r.from, payDay: r.payDay, note: r.note);
  if (context.mounted) showSnack(context, l.saved);
}

typedef _SalaryInput = ({int amount, String currency, int payDay, DateTime from, String note});

class _SalaryDialog extends ConsumerStatefulWidget {
  const _SalaryDialog();

  @override
  ConsumerState<_SalaryDialog> createState() => _SalaryDialogState();
}

class _SalaryDialogState extends ConsumerState<_SalaryDialog> {
  final _key = GlobalKey<FormState>();
  late final SalaryRate? _cur = currentSalary(ref.read(dataProvider), DateTime.now());
  late final _amount = TextEditingController(text: _cur == null ? '' : _amountText(_cur.amountMinor));
  final _note = TextEditingController();
  late String _currency = _cur?.currency ?? ref.read(settingsProvider).currency;
  late int _payDay = _cur?.payDay ?? 27;
  // The first salary counts from the start of this month; a change from today.
  late DateTime _from = ref.read(dataProvider).salaryRates.isEmpty ? DateTime(DateTime.now().year, DateTime.now().month) : dateOnly(DateTime.now());

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context, use24h: ref.read(settingsProvider).use24h);
    return AlertDialog(
      title: Text(_cur == null ? l.setSalary : l.changeSalary),
      content: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _AmountRow(controller: _amount, currency: _currency, label: l.salaryLabel, autofocus: true, onCurrency: (v) => setState(() => _currency = v)),
            const SizedBox(height: Space.m),
            DropdownButtonFormField<int>(
              isExpanded: true,
              initialValue: _payDay,
              decoration: InputDecoration(labelText: l.payDay),
              items: [for (var x = 1; x <= 31; x++) DropdownMenuItem(value: x, child: Text(fmt.number(x)))],
              onChanged: (v) => setState(() => _payDay = v ?? _payDay),
            ),
            const SizedBox(height: Space.m),
            DatePickerField(label: l.effectiveFrom, value: _from, fmt: fmt, clearable: false, onChanged: (v) => setState(() => _from = v ?? _from)),
            const SizedBox(height: Space.s),
            Text(l.salaryChangeNote, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: Space.m),
            AppTextField(label: l.notesOptional, controller: _note, maxLength: 200),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            if (!_key.currentState!.validate()) return;
            Navigator.pop<_SalaryInput>(context,
                (amount: parseAmountMinor(_amount.text)!, currency: _currency, payDay: _payDay, from: _from, note: _note.text));
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}

/// Fixed salary → variable income from a chosen date.
Future<void> showSwitchToVariable(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final fmt = Fmt.of(context, use24h: ref.read(settingsProvider).use24h);
  var from = dateOnly(DateTime.now());
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) => AlertDialog(
        title: Text(l.switchToVariableTitle),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.switchToVariableBody),
          const SizedBox(height: Space.m),
          DatePickerField(label: l.effectiveFrom, value: from, fmt: fmt, clearable: false, onChanged: (v) => set(() => from = v ?? from)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.switchLabel)),
        ],
      ),
    ),
  );
  if (ok != true) return;
  try {
    ref.read(dataProvider.notifier).stopSalary(from);
    if (context.mounted) showSnack(context, l.saved);
  } on StateError {
    if (context.mounted) showSnack(context, l.noSalaryYet);
  }
}
