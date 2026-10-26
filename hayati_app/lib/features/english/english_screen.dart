import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/learning.dart';
import '../../domain/learning/curriculum.dart';
import '../../domain/learning/path.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';

/// Screen 16 — the English path: level, today's lesson, reviews due, the
/// weekly goal, the lessons of the current level, and test history.
class EnglishScreen extends ConsumerWidget {
  const EnglishScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final now = ref.watch(clockProvider)();
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final path = d.learningPath;
    final lang = l.localeName;

    if (path == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.navEnglish)),
        body: ResponsiveContainer(
          maxWidth: 720,
          child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [
            FadeSlideIn(
              child: _Hero(
                title: l.englishIntroTitle,
                body: l.englishIntroBody,
                actions: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.deepGreen),
                    onPressed: () => context.push(Routes.placement),
                    icon: const Icon(Icons.quiz_outlined),
                    label: Text(l.takePlacement),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                    onPressed: () {
                      ref.read(dataProvider.notifier).startLearning(Cefr.a1, 3);
                      showSnack(context, l.pathStarted);
                    },
                    child: Text(l.startFromBeginning),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.l),
            _SkillsNote(),
          ]),
        ),
      );
    }

    final next = nextLesson(d);
    final due = dueReviews(d, now);
    final week = lessonsThisWeek(d, now, d.settings.weekStart);
    final levelLessons = lessonsAt(path.level);
    final lastPlacement = d.assessments.where((a) => a.kind == AssessmentKind.placement).lastOrNull;
    final history = [...d.assessments]..sort((a, b) => b.takenAt.compareTo(a.takenAt));
    final doneToday = lessonDoneToday(d, now);

    final sections = <Widget>[
      _Hero(
        title: next != null ? next.title(lang) : l.levelComplete(l.cefr(path.level)),
        eyebrow: '${l.cefr(path.level)} · ${next != null ? (doneToday ? l.extraLesson : l.todaysLesson) : l.levelCheckReady}',
        body: next != null ? l.lessonMinutes(next.minutes) : l.levelCheckBody,
        actions: [
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.deepGreen),
            onPressed: () => context.push(next != null ? Routes.lesson(next.id) : Routes.levelCheck),
            icon: Icon(next != null ? Icons.play_arrow : Icons.quiz_outlined),
            label: Text(next != null ? l.startLesson : l.takeLevelCheck),
          ),
        ],
      ),
      if (due.isNotEmpty)
        AppCard(
          onTap: () => context.push(Routes.englishReview),
          child: Row(children: [
            CircleAvatar(backgroundColor: context.status.highlight, child: Icon(Icons.replay, color: scheme.primary)),
            const SizedBox(width: Space.m),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.reviewDue(due.length), style: t.titleSmall),
                Text(l.reviewWhy, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
              ]),
            ),
            const Icon(Icons.chevron_right),
          ]),
        ),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.flag_outlined, color: scheme.primary),
            const SizedBox(width: Space.m),
            Expanded(child: Text(l.weeklyLessons(week, path.weeklyGoal), style: t.titleSmall)),
          ]),
          const SizedBox(height: Space.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: (week / path.weeklyGoal).clamp(0, 1).toDouble()),
              duration: Motion.slow,
              curve: Motion.curve,
              builder: (_, v, _) => LinearProgressIndicator(value: v, minHeight: 8),
            ),
          ),
          const SizedBox(height: Space.s),
          Wrap(spacing: Space.s, children: [
            for (final g in const [2, 3, 5, 7])
              ChoiceChip(
                label: Text(l.perWeek(g)),
                selected: path.weeklyGoal == g,
                onSelected: (_) => ref.read(dataProvider.notifier).setWeeklyLessons(g),
              ),
          ]),
        ]),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeader(l.levelLessons(l.cefr(path.level))),
        for (final lesson in levelLessons)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s),
            child: Builder(builder: (context) {
              final p = d.lessonProgress(lesson.id);
              final (icon, color, status) = switch (p) {
                null => (Icons.circle_outlined, context.status.inactive, l.notStarted),
                _ when p.mastered => (Icons.check_circle, context.status.success, l.masteredScore(p.bestScore)),
                _ => (Icons.replay_circle_filled, context.status.warning, l.needsReviewScore(p.bestScore)),
              };
              return AppCard(
                color: lesson == next ? context.status.highlight : null,
                onTap: () => context.push(Routes.lesson(lesson.id)),
                child: Row(children: [
                  Icon(icon, color: color),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(lesson.title(lang), style: t.titleSmall),
                      Text(status, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                    ]),
                  ),
                  const Icon(Icons.chevron_right),
                ]),
              );
            }),
          ),
      ]),
      if (lastPlacement != null)
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.yourSkills, style: t.titleSmall),
            const SizedBox(height: Space.s),
            for (final s in Skill.values)
              if (lastPlacement.scores[s] case final score?)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.s),
                  child: Row(children: [
                    SizedBox(width: 90, child: Text(l.skill(s), style: t.bodyMedium)),
                    Expanded(child: AppProgress(percent: score.percent, label: l.skill(s))),
                    const SizedBox(width: Space.s),
                    if (lastPlacement.skillLevels[s] case final lv?) Pill(label: lv.name.toUpperCase(), color: scheme.primary),
                  ]),
                ),
          ]),
        ),
      if (history.isNotEmpty)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionHeader(l.testHistory, action: l.retakePlacement, onAction: () => context.push(Routes.placement)),
          for (final a in history.take(5))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(a.kind == AssessmentKind.placement ? Icons.quiz_outlined : (a.passed ? Icons.emoji_events_outlined : Icons.replay)),
              title: Text(a.kind == AssessmentKind.placement ? l.placementResult(l.cefr(a.level)) : (a.passed ? l.levelPassed(l.cefr(a.level)) : l.levelNotYet(l.cefr(a.level)))),
              subtitle: Text(Fmt.of(context).date(a.takenAt)),
            ),
        ]),
      _SkillsNote(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.navEnglish)),
      body: ResponsiveContainer(
        maxWidth: 760,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl),
          itemCount: sections.length,
          separatorBuilder: (_, _) => const SizedBox(height: Space.l),
          itemBuilder: (_, i) => FadeSlideIn(index: i, child: sections[i]),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.title, required this.body, this.eyebrow, this.actions = const []});
  final String title;
  final String body;
  final String? eyebrow;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(Space.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.sheet),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppColors.deepGreen, AppColors.midGreen],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.translate, color: Colors.white, size: 32),
        const SizedBox(height: Space.m),
        if (eyebrow != null) Text(eyebrow!, style: t.labelMedium?.copyWith(color: Colors.white70)),
        Text(title, style: t.headlineSmall?.copyWith(color: Colors.white)),
        const SizedBox(height: Space.xs),
        Text(body, style: t.bodyMedium?.copyWith(color: Colors.white70)),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: Space.l),
          Wrap(spacing: Space.s, runSpacing: Space.s, children: actions),
        ],
      ]),
    );
  }
}

class _SkillsNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline, size: 18, color: context.status.info),
      const SizedBox(width: Space.s),
      Expanded(
        child: Text(l.skillsMeasuredNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.status.textSecondary)),
      ),
    ]);
  }
}
