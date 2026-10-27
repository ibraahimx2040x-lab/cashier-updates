import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/learning.dart';
import '../../domain/learning/curriculum.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_surface.dart';
import '../../widgets/motion.dart';
import 'quiz.dart';

/// Screen 18 — a lesson: explanation, examples, new words, then a short
/// quiz. 80% marks it mastered; below that it comes back before the next.
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

enum _Stage { learn, quiz, result }

class _LessonScreenState extends ConsumerState<LessonScreen> {
  _Stage _stage = _Stage.learn;
  int _score = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lesson = lessonById(widget.lessonId);
    if (lesson == null) return Scaffold(appBar: AppBar(), body: EmptyState(icon: Icons.search_off, title: l.itemGone));
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final lang = l.localeName;

    final learn = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Pill(label: l.cefr(lesson.level), color: scheme.primary, icon: Icons.school_outlined),
      const SizedBox(height: Space.m),
      SectionHeader(l.explanation),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final p in lesson.explainAr)
            Padding(padding: const EdgeInsets.only(bottom: Space.s), child: Text(isolateLatin(p), style: t.bodyLarge)),
        ]),
      ),
      const SizedBox(height: Space.l),
      SectionHeader(l.examples),
      for (final (en, ar) in lesson.examples)
        Padding(
          padding: const EdgeInsets.only(bottom: Space.s),
          child: AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(en, style: t.titleMedium?.copyWith(fontFamily: 'Inter')),
              ),
              const SizedBox(height: 2),
              Text(ar, style: t.bodyMedium?.copyWith(color: context.status.textSecondary)),
            ]),
          ),
        ),
      const SizedBox(height: Space.l),
      SectionHeader(l.newWords),
      AppCard(
        padding: const EdgeInsets.symmetric(vertical: Space.s),
        child: Column(children: [
          for (final w in lesson.words)
            ListTile(
              title: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(w.en, style: t.titleSmall?.copyWith(fontFamily: 'Inter')),
              ),
              subtitle: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(w.example, style: t.bodySmall?.copyWith(fontFamily: 'Inter')),
              ),
              trailing: Text(isolateLatin(w.ar), style: t.bodyMedium?.copyWith(color: scheme.primary)),
            ),
        ]),
      ),
      const SizedBox(height: Space.xl),
      PrimaryButton(label: l.startQuiz, icon: Icons.quiz_outlined, onPressed: () => setState(() => _stage = _Stage.quiz)),
    ]);

    final quiz = QuizRunner(
      questions: lesson.quiz,
      onDone: (a) {
        final score = scorePercent(lesson.quiz, a);
        ref.read(dataProvider.notifier).recordLesson(lesson.id, score, [for (final w in lesson.words) w.id]);
        setState(() {
          _score = score;
          _stage = _Stage.result;
        });
      },
    );

    final passed = _score >= LessonProgress.passMark;
    final result = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      HeroSurface(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(passed ? Icons.emoji_events_outlined : Icons.replay, color: AppColors.gold, size: 32),
          const SizedBox(height: Space.m),
          Text('$_score%', style: t.displaySmall?.copyWith(color: Colors.white)),
          Text(passed ? l.lessonMastered : l.lessonAgain, style: t.bodyMedium?.copyWith(color: Colors.white70)),
        ]),
      ),
      const SizedBox(height: Space.l),
      Text(l.wordsAddedToReview, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
      const SizedBox(height: Space.xl),
      PrimaryButton(label: l.backToPath, onPressed: () => context.go(Routes.english)),
      const SizedBox(height: Space.s),
      SecondaryButton(label: l.tryAgain, onPressed: () => setState(() => _stage = _Stage.learn)),
    ]);

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title(lang))),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl),
          children: [
            SmoothSwitcher(
              childKey: _stage,
              child: switch (_stage) {
                _Stage.learn => learn,
                _Stage.quiz => quiz,
                _Stage.result => result,
              },
            ),
          ],
        ),
      ),
    );
  }
}
