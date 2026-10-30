import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/data_controller.dart';
import '../../data/models/health.dart';
import '../../l10n/app_localizations.dart';
import '../../services/health_lock.dart';
import '../../widgets/common.dart';
import 'womens_gate.dart';
import '../../widgets/home_logo.dart';

/// Screen 48 — health privacy: the lock, keeping women's health off the
/// home screen, neutral reminders, keeping cycle data on this device only,
/// and exporting or deleting the health data alone.
class HealthPrivacyScreen extends ConsumerWidget {
  const HealthPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final s = ref.watch(settingsProvider);
    final h = s.health;
    final data = ref.read(dataProvider.notifier);
    final canLock = ref.watch(deviceAuthAvailableProvider).value ?? false;
    final womens = womensVisible(s);
    void up(HealthSettings Function(HealthSettings) f) => data.updateHealth(f);

    return Scaffold(
      appBar: AppBar(title: Text(l.healthPrivacy), actions: const [HomeLogoButton()]),
      body: HealthLockGate(
        child: ResponsiveContainer(
          maxWidth: 720,
          child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl), children: [
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: Space.s),
              child: Column(children: [
                SwitchListTile(
                  secondary: const IconBadge(Icons.fingerprint),
                  title: Text(l.healthLock),
                  subtitle: Text(canLock ? l.healthLockSub : l.healthLockUnavailable),
                  value: h.lockEnabled,
                  onChanged: !canLock && !h.lockEnabled
                      ? null
                      : (v) async {
                          // Turning it on proves the unlock works on this phone first.
                          if (v && !await ref.read(healthUnlockProvider.notifier).unlock(l.unlockReason)) return;
                          up((x) => x.copyWith(lockEnabled: v));
                        },
                ),
                if (womens) ...[
                  SwitchListTile(
                    secondary: const IconBadge(Icons.visibility_off_outlined),
                    title: Text(l.hideFromHome),
                    subtitle: Text(l.hideFromHomeSub),
                    value: h.hideFromHome,
                    onChanged: (v) => up((x) => x.copyWith(hideFromHome: v)),
                  ),
                  SwitchListTile(
                    secondary: const IconBadge(Icons.notifications_none),
                    title: Text(l.cycleReminders),
                    subtitle: Text(l.cycleRemindersSub),
                    value: h.cycleReminders,
                    onChanged: (v) => up((x) => x.copyWith(cycleReminders: v)),
                  ),
                  SwitchListTile(
                    secondary: const IconBadge(Icons.phone_android),
                    title: Text(l.cycleLocalOnly),
                    subtitle: Text(h.cycleLocalOnly ? l.cycleLocalOnlyOn : l.cycleLocalOnlyOff),
                    value: h.cycleLocalOnly,
                    onChanged: (v) async {
                      final ok = await confirmDialog(
                        context,
                        title: v ? l.cycleLocalOnlyTitle : l.cycleSyncTitle,
                        message: v ? l.cycleLocalOnlyBody : l.cycleSyncBody,
                        confirmLabel: l.continueLabel,
                        danger: false,
                      );
                      if (ok) up((x) => x.copyWith(cycleLocalOnly: v));
                    },
                  ),
                ],
              ]),
            ),
            const SizedBox(height: Space.s),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.lock_outline, size: 18, color: context.status.success),
              const SizedBox(width: Space.s),
              Expanded(child: Text(l.healthPrivacyNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary))),
            ]),
            const SizedBox(height: Space.xl),
            SectionHeader(l.healthDataTitle),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: Space.s),
              child: Column(children: [
                ListTile(
                  leading: const IconBadge(Icons.download_outlined),
                  title: Text(l.exportHealthData),
                  subtitle: Text(l.exportHealthDataSub),
                  onTap: () async {
                    final json = data.exportHealthJson();
                    await Clipboard.setData(ClipboardData(text: json));
                    if (context.mounted) showSnack(context, l.exportCopied(json.length));
                  },
                ),
                ListTile(
                  leading: IconBadge(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
                  title: Text(l.deleteHealthData, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  subtitle: Text(l.deleteHealthDataSub),
                  onTap: () async {
                    if (await confirmDialog(context, title: l.deleteHealthDataTitle, message: l.deleteHealthDataBody, confirmLabel: l.delete)) {
                      data.deleteHealthData();
                      if (context.mounted) showSnack(context, l.healthDataDeleted);
                    }
                  },
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
