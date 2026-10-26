import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/device_notifications.dart';
import 'common.dart';

/// Lets the user turn on phone/browser notifications. Never asks on its own:
/// browsers block prompts that aren't triggered by the user.
class DeviceNotificationsCard extends ConsumerWidget {
  const DeviceNotificationsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(devicePermissionProvider).value ?? DevicePermission.unknown;
    final t = Theme.of(context).textTheme;
    if (p == DevicePermission.unsupported) return const SizedBox.shrink();
    return AppCard(
      color: p == DevicePermission.granted ? null : context.status.highlight,
      child: Row(children: [
        Icon(p == DevicePermission.granted ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
            color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.devNotifTitle, style: t.titleSmall),
            Text(
              switch (p) {
                DevicePermission.granted => kIsWeb ? l.devNotifOnWeb : l.devNotifOn,
                DevicePermission.denied => l.devNotifDenied,
                _ => kIsWeb ? l.devNotifBodyWeb : l.devNotifBody,
              },
              style: t.bodySmall,
            ),
          ]),
        ),
        if (p == DevicePermission.unknown)
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
            onPressed: () async {
              await ref.read(deviceNotificationsProvider).requestPermission();
              ref.invalidate(devicePermissionProvider);
            },
            child: Text(l.devNotifEnable),
          ),
      ]),
    );
  }
}

/// Asks once, right after the user sets a reminder: the moment the reason
/// is obvious. Does nothing if they already answered. Takes the container
/// (not a WidgetRef) because the editor closes while this is pending.
Future<void> askForNotificationsIfUnknown(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final device = container.read(deviceNotificationsProvider);
  if (await device.permission() != DevicePermission.unknown) return;
  await device.requestPermission();
  container.invalidate(devicePermissionProvider);
}
