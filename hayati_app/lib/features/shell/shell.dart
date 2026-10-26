import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/data_controller.dart';
import '../../data/models/misc.dart';
import '../../data/models/settings.dart';
import '../../data/remote/sync.dart';
import '../../domain/device_reminders.dart';
import '../../domain/reminders.dart';
import '../../l10n/app_localizations.dart';
import '../../services/device_notifications.dart';
import '../../widgets/common.dart';
import 'quick_add.dart';

/// Five fixed destinations: bottom bar on phones, sidebar on wide screens.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  Timer? _timer;
  Timer? _plan;
  ProviderSubscription<Object>? _dataSub;

  // Captured up front: `ref` is unusable in dispose().
  late final DeviceNotifications _device = ref.read(deviceNotificationsProvider);

  @override
  void initState() {
    super.initState();
    _device;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _sync();
      await _device.init(onOpen: (route) {
        if (mounted) ref.read(routerProvider).push(route);
      });
      _schedule();
    });
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _sync());
    // Re-plan device reminders shortly after any data change.
    _dataSub = ref.listenManual(dataProvider, (_, _) {
      _plan?.cancel();
      _plan = Timer(const Duration(seconds: 2), _schedule);
    });
  }

  void _schedule() {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    _device.reschedule(planDeviceReminders(ref.read(dataProvider), ref.read(clockProvider)(), l));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _plan?.cancel();
    _dataSub?.close();
    // Leaving the main app means signing out (or deleting the account):
    // no reminders should fire for a signed-out user.
    _device.reschedule(const []);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sync();
      ref.read(syncProvider.notifier).sync();
    }
  }

  void _sync() {
    if (!mounted) return;
    final added = syncReminders(ref.read(dataProvider.notifier), ref.read(clockProvider)(), AppLocalizations.of(context));
    // Browsers can't schedule ahead: surface new reminders as browser
    // notifications while the app is open. Phones already scheduled them.
    if (!_device.canSchedule) {
      for (final n in added) {
        _device.showNow(stableId(n.dedupeKey), n.title, n.body, _routeFor(n));
      }
    }
  }

  static String _routeFor(AppNotification n) => switch (n.type) {
        NotificationType.task when n.refId != null => Routes.task(n.refId!),
        NotificationType.event when n.refId != null => Routes.event(n.refId!),
        NotificationType.habit => Routes.habits,
        _ => Routes.notifications,
      };

  void _go(int i) => widget.shell.goBranch(i, initialLocation: i == widget.shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final i = widget.shell.currentIndex;
    final showFab = i <= 2;
    final dests = [
      (Icons.home_outlined, Icons.home, l.navHome),
      (Icons.schedule_outlined, Icons.schedule, l.navTime),
      (Icons.flag_outlined, Icons.flag, l.navGoals),
      (Icons.auto_awesome_outlined, Icons.auto_awesome, l.navAssistant),
      (Icons.insights_outlined, Icons.insights, l.navProgress),
    ];
    final fab = showFab
        ? FloatingActionButton(
            tooltip: l.quickAdd,
            onPressed: () => showQuickAdd(context, ref),
            child: const Icon(Icons.add),
          )
        : null;

    if (isWide(context)) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(index: i, onSelect: _go, dests: dests),
            const VerticalDivider(width: 1),
            Expanded(child: Column(children: [Expanded(child: widget.shell), const SyncBanner()])),
          ],
        ),
        floatingActionButton: fab,
      );
    }
    return Scaffold(
      body: Column(children: [Expanded(child: widget.shell), const SyncBanner()]),
      floatingActionButton: fab,
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: _go,
        destinations: [
          for (final d in dests) NavigationDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3),
        ],
      ),
    );
  }
}

/// Web/tablet sidebar: main destinations plus secondary sections.
class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.index, required this.onSelect, required this.dests});
  final int index;
  final ValueChanged<int> onSelect;
  final List<(IconData, IconData, String)> dests;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final unread = ref.watch(dataProvider.select((d) => d.unreadNotifications));
    final scheme = Theme.of(context).colorScheme;
    Widget item(IconData icon, String label, VoidCallback onTap, {bool selected = false, int badge = 0}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s, vertical: 2),
      child: ListTile(
        dense: true,
        selected: selected,
        selectedTileColor: Theme.of(context).navigationRailTheme.indicatorColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.button)),
        leading: badge > 0 ? Badge(label: Text('$badge'), child: Icon(icon)) : Icon(icon),
        title: Text(label),
        onTap: onTap,
      ),
    );
    return Material(
      color: scheme.surface,
      child: SizedBox(
        width: 248,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: Space.l),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.xl, 0, Space.xl, Space.l),
                child: Row(
                  children: [
                    Icon(Icons.explore_outlined, color: scheme.primary),
                    const SizedBox(width: Space.s),
                    Text(l.appName, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: scheme.primary)),
                  ],
                ),
              ),
              for (var i = 0; i < dests.length; i++)
                item(index == i ? dests[i].$2 : dests[i].$1, dests[i].$3, () => onSelect(i), selected: index == i),
              const Divider(height: Space.xl),
              if (s.has(AppModule.habits)) item(Icons.repeat, l.navHabits, () => context.push(Routes.habits)),
              if (s.has(AppModule.notes))
                item(Icons.sticky_note_2_outlined, l.navNotes, () => context.push(Routes.notes)),
              if (s.has(AppModule.expenses))
                item(Icons.account_balance_wallet_outlined, l.navExpenses, () => context.push(Routes.expenses)),
              item(
                Icons.notifications_outlined,
                l.navNotifications,
                () => context.push(Routes.notifications),
                badge: unread,
              ),
              item(Icons.settings_outlined, l.navSettings, () => context.push(Routes.settings)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown only in connected mode when changes are waiting or were refused.
class SyncBanner extends ConsumerWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(syncProvider);
    final (show, icon, text) = switch (s.phase) {
      SyncPhase.offline => (true, Icons.cloud_off_outlined, l.syncOffline(s.pending)),
      SyncPhase.error => (true, Icons.sync_problem_outlined, l.syncRejected),
      _ => (false, Icons.cloud_done_outlined, ''),
    };
    if (!show) return const SizedBox.shrink();
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter, vertical: Space.s),
          child: Semantics(
            liveRegion: true,
            child: Row(children: [
              Icon(icon, size: 18),
              const SizedBox(width: Space.s),
              Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
              TextButton(onPressed: () => ref.read(syncProvider.notifier).sync(), child: Text(l.retry)),
            ]),
          ),
        ),
    );
  }
}
