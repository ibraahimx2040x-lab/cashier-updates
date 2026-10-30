import '../core/utils/dates.dart';
import '../data/app_data.dart';
import '../data/models/task.dart';
import 'activity.dart';
import 'metrics.dart';
import 'money.dart';

/// What a progress chart can show (v4 change 13).
enum ProgressMetric { tasks, habits, steps, workouts, lessons, spending, income }

/// One bar: a day (short ranges) or a week (long ones). [value] is null when
/// nothing was recorded, so an empty day never reads as a zero.
typedef Bucket = ({DateTime start, double? value});

class ProgressSeries {
  const ProgressSeries({required this.metric, required this.buckets, required this.total, required this.previous, required this.weekly});

  final ProgressMetric metric;
  final List<Bucket> buckets;

  /// Sum over the period (for habits: the adherence rate, 0–1).
  final double? total;

  /// The same figure for the period just before, of the same length.
  final double? previous;

  /// Buckets are weeks rather than days.
  final bool weekly;

  /// Enough recorded points to draw a trend; with fewer, the screen says so
  /// instead of drawing a misleading chart.
  bool get enough => buckets.where((b) => b.value != null).length >= 2;

  /// Change from the previous period in percent, or null when there is
  /// nothing to compare with.
  int? get change {
    final cur = total, prev = previous;
    if (cur == null || prev == null || prev == 0) return null;
    return ((cur - prev) * 100 / prev).round();
  }

  double get max => buckets.fold<double>(0, (m, b) => (b.value ?? 0) > m ? b.value! : m);

  static ProgressSeries build(AppData d, ProgressMetric m, DateTime from, DateTime toExclusive, DateTime now) {
    final days = toExclusive.difference(from).inDays;
    final weekly = days > 45;
    final step = weekly ? 7 : 1;
    final last = toExclusive.isAfter(now) ? dateOnly(now).add(const Duration(days: 1)) : toExclusive;
    final buckets = <Bucket>[
      for (var s = from; s.isBefore(toExclusive); s = s.add(Duration(days: step)))
        (start: s, value: s.isBefore(last) ? _value(d, m, s, _min(s.add(Duration(days: step)), last), now) : null),
    ];
    final prevFrom = from.subtract(Duration(days: days));
    return ProgressSeries(
      metric: m,
      buckets: buckets,
      weekly: weekly,
      total: _value(d, m, from, last, now),
      previous: _value(d, m, prevFrom, from, now),
    );
  }
}

DateTime _min(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

bool _in(DateTime t, DateTime a, DateTime b) => !t.isBefore(a) && t.isBefore(b);
bool _inDay(String day, DateTime a, DateTime b) => _in(parseDayKey(day), a, b);

/// The figure for [a, b), or null when nothing was recorded.
double? _value(AppData d, ProgressMetric m, DateTime a, DateTime b, DateTime now) {
  if (!b.isAfter(a)) return null;
  switch (m) {
    case ProgressMetric.tasks:
      final n = d.tasks.where((t) => t.status == TaskStatus.done && t.completedAt != null && _in(t.completedAt!, a, b)).length;
      final anyDue = d.tasks.any((t) => t.dueAt != null && _in(t.dueAt!, a, b));
      return n == 0 && !anyDue ? null : n.toDouble();
    case ProgressMetric.habits:
      var due = 0, done = 0;
      final until = b.subtract(const Duration(days: 1));
      for (final h in d.habits) {
        if (parseDayKey(h.startDate).isAfter(until)) continue;
        final from = parseDayKey(h.startDate).isAfter(a) ? parseDayKey(h.startDate) : a;
        final logged = d.habitLogs.where((l) => l.habitId == h.id).map((l) => l.day).toSet();
        final s = HabitStats.compute(h, logged, from, until.isAfter(now) ? now : until);
        due += s.dueDays;
        done += s.doneDays;
      }
      return due == 0 ? null : done / due;
    case ProgressMetric.steps:
      var sum = 0, any = false;
      for (var day = dateOnly(a); day.isBefore(b); day = day.add(const Duration(days: 1))) {
        final s = activityDay(d, dayKey(day));
        if (s.hasData) {
          any = true;
          sum += s.steps;
        }
      }
      return any ? sum.toDouble() : null;
    case ProgressMetric.workouts:
      final n = d.workoutSessions.where((w) => _inDay(w.day, a, b)).length +
          d.deviceWorkouts.where((w) => _in(w.start, a, b)).length;
      return n == 0 ? null : n.toDouble();
    case ProgressMetric.lessons:
      final n = d.lessonProgresses.where((p) => _in(p.lastAt, a, b)).length + d.assessments.where((x) => _in(x.takenAt, a, b)).length;
      return n == 0 ? null : n.toDouble();
    case ProgressMetric.spending:
    case ProgressMetric.income:
      final s = MoneySummary.build(d, a, b, now);
      final map = m == ProgressMetric.spending ? s.expenses : s.income;
      final v = map[d.settings.currency];
      return v == null ? null : v / 100;
  }
}
