import 'package:uuid/uuid.dart';

import '../core/utils/dates.dart';
import '../data/app_data.dart';
import '../data/models/misc.dart';
import '../data/models/money.dart';

/// Income, expenses and what is left, per currency. Amounts in different
/// currencies are never added together.

DateTime _monthStart(DateTime d) => DateTime(d.year, d.month);

/// [day] in [month], or the month's last day when it is shorter.
DateTime dueIn(DateTime month, int day) {
  final last = DateTime(month.year, month.month + 1, 0).day;
  return DateTime(month.year, month.month, day.clamp(1, last));
}

List<SalaryRate> _byDate(Iterable<SalaryRate> rates) => [...rates]..sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom));

/// The rate in force on [day], or null before the first one.
SalaryRate? rateOn(AppData d, DateTime day) {
  final key = dayKey(day);
  SalaryRate? out;
  for (final r in _byDate(d.salaryRates)) {
    if (r.effectiveFrom.compareTo(key) > 0) break;
    out = r;
  }
  return out;
}

/// The salary in force now, or null if income is variable (no rate, or the
/// last one stopped the salary).
SalaryRate? currentSalary(AppData d, DateTime now) {
  final r = rateOn(d, now);
  return r == null || r.isStop ? null : r;
}

/// Newest first, for the history list.
List<SalaryRate> salaryHistory(AppData d) => _byDate(d.salaryRates).reversed.toList();

/// One fixed-salary payment. [received] is false for a pay day still ahead.
typedef SalaryPay = ({DateTime on, int amountMinor, String currency, bool received});

/// Fixed-salary payments with a pay day in [from, toExclusive). Each month is
/// paid at the rate in force on its own pay day, so a raise never changes the
/// months before it.
List<SalaryPay> salaryPays(AppData d, DateTime from, DateTime toExclusive, DateTime now) {
  if (d.salaryRates.isEmpty) return const [];
  final today = dateOnly(now);
  final out = <SalaryPay>[];
  for (var m = _monthStart(from); m.isBefore(toExclusive); m = DateTime(m.year, m.month + 1)) {
    // One payment a month: the pay day of the latest rate started by the
    // month's end, at the amount in force on that day.
    final dayRate = rateOn(d, DateTime(m.year, m.month + 1, 0));
    if (dayRate == null) continue;
    final on = dueIn(m, dayRate.payDay);
    if (on.isBefore(from) || !on.isBefore(toExclusive)) continue;
    final r = rateOn(d, on);
    if (r == null || r.isStop) continue;
    out.add((on: on, amountMinor: r.amountMinor, currency: r.currency, received: !on.isAfter(today)));
  }
  return out;
}

bool _inRange(DateTime t, DateTime from, DateTime toExclusive) => !t.isBefore(from) && t.isBefore(toExclusive);

Map<String, int> _sum(Iterable<(String, int)> xs) {
  final out = <String, int>{};
  for (final (c, a) in xs) {
    out[c] = (out[c] ?? 0) + a;
  }
  return out;
}

class MoneySummary {
  const MoneySummary({
    required this.from,
    required this.toExclusive,
    required this.salary,
    required this.otherIncome,
    required this.expenses,
    required this.upcomingSalary,
  });

  final DateTime from;
  final DateTime toExclusive;

  /// Fixed salary already paid in the period.
  final Map<String, int> salary;

  /// Variable pay and extra income received in the period.
  final Map<String, int> otherIncome;
  final Map<String, int> expenses;

  /// Fixed salary due later in the period (not counted as income yet).
  final Map<String, int> upcomingSalary;

  Map<String, int> get income => _sum([
        for (final e in salary.entries) (e.key, e.value),
        for (final e in otherIncome.entries) (e.key, e.value),
      ]);

  Set<String> get currencies => {...income.keys, ...expenses.keys};

  /// Remaining = income − expenses, per currency. Can be negative.
  int remaining(String currency) => (income[currency] ?? 0) - (expenses[currency] ?? 0);

  bool get isEmpty => currencies.isEmpty && upcomingSalary.isEmpty;

