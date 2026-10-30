import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/alarm.dart';
import 'package:hayati/data/remote/rows.dart';
import 'package:hayati/domain/device_reminders.dart';
import 'package:hayati/l10n/app_localizations.dart';

import 'helpers.dart';

void main() {
  final now = fixedNow; // Tuesday 2026-03-10 08:00
  final l = lookupAppLocalizations(const Locale('ar'));

  test('repeating alarms ring on their days, a one-time alarm once, a snooze first', () {
    final weekdays = Alarm(id: 'a', minutes: 5 * 60, weekdays: const {2, 4}, updatedAt: now); // Tue, Thu at 5:00
    expect(weekdays.nextRings(now), [DateTime(2026, 3, 12, 5), DateTime(2026, 3, 17, 5)], reason: "today's 5:00 has passed");
    final once = Alarm(id: 'b', minutes: 9 * 60, onDate: '2026-03-10', updatedAt: now);
    expect(once.nextRings(now), [DateTime(2026, 3, 10, 9)]);
    expect(once.copyWith(enabled: false).nextRings(now), isEmpty);
    final snoozed = once.copyWith(snoozedUntil: () => now.add(const Duration(minutes: 10)));
    expect(snoozed.nextRings(now).first, DateTime(2026, 3, 10, 8, 10));
  });

  test('alarms are planned as sounding reminders and always get a place', () {
    final d = AppData(
      alarms: [Alarm(id: 'a', label: 'الفجر', minutes: 9 * 60, onDate: '2026-03-10', updatedAt: now)],
      tasks: const [],
    );
    final r = planDeviceReminders(d, now, l);
    expect((r.single.alarm?.id, r.single.title, r.single.route), ('a', 'الفجر', '/alarms'));
    expect(planAlarms(d, now, l), hasLength(1));
  });

  test('snooze, stop, links cleared when the task goes, and bad input refused', () async {
    final c = await signedInContainer();
    final data = c.read(dataProvider.notifier);
    final t = data.newTask(title: 'Report');
    data.saveTask(t);
    data.saveAlarm(Alarm(id: 'x', minutes: 600, onDate: '2026-03-11', taskId: t.id, snoozeMinutes: 5, updatedAt: now));
    data.saveAlarm(Alarm(id: 'r', minutes: 300, weekdays: const {1}, updatedAt: now));
    data.snoozeAlarm('x');
    expect(c.read(dataProvider).alarms.firstWhere((a) => a.id == 'x').snoozedUntil, now.add(const Duration(minutes: 5)));
    data.stopAlarm('x');
    final x = c.read(dataProvider).alarms.firstWhere((a) => a.id == 'x');
    expect((x.snoozedUntil, x.enabled), (null, false), reason: 'a one-time alarm turns off once stopped');
    data.stopAlarm('r');
    expect(c.read(dataProvider).alarms.firstWhere((a) => a.id == 'r').enabled, isTrue, reason: 'a repeating one stays on');
    data.deleteTask(t.id);
    expect(c.read(dataProvider).alarms.firstWhere((a) => a.id == 'x').taskId, isNull);
    expect(() => data.saveAlarm(Alarm(id: 'bad', minutes: 600, updatedAt: now)), throwsArgumentError, reason: 'no day');
    expect(() => data.saveAlarm(Alarm(id: 'bad', minutes: 1440, weekdays: const {1}, updatedAt: now)), throwsArgumentError);
  });

  test('rows and JSON round-trip', () {
    final a = Alarm(id: 'a', label: 'L', minutes: 285, weekdays: const {5, 1}, tone: AlarmTone.bells, vibrate: false, snoozeMinutes: 15, eventId: 'e', updatedAt: now);
    final b = alarmFrom(alarmRow(a));
    expect(b.weekdays, {1, 5});
    expect((b.tone, b.vibrate, b.snoozeMinutes, b.eventId), (AlarmTone.bells, false, 15, 'e'));
    expect(AppData.fromJson(AppData(alarms: [a]).toJson()).alarms.single.label, 'L');
  });
}
