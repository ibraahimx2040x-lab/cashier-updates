import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../settings/privacy_screen.dart';
import 'splash_screen.dart';

/// Screen 2 — value before sign-up.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final locale = ref.watch(localeProvider);
    Widget benefit(IconData i, String title, String body) => Padding(
          padding: const EdgeInsets.only(bottom: Space.l),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconBadge(i, size: 22),
            const SizedBox(width: Space.m),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: t.titleSmall),
                Text(body, style: t.bodyMedium?.copyWith(color: context.status.textSecondary)),
              ]),
            ),
          ]),
        );

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 520,
          child: ListView(padding: const EdgeInsets.all(Space.xl), children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                icon: const Icon(Icons.translate, size: 18),
                label: Text(locale.languageCode == 'ar' ? 'English' : 'العربية'),
                onPressed: () => ref.read(localeProvider.notifier).set(Locale(locale.languageCode == 'ar' ? 'en' : 'ar')),
              ),
            ),
            const SizedBox(height: Space.xl),
            Center(
              child: Container(
                padding: const EdgeInsets.all(Space.l),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                  boxShadow: [BoxShadow(color: AppColors.navy.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: const HayatiLogo(size: 56),
              ),
            ),
            const SizedBox(height: Space.xl),
            Text(l.welcomeTitle, style: t.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: Space.s),
            Text(l.welcomeBody, style: t.bodyLarge?.copyWith(color: context.status.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: Space.xxl),
            benefit(Icons.view_timeline_outlined, l.benefit1Title, l.benefit1Body),
            benefit(Icons.flag_outlined, l.benefit2Title, l.benefit2Body),
            benefit(Icons.auto_awesome_outlined, l.benefit3Title, l.benefit3Body),
            const SizedBox(height: Space.l),
            PrimaryButton(label: l.getStarted, onPressed: () => context.push('${Routes.auth}?mode=signup')),
            const SizedBox(height: Space.m),
            SecondaryButton(label: l.haveAccount, onPressed: () => context.push(Routes.auth)),
            const SizedBox(height: Space.l),
            Wrap(alignment: WrapAlignment.center, children: [
              TextButton(onPressed: () => showLegal(context, privacy: true), child: Text(l.privacyPolicy)),
              TextButton(onPressed: () => showLegal(context, privacy: false), child: Text(l.terms)),
            ]),
          ]),
        ),
      ),
    );
  }
}
