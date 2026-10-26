/// English learning (design doc v2, section 3-e): the user's path, test
/// results, lesson progress and vocabulary reviews.
library;

/// CEFR levels covered by the built-in course.
enum Cefr { a1, a2, b1, b2 }

/// Skills the app can measure on its own. Listening and speaking need audio
/// and speech tools and are not assessed yet.
enum Skill { vocabulary, grammar, reading }

/// One path per subject (only English for now).
class LearningPath {
  const LearningPath({required this.id, required this.level, required this.weeklyGoal, required this.startedAt});
  final String id;

  /// The level whose lessons are being studied.
  final Cefr level;

  /// Lessons per week the user aims for.
  final int weeklyGoal;
  final DateTime startedAt;

  LearningPath copyWith({Cefr? level, int? weeklyGoal}) =>
      LearningPath(id: id, level: level ?? this.level, weeklyGoal: weeklyGoal ?? this.weeklyGoal, startedAt: startedAt);

  Map<String, Object?> toJson() => {
        'id': id,
        'level': level.name,
        'weeklyGoal': weeklyGoal,
        'startedAt': startedAt.toUtc().toIso8601String(),
      };

  factory LearningPath.fromJson(Map<String, Object?> j) => LearningPath(
        id: j['id'] as String,
        level: Cefr.values.byName(j['level'] as String),
        weeklyGoal: j['weeklyGoal'] as int,
        startedAt: DateTime.parse(j['startedAt'] as String).toLocal(),
      );
}

enum AssessmentKind { placement, levelCheck }

/// Correct answers out of total for one skill.
class SkillScore {
  const SkillScore(this.correct, this.total);
  final int correct;
  final int total;
  int get percent => total == 0 ? 0 : (correct * 100 / total).round();

  Map<String, Object?> toJson() => {'correct': correct, 'total': total};
  factory SkillScore.fromJson(Map<String, Object?> j) => SkillScore(j['correct'] as int, j['total'] as int);
}

/// A placement test or end-of-level check, kept as history.
class Assessment {
  const Assessment({
    required this.id,
    required this.kind,
    required this.level,
    required this.scores,
    this.skillLevels = const {},
    required this.passed,
    required this.takenAt,
  });

  final String id;
  final AssessmentKind kind;

  /// Placement: the level to start at. Level check: the level tested.
  final Cefr level;
  final Map<Skill, SkillScore> scores;

  /// Placement only: the level reached in each skill.
  final Map<Skill, Cefr> skillLevels;

  /// Level check: moved up. Placement: always true.
  final bool passed;
  final DateTime takenAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.name,
        'level': level.name,
        'scores': {for (final e in scores.entries) e.key.name: e.value.toJson()},
        'skillLevels': {for (final e in skillLevels.entries) e.key.name: e.value.name},
        'passed': passed,
        'takenAt': takenAt.toUtc().toIso8601String(),
      };

  factory Assessment.fromJson(Map<String, Object?> j) => Assessment(
        id: j['id'] as String,
        kind: AssessmentKind.values.byName(j['kind'] as String),
        level: Cefr.values.byName(j['level'] as String),
        scores: {
          for (final e in ((j['scores'] as Map?) ?? const {}).entries)
            if (Skill.values.any((s) => s.name == e.key))
              Skill.values.byName(e.key as String): SkillScore.fromJson((e.value as Map).cast()),
        },
        skillLevels: {
          for (final e in ((j['skillLevels'] as Map?) ?? const {}).entries)
            if (Skill.values.any((s) => s.name == e.key))
              Skill.values.byName(e.key as String): Cefr.values.byName(e.value as String),
        },
        passed: j['passed'] as bool,
        takenAt: DateTime.parse(j['takenAt'] as String).toLocal(),
      );
}

/// Best result on one lesson's quiz. A lesson counts as mastered at 80%.
class LessonProgress {
  const LessonProgress({required this.id, required this.lessonId, required this.bestScore, required this.attempts, required this.lastAt});
  final String id;
  final String lessonId;

  /// 0–100.
  final int bestScore;
  final int attempts;
  final DateTime lastAt;

  static const passMark = 80;
  bool get mastered => bestScore >= passMark;

  Map<String, Object?> toJson() => {
        'id': id,
        'lessonId': lessonId,
        'bestScore': bestScore,
        'attempts': attempts,
        'lastAt': lastAt.toUtc().toIso8601String(),
      };

  factory LessonProgress.fromJson(Map<String, Object?> j) => LessonProgress(
        id: j['id'] as String,
        lessonId: j['lessonId'] as String,
        bestScore: j['bestScore'] as int,
        attempts: j['attempts'] as int,
        lastAt: DateTime.parse(j['lastAt'] as String).toLocal(),
      );
}

/// Spaced review of a learned word (Leitner boxes 1–5).
class VocabReview {
  const VocabReview({required this.id, required this.wordId, required this.box, required this.due});
  final String id;
  final String wordId;
  final int box;

  /// YYYY-MM-DD of the next review.
  final String due;

  /// Days until the next review after a correct answer in [box].
  static const intervals = [1, 2, 4, 7, 15];

  Map<String, Object?> toJson() => {'id': id, 'wordId': wordId, 'box': box, 'due': due};
  factory VocabReview.fromJson(Map<String, Object?> j) =>
      VocabReview(id: j['id'] as String, wordId: j['wordId'] as String, box: j['box'] as int, due: j['due'] as String);
}
