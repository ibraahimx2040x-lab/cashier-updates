import '../../data/models/fitness.dart';
import '../../data/models/health.dart';
import 'exercises.dart';
import 'plan_generator.dart';

/// What an exercise works, in more detail than [Muscle] (v4 change 7).
enum Target {
  quads, hamstrings, glutes, calves, hips, chest, upperBack, lats, lowerBack, shoulders, biceps, triceps, abs, obliques,
  neck, pelvicFloor, heartLungs, diaphragm,
}

/// A safety warning shown with the exercise, beyond its own [Exercise.tipAr].
enum Caution { knees, back, shoulders, heavyLoad, heart, balance, neck, pregnancy, stopIfPain }

/// Exercises with start and end photos in `assets/exercises/<id>_0.jpg` and
/// `_1.jpg` (free-exercise-db, public domain). Each one was checked against
/// the exercise's own steps; the rest show none rather than a near match.
const _withPhotos = {
  'bw_squat', 'goblet_squat', 'barbell_squat', 'leg_press', 'reverse_lunge', 'split_squat', 'step_up', 'glute_bridge',
  'db_rdl', 'kb_swing', 'barbell_deadlift', 'leg_curl', 'incline_pushup', 'pushup', 'db_floor_press', 'db_bench_press',
  'machine_chest_press', 'db_shoulder_press', 'chair_dip', 'db_overhead_triceps', 'triceps_pushdown', 'db_row',
  'cable_row', 'superman', 'pullup', 'lat_pulldown', 'db_curl', 'plank', 'side_plank', 'dead_bug', 'treadmill', 'bike',
  'cat_cow', 'hip_flexor_stretch', 'hamstring_stretch', 'childs_pose', 'calf_stretch', 'neck_stretch',
  'single_leg_rdl_bw', 'standing_side_leg_raise',
};

/// Start and end photos, or empty.
List<String> exercisePhotos(Exercise e) =>
    _withPhotos.contains(e.id) ? ['assets/exercises/${e.id}_0.jpg', 'assets/exercises/${e.id}_1.jpg'] : const [];

typedef _T = Target;

/// Main targets first, then the ones that help.
const _targets = <String, (List<Target>, List<Target>)>{
  'bw_squat': ([_T.quads, _T.glutes], [_T.hamstrings, _T.abs]),
  'goblet_squat': ([_T.quads, _T.glutes], [_T.abs, _T.upperBack]),
  'barbell_squat': ([_T.quads, _T.glutes], [_T.hamstrings, _T.lowerBack, _T.abs]),
  'leg_press': ([_T.quads, _T.glutes], [_T.hamstrings]),
  'reverse_lunge': ([_T.quads, _T.glutes], [_T.hamstrings, _T.calves]),
  'split_squat': ([_T.quads, _T.glutes], [_T.hamstrings, _T.hips]),
  'step_up': ([_T.quads, _T.glutes], [_T.calves]),
  'glute_bridge': ([_T.glutes], [_T.hamstrings, _T.abs]),
  'db_rdl': ([_T.hamstrings, _T.glutes], [_T.lowerBack]),
  'kb_swing': ([_T.glutes, _T.hamstrings], [_T.lowerBack, _T.shoulders, _T.heartLungs]),
  'barbell_deadlift': ([_T.hamstrings, _T.glutes, _T.lowerBack], [_T.quads, _T.upperBack, _T.lats]),
  'leg_curl': ([_T.hamstrings], [_T.calves]),
  'calf_raise': ([_T.calves], []),
  'incline_pushup': ([_T.chest], [_T.triceps, _T.shoulders]),
  'pushup': ([_T.chest, _T.triceps], [_T.shoulders, _T.abs]),
  'db_floor_press': ([_T.chest], [_T.triceps, _T.shoulders]),
  'db_bench_press': ([_T.chest], [_T.triceps, _T.shoulders]),
  'machine_chest_press': ([_T.chest], [_T.triceps, _T.shoulders]),
  'pike_pushup': ([_T.shoulders], [_T.triceps, _T.upperBack]),
  'band_press': ([_T.shoulders], [_T.triceps]),
  'db_shoulder_press': ([_T.shoulders], [_T.triceps, _T.upperBack]),
  'chair_dip': ([_T.triceps], [_T.chest, _T.shoulders]),
  'db_overhead_triceps': ([_T.triceps], []),
  'triceps_pushdown': ([_T.triceps], []),
  'band_row': ([_T.upperBack, _T.lats], [_T.biceps]),
  'db_row': ([_T.lats, _T.upperBack], [_T.biceps]),
  'cable_row': ([_T.upperBack, _T.lats], [_T.biceps]),
  'superman': ([_T.lowerBack], [_T.glutes, _T.upperBack]),
  'band_pulldown': ([_T.lats], [_T.biceps, _T.upperBack]),
  'pullup': ([_T.lats, _T.upperBack], [_T.biceps, _T.abs]),
  'lat_pulldown': ([_T.lats], [_T.biceps, _T.upperBack]),
  'db_curl': ([_T.biceps], []),
  'band_curl': ([_T.biceps], []),
  'plank': ([_T.abs], [_T.shoulders, _T.glutes]),
  'side_plank': ([_T.obliques], [_T.abs, _T.shoulders, _T.hips]),
  'dead_bug': ([_T.abs], [_T.hips]),
  'bird_dog': ([_T.abs, _T.lowerBack], [_T.glutes, _T.shoulders]),
  'hanging_knee_raise': ([_T.abs], [_T.lats]),
  'brisk_walk': ([_T.heartLungs], [_T.calves, _T.glutes]),
  'jumping_jacks': ([_T.heartLungs], [_T.calves, _T.shoulders]),
  'treadmill': ([_T.heartLungs], [_T.quads, _T.calves]),
  'bike': ([_T.heartLungs], [_T.quads, _T.glutes]),
  'cat_cow': ([_T.lowerBack, _T.upperBack], [_T.abs]),
  'hip_flexor_stretch': ([_T.hips], [_T.quads]),
  'thoracic_rotation': ([_T.upperBack], [_T.obliques]),
  'hamstring_stretch': ([_T.hamstrings], [_T.lowerBack]),
  'childs_pose': ([_T.lowerBack], [_T.lats, _T.hips]),
  'quad_stretch': ([_T.quads], [_T.hips]),
  'figure_four_stretch': ([_T.glutes, _T.hips], []),
  'chest_doorway_stretch': ([_T.chest], [_T.shoulders]),
  'calf_stretch': ([_T.calves], []),
  'neck_stretch': ([_T.neck], []),
  'chin_tuck': ([_T.neck], [_T.upperBack]),
  'prone_y_raise': ([_T.upperBack], [_T.shoulders]),
  'single_leg_stand': ([_T.hips], [_T.calves, _T.abs]),
  'tandem_stance': ([_T.hips], [_T.calves]),
  'heel_toe_walk': ([_T.hips], [_T.calves]),
  'single_leg_rdl_bw': ([_T.hamstrings, _T.glutes], [_T.hips]),
  'standing_side_leg_raise': ([_T.glutes, _T.hips], []),
  'pelvic_floor_hold': ([_T.pelvicFloor], [_T.abs]),
  'pelvic_floor_quick': ([_T.pelvicFloor], []),
  'diaphragmatic_breathing': ([_T.diaphragm], [_T.abs, _T.pelvicFloor]),
  'clamshell': ([_T.glutes], [_T.hips]),
  'sit_to_stand': ([_T.quads, _T.glutes], []),
  'pelvic_tilt_wall': ([_T.abs], [_T.lowerBack]),
  'heel_slide': ([_T.abs], [_T.hips]),
};

