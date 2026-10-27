import '../core/utils/dates.dart';
import '../data/app_data.dart';
import '../data/models/health.dart';

/// A day's activity as the app shows it: one source, never a sum of
/// sources (a phone and a watch both count the same walk).
class ActivityDay {
  const ActivityDay({
    required this.day,
    required this.steps,
    required this.distanceM,
    required this.distanceEstimated,
    this.activeMinutes,
    this.source,
    this.updatedAt,
  });

  final String day;
  final int steps;
  final int distanceM;

  /// True when the source gave no distance and it was worked out from
  /// steps and height.
  final bool distanceEstimated;
  final int? activeMinutes;

  /// Null for a day with no data.
  final ActivitySource? source;
  final DateTime? updatedAt;

  bool get hasData => source != null;
}

/// Picks the row that counts for [day]: the user's preferred source if it
/// has that day, otherwise the first available in [activitySourcePriority].
DailyActivity? effectiveActivity(AppData d, String day) {
  final rows = d.activity.where((a) => a.day == day).toList();
  if (rows.isEmpty) return null;
  final preferred = d.settings.health.preferredSource;
  if (preferred != null) {
    final p = rows.where((a) => a.source == preferred).firstOrNull;
    if (p != null) return p;
  }
  for (final s in activitySourcePriority) {
    final r = rows.where((a) => a.source == s).firstOrNull;
    if (r != null) return r;
  }
  return rows.first;
}

/// Average step length from height (a common 0.415 × height rule), or
/// 0.75 m when height is unknown.
double strideMeters(int? heightCm) => heightCm == null ? 0.75 : heightCm * 0.415 / 100;

int estimateDistanceM(int steps, int? heightCm) => (steps * strideMeters(heightCm)).round();

ActivityDay activityDay(AppData d, String day) {
  final a = effectiveActivity(d, day);
  final h = d.settings.health.heightCm;
  if (a == null) return ActivityDay(day: day, steps: 0, distanceM: 0, distanceEstimated: false);
  return ActivityDay(
    day: day,
    steps: a.steps,
    distanceM: a.distanceM ?? estimateDistanceM(a.steps, h),
    distanceEstimated: a.distanceM == null,
    activeMinutes: a.activeMinutes,
    source: a.source,
    updatedAt: a.updatedAt,
  );
}

/// [days] consecutive days ending on [last] (oldest first).
List<ActivityDay> activitySeries(AppData d, DateTime last, int days) => [
      for (var i = days - 1; i >= 0; i--) activityDay(d, dayKey(dateOnly(last).subtract(Duration(days: i)))),
    ];

class ActivityStats {
  const ActivityStats({required this.total, required this.average, required this.goalDays, required this.daysWithData, this.best});
  final int total;

  /// Over days that have data, so a missing day doesn't pull it down.
  final int average;
  final int goalDays;
  final int daysWithData;
  final ActivityDay? best;
}

ActivityStats activityStats(List<ActivityDay> series, int goal) {
  final withData = series.where((x) => x.hasData).toList();
  final total = withData.fold(0, (a, x) => a + x.steps);
  ActivityDay? best;
  for (final x in withData) {
    if (best == null || x.steps > best.steps) best = x;
  }
  return ActivityStats(
    total: total,
    average: withData.isEmpty ? 0 : (total / withData.length).round(),
    goalDays: withData.where((x) => x.steps >= goal).length,
    daysWithData: withData.length,
    best: best,
  );
}

/// Consecutive days reaching [goal], counting back from today (today
/// counts only once reached, so an unfinished today doesn't break it).
int goalStreak(AppData d, DateTime now, int goal) {
  var streak = 0;
  var day = dateOnly(now);
  if (activityDay(d, dayKey(day)).steps >= goal) streak++;
  while (true) {
    day = day.subtract(const Duration(days: 1));
    if (activityDay(d, dayKey(day)).steps < goal) break;
    streak++;
    if (streak > 3650) break;
  }
  return streak;
}
