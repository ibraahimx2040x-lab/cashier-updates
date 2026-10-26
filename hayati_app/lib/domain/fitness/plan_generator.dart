import '../../data/models/fitness.dart';
import 'exercises.dart';

/// Builds a weekly plan from the user's answers, deterministically, so the
/// same answers always give the same plan and every choice can be
/// explained. There is no "abs day": core work goes into every session.
class PlanGenerator {
  const PlanGenerator();

  static const warmupMinutes = 5;

  List<WorkoutDay> build(FitnessProfile p, WorkoutPlace place) {
    final focuses = focusesFor(p.goal, p.daysPerWeek);
    final days = <WorkoutDay>[];
    final seen = <DayFocus, int>{};
    for (var i = 0; i < p.weekdays.length && i < focuses.length; i++) {
      final f = focuses[i];
      final variant = seen[f] = (seen[f] ?? -1) + 1;
      days.add(_day(p, place, p.weekdays[i], f, variant));
    }
    return days;
  }

  /// The weekly split: full body up to 3 days, upper/lower from 4, with
  /// conditioning and mobility days filling 5–6.
  static List<DayFocus> focusesFor(FitnessGoal goal, int n) {
    if (goal == FitnessGoal.mobility) {
      return [for (var i = 0; i < n; i++) i.isEven ? DayFocus.mobility : DayFocus.fullBody];
    }
    final extra = goal == FitnessGoal.fatLoss || goal == FitnessGoal.general ? DayFocus.conditioning : DayFocus.fullBody;
    return switch (n) {
      <= 3 => List.filled(n, DayFocus.fullBody),
      4 => const [DayFocus.upper, DayFocus.lower, DayFocus.upper, DayFocus.lower],
      5 => [DayFocus.upper, DayFocus.lower, extra, DayFocus.upper, DayFocus.lower],
      _ => const [DayFocus.upper, DayFocus.lower, DayFocus.conditioning, DayFocus.upper, DayFocus.lower, DayFocus.mobility],
    };
  }

  /// Spread [n] days through the week starting on [weekStart] (ISO
  /// weekday), leaving rest days between full-body sessions.
  static List<int> defaultWeekdays(int n, int weekStart) {
    final offsets = switch (n) {
      <= 1 => const [0],
      2 => const [0, 3],
      3 => const [0, 2, 4],
      4 => const [0, 1, 3, 4],
      5 => const [0, 1, 2, 4, 5],
      _ => const [0, 1, 2, 3, 4, 5],
    };
    return [for (final o in offsets) (weekStart - 1 + o) % 7 + 1];
  }

  /// True when two sessions that load the same muscles fall on back-to-back
  /// days (e.g. full body on Sunday and Monday) — the UI warns about it.
  static bool needsMoreRecovery(List<WorkoutDay> days) {
    bool heavy(DayFocus f) => f == DayFocus.fullBody || f == DayFocus.upper || f == DayFocus.lower;
    for (final a in days) {
      for (final b in days) {
        if (identical(a, b) || !heavy(a.focus)) continue;
        final next = a.weekday % 7 + 1;
        final clash = a.focus == b.focus || a.focus == DayFocus.fullBody || b.focus == DayFocus.fullBody;
        if (b.weekday == next && clash) return true;
      }
    }
    return false;
  }

  static const _slots = {
    DayFocus.fullBody: [
      [Pattern.squat, Pattern.pushH, Pattern.hinge, Pattern.pullH, Pattern.core],
      [Pattern.lunge, Pattern.pushV, Pattern.glute, Pattern.pullV, Pattern.core],
      [Pattern.squat, Pattern.pushH, Pattern.lunge, Pattern.pullH, Pattern.core],
    ],
    DayFocus.upper: [
      [Pattern.pushH, Pattern.pullH, Pattern.pushV, Pattern.pullV, Pattern.triceps, Pattern.biceps, Pattern.core],
      [Pattern.pushV, Pattern.pullV, Pattern.pushH, Pattern.pullH, Pattern.biceps, Pattern.triceps, Pattern.core],
    ],
    DayFocus.lower: [
      [Pattern.squat, Pattern.hinge, Pattern.lunge, Pattern.calf, Pattern.core],
      [Pattern.hinge, Pattern.lunge, Pattern.squat, Pattern.glute, Pattern.core],
    ],
    DayFocus.conditioning: [
      [Pattern.cardio, Pattern.core, Pattern.mobility],
    ],
    DayFocus.mobility: [
      [Pattern.mobility, Pattern.mobility, Pattern.mobility, Pattern.core, Pattern.mobility, Pattern.mobility],
    ],
  };

