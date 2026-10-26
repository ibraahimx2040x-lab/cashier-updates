import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/core/utils/dates.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/learning.dart';
import 'package:hayati/data/models/settings.dart';
import 'package:hayati/data/remote/rows.dart';
import 'package:hayati/domain/assistant/engine.dart';
import 'package:hayati/domain/day_timeline.dart';
import 'package:hayati/domain/learning/curriculum.dart';
import 'package:hayati/domain/learning/path.dart';
import 'package:hayati/l10n/app_localizations.dart';

import 'helpers.dart';

void main() {
  group('course content', () {
    test('ids are unique, answers valid, every level complete', () {
      final allQ = [...placementQuestions, for (final l in lessons) ...l.quiz];
      expect(allQ.map((q) => q.id).toSet().length, allQ.length, reason: 'question ids');
      expect(lessons.map((l) => l.id).toSet().length, lessons.length, reason: 'lesson ids');
      final words = [for (final l in lessons) ...l.words];
      expect(words.map((w) => w.id).toSet().length, words.length, reason: 'word ids');
      for (final q in allQ) {
        expect(q.answer, inInclusiveRange(0, q.options.length - 1), reason: q.id);
        expect(q.options.toSet().length, q.options.length, reason: '${q.id}: duplicate option');
        if (q.passageId != null) expect(passageById(q.passageId), isNotNull, reason: q.id);
      }
      for (final level in Cefr.values) {
        expect(lessonsAt(level), isNotEmpty, reason: '$level lessons');
        for (final s in Skill.values) {
          expect(placementQuestions.where((q) => q.level == level && q.skill == s), hasLength(2), reason: '$level $s');
        }
      }
      for (final l in lessons) {
        expect(l.quiz.length, greaterThanOrEqualTo(5), reason: l.id);
        expect(l.words.length, greaterThanOrEqualTo(3), reason: l.id);
        expect(l.quiz.every((q) => q.level == l.level), isTrue, reason: l.id);
      }
    });
  });

  test('English inside Arabic text keeps its order (bidi isolates)', () {
    expect(isolateLatin('استخدم by: The book was written by Naguib Mahfouz.'),
        'استخدم \u2066by: The book was written by Naguib Mahfouz.\u2069');
    expect(isolateLatin('بُني (تصريف build)'), 'بُني (تصريف \u2066build\u2069)');
    expect(isolateLatin('بدون إنجليزية'), 'بدون إنجليزية');
  });

  group('placement', () {
    Map<String, int> answers(bool Function(Question) right) => {
          for (final q in placementQuestions) q.id: right(q) ? q.answer : (q.answer + 1) % q.options.length,
        };

    test('all right → B2, all wrong → A1', () {
      final top = scorePlacement(answers((_) => true));
      expect(top.level, Cefr.b2);
      expect(top.scores[Skill.grammar]!.percent, 100);
      expect(scorePlacement(answers((_) => false)).level, Cefr.a1);
      expect(scorePlacement(const {}).level, Cefr.a1);
    });

    test('each skill gets its own level; the start level is the middle one', () {
      final p = scorePlacement(answers((q) => switch (q.skill) {
            Skill.vocabulary => q.level.index <= Cefr.b1.index,
            Skill.grammar => q.level.index <= Cefr.a2.index,
            Skill.reading => true,
          }));
      expect(p.skillLevels, {Skill.vocabulary: Cefr.b1, Skill.grammar: Cefr.a2, Skill.reading: Cefr.b2});
      expect(p.level, Cefr.b1);
    });

    test('a level counts only if the levels below were passed', () {
      // Right at B1/B2 but wrong at A2: stays at A1 (lucky guesses don't skip).
      final p = scorePlacement(answers((q) => q.level != Cefr.a2));
      expect(p.skillLevels.values, everyElement(Cefr.a1));
    });
  });

  group('path', () {
    test('a lesson below 80% comes back before the next one', () async {
      final c = await signedInContainer();
      addTearDown(c.dispose);
      final data = c.read(dataProvider.notifier);
      data.startLearning(Cefr.a2, 3);
      AppData d() => c.read(dataProvider);
      final first = lessonsAt(Cefr.a2).first;
      expect(nextLesson(d())!.id, first.id);
      data.recordLesson(first.id, 60, [for (final w in first.words) w.id]);
      expect(nextLesson(d())!.id, first.id, reason: 'not mastered: repeat');
      data.recordLesson(first.id, 100, [for (final w in first.words) w.id]);
      data.recordLesson(first.id, 40, [for (final w in first.words) w.id]);
      final p = d().lessonProgress(first.id)!;
      expect(p.bestScore, 100, reason: 'best score kept');
      expect(p.attempts, 3);
      expect(d().vocabReviews, hasLength(first.words.length), reason: 'words added once');
      expect(d().vocabReviews.first.due, dayKey(fixedNow.add(const Duration(days: 1))));
      expect(nextLesson(d())!.id, lessonsAt(Cefr.a2)[1].id);
      for (final l in lessonsAt(Cefr.a2)) {
        data.recordLesson(l.id, 90, const []);
      }
      expect(nextLesson(d()), isNull, reason: 'level check time');
      expect(lessonsThisWeek(d(), fixedNow, 7), lessonsAt(Cefr.a2).length);

      data.recordLevelCheck(
        Assessment(id: 'x', kind: AssessmentKind.levelCheck, level: Cefr.a2, scores: const {}, passed: false, takenAt: fixedNow),
        next: Cefr.b1,
      );
      expect(d().learningPath!.level, Cefr.a2, reason: 'failed check: stay');
      data.recordLevelCheck(
        Assessment(id: 'y', kind: AssessmentKind.levelCheck, level: Cefr.a2, scores: const {}, passed: true, takenAt: fixedNow),
        next: levelAfter(Cefr.a2),
      );
      expect(d().learningPath!.level, Cefr.b1);
      expect(d().assessments, hasLength(2));
    });

    test('review boxes grow on success and reset on a miss', () {
      final now = DateTime(2026, 3, 10);
      const r = VocabReview(id: 'r', wordId: 'w_tired', box: 1, due: '2026-03-10');
      expect(nextReview(r, true, now), (2, '2026-03-12'));
      expect(nextReview(r, false, now), (1, '2026-03-11'));
      expect(nextReview(const VocabReview(id: 'r', wordId: 'w', box: 5, due: ''), true, now).$1, 5);
      final d = AppData(vocabReviews: const [r, VocabReview(id: 's', wordId: 'w_ready', box: 2, due: '2026-03-20')]);
      expect(dueReviews(d, now).map((x) => x.wordId), ['w_tired']);
    });

    test('level check uses the level\'s questions', () {
      final qs = levelCheckQuestions(Cefr.b1);
      expect(qs.every((q) => q.level == Cefr.b1), isTrue);
      expect(qs.length, 6 + 2 * lessonsAt(Cefr.b1).length);
    });
  });

  group('data', () {
    test('rows and JSON round-trip', () {
      final path = LearningPath(id: 'p', level: Cefr.b1, weeklyGoal: 5, startedAt: fixedNow);
      expect(learningPathFrom(learningPathRow(path)).weeklyGoal, 5);
      final a = Assessment(
        id: 'a',
        kind: AssessmentKind.placement,
        level: Cefr.a2,
        scores: const {Skill.reading: SkillScore(6, 8)},
        skillLevels: const {Skill.reading: Cefr.b1},
        passed: true,
        takenAt: fixedNow,
      );
      final back = assessmentFrom(assessmentRow(a));
      expect(back.scores[Skill.reading]!.correct, 6);
      expect(back.skillLevels[Skill.reading], Cefr.b1);
      expect(Assessment.fromJson(a.toJson()).level, Cefr.a2);
      final p = LessonProgress(id: 'l', lessonId: 'a1_be', bestScore: 80, attempts: 2, lastAt: fixedNow);
      expect(lessonProgressFrom(lessonProgressRow(p)).mastered, isTrue);
      const v = VocabReview(id: 'v', wordId: 'w_ready', box: 3, due: '2026-03-14');
      expect(vocabReviewFrom(vocabReviewRow(v)).box, 3);
    });
  });

  group('day and assistant', () {
    final now = DateTime(2026, 3, 10, 9);
    final l = lookupAppLocalizations(const Locale('ar'));

    test("today's lesson is a flexible item until a lesson is studied", () {
      final d = AppData(learningPaths: [LearningPath(id: 'p', level: Cefr.a1, weeklyGoal: 3, startedAt: now)]);
      final item = buildTimeline(d, now).items.where((i) => i.kind == TimelineKind.lesson).single;
      expect(item.refId, lessonsAt(Cefr.a1).first.id);
      final studied = d.copyWith(lessonProgresses: [LessonProgress(id: 'x', lessonId: 'a1_be', bestScore: 40, attempts: 1, lastAt: now)]);
      expect(buildTimeline(studied, now).items.where((i) => i.kind == TimelineKind.lesson), isEmpty);
    });

    test('"I missed my lesson" names the next lesson and the reviews first', () {
      final d = AppData(
        learningPaths: [LearningPath(id: 'p', level: Cefr.a1, weeklyGoal: 3, startedAt: now)],
        vocabReviews: const [VocabReview(id: 'r', wordId: 'w_ready', box: 1, due: '2026-03-01')],
      );
      final r = LocalAssistantEngine(l).respond('فاتني الدرس اليوم', AssistantContext(d, const AssistantPermissions()), now);
      expect(r.calls, isEmpty);
      expect(r.text, contains(lessonsAt(Cefr.a1).first.title('ar')));
      expect(r.text, contains(l.aiReviewFirst(1)));
      final off = LocalAssistantEngine(l)
          .respond('فاتني الدرس', AssistantContext(d, const AssistantPermissions(shareLearning: false)), now);
      expect(off.text, l.aiNeedsSharing(l.navEnglish));
    });
  });
}
