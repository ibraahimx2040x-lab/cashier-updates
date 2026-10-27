import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/misc.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/device_notifications_card.dart';
import '../habits/habits_screen.dart';

/// Screen 18 — in-app notification centre. Removing a notification never
/// deletes the task or event it points to.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _unreadOnly = false;
  NotificationType? _type;

  void _open(AppNotification n) {
    final c = ref.read(dataProvider.notifier);
    c.markNotificationRead(n.id);
    final d = ref.read(dataProvider);
    final id = n.refId;
    switch (n.type) {
      case NotificationType.task when d.task(id) != null:
        context.push(Routes.task(id!));
      case NotificationType.event when d.event(id) != null:
        context.push(Routes.event(id!));
      case NotificationType.habit when d.habit(id) != null:
        showHabitHistory(context, ref, id!);
      case NotificationType.billing:
        context.push(Routes.subscription);
      case NotificationType.accountability when d.accountabilityEvents.any((e) => e.id == id):
        context.push(Routes.accountabilityEvent(id!));
      default:
        showSnack(context, AppLocalizations.of(context).itemGone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final c = ref.read(dataProvider.notifier);
    final list = d.visibleNotifications
        .where((n) => !_unreadOnly || !n.read)
        .where((n) => _type == null || n.type == _type)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navNotifications),
        actions: [
          PopupMenuButton<String>(
            tooltip: l.moreOptions,
            onSelected: (v) {
              if (v == 'read') c.markAllNotificationsRead();
              if (v == 'clear') c.clearReadNotifications();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'read', child: Text(l.markAllRead)),
              PopupMenuItem(value: 'clear', child: Text(l.clearRead)),
            ],
          ),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 760,
        child: Column(children: [
          const SizedBox(height: Space.s),
          FilterChips<Object?>(
            values: [false, true, ...NotificationType.values.where((t) => t != NotificationType.billing)],
            selected: _type ?? _unreadOnly,
            label: (v) => switch (v) {
              false => l.filterAll,
              true => l.unread,
              NotificationType t => l.notificationType(t),
              _ => '',
            },
            onSelected: (v) => setState(() {
              if (v is bool) {
                _unreadOnly = v;
                _type = null;
              } else {
                _type = v as NotificationType;
                _unreadOnly = false;
              }
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.gutter, Space.m, Space.gutter, 0),
            child: const DeviceNotificationsCard(),
          ),
          Expanded(
            child: list.isEmpty
                ? EmptyState(icon: Icons.notifications_none, title: _unreadOnly ? l.noUnread : l.noNotifications)
                : ListView.separated(
                    padding: const EdgeInsets.all(Space.gutter),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: Space.s),
                    itemBuilder: (_, i) => NotificationTile(
                      n: list[i],
                      fmt: fmt,
                      onTap: () => _open(list[i]),
                      onMarkRead: () => c.markNotificationRead(list[i].id),
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}
