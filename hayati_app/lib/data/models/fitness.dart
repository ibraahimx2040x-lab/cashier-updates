/// Fitness (design doc v2, section 3-d): the user's profile, versioned
/// home/gym plans, and logged sessions.
library;

enum FitnessGoal { strength, muscle, fatLoss, general, mobility }

enum FitnessLevel { beginner, intermediate, advanced }

enum WorkoutPlace { home, gym }

/// Equipment a home may have. The gym is assumed to have everything.
enum Equipment { dumbbells, kettlebell, bands, pullupBar, bench }

/// What a training day concentrates on.
enum DayFocus { fullBody, upper, lower, conditioning, mobility }

/// Answers to the plan setup (screen 13), stored in
/// `profiles.fitness_profile`. Null [FitnessProfile] means not set up.
class FitnessProfile {
  const FitnessProfile({
    required this.goal,
    required this.level,
    required this.daysPerWeek,
    required this.minutesPerSession,
    required this.weekdays,
    required this.places,
    this.homeEquipment = const {},
    this.preferredPlace = WorkoutPlace.home,
  });

  final FitnessGoal goal;
  final FitnessLevel level;
  final int daysPerWeek;
  final int minutesPerSession;

  /// Training days, ISO weekday numbers (1 = Monday … 7 = Sunday).
  final List<int> weekdays;
  final Set<WorkoutPlace> places;
  final Set<Equipment> homeEquipment;

  /// Which plan "today's workout" uses when both exist.
  final WorkoutPlace preferredPlace;

  FitnessProfile copyWith({WorkoutPlace? preferredPlace}) => FitnessProfile(
        goal: goal,
        level: level,
        daysPerWeek: daysPerWeek,
        minutesPerSession: minutesPerSession,
        weekdays: weekdays,
        places: places,
        homeEquipment: homeEquipment,
        preferredPlace: preferredPlace ?? this.preferredPlace,
      );

  Map<String, Object?> toJson() => {
        'goal': goal.name,
        'level': level.name,
        'daysPerWeek': daysPerWeek,
        'minutesPerSession': minutesPerSession,
        'weekdays': weekdays,
        'places': [for (final p in places) p.name]..sort(),
        'homeEquipment': [for (final e in homeEquipment) e.name]..sort(),
        'preferredPlace': preferredPlace.name,
      };

  /// Null for an empty or unreadable object (profile not set up).
  static FitnessProfile? fromJson(Map<String, Object?>? j) {
    if (j == null || j['goal'] == null) return null;
    T byName<T extends Enum>(List<T> values, Object? v, T fallback) =>
        values.where((x) => x.name == v).firstOrNull ?? fallback;
    return FitnessProfile(
      goal: byName(FitnessGoal.values, j['goal'], FitnessGoal.general),
      level: byName(FitnessLevel.values, j['level'], FitnessLevel.beginner),
      daysPerWeek: (j['daysPerWeek'] as int?) ?? 3,
      minutesPerSession: (j['minutesPerSession'] as int?) ?? 45,
      weekdays: ((j['weekdays'] as List?) ?? const []).cast<int>(),
      places: {
        for (final p in (j['places'] as List?) ?? const ['home'])
          if (WorkoutPlace.values.any((x) => x.name == p)) WorkoutPlace.values.byName(p as String),
      },
      homeEquipment: {
        for (final e in (j['homeEquipment'] as List?) ?? const [])
          if (Equipment.values.any((x) => x.name == e)) Equipment.values.byName(e as String),
      },
      preferredPlace: byName(WorkoutPlace.values, j['preferredPlace'], WorkoutPlace.home),
    );
  }
}

/// One exercise in a planned day: sets × reps, or sets × seconds.
class PlannedExercise {
  const PlannedExercise({required this.exerciseId, required this.sets, this.reps, this.seconds, required this.restSeconds})
      : assert((reps == null) != (seconds == null));
  final String exerciseId;
  final int sets;
  final int? reps;
  final int? seconds;
  final int restSeconds;

  Map<String, Object?> toJson() =>
      {'exerciseId': exerciseId, 'sets': sets, 'reps': reps, 'seconds': seconds, 'restSeconds': restSeconds};

  factory PlannedExercise.fromJson(Map<String, Object?> j) => PlannedExercise(
        exerciseId: j['exerciseId'] as String,
        sets: j['sets'] as int,
        reps: j['reps'] as int?,
        seconds: j['seconds'] as int?,
        restSeconds: j['restSeconds'] as int,
      );
}

