/// Health additions (spec v3, `docs/SPEC_V3_HEALTH.md`): who the user is,
/// which health sections they use, and daily activity.
library;

/// Chosen at sign-up so the app can show the matching health section.
/// Never inferred from other data.
enum Sex { male, female }

/// Health sections the user can turn on or off (screen 33).
enum HealthModule { activity, nutrition, sleep, womens, mens }

/// Where a day's activity numbers came from. Health Connect / HealthKit
/// already merge the user's devices, so each is one source.
enum ActivitySource { healthConnect, healthKit, phone, manual }

/// What the app can read from the phone's health store (screen 40).
enum HealthKind { steps, sleep, heartRate, workouts }

/// Preference order when several sources have the same day.
const activitySourcePriority = [
  ActivitySource.healthConnect,
  ActivitySource.healthKit,
  ActivitySource.phone,
  ActivitySource.manual,
];

class HealthSettings {
  const HealthSettings({
    this.modules = const {HealthModule.activity, HealthModule.nutrition, HealthModule.sleep},
    this.stepGoal = 8000,
    this.heightCm,
    this.moveReminders = false,
    this.moveStart = 10 * 60,
    this.moveEnd = 20 * 60,
    this.moveEvery = 120,
    this.preferredSource,
    this.sleepSource,
    this.heartSource,
    this.kcalGoal,
    this.waterGoalMl = 2000,
    this.pregnancyCleared = false,
    this.postpartumCleared = false,
  });

  final Set<HealthModule> modules;
  final int stepGoal;

  /// Used to estimate distance from steps when a source gives no distance.
  final int? heightCm;

  /// Plain reminders to move every [moveEvery] minutes between
  /// [moveStart] and [moveEnd] (minutes since midnight).
  final bool moveReminders;
  final int moveStart;
  final int moveEnd;
  final int moveEvery;

  /// Overrides [activitySourcePriority] for the first pick of steps,
  /// sleep and resting heart rate.
  final ActivitySource? preferredSource;
  final ActivitySource? sleepSource;
  final ActivitySource? heartSource;

  /// The preferred source for [kind] (workouts are never merged: each one is
  /// its own record, so there is nothing to pick).
  ActivitySource? preferredFor(HealthKind kind) => switch (kind) {
        HealthKind.steps => preferredSource,
        HealthKind.sleep => sleepSource,
        HealthKind.heartRate => heartSource,
        HealthKind.workouts => null,
      };

  /// Optional daily calorie target the user sets; the app never suggests one.
  final int? kcalGoal;
  final int waterGoalMl;

  /// The user confirmed their doctor's go-ahead for these programs.
  final bool pregnancyCleared;
  final bool postpartumCleared;

  bool has(HealthModule m) => modules.contains(m);

  static const minStepGoal = 1000;
  static const maxStepGoal = 50000;

  HealthSettings copyWith({
    Set<HealthModule>? modules,
    int? stepGoal,
    int? Function()? heightCm,
    bool? moveReminders,
    int? moveStart,
    int? moveEnd,
    int? moveEvery,
    ActivitySource? Function()? preferredSource,
    ActivitySource? Function()? sleepSource,
    ActivitySource? Function()? heartSource,
    int? Function()? kcalGoal,
    int? waterGoalMl,
    bool? pregnancyCleared,
    bool? postpartumCleared,
  }) =>
      HealthSettings(
        modules: modules ?? this.modules,
        stepGoal: stepGoal ?? this.stepGoal,
        heightCm: heightCm != null ? heightCm() : this.heightCm,
        moveReminders: moveReminders ?? this.moveReminders,
        moveStart: moveStart ?? this.moveStart,
        moveEnd: moveEnd ?? this.moveEnd,
        moveEvery: moveEvery ?? this.moveEvery,
        preferredSource: preferredSource != null ? preferredSource() : this.preferredSource,
        sleepSource: sleepSource != null ? sleepSource() : this.sleepSource,
        heartSource: heartSource != null ? heartSource() : this.heartSource,
        kcalGoal: kcalGoal != null ? kcalGoal() : this.kcalGoal,
        waterGoalMl: waterGoalMl ?? this.waterGoalMl,
        pregnancyCleared: pregnancyCleared ?? this.pregnancyCleared,
        postpartumCleared: postpartumCleared ?? this.postpartumCleared,
      );

