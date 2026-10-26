import '../../core/utils/dates.dart';
import '../../data/app_data.dart';
import '../../data/models/learning.dart';
import 'curriculum.dart';

/// Result of the placement test.
class Placement {
  const Placement(this.scores, this.skillLevels, this.level);
  final Map<Skill, SkillScore> scores;
  final Map<Skill, Cefr> skillLevels;

  /// Where to start: the middle of the three skill levels, so one weak or
  /// lucky skill doesn't decide alone.
  final Cefr level;
}

/// Scores [answers] (question id → chosen option). A skill reaches a level
/// when at least half of its questions at that level and every level below
/// were right.
Placement scorePlacement(Map<String, int> answers, [List<Question>? questions]) {
  final qs = questions ?? placementQuestions;
  final scores = <Skill, SkillScore>{};
  final levels = <Skill, Cefr>{};
  for (final s in Skill.values) {
    final mine = qs.where((q) => q.skill == s).toList();
    scores[s] = SkillScore(mine.where((q) => answers[q.id] == q.answer).length, mine.length);
    var reached = Cefr.a1;
    for (final l in Cefr.values) {
      final at = mine.where((q) => q.level == l).toList();
      if (at.isEmpty) continue;
      final right = at.where((q) => answers[q.id] == q.answer).length;
      if (right * 2 < at.length) break;
      reached = l;
    }
    levels[s] = reached;
  }
  final sorted = [...levels.values]..sort((a, b) => a.index.compareTo(b.index));
  return Placement(scores, levels, sorted[sorted.length ~/ 2]);
}

/// Pass mark for an end-of-level check.
const levelCheckPass = 75;

/// End-of-level check: the placement questions for [level] plus the first
/// two quiz questions of each of its lessons.
List<Question> levelCheckQuestions(Cefr level) => [
      ...placementQuestions.where((q) => q.level == level),
      for (final l in lessonsAt(level)) ...l.quiz.take(2),
    ];

/// The lesson to study next: the first lesson of the current level not yet
/// mastered. A lesson that wasn't mastered comes back before moving on.
/// Null when every lesson of the level is mastered (time for the check).
Lesson? nextLesson(AppData d) {
  final path = d.learningPath;
  if (path == null) return null;
  for (final l in lessonsAt(path.level)) {
    if (!(d.lessonProgress(l.id)?.mastered ?? false)) return l;
  }
  return null;
}

/// Whether a lesson quiz was taken today.
bool lessonDoneToday(AppData d, DateTime now) => d.lessonProgresses.any((p) => isSameDay(p.lastAt, now));

/// Words due for review on or before [now].
List<VocabReview> dueReviews(AppData d, DateTime now) {
  final today = dayKey(now);
  return d.vocabReviews.where((r) => r.due.compareTo(today) <= 0).toList()..sort((a, b) => a.due.compareTo(b.due));
}

/// Lessons studied in the week containing [now] (weeks start on
/// [weekStart], ISO weekday).
int lessonsThisWeek(AppData d, DateTime now, int weekStart) {
  final start = dateOnly(now).subtract(Duration(days: (now.weekday - weekStart + 7) % 7));
  final end = start.add(const Duration(days: 7));
  return d.lessonProgresses.where((p) => !p.lastAt.isBefore(start) && p.lastAt.isBefore(end)).length;
}

/// The next box and due day after answering a review.
(int, String) nextReview(VocabReview r, bool correct, DateTime now) {
  final box = correct ? (r.box + 1).clamp(1, VocabReview.intervals.length) : 1;
  final days = VocabReview.intervals[box - 1];
  return (box, dayKey(dateOnly(now).add(Duration(days: days))));
}

Cefr? levelAfter(Cefr l) => l.index + 1 < Cefr.values.length ? Cefr.values[l.index + 1] : null;
