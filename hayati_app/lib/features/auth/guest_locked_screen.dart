import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/auth.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';

/// Where a guest lands when they open a section that needs an account:
/// what they can use now, and one step to everything else.
class GuestLockedScreen extends StatelessWidget {
  const GuestLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    Widget open(IconData i, String label) => Chip(avatar: Icon(i, size: 18), label: Text(label));
    return Scaffold(
      appBar: AppBar(),
      body: ResponsiveContainer(
        maxWidth: 520,
        child: ListView(padding: const EdgeInsets.all(Space.xl), children: [
          const Center(child: SanadTile(size: 72)),
          const SizedBox(height: Space.xl),
          Text(l.lockedTitle, style: t.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: Space.s),
          Text(l.lockedBody, style: t.bodyLarge?.copyWith(color: context.status.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: Space.xl),
          Text(l.guestAvailable, style: t.labelMedium, textAlign: TextAlign.center),
          const SizedBox(height: Space.s),
          Wrap(alignment: WrapAlignment.center, spacing: Space.s, runSpacing: Space.s, children: [
            open(Icons.check_circle_outline, l.navTasks),
            open(Icons.calendar_month_outlined, l.calendar),
            open(Icons.repeat, l.navHabits),
          ]),
          const SizedBox(height: Space.xxl),
          PrimaryButton(label: l.createAccount, onPressed: () => context.push('${Routes.auth}?mode=signup')),
          const SizedBox(height: Space.m),
          SecondaryButton(label: l.backHome, onPressed: () => context.go(Routes.home)),
        ]),
      ),
    );
  }
}

/// Shown to guests on "My day" and in settings: what being a guest means,
/// and the way out of it either direction.
class GuestCard extends ConsumerWidget {
  const GuestCard({super.key, this.showLeave = false});
  final bool showLeave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return AppCard(
      color: context.status.highlight,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const IconBadge(Icons.person_outline),
          const SizedBox(width: Space.m),
          Expanded(child: Text(l.guestBanner, style: t.bodyMedium)),
        ]),
        const SizedBox(height: Space.m),
        Wrap(spacing: Space.s, runSpacing: Space.s, children: [
          FilledButton(onPressed: () => context.push('${Routes.auth}?mode=signup'), child: Text(l.createAccount)),
          if (showLeave)
            TextButton(onPressed: () => ref.read(authProvider.notifier).signOut(), child: Text(l.leaveGuest)),
        ]),
      ]),
    );
  }
}