  Map<String, Object?> toJson() => {
        'modules': [for (final m in modules) m.name]..sort(),
        'stepGoal': stepGoal,
        'heightCm': heightCm,
        'moveReminders': moveReminders,
        'moveStart': moveStart,
        'moveEnd': moveEnd,
        'moveEvery': moveEvery,
        'preferredSource': preferredSource?.name,
        'sleepSource': sleepSource?.name,
        'heartSource': heartSource?.name,
        'kcalGoal': kcalGoal,
        'waterGoalMl': waterGoalMl,
        'pregnancyCleared': pregnancyCleared,
        'postpartumCleared': postpartumCleared,
      };

  factory HealthSettings.fromJson(Map<String, Object?>? j) {
    const d = HealthSettings();
    if (j == null || j.isEmpty) return d;
    T? pick<T extends Enum>(List<T> values, Object? name) =>
        values.where((v) => v.name == name).firstOrNull;
    return HealthSettings(
      modules: j['modules'] is List
          ? {for (final m in j['modules'] as List) ?pick(HealthModule.values, m)}
          : d.modules,
      stepGoal: (j['stepGoal'] as int?) ?? d.stepGoal,
      heightCm: j['heightCm'] as int?,
      moveReminders: (j['moveReminders'] as bool?) ?? d.moveReminders,
      moveStart: (j['moveStart'] as int?) ?? d.moveStart,
      moveEnd: (j['moveEnd'] as int?) ?? d.moveEnd,
      moveEvery: (j['moveEvery'] as int?) ?? d.moveEvery,
      preferredSource: pick(ActivitySource.values, j['preferredSource']),
      sleepSource: pick(ActivitySource.values, j['sleepSource']),
      heartSource: pick(ActivitySource.values, j['heartSource']),
      kcalGoal: j['kcalGoal'] as int?,
      waterGoalMl: (j['waterGoalMl'] as int?) ?? d.waterGoalMl,
      pregnancyCleared: (j['pregnancyCleared'] as bool?) ?? false,
      postpartumCleared: (j['postpartumCleared'] as bool?) ?? false,
    );
  }
}

/// One day's activity from one source.
class DailyActivity {
  const DailyActivity({
    required this.id,
    required this.day,
    required this.source,
    required this.steps,
    this.distanceM,
    this.activeMinutes,
    required this.updatedAt,
  });

  final String id;

  /// YYYY-MM-DD.
  final String day;
  final ActivitySource source;
  final int steps;

  /// Null when the source doesn't report it; then it is estimated.
  final int? distanceM;
  final int? activeMinutes;
  final DateTime updatedAt;

  static const maxSteps = 150000;

  DailyActivity copyWith({int? steps, int? Function()? distanceM, int? Function()? activeMinutes, DateTime? updatedAt}) =>
      DailyActivity(
        id: id,
        day: day,
        source: source,
        steps: steps ?? this.steps,
        distanceM: distanceM != null ? distanceM() : this.distanceM,
        activeMinutes: activeMinutes != null ? activeMinutes() : this.activeMinutes,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'day': day,
        'source': source.name,
        'steps': steps,
        'distanceM': distanceM,
        'activeMinutes': activeMinutes,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory DailyActivity.fromJson(Map<String, Object?> j) => DailyActivity(
        id: j['id'] as String,
        day: j['day'] as String,
        source: ActivitySource.values.byName(j['source'] as String),
        steps: j['steps'] as int,
        distanceM: j['distanceM'] as int?,
        activeMinutes: j['activeMinutes'] as int?,
        updatedAt: DateTime.parse(j['updatedAt'] as String).toLocal(),
      );
}

/// One stretch of sleep from one source. Imported sessions are merged from
/// the store's segments (see `domain/sleep.dart`); later the user can add
/// their own (phase 12).
class SleepSession {
  const SleepSession({
    required this.id,
    required this.source,
    required this.start,
    required this.end,
    this.quality,
    required this.updatedAt,
  });

  final String id;
  final ActivitySource source;
  final DateTime start;
  final DateTime end;

  /// 1–5, entered by the user only.
  final int? quality;
  final DateTime updatedAt;

