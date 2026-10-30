import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/data_controller.dart';
import '../../data/models/health.dart';
import '../../data/models/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../services/health_lock.dart';
import '../../widgets/common.dart';
import '../../widgets/home_logo.dart';

/// Women's health is shown to female accounts with the section on, and to
/// no one else (owner's decision).
bool womensVisible(UserSettings s) => s.sex == Sex.female && s.health.has(HealthModule.womens);

/// Appointments belong to both health sections.
bool appointmentsVisible(UserSettings s) => s.health.has(HealthModule.womens) || s.health.has(HealthModule.mens);

/// Wraps a health screen's body: asks for the phone's unlock first when the
/// user turned the lock on and this device has one. On the web the account
/// password is the lock.
class HealthLockGate extends ConsumerStatefulWidget {
  const HealthLockGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<HealthLockGate> createState() => _HealthLockGateState();
}

class _HealthLockGateState extends ConsumerState<HealthLockGate> {
  bool _asked = false;

  Future<void> _unlock() async {
    final l = AppLocalizations.of(context);
    final ok = await ref.read(healthUnlockProvider.notifier).unlock(l.unlockReason);
    if (!ok && mounted) showSnack(context, l.unlockFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final on = ref.watch(settingsProvider.select((s) => s.health.lockEnabled));
    final available = ref.watch(deviceAuthAvailableProvider).value ?? false;
    final unlocked = ref.watch(healthUnlockProvider);
    if (!on || !available || unlocked) return widget.child;
    if (!_asked) {
      _asked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const IconBadge(Icons.lock_outline, color: AppColors.goldDeep, size: 34, circle: true),
          const SizedBox(height: Space.l),
          Text(l.healthLocked, style: t.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: Space.s),
          Text(l.healthLockedBody, style: t.bodyMedium?.copyWith(color: context.status.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: Space.l),
          FilledButton.icon(onPressed: _unlock, icon: const Icon(Icons.fingerprint), label: Text(l.unlock)),
        ]),
      ),
    );
  }
}

/// Shown instead of a women's health screen to anyone it isn't for.
class WomensUnavailable extends StatelessWidget {
  const WomensUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(appBar: AppBar(actions: const [HomeLogoButton()]), body: EmptyState(icon: Icons.lock_outline, title: l.programUnavailable, message: l.womensUnavailable));
  }
}