  static MoneySummary build(AppData d, DateTime from, DateTime toExclusive, DateTime now, {String? category}) {
    final pays = salaryPays(d, from, toExclusive, now);
    return MoneySummary(
      from: from,
      toExclusive: toExclusive,
      salary: _sum([for (final p in pays.where((p) => p.received)) (p.currency, p.amountMinor)]),
      upcomingSalary: _sum([for (final p in pays.where((p) => !p.received)) (p.currency, p.amountMinor)]),
      otherIncome: _sum([
        for (final i in d.incomes.where((i) => _inRange(i.receivedAt, from, toExclusive))) (i.currency, i.amountMinor),
      ]),
      expenses: _sum([
        for (final e in d.expenses.where((e) => _inRange(e.spentAt, from, toExclusive) && (category == null || e.category == category)))
          (e.currency, e.amountMinor),
      ]),
    );
  }

  static MoneySummary month(AppData d, DateTime month, DateTime now) =>
      build(d, _monthStart(month), DateTime(month.year, month.month + 1), now);
}

/// The [count] months up to and including [month], oldest first.
List<MoneySummary> monthHistory(AppData d, DateTime month, DateTime now, {int count = 6}) => [
      for (var i = count - 1; i >= 0; i--) MoneySummary.month(d, DateTime(month.year, month.month - i), now),
    ];

/// Percent change from [prev] to [cur], or null when there is nothing to
/// compare with (so no "+∞%" is ever shown).
int? percentChange(int cur, int? prev) {
  if (prev == null || prev == 0) return null;
  return ((cur - prev) * 100 / prev).round();
}

/// Expenses spent in [from, toExclusive), optionally in one category, newest
/// first.
List<Expense> expensesIn(AppData d, DateTime from, DateTime toExclusive, {String? category}) => d.expenses
    .where((e) => _inRange(e.spentAt, from, toExclusive) && (category == null || e.category == category))
    .toList()
  ..sort((a, b) => b.spentAt.compareTo(a.spentAt));

List<Income> incomesIn(AppData d, DateTime from, DateTime toExclusive) =>
    d.incomes.where((i) => _inRange(i.receivedAt, from, toExclusive)).toList()..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

/// Totals per category for [expenses], each per currency, largest first.
List<(String, Map<String, int>)> byCategory(Iterable<Expense> expenses) {
  final out = <String, Map<String, int>>{};
  for (final e in expenses) {
    final m = out.putIfAbsent(e.category, () => {});
    m[e.currency] = (m[e.currency] ?? 0) + e.amountMinor;
  }
  int total(Map<String, int> m) => m.values.fold(0, (s, v) => s + v);
  return [for (final e in out.entries) (e.key, e.value)]..sort((a, b) => total(b.$2).compareTo(total(a.$2)));
}

/// Records made by monthly items, and the items with their progress saved.
typedef RecurringRun = ({List<Expense> expenses, List<Income> incomes, List<RecurringItem> items});

/// Makes the record for every month an item has fallen due in, up to today.
/// Ids are derived from the item and month, so running twice (or on two
/// devices) makes the same records once.
RecurringRun runRecurring(AppData d, DateTime now) {
  final today = dateOnly(now);
  final expenses = <Expense>[];
  final incomes = <Income>[];
  final items = <RecurringItem>[];
  for (final it in d.recurring) {
    if (!it.active) continue;
    final start = parseDayKey(it.startsOn);
    final end = it.endsOn == null ? null : parseDayKey(it.endsOn!);
    var m = it.generatedThrough == null
        ? _monthStart(start)
        : (() {
            final g = parseDayKey('${it.generatedThrough}-01');
            return DateTime(g.year, g.month + 1);
          })();
    String? through = it.generatedThrough;
    for (; !m.isAfter(today); m = DateTime(m.year, m.month + 1)) {
      final due = dueIn(m, it.dayOfMonth);
      if (due.isAfter(today)) break;
      through = monthKey(m);
      if (due.isBefore(start) || (end != null && due.isAfter(end))) continue;
      final id = const Uuid().v5(Namespace.url.value, 'hayati:recurring:${it.id}:${monthKey(m)}');
      final at = DateTime(due.year, due.month, due.day, 9);
      if (it.kind == RecurringKind.expense) {
        if (d.expenses.any((e) => e.id == id)) continue;
        expenses.add(Expense(
          id: id,
          amountMinor: it.amountMinor,
          currency: it.currency,
          category: it.category,
          spentAt: at,
          description: it.title,
          recurringId: it.id,
        ));
      } else {
        if (d.incomes.any((e) => e.id == id)) continue;
        incomes.add(Income(id: id, amountMinor: it.amountMinor, currency: it.currency, source: it.title, receivedAt: at, recurringId: it.id));
      }
    }
    if (through != it.generatedThrough) items.add(it.copyWith(generatedThrough: () => through));
  }
  return (expenses: expenses, incomes: incomes, items: items);
}