  /// When nothing fits a pattern (e.g. no hinge at home without weights).
  static const _fallback = {
    Pattern.hinge: Pattern.glute,
    Pattern.pullV: Pattern.pullH,
    Pattern.pushV: Pattern.pushH,
    Pattern.lunge: Pattern.squat,
  };

  static int levelMax(FitnessLevel l) => switch (l) {
        FitnessLevel.beginner => 1,
        FitnessLevel.intermediate => 2,
        FitnessLevel.advanced => 3,
      };

  WorkoutDay _day(FitnessProfile p, WorkoutPlace place, int weekday, DayFocus focus, int variant) {
    final templates = _slots[focus]!;
    final slots = [...templates[variant % templates.length]];
    final finisher = (p.goal == FitnessGoal.fatLoss || p.goal == FitnessGoal.general) &&
        (focus == DayFocus.fullBody || focus == DayFocus.upper || focus == DayFocus.lower);
    if (finisher) slots.add(Pattern.cardio);

    final used = <String>{};
    final chosen = <PlannedExercise>[];
    for (final s in slots) {
      final e = pick(s, place, p.homeEquipment, p.level, variant, used) ??
          (_fallback[s] == null ? null : pick(_fallback[s]!, place, p.homeEquipment, p.level, variant, used));
      if (e == null) continue;
      used.add(e.id);
      chosen.add(prescribe(e, p.goal, p.level, focus: focus, finisher: finisher && s == Pattern.cardio));
    }

    // Fit the session length: drop optional work from the end, keeping the
    // core exercise and at least two main movements.
    while (minutesOf(chosen) > p.minutesPerSession && chosen.length > 3) {
      final i = chosen.lastIndexWhere((x) => exerciseById(x.exerciseId)!.pattern != Pattern.core);
      if (i < 2) break;
      chosen.removeAt(i);
    }
    return WorkoutDay(weekday: weekday, focus: focus, exercises: chosen, minutes: minutesOf(chosen));
  }

  /// The best available exercise for [pattern]: as hard as the level
  /// allows, then the best fit for the place (machines and free weights at
  /// the gym; the user's own equipment at home), rotated by [variant] so
  /// A/B days differ.
  static Exercise? pick(Pattern pattern, WorkoutPlace place, Set<Equipment> home, FitnessLevel level, int variant,
      [Set<String> exclude = const {}]) {
    final max = levelMax(level);
    int fit(Exercise e) {
      final weights = e.equipment.any((q) => q != Equipment.bands);
      return switch (place) {
        WorkoutPlace.gym => e.gymOnly.isNotEmpty || weights ? 2 : (e.equipment.isEmpty ? 1 : 0),
        WorkoutPlace.home => weights ? 2 : (e.equipment.isNotEmpty ? 1 : 0),
      };
    }

    final c = exercises
        .where((e) => e.pattern == pattern && e.difficulty <= max && e.availableAt(place, home) && !exclude.contains(e.id))
        .toList()
      ..sort((a, b) {
        final d = b.difficulty.compareTo(a.difficulty);
        if (d != 0) return d;
        final f = fit(b).compareTo(fit(a));
        return f != 0 ? f : a.id.compareTo(b.id);
      });
    if (c.isEmpty) return null;
    // Rotate only among the equally good options.
    final top = c.where((e) => e.difficulty == c.first.difficulty && fit(e) == fit(c.first)).toList();
    return top[variant % top.length];
  }

