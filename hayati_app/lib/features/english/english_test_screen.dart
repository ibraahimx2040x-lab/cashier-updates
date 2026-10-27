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
import '../../domain/learning/path.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_surface.dart';
import '../../widgets/motion.dart';
import 'quiz.dart';

/// Screen 17 — the placement test, and the end-of-level check (same screen,
/// different questions and outcome).
class EnglishTestScreen extends ConsumerStatefulWidget {
  const EnglishTestScreen({super.key, required this.levelCheck});
  final bool levelCheck;

  @override
  ConsumerState<EnglishTestScreen> createState() => _EnglishTestScreenState();
}

class _EnglishTestScreenState extends ConsumerState<EnglishTestScreen> {
  late final List<Question> _questions;
  late final Cefr? _level;
  Map<String, int>? _answers;
  int _goal = 3;

  @override
  void initState() {
    super.initState();
    final d = ref.read(dataProvider);
    _level = widget.levelCheck ? d.learningPath?.level : null;
    _questions = _level == null ? placementQuestions : levelCheckQuestions(_level);
    _goal = d.learningPath?.weeklyGoal ?? 3;
  }

  Map<Skill, SkillScore> _scores(Map<String, int> a) => {
        for (final s in Skill.values)
          if (_questions.any((q) => q.skill == s))
            s: SkillScore(
              _questions.where((q) => q.skill == s && a[q.id] == q.answer).length,
              _questions.where((q) => q.skill == s).length,
            ),
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: _answers != null,
      onPopInvokedWithResult: (popped, _) async {
        if (popped) return;
        if (await confirmDialog(context, title: l.leaveTestTitle, message: l.leaveTestBody, confirmLabel: l.leave) &&
            context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.levelCheck ? l.levelCheckTitle(l.cefr(_level ?? Cefr.a1)) : l.placementTitle)),
        body: ResponsiveContainer(
          maxWidth: 720,
          child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl), children: [
            if (_answers == null) ...[
              Text(widget.levelCheck ? l.levelCheckIntro : l.placementIntro,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.status.textSecondary)),
              const SizedBox(height: Space.l),
              QuizRunner(
                questions: _questions,
                feedback: false,
                onDone: (a) => setState(() => _answers = a),
              ),
            ] else
              FadeSlideIn(child: widget.levelCheck ? _levelResult(l) : _placementResult(l)),
          ]),
        ),
      ),
    );
  }

  Widget _placementResult(AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final p = scorePlacement(_answers!, _questions);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _ResultHero(title: l.placementResult(l.cefr(p.level)), body: l.placementExplain),
      const SizedBox(height: Space.l),
      AppCard(
        child: Column(children: [
          for (final s in Skill.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.xs),
              child: Row(children: [
                SizedBox(width: 90, child: Text(l.skill(s))),
                Expanded(child: AppProgress(percent: p.scores[s]!.percent, label: l.skill(s))),
                const SizedBox(width: Space.s),
                Pill(label: p.skillLevels[s]!.name.toUpperCase(), color: Theme.of(context).colorScheme.primary),
              ]),
            ),
        ]),
      ),
      const SizedBox(height: Space.l),
      Text(l.weeklyGoalQuestion, style: t.titleSmall),
      const SizedBox(height: Space.s),
      Wrap(spacing: Space.s, children: [
        for (final g in const [2, 3, 5, 7])
          ChoiceChip(label: Text(l.perWeek(g)), selected: _goal == g, onSelected: (_) => setState(() => _goal = g)),
      ]),
      const SizedBox(height: Space.xl),
      PrimaryButton(
        label: l.startPath,
        icon: Icons.play_arrow,
        onPressed: () {
          final now = ref.read(clockProvider)();
          ref.read(dataProvider.notifier).startLearning(
                p.level,
                _goal,
                placement: Assessment(
                  id: newId(),
                  kind: AssessmentKind.placement,
                  level: p.level,
                  scores: p.scores,
                  skillLevels: p.skillLevels,
                  passed: true,
                  takenAt: now,
                ),
              );
          context.go(Routes.english);
        },
      ),
    ]);
  }

  Widget _levelResult(AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final level = _level!;
    final score = scorePercent(_questions, _answers!);
    final passed = score >= levelCheckPass;
    final next = levelAfter(level);
    // Lessons whose questions were missed: what to go back over.
    final weak = [
      for (final lesson in lessonsAt(level))
        if (lesson.quiz.any((q) => _answers!.containsKey(q.id) && _answers![q.id] != q.answer)) lesson,
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _ResultHero(
        title: passed ? (next != null ? l.levelUp(l.cefr(next)) : l.courseComplete) : l.levelNotYet(l.cefr(level)),
        body: l.scoreOutOf(score, levelCheckPass),
      ),
      if (!passed && weak.isNotEmpty) ...[
        const SizedBox(height: Space.l),
        Text(l.goBackOver, style: t.titleSmall),
        for (final lesson in weak)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(lesson.title(l.localeName)),
            onTap: () => context.push(Routes.lesson(lesson.id)),
          ),
      ],
      const SizedBox(height: Space.xl),
      PrimaryButton(
        label: l.done,
        onPressed: () {
          ref.read(dataProvider.notifier).recordLevelCheck(
                Assessment(
                  id: newId(),
                  kind: AssessmentKind.levelCheck,
                  level: level,
                  scores: _scores(_answers!),
                  passed: passed,
                  takenAt: ref.read(clockProvider)(),
                ),
                next: next,
              );
          context.go(Routes.english);
        },
      ),
    ]);
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return HeroSurface(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.emoji_events_outlined, color: AppColors.gold, size: 32),
        const SizedBox(height: Space.m),
        Text(title, style: t.headlineSmall?.copyWith(color: Colors.white)),
        const SizedBox(height: Space.xs),
        Text(body, style: t.bodyMedium?.copyWith(color: Colors.white70)),
      ]),
    );
  }
}
