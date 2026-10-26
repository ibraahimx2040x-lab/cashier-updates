import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/store/local_store.dart';
import '../domain/device_reminders.dart';

enum DevicePermission { unknown, granted, denied, unsupported }

/// The phone/browser notification system.
///
/// Phones: reminders are scheduled with the OS (inexact alarms, typically
/// within a few minutes of the set time) and survive app closure and
/// reboots. Browsers can't schedule ahead, so on the web a reminder is
/// shown only while the app is open, when the in-app reminder fires.
abstract interface class DeviceNotifications {
  Future<void> init({required void Function(String route) onOpen});
  Future<DevicePermission> permission();

  /// Must be called from a user action (browsers block it otherwise).
  Future<DevicePermission> requestPermission();

  /// Replaces every scheduled reminder with [reminders].
  Future<void> reschedule(List<DeviceReminder> reminders);

  /// Shows a notification now (web, while the app is open).
  Future<void> showNow(int id, String title, String body, String route);

  /// Whether the platform can schedule reminders ahead of time.
  bool get canSchedule;
}

class PluginDeviceNotifications implements DeviceNotifications {
  PluginDeviceNotifications(this._store);

  final LocalStore _store;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  String _lastPlan = '';

  static const _askedKey = 'hayati.notifPermission';

  @override
  bool get canSchedule => !kIsWeb;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Task, event and habit reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  @override
  Future<void> init({required void Function(String route) onOpen}) async {
    if (_ready) return;
    if (!kIsWeb) {
      tzdata.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (_) {
        // Unknown zone id: fall back to UTC offsets via absolute instants.
      }
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Ask only when the user opts in (see requestPermission).
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        web: WebInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (r) {
        final route = r.payload;
        if (route != null && route.startsWith('/')) onOpen(route);
      },
    );
    _ready = true;
    // Opened by tapping a notification while the app was closed.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final route = launch?.notificationResponse?.payload;
    if (launch?.didNotificationLaunchApp == true && route != null && route.startsWith('/')) onOpen(route);
  }

  @override
  Future<DevicePermission> permission() async {
    if (kIsWeb) {
      final web = _plugin.resolvePlatformSpecificImplementation<WebFlutterLocalNotificationsPlugin>();
      return switch (web?.permissionStatus) {
        WebNotificationPermission.granted => DevicePermission.granted,
        WebNotificationPermission.denied => DevicePermission.denied,
        _ => DevicePermission.unknown,
      };
    }
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return (await android.areNotificationsEnabled()) == true ? DevicePermission.granted : DevicePermission.denied;
    }
    // iOS has no read-only check here; remember the user's answer.
    return switch (_store.readString(_askedKey)) {
      'granted' => DevicePermission.granted,
      'denied' => DevicePermission.denied,
      _ => DevicePermission.unknown,
    };
  }

  @override
  Future<DevicePermission> requestPermission() async {
    bool? ok;
    if (kIsWeb) {
      ok = await _plugin.resolvePlatformSpecificImplementation<WebFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    } else {
      ok = await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission() ??
          await _plugin
              .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true);
    }
    final p = ok == true ? DevicePermission.granted : DevicePermission.denied;
    await _store.writeString(_askedKey, p.name);
    return p;
  }

  @override
  Future<void> reschedule(List<DeviceReminder> reminders) async {
    if (!_ready || !canSchedule) return;
    // Skip the OS round-trip when nothing changed.
    final plan = reminders.map((r) => '${r.id}@${r.at.millisecondsSinceEpoch}|${r.title}|${r.body}').join(',');
    if (plan == _lastPlan) return;
    _lastPlan = plan;
    await _plugin.cancelAllPendingNotifications();
    for (final r in reminders) {
      await _plugin.zonedSchedule(
        id: r.id,
        scheduledDate: tz.TZDateTime.from(r.at, tz.local),
        notificationDetails: _details,
        // Inexact: no exact-alarm permission needed; may arrive a few
        // minutes late on Android.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: r.title,
        body: r.body.isEmpty ? null : r.body,
        payload: r.route,
      );
    }
  }

  @override
  Future<void> showNow(int id, String title, String body, String route) async {
    if (!_ready || await permission() != DevicePermission.granted) return;
    await _plugin.show(id: id, title: title, body: body.isEmpty ? null : body, notificationDetails: _details, payload: route);
  }
}

/// Overridden in tests with a fake.
final deviceNotificationsProvider = Provider<DeviceNotifications>(
  (ref) => PluginDeviceNotifications(ref.read(localStoreProvider)),
);

/// Current permission, refreshed after requests.
final devicePermissionProvider = FutureProvider<DevicePermission>(
  (ref) => ref.watch(deviceNotificationsProvider).permission(),
);
