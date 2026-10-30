import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/misc.dart';
import 'package:hayati/data/models/money.dart';
import 'package:hayati/data/remote/rows.dart';
import 'package:hayati/domain/money.dart';

import 'helpers.dart';

DateTime m(int month) => DateTime(2026, month);

void main() {
  final now = fixedNow; // Tuesday 2026-03-10 08:00

  group('salary', () {
    test('a raise counts from its date on; the months before keep the old amount', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      data.setSalary(amountMinor: 500000, currency: 'SAR', from: DateTime(2025, 12, 1), payDay: 27);
      data.setSalary(amountMinor: 600000, currency: 'SAR', from: DateTime(2026, 2, 1), payDay: 27);
      final d = c.read(dataProvider);
      expect(MoneySummary.month(d, m(1), now).salary, {'SAR': 500000});
      expect(MoneySummary.month(d, m(2), now).salary, {'SAR': 600000});
      // March's pay day (27th) is still ahead: shown as expected, not counted.
      final march = MoneySummary.month(d, m(3), now);
      expect(march.salary, isEmpty);
      expect(march.upcomingSalary, {'SAR': 600000});
      expect(currentSalary(d, now)!.amountMinor, 600000);
      expect(salaryHistory(d).map((r) => r.amountMinor), [600000, 500000]);
    });

    test('a change on the same day replaces it; bad input is refused', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      data.setSalary(amountMinor: 500000, currency: 'SAR', from: m(1));
      data.setSalary(amountMinor: 550000, currency: 'SAR', from: m(1));
      expect(c.read(dataProvider).salaryRates.single.amountMinor, 550000);
      expect(() => data.setSalary(amountMinor: 0, currency: 'SAR', from: m(2)), throwsArgumentError);
      expect(() => data.setSalary(amountMinor: 1, currency: 'sar', from: m(2)), throwsArgumentError);
      expect(() => data.setSalary(amountMinor: 1, currency: 'SAR', from: m(2), payDay: 32), throwsArgumentError);
    });

    test('switching to variable income stops the salary from that date; back to fixed later', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      data.setSalary(amountMinor: 500000, currency: 'SAR', from: DateTime(2025, 12, 1), payDay: 1);
      data.stopSalary(DateTime(2026, 2, 1));
      var d = c.read(dataProvider);
      expect(currentSalary(d, now), isNull);
      expect(MoneySummary.month(d, m(1), now).salary, {'SAR': 500000});
      expect(MoneySummary.month(d, m(2), now).salary, isEmpty);
      expect(() => data.stopSalary(DateTime(2026, 3, 1)), throwsStateError);
      data.setSalary(amountMinor: 700000, currency: 'SAR', from: DateTime(2026, 3, 1), payDay: 1);
      d = c.read(dataProvider);
      expect(MoneySummary.month(d, m(3), now).salary, {'SAR': 700000});
    });

    test('pay day 31 is paid on the last day of shorter months', () {
      final d = AppData(salaryRates: [
        SalaryRate(id: 'r', amountMinor: 100, currency: 'SAR', effectiveFrom: '2026-01-01', payDay: 31, updatedAt: now),
      ]);
      expect(salaryPays(d, m(2), m(3), DateTime(2026, 4, 1)).single.on, DateTime(2026, 2, 28));
      expect(dueIn(DateTime(2028, 2), 30), DateTime(2028, 2, 29));
    });
  });

  group('income and what is left', () {
    test('remaining = income − expenses, per currency, never mixed', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      data.setSalary(amountMinor: 500000, currency: 'SAR', from: m(1), payDay: 1);
      data.saveIncome(Income(id: 'i1', amountMinor: 80000, currency: 'SAR', source: 'Freelance', receivedAt: DateTime(2026, 3, 5)));
      data.saveIncome(Income(id: 'i2', amountMinor: 20000, currency: 'USD', receivedAt: DateTime(2026, 3, 6)));
      data.addExpense(Expense(id: 'e1', amountMinor: 120000, currency: 'SAR', category: 'food', spentAt: DateTime(2026, 3, 2)));
      data.addExpense(Expense(id: 'e2', amountMinor: 5000, currency: 'USD', category: 'other', spentAt: DateTime(2026, 3, 3)));
      final s = MoneySummary.month(c.read(dataProvider), m(3), now);
      expect(s.income, {'SAR': 580000, 'USD': 20000});
      expect((s.remaining('SAR'), s.remaining('USD')), (460000, 15000));
      expect(() => data.saveIncome(Income(id: 'f', amountMinor: 1, currency: 'SAR', receivedAt: DateTime(2026, 3, 11))), throwsArgumentError);
    });

    test('filters by dates and category; comparison only with something to compare', () {
      final d = AppData(expenses: [
        Expense(id: 'a', amountMinor: 100, currency: 'SAR', category: 'food', spentAt: DateTime(2026, 3, 1)),
        Expense(id: 'b', amountMinor: 300, currency: 'SAR', category: 'bills', spentAt: DateTime(2026, 3, 9)),
        Expense(id: 'c', amountMinor: 50, currency: 'SAR', category: 'food', spentAt: DateTime(2026, 2, 20)),
      ]);
      expect(expensesIn(d, DateTime(2026, 2, 15), DateTime(2026, 3, 5)).map((e) => e.id), ['a', 'c']);
      expect(expensesIn(d, m(1), m(4), category: 'food').map((e) => e.id), ['a', 'c']);
      expect(byCategory(expensesIn(d, m(3), m(4))).map((x) => x.$1), ['bills', 'food']);
      final h = monthHistory(d, m(3), now, count: 3);
      expect([for (final x in h) x.expenses['SAR']], [null, 50, 400]);
      expect(percentChange(400, 50), 700);
      expect(percentChange(400, null), isNull);
      expect(percentChange(400, 0), isNull);
    });
  });

  group('monthly items', () {
    test('every month due up to today is recorded once, and a deleted one stays deleted', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      data.saveRecurring(RecurringItem(
          id: 'rent', kind: RecurringKind.expense, amountMinor: 150000, currency: 'SAR', category: 'bills', title: 'Rent',
          dayOfMonth: 1, startsOn: '2026-01-01', updatedAt: now));
      data.saveRecurring(RecurringItem(
          id: 'side', kind: RecurringKind.income, amountMinor: 30000, currency: 'SAR', title: 'Side work',
          dayOfMonth: 15, startsOn: '2026-01-20', updatedAt: now));
      var d = c.read(dataProvider);
      expect(d.expenses.map((e) => e.spentAt.month), [1, 2, 3]);
      expect(d.expenses.every((e) => e.recurringId == 'rent' && e.description == 'Rent'), isTrue);
      expect(d.incomes.map((e) => e.receivedAt.month), [2], reason: 'starts after 15 Jan; 15 Mar is still ahead');
      expect(d.recurring.firstWhere((r) => r.id == 'side').generatedThrough, '2026-02');

      final feb = d.expenses.firstWhere((e) => e.spentAt.month == 2);
      data.deleteExpense(feb.id);
      data.runRecurringDue();
      expect(c.read(dataProvider).expenses, hasLength(2));
      // The same ids on any device: running from a fresh copy adds nothing new.
      final again = runRecurring(d.copyWith(recurring: [for (final r in d.recurring) r.copyWith(generatedThrough: () => null)]), now);
      expect(again.expenses, isEmpty);
      expect(again.incomes, isEmpty);

      data.deleteRecurring('rent');
      d = c.read(dataProvider);
      expect((d.expenses.length, d.expenses.every((e) => e.recurringId == null)), (2, true));
    });

    test('an end date stops it; paused items make nothing', () {
      final d = AppData(recurring: [
        RecurringItem(id: 'a', kind: RecurringKind.expense, amountMinor: 1, currency: 'SAR', dayOfMonth: 5, startsOn: '2026-01-01', endsOn: '2026-01-31', updatedAt: now),
        RecurringItem(id: 'b', kind: RecurringKind.expense, amountMinor: 1, currency: 'SAR', startsOn: '2026-01-01', active: false, updatedAt: now),
      ]);
      final r = runRecurring(d, now);
      expect(r.expenses.map((e) => e.spentAt), [DateTime(2026, 1, 5, 9)]);
      expect(r.items.single.generatedThrough, '2026-03');
    });
  });

  test('rows and JSON round-trip', () {
    final rate = SalaryRate(id: 'r', amountMinor: 5, currency: 'SAR', effectiveFrom: '2026-01-01', payDay: 27, note: 'x', updatedAt: now);
    final inc = Income(id: 'i', amountMinor: 7, currency: 'SAR', kind: IncomeKind.pay, source: 's', receivedAt: now, recurringId: 'q');
    final rec = RecurringItem(id: 'q', kind: RecurringKind.income, amountMinor: 9, currency: 'SAR', startsOn: '2026-01-01', generatedThrough: '2026-02', updatedAt: now);
    expect(salaryRateFrom(salaryRateRow(rate)).payDay, 27);
    expect(incomeFrom(incomeRow(inc)).kind, IncomeKind.pay);
    expect(recurringFrom(recurringRow(rec)).generatedThrough, '2026-02');
    final e = Expense(id: 'e', amountMinor: 1, currency: 'SAR', category: 'x', spentAt: now, recurringId: 'q');
    expect(expenseFrom(expenseRow(e)).recurringId, 'q');
    final back = AppData.fromJson(AppData(salaryRates: [rate], incomes: [inc], recurring: [rec], expenses: [e]).toJson());
    expect((back.salaryRates.single.note, back.incomes.single.recurringId, back.recurring.single.kind, back.expenses.single.recurringId),
        ('x', 'q', RecurringKind.income, 'q'));
  });
}
