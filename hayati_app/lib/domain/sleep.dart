import '../core/utils/dates.dart';
import '../data/app_data.dart';
import '../data/models/health.dart';

/// Joins sleep segments that overlap or sit within [gap] of each other into
/// sessions, and drops what is left shorter than [minLength]. HealthKit
/// gives sleep as stage segments (core, deep, REM…), often written by both
/// the iPhone and the watch; merging keeps one session per night.
List<(DateTime, DateTime)> mergeSleepSegments(
  List<(DateTime, DateTime)> segments, {
  Duration gap = const Duration(minutes: 60),
  Duration minLength = const Duration(minutes: 20),
}) {
  final sorted = [
    for (final s in segments)
      if (s.$2.isAfter(s.$1)) s,
  ]..sort((a, b) => a.$1.compareTo(b.$1));
  final out = <(DateTime, DateTime)>[];
  for (final s in sorted) {
    if (out.isNotEmpty && !s.$1.isAfter(out.last.$2.add(gap))) {
      final last = out.removeLast();
      out.add((last.$1, s.$2.isAfter(last.$2) ? s.$2 : last.$2));
    } else {
      out.add(s);
    }
  }
  return [
    for (final s in out)
      if (s.$2.difference(s.$1) >= minLength && s.$2.difference(s.$1) <= SleepSession.maxLength) s,
  ];
}

/// The day a session counts for: the day the user woke up.
String sleepDayOf(SleepSession s) => dayKey(s.end);

/// The source that counts when several have data: the user's pick for
/// [kind] if present, otherwise the first in [activitySourcePriority].
ActivitySource? pickSource(Iterable<ActivitySource> available, ActivitySource? preferred) {
  final set = available.toSet();
  if (set.isEmpty) return null;
  if (preferred != null && set.contains(preferred)) return preferred;
  for (final s in activitySourcePriority) {
    if (set.contains(s)) return s;
  }
  return set.first;
}

class SleepDay {
  const SleepDay({required this.day, required this.sessions, this.source});
  final String day;

  /// From [source] only, oldest first. Two sources are never added up.
  final List<SleepSession> sessions;
  final ActivitySource? source;

  bool get hasData => sessions.isNotEmpty;
  int get minutes => sessions.fold(0, (a, s) => a + s.minutes);

  /// The longest session: the night's sleep rather than a nap.
  SleepSession? get main => sessions.isEmpty ? null : sessions.reduce((a, b) => b.minutes > a.minutes ? b : a);
}

SleepDay sleepDay(AppData d, String day) {
  final rows = d.sleep.where((s) => sleepDayOf(s) == day).toList();
  final source = pickSource(rows.map((s) => s.source), d.settings.health.sleepSource);
  final mine = rows.where((s) => s.source == source).toList()..sort((a, b) => a.start.compareTo(b.start));
  return SleepDay(day: day, sessions: mine, source: source);
}

/// [days] consecutive days ending on [last], oldest first.
List<SleepDay> sleepSeries(AppData d, DateTime last, int days) => [
      for (var i = days - 1; i >= 0; i--) sleepDay(d, dayKey(dateOnly(last).subtract(Duration(days: i)))),
    ];

/// Average minutes over the days that have data (0 when none).
int averageSleepMinutes(List<SleepDay> series) {
  final withData = series.where((s) => s.hasData).toList();
  if (withData.isEmpty) return 0;
  return (withData.fold(0, (a, s) => a + s.minutes) / withData.length).round();
}

/// Resting heart rate for [day] from the source that counts.
BodyMetric? restingHeartOn(AppData d, String day) {
  final rows = d.bodyMetrics.where((m) => m.kind == MetricKind.restingHr && dayKey(m.measuredAt) == day).toList();
  final source = pickSource(rows.map((m) => m.source), d.settings.health.heartSource);
  final mine = rows.where((m) => m.source == source).toList()..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
  return mine.lastOrNull;
}

/// Most recent resting heart rate within [days] of [now], and the average
/// over that span (days with data only).
(BodyMetric?, int?) restingHeartSummary(AppData d, DateTime now, {int days = 7}) {
  BodyMetric? latest;
  final values = <double>[];
  for (var i = 0; i < days; i++) {
    final m = restingHeartOn(d, dayKey(dateOnly(now).subtract(Duration(days: i))));
    if (m == null) continue;
    latest ??= m;
    values.add(m.value);
  }
  return (latest, values.isEmpty ? null : (values.reduce((a, b) => a + b) / values.length).round());
}

/// Imported workouts, newest first.
List<DeviceWorkout> recentDeviceWorkouts(AppData d, {int limit = 20}) =>
    ([...d.deviceWorkouts]..sort((a, b) => b.start.compareTo(a.start))).take(limit).toList();

/// What is stored per source, for the sources screen.
class SourceSummary {
  const SourceSummary(this.source, {this.stepDays = 0, this.sleepNights = 0, this.heartDays = 0, this.workouts = 0, this.latest});
  final ActivitySource source;
  final int stepDays;
  final int sleepNights;
  final int heartDays;
  final int workouts;
  final DateTime? latest;

  int get total => stepDays + sleepNights + heartDays + workouts;
}

List<SourceSummary> sourceSummaries(AppData d) {
  final out = <SourceSummary>[];
  for (final s in ActivitySource.values) {
    final steps = d.activity.where((a) => a.source == s).toList();
    final sleep = d.sleep.where((x) => x.source == s).toList();
    final heart = d.bodyMetrics.where((m) => m.source == s && m.kind == MetricKind.restingHr).toList();
    final workouts = d.deviceWorkouts.where((w) => w.source == s).toList();
    final times = [
      for (final a in steps) a.updatedAt,
      for (final x in sleep) x.end,
      for (final m in heart) m.measuredAt,
      for (final w in workouts) w.end,
    ];
    if (times.isEmpty) continue;
    out.add(SourceSummary(
      s,
      stepDays: steps.length,
      sleepNights: sleep.map(sleepDayOf).toSet().length,
      heartDays: heart.map((m) => dayKey(m.measuredAt)).toSet().length,
      workouts: workouts.length,
      latest: times.reduce((a, b) => a.isAfter(b) ? a : b),
    ));
  }
  return out;
}

/// Sources with data for [kind], for choosing which one counts.
Set<ActivitySource> sourcesWith(AppData d, HealthKind kind) => switch (kind) {
      HealthKind.steps => {for (final a in d.activity) a.source},
      HealthKind.sleep => {for (final s in d.sleep) s.source},
      HealthKind.heartRate => {
          for (final m in d.bodyMetrics)
            if (m.kind == MetricKind.restingHr) m.source,
        },
      HealthKind.workouts => {for (final w in d.deviceWorkouts) w.source},
    };
