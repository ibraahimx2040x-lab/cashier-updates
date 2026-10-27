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

  /// Overrides [activitySourcePriority] for the first pick.
  final ActivitySource? preferredSource;

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
