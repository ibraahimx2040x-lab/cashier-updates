import '../../data/app_data.dart';
import '../../data/models/fitness.dart';

/// What a set measured: weight (with reps), reps alone, or time.
enum ProgressKind { weight, reps, seconds }

/// One session's best set for an exercise.
class ProgressPoint {
  const ProgressPoint(this.day, this.value, {this.reps});
  final String day;

  /// Kilograms, reps or seconds, depending on [ExerciseProgress.kind].
  final double value;

  /// Reps done at that weight, for weight points.
  final int? reps;
}

class ExerciseProgress {
  const ExerciseProgress({required this.exerciseId, required this.kind, required this.points});
  final String exerciseId;
  final ProgressKind kind;

  /// Oldest first, one per session.
  final List<ProgressPoint> points;

  ProgressPoint get best => points.reduce((a, b) => b.value > a.value || (b.value == a.value && (b.reps ?? 0) > (a.reps ?? 0)) ? b : a);
  ProgressPoint get last => points.last;

  /// Last minus first; positive means improving.
  double get change => points.length < 2 ? 0 : points.last.value - points.first.value;
}

/// Per exercise, the best set of each session, from what the user logged.
/// An exercise counts by weight once any set had a weight, else by reps,
/// else by time. Most recently done first.
List<ExerciseProgress> exerciseProgress(AppData d) {
  final sessions = [...d.workoutSessions]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  final byExercise = <String, List<(String, List<SetLog>)>>{};
  for (final s in sessions) {
    final sets = <String, List<SetLog>>{};
    for (final x in s.sets) {
      (sets[x.exerciseId] ??= []).add(x);
    }
    for (final e in sets.entries) {
      (byExercise[e.key] ??= []).add((s.day, e.value));
    }
  }
  final out = <ExerciseProgress>[];
  for (final e in byExercise.entries) {
    final all = [for (final (_, sets) in e.value) ...sets];
    final kind = all.any((x) => (x.weightKg ?? 0) > 0)
        ? ProgressKind.weight
        : all.any((x) => (x.reps ?? 0) > 0)
            ? ProgressKind.reps
            : ProgressKind.seconds;
    final points = <ProgressPoint>[];
    for (final (day, sets) in e.value) {
      ProgressPoint? top;
      for (final x in sets) {
        final p = switch (kind) {
          ProgressKind.weight => ProgressPoint(day, x.weightKg ?? 0, reps: x.reps),
          ProgressKind.reps => ProgressPoint(day, (x.reps ?? 0).toDouble()),
          ProgressKind.seconds => ProgressPoint(day, (x.seconds ?? 0).toDouble()),
        };
        if (top == null || p.value > top.value || (p.value == top.value && (p.reps ?? 0) > (top.reps ?? 0))) top = p;
      }
      if (top != null && top.value > 0) points.add(top);
    }
    if (points.isNotEmpty) out.add(ExerciseProgress(exerciseId: e.key, kind: kind, points: points));
  }
  out.sort((a, b) => b.last.day.compareTo(a.last.day));
  return out;
}