/// Main targets, then helpers. Falls back to nothing for an unknown id.
(List<Target>, List<Target>) targetsOf(Exercise e) => _targets[e.id] ?? (const [], const []);

/// The goals an exercise serves, for browsing the library by goal.
Set<FitnessGoal> goalsOf(Exercise e) => switch (e.pattern) {
      Pattern.squat || Pattern.hinge || Pattern.lunge => {FitnessGoal.strength, FitnessGoal.muscle, FitnessGoal.fatLoss, FitnessGoal.general},
      Pattern.pushH || Pattern.pushV || Pattern.pullH || Pattern.pullV => {FitnessGoal.strength, FitnessGoal.muscle, FitnessGoal.general},
      Pattern.glute || Pattern.calf || Pattern.biceps || Pattern.triceps => {FitnessGoal.muscle, FitnessGoal.general},
      Pattern.core => {FitnessGoal.strength, FitnessGoal.general},
      Pattern.cardio => {FitnessGoal.fatLoss, FitnessGoal.general},
      Pattern.mobility || Pattern.balance || Pattern.pelvicFloor || Pattern.breathing || Pattern.gentle => {FitnessGoal.mobility, FitnessGoal.general},
    };

const _heavy = {'barbell_squat', 'barbell_deadlift', 'db_bench_press'};
const _onBack = {'glute_bridge', 'dead_bug', 'db_floor_press', 'db_bench_press', 'heel_slide'};

/// Warnings for [e], most specific first; "stop if it hurts" always last.
/// The pregnancy note is left out for men.
List<Caution> cautionsOf(Exercise e, {Sex? sex}) => [
      if (e.pattern case Pattern.squat || Pattern.lunge) Caution.knees,
      if (e.pattern == Pattern.hinge || e.id == 'superman' || e.id == 'barbell_squat') Caution.back,
      if (e.pattern == Pattern.pushV || e.pattern == Pattern.pullV || e.id == 'chair_dip') Caution.shoulders,
      if (_heavy.contains(e.id)) Caution.heavyLoad,
      if (e.pattern == Pattern.cardio || e.id == 'kb_swing') Caution.heart,
      if (e.pattern == Pattern.balance) Caution.balance,
      if (e.id case 'neck_stretch' || 'chin_tuck') Caution.neck,
      if (sex != Sex.male && (e.pattern == Pattern.pelvicFloor || _onBack.contains(e.id) || e.pattern == Pattern.core)) Caution.pregnancy,
      Caution.stopIfPain,
    ];

/// Suggested sets × reps (or time) and rest for each level, for [goal].
Map<FitnessLevel, PlannedExercise> dosageOf(Exercise e, FitnessGoal goal) =>
    {for (final l in FitnessLevel.values) l: PlanGenerator.prescribe(e, goal, l)};

/// The library, narrowed by muscle, level, goal, place and a name search
/// (Arabic or English), ordered by muscle group, then easiest first.
List<Exercise> filterExercises({
  Muscle? muscle,
  int? level,
  FitnessGoal? goal,
  WorkoutPlace? place,
  Set<Equipment> home = const {},
  String query = '',
}) {
  final q = query.trim().toLowerCase();
  return [
    for (final e in exercises)
      if ((muscle == null || e.muscle == muscle) &&
          (level == null || e.difficulty == level) &&
          (goal == null || goalsOf(e).contains(goal)) &&
          (place == null || (place == WorkoutPlace.gym ? true : e.availableAt(WorkoutPlace.home, home))) &&
          (q.isEmpty || e.ar.contains(q) || e.en.toLowerCase().contains(q)))
        e,
  ]..sort((a, b) {
      final m = a.muscle.index.compareTo(b.muscle.index);
      return m != 0 ? m : a.difficulty.compareTo(b.difficulty);
    });
}
