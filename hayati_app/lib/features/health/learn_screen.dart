import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/data_controller.dart';
import '../../domain/fitness/programs.dart' show Audience;
import '../../domain/health_articles.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/home_logo.dart';

IconData _audienceIcon(Audience a) => switch (a) {
      Audience.female => Icons.female,
      Audience.male => Icons.male,
      Audience.all => Icons.menu_book_outlined,
    };

/// Screen 47 — short health reading, chosen by the user. Men's topics for
/// male accounts, women's for female accounts, the rest for everyone.
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = l.localeName;
    final list = articlesFor(ref.watch(settingsProvider));

    return Scaffold(
      appBar: AppBar(title: Text(l.healthLearn), actions: const [HomeLogoButton()]),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl), children: [
          Text(l.learnIntro, style: t.bodyMedium?.copyWith(color: context.status.textSecondary)),
          const SizedBox(height: Space.l),
          for (final a in list)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s),
              child: AppCard(
                onTap: () => context.push(Routes.article(a.id)),
                child: Row(children: [
                  IconBadge(_audienceIcon(a.audience)),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(a.title(lang), style: t.titleSmall),
                      Text(a.summary(lang), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                    ]),
                  ),
                  const Icon(Icons.chevron_right),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}

class ArticleScreen extends ConsumerWidget {
  const ArticleScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = l.localeName;
    final a = articleById(id);
    if (a == null || !articlesFor(ref.watch(settingsProvider)).contains(a)) {
      return Scaffold(appBar: AppBar(actions: const [HomeLogoButton()]), body: EmptyState(icon: Icons.lock_outline, title: l.programUnavailable, message: l.articleUnavailable));
    }
    return Scaffold(
      appBar: AppBar(title: Text(a.title(lang)), actions: const [HomeLogoButton()]),
      body: ResponsiveContainer(
        maxWidth: 680,
        // Short pages: built whole, so the sources at the end are always there.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(a.title(lang), style: t.headlineSmall),
          const SizedBox(height: Space.s),
          Text(a.summary(lang), style: t.bodyLarge?.copyWith(color: context.status.textSecondary)),
          const SizedBox(height: Space.l),
          for (final p in a.body(lang))
            Padding(
              padding: const EdgeInsets.only(bottom: Space.m),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(padding: EdgeInsets.only(top: 6), child: CircleAvatar(radius: 3, backgroundColor: AppColors.gold)),
                const SizedBox(width: Space.m),
                Expanded(child: Text(p, style: t.bodyLarge?.copyWith(height: 1.6))),
              ]),
            ),
          const SizedBox(height: Space.l),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.sources, style: t.titleSmall),
              const SizedBox(height: Space.xs),
              for (final (name, site) in a.sources) Text('• $name ($site)', style: t.bodySmall),
            ]),
          ),
          const SizedBox(height: Space.m),
          Text(l.articleDisclaimer, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
          ]),
        ),
      ),
    );
  }
}