class WorkoutDay {
  const WorkoutDay({required this.weekday, required this.focus, required this.exercises, required this.minutes});
  final int weekday;
  final DayFocus focus;
  final List<PlannedExercise> exercises;

  /// Estimated length including a warm-up.
  final int minutes;

  Map<String, Object?> toJson() => {
        'weekday': weekday,
        'focus': focus.name,
        'minutes': minutes,
        'exercises': [for (final e in exercises) e.toJson()],
      };

  factory WorkoutDay.fromJson(Map<String, Object?> j) => WorkoutDay(
        weekday: j['weekday'] as int,
        focus: DayFocus.values.byName(j['focus'] as String),
        minutes: j['minutes'] as int,
        exercises: [for (final e in (j['exercises'] as List)) PlannedExercise.fromJson((e as Map).cast())],
      );
}

/// A generated plan for one place. Regenerating creates a new version and
/// deactivates the old one, so past sessions still point at the plan the
/// user actually followed.
class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.place,
    required this.version,
    required this.active,
    required this.goal,
    required this.days,
    required this.createdAt,
  });

  final String id;
  final WorkoutPlace place;
  final int version;
  final bool active;
  final FitnessGoal goal;
  final List<WorkoutDay> days;
  final DateTime createdAt;

  WorkoutDay? dayFor(int weekday) => days.where((d) => d.weekday == weekday).firstOrNull;

  WorkoutPlan copyWith({bool? active}) => WorkoutPlan(
        id: id,
        place: place,
        version: version,
        active: active ?? this.active,
        goal: goal,
        days: days,
        createdAt: createdAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'place': place.name,
        'version': version,
        'active': active,
        'goal': goal.name,
        'days': [for (final d in days) d.toJson()],
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory WorkoutPlan.fromJson(Map<String, Object?> j) => WorkoutPlan(
        id: j['id'] as String,
        place: WorkoutPlace.values.byName(j['place'] as String),
        version: j['version'] as int,
        active: j['active'] as bool,
        goal: FitnessGoal.values.byName(j['goal'] as String),
        days: [for (final d in (j['days'] as List)) WorkoutDay.fromJson((d as Map).cast())],
        createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
      );
}

/// One set the user actually did (only what they entered is recorded).
class SetLog {
  const SetLog({required this.exerciseId, required this.setIndex, this.reps, this.seconds, this.weightKg});
  final String exerciseId;
  final int setIndex;
  final int? reps;
  final int? seconds;
  final double? weightKg;

  Map<String, Object?> toJson() =>
      {'exerciseId': exerciseId, 'setIndex': setIndex, 'reps': reps, 'seconds': seconds, 'weightKg': weightKg};

  factory SetLog.fromJson(Map<String, Object?> j) => SetLog(
        exerciseId: j['exerciseId'] as String,
        setIndex: j['setIndex'] as int,
        reps: j['reps'] as int?,
        seconds: j['seconds'] as int?,
        weightKg: (j['weightKg'] as num?)?.toDouble(),
      );
}

enum SessionStatus { completed, partial }

/// A finished workout (screen 15).
class WorkoutSession {
  const WorkoutSession({
    required this.id,
    this.planId,
    required this.day,
    required this.place,
    required this.focus,
    required this.status,
    this.difficulty,
    this.note = '',
    this.sets = const [],
    this.substituted = false,
    required this.createdAt,
  });

  final String id;

  /// The plan version followed; null for a free session.
  final String? planId;

  /// YYYY-MM-DD.
  final String day;
  final WorkoutPlace place;
  final DayFocus focus;
  final SessionStatus status;

  /// How hard it felt, 1 (easy) … 5 (very hard), if the user said.
  final int? difficulty;
  final String note;
  final List<SetLog> sets;

  /// Done at home in place of a gym day.
  final bool substituted;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'planId': planId,
        'day': day,
        'place': place.name,
        'focus': focus.name,
        'status': status.name,
        'difficulty': difficulty,
        'note': note,
        'sets': [for (final s in sets) s.toJson()],
        'substituted': substituted,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory WorkoutSession.fromJson(Map<String, Object?> j) => WorkoutSession(
        id: j['id'] as String,
        planId: j['planId'] as String?,
        day: j['day'] as String,
        place: WorkoutPlace.values.byName(j['place'] as String),
        focus: DayFocus.values.byName(j['focus'] as String),
        status: SessionStatus.values.byName(j['status'] as String),
        difficulty: j['difficulty'] as int?,
        note: (j['note'] as String?) ?? '',
        sets: [for (final s in (j['sets'] as List? ?? const [])) SetLog.fromJson((s as Map).cast())],
        substituted: (j['substituted'] as bool?) ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
      );
}