  int get minutes => end.difference(start).inMinutes;

  static const maxLength = Duration(hours: 24);

  Map<String, Object?> toJson() => {
        'id': id,
        'source': source.name,
        'start': start.toUtc().toIso8601String(),
        'end': end.toUtc().toIso8601String(),
        'quality': quality,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory SleepSession.fromJson(Map<String, Object?> j) => SleepSession(
        id: j['id'] as String,
        source: ActivitySource.values.byName(j['source'] as String),
        start: DateTime.parse(j['start'] as String).toLocal(),
        end: DateTime.parse(j['end'] as String).toLocal(),
        quality: j['quality'] as int?,
        updatedAt: DateTime.parse(j['updatedAt'] as String).toLocal(),
      );
}

/// Body measurements (spec 4.5). Phase 10 imports resting heart rate; the
/// other kinds get their screen in phase 12.
enum MetricKind { weight, waist, restingHr, bp, bodyFat }

class BodyMetric {
  const BodyMetric({
    required this.id,
    required this.kind,
    required this.value,
    this.value2,
    required this.source,
    required this.measuredAt,
    this.note = '',
  });

  final String id;
  final MetricKind kind;

  /// kg, cm, bpm, systolic mmHg or percent, by [kind].
  final double value;

  /// Diastolic, for blood pressure only.
  final double? value2;
  final ActivitySource source;
  final DateTime measuredAt;
  final String note;

  /// Sensible bounds per kind, as the database checks them.
  static (double, double) range(MetricKind k) => switch (k) {
        MetricKind.weight => (20, 400),
        MetricKind.waist => (30, 250),
        MetricKind.restingHr => (25, 220),
        MetricKind.bp => (60, 260),
        MetricKind.bodyFat => (2, 75),
      };

  bool get valid {
    final (lo, hi) = range(kind);
    if (value < lo || value > hi) return false;
    if (kind == MetricKind.bp) return value2 != null && value2! >= 30 && value2! <= 160;
    return value2 == null;
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.name,
        'value': value,
        'value2': value2,
        'source': source.name,
        'measuredAt': measuredAt.toUtc().toIso8601String(),
        'note': note,
      };

  factory BodyMetric.fromJson(Map<String, Object?> j) => BodyMetric(
        id: j['id'] as String,
        kind: MetricKind.values.byName(j['kind'] as String),
        value: (j['value'] as num).toDouble(),
        value2: (j['value2'] as num?)?.toDouble(),
        source: ActivitySource.values.byName(j['source'] as String),
        measuredAt: DateTime.parse(j['measuredAt'] as String).toLocal(),
        note: (j['note'] as String?) ?? '',
      );
}

/// A workout recorded by a watch or another app, read from the health
/// store. Kept apart from the app's own sessions, which follow a plan.
class DeviceWorkout {
  const DeviceWorkout({
    required this.id,
    required this.source,
    required this.activity,
    required this.start,
    required this.end,
    this.kcal,
    this.distanceM,
    this.steps,
    required this.updatedAt,
  });

  final String id;
  final ActivitySource source;

  /// The store's activity code, e.g. RUNNING, WALKING, SWIMMING.
  final String activity;
  final DateTime start;
  final DateTime end;
  final int? kcal;
  final int? distanceM;
  final int? steps;
  final DateTime updatedAt;

  int get minutes => end.difference(start).inMinutes;

  Map<String, Object?> toJson() => {
        'id': id,
        'source': source.name,
        'activity': activity,
        'start': start.toUtc().toIso8601String(),
        'end': end.toUtc().toIso8601String(),
        'kcal': kcal,
        'distanceM': distanceM,
        'steps': steps,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory DeviceWorkout.fromJson(Map<String, Object?> j) => DeviceWorkout(
        id: j['id'] as String,
        source: ActivitySource.values.byName(j['source'] as String),
        activity: j['activity'] as String,
        start: DateTime.parse(j['start'] as String).toLocal(),
        end: DateTime.parse(j['end'] as String).toLocal(),
        kcal: j['kcal'] as int?,
        distanceM: j['distanceM'] as int?,
        steps: j['steps'] as int?,
        updatedAt: DateTime.parse(j['updatedAt'] as String).toLocal(),
      );
}