  /// Sets, reps or time, and rest for [e] given the goal and level.
  static PlannedExercise prescribe(Exercise e, FitnessGoal goal, FitnessLevel level,
      {DayFocus focus = DayFocus.fullBody, bool finisher = false}) {
    final beginner = level == FitnessLevel.beginner;
    final advanced = level == FitnessLevel.advanced;
    switch (e.pattern) {
      case Pattern.cardio:
        final minutes = finisher ? 10 : (goal == FitnessGoal.fatLoss ? 25 : 20) - (beginner ? 5 : 0);
        return PlannedExercise(exerciseId: e.id, sets: 1, seconds: minutes * 60, restSeconds: 0);
      case Pattern.mobility:
        return PlannedExercise(exerciseId: e.id, sets: 2, seconds: beginner ? 30 : 45, restSeconds: 15);
      default:
        break;
    }
    if (e.timed) {
      final hold = beginner ? 20 : (advanced ? 45 : 30);
      return PlannedExercise(exerciseId: e.id, sets: 3, seconds: hold, restSeconds: 45);
    }
    final isolation = e.pattern == Pattern.biceps || e.pattern == Pattern.triceps || e.pattern == Pattern.calf;
    final core = e.pattern == Pattern.core;
    var (sets, reps, rest) = switch (goal) {
      FitnessGoal.strength => (beginner ? 3 : (advanced ? 5 : 4), beginner ? 8 : 6, beginner ? 90 : 120),
      FitnessGoal.muscle => (advanced ? 4 : 3, 10, 75),
      FitnessGoal.fatLoss => (3, 12, 45),
      FitnessGoal.general => (beginner ? 2 : 3, 10, 60),
      FitnessGoal.mobility => (2, 10, 45),
    };
    if (isolation || core) {
      sets = sets.clamp(2, 3);
      reps += 2;
      rest = rest.clamp(30, 60);
    }
    return PlannedExercise(exerciseId: e.id, sets: sets, reps: reps, restSeconds: rest);
  }

  /// Estimated minutes, warm-up included.
  static int minutesOf(List<PlannedExercise> list) {
    var seconds = warmupMinutes * 60;
    for (final x in list) {
      final work = x.seconds ?? (x.reps! * 4);
      seconds += x.sets * (work + x.restSeconds) + 60;
    }
    return (seconds / 60).ceil();
  }
}

enum SwapKind { same, alternative, approximate, none }

/// One line of "do this gym day at home instead".
class Swap {
  const Swap(this.original, this.replacement, this.kind);
  final PlannedExercise original;
  final PlannedExercise? replacement;
  final SwapKind kind;
}

/// A home version of [day]: the same exercise when possible, else a listed
/// alternative, else something for the same movement marked approximate.
/// Never pretends every exercise has an exact match: what has no home
/// option is reported as such.
List<Swap> homeVersion(WorkoutDay day, FitnessProfile p) {
  final used = <String>{};
  final out = <Swap>[];
  for (final x in day.exercises) {
    final e = exerciseById(x.exerciseId)!;
    if (e.availableAt(WorkoutPlace.home, p.homeEquipment)) {
      used.add(e.id);
      out.add(Swap(x, x, SwapKind.same));
      continue;
    }
    final alt = e.alternatives
        .map(exerciseById)
        .whereType<Exercise>()
        .where((a) => a.availableAt(WorkoutPlace.home, p.homeEquipment) && !used.contains(a.id))
        .firstOrNull;
    if (alt != null) {
      used.add(alt.id);
      out.add(Swap(x, PlanGenerator.prescribe(alt, p.goal, p.level, focus: day.focus), SwapKind.alternative));
      continue;
    }
    final near = PlanGenerator.pick(e.pattern, WorkoutPlace.home, p.homeEquipment, p.level, 0, used) ??
        PlanGenerator.pick(e.pattern, WorkoutPlace.home, p.homeEquipment, FitnessLevel.advanced, 0, used);
    if (near != null) {
      used.add(near.id);
      out.add(Swap(x, PlanGenerator.prescribe(near, p.goal, p.level, focus: day.focus), SwapKind.approximate));
    } else {
      out.add(Swap(x, null, SwapKind.none));
    }
  }
  return out;
}
