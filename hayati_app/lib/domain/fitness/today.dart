import '../../data/app_data.dart';
import '../../data/models/fitness.dart';

/// Today's workout for [d] at the user's preferred place (falls back to the
/// other place's plan). Null on rest days or without a plan.
(WorkoutPlan, WorkoutDay)? todaysWorkout(AppData d, DateTime now) {
  final f = d.settings.fitness;
  if (f == null) return null;
  for (final place in [f.preferredPlace, ...WorkoutPlace.values.where((p) => p != f.preferredPlace)]) {
    final plan = d.activePlan(place);
    final day = plan?.dayFor(now.weekday);
    if (plan != null && day != null) return (plan, day);
  }
  return null;
}
