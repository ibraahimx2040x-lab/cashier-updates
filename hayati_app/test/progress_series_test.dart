import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/models/health.dart';
import 'package:hayati/data/models/misc.dart';
import 'package:hayati/data/models/task.dart';
import 'package:hayati/domain/progress_series.dart';

import 'helpers.dart';

Task done(String id, DateTime at) =>
    Task(id: id, title: id, status: TaskStatus.done, completedAt: at, createdAt: at, updatedAt: at);

void main() {
  final now = fixedNow; // Tuesday 2026-03-10 08:00
  final weekStart = DateTime(2026, 3, 8);
  final weekEnd = DateTime(2026, 3, 15);

  test('tasks: a bar per day, empty days stay empty, future days are not counted', () {
    final d = AppData(tasks: [
      done('a', DateTime(2026, 3, 8, 9)),
      done('b', DateTime(2026, 3, 8, 15)),
      done('c', DateTime(2026, 3, 10, 7)),
      done('old', DateTime(2026, 3, 3, 9)),
    ]);
    final s = ProgressSeries.build(d, ProgressMetric.tasks, weekStart, weekEnd, now);
    expect(s.buckets.map((b) => b.value), [2, null, 1, null, null, null, null]);
    expect((s.total, s.previous, s.change, s.enough), (3.0, 1.0, 200, true));
  });

  test('no misleading charts: one point is not a trend, nothing before means no comparison', () {
    final d = AppData(tasks: [done('a', DateTime(2026, 3, 10, 7))]);
    final s = ProgressSeries.build(d, ProgressMetric.tasks, weekStart, weekEnd, now);
    expect((s.enough, s.change, s.previous), (false, null, null));
    final empty = ProgressSeries.build(const AppData(), ProgressMetric.steps, weekStart, weekEnd, now);
    expect((empty.total, empty.enough), (null, false));
  });

  test('steps, spending in the main currency, and long ranges in weeks', () {
    DailyActivity steps(String day, int n) => DailyActivity(id: day, day: day, source: ActivitySource.manual, steps: n, updatedAt: now);
    final d = AppData(
      activity: [steps('2026-03-08', 4000), steps('2026-03-09', 6000), steps('2026-03-01', 5000)],
      expenses: [
        Expense(id: 'e1', amountMinor: 2500, currency: 'SAR', category: 'food', spentAt: DateTime(2026, 3, 9)),
        Expense(id: 'e2', amountMinor: 900, currency: 'USD', category: 'food', spentAt: DateTime(2026, 3, 9)),
      ],
    );
    final st = ProgressSeries.build(d, ProgressMetric.steps, weekStart, weekEnd, now);
    expect((st.total, st.previous, st.change), (10000.0, 5000.0, 100));
    final sp = ProgressSeries.build(d, ProgressMetric.spending, weekStart, weekEnd, now);
    expect(sp.total, 25.0, reason: 'SAR only; USD is never added in');
    final long = ProgressSeries.build(d, ProgressMetric.steps, DateTime(2026, 1, 1), DateTime(2026, 3, 15), now);
    expect((long.weekly, long.buckets.length), (true, 11));
  });
}
