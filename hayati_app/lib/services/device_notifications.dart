import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/models/alarm.dart';
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
  /// [onAlarm] receives an alarm's id and the button pressed ('snooze' or
  /// 'stop'; 'open' when the alarm itself was tapped).
  Future<void> init({required void Function(String route) onOpen, void Function(String alarmId, String action)? onAlarm});
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

  /// One channel per tone and vibration choice: Android fixes a channel's
  /// sound and vibration once it exists.
  static NotificationDetails _alarmDetails(Alarm a, String snooze, String stop) {
    final key = 'alarm_${a.tone.name}_${a.vibrate ? 'v' : 's'}';
    return NotificationDetails(
      android: AndroidNotificationDetails(
        key,
        'Alarm · ${a.tone.name}${a.vibrate ? '' : ' (silent vibration)'}',
        channelDescription: 'Alarms that ring until stopped',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        sound: RawResourceAndroidNotificationSound('alarm_${a.tone.name}'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableVibration: a.vibrate,
        vibrationPattern: a.vibrate ? Int64List.fromList([0, 600, 400, 600, 400, 900]) : null,
        fullScreenIntent: true,
        // FLAG_INSISTENT: the sound repeats until the alarm is answered.
        additionalFlags: Int32List.fromList([4]),
        actions: [
          AndroidNotificationAction('snooze', snooze, showsUserInterface: true, cancelNotification: true),
          AndroidNotificationAction('stop', stop, showsUserInterface: true, cancelNotification: true),
        ],
      ),
      iOS: const DarwinNotificationDetails(presentSound: true, interruptionLevel: InterruptionLevel.timeSensitive),
    );
  }

  /// Button labels for alarms, set by the shell in the user's language.
  String snoozeLabel = 'Snooze';
  String stopLabel = 'Stop';

  /// Rings on the minute when the phone allows exact alarms; otherwise
  /// within a few minutes, like other reminders.
  bool _exact = false;

  static void Function(String route)? _onOpen;
  static void Function(String alarmId, String action)? _onAlarm;

  static void _respond(NotificationResponse r) {
    final p = r.payload;
    if (p == null) return;
    if (p.startsWith('alarm:')) {
      final parts = p.substring(6).split('|');
      final action = r.actionId ?? 'open';
      _onAlarm?.call(parts[0], action);
      if (action == 'open' && parts.length > 1) _onOpen?.call(parts[1]);
      return;
    }
    if (p.startsWith('/')) _onOpen?.call(p);
  }

  /// Asks Android for exact alarms (Android 12+); remembered by the OS.
  Future<void> requestExactAlarms() async {
    if (kIsWeb) return;
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    _exact = (await android.canScheduleExactNotifications()) ?? false;
    if (!_exact) {
      await android.requestExactAlarmsPermission();
      _exact = (await android.canScheduleExactNotifications()) ?? false;
    }
    _lastPlan = '';
  }

  @override
  Future<void> init({required void Function(String route) onOpen, void Function(String alarmId, String action)? onAlarm}) async {
    _onOpen = onOpen;
    _onAlarm = onAlarm;
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
      onDidReceiveNotificationResponse: _respond,
    );
    _ready = true;
    if (!kIsWeb) {
      _exact = (await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.canScheduleExactNotifications()) ?? false;
    }
    // Opened by tapping a notification (or an alarm button) while the app was closed.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final r = launch?.notificationResponse;
    if (launch?.didNotificationLaunchApp == true && r != null) _respond(r);
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
      final alarm = r.alarm;
      await _plugin.zonedSchedule(
        id: r.id,
        scheduledDate: tz.TZDateTime.from(r.at, tz.local),
        notificationDetails: alarm == null ? _details : _alarmDetails(alarm, snoozeLabel, stopLabel),
        // Reminders are inexact (no special permission; may arrive a few
        // minutes late). Alarms ring on the minute when allowed.
        androidScheduleMode: alarm != null && _exact ? AndroidScheduleMode.alarmClock : AndroidScheduleMode.inexactAllowWhileIdle,
        title: r.title,
        body: r.body.isEmpty ? null : r.body,
        payload: alarm == null ? r.route : 'alarm:${alarm.id}|${r.route}',
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
