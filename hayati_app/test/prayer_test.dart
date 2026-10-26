import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/core/utils/dates.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/prayer.dart';
import 'package:hayati/data/models/settings.dart';
import 'package:hayati/data/models/task.dart';
import 'package:hayati/data/remote/rows.dart';
import 'package:hayati/domain/assistant/engine.dart';
import 'package:hayati/domain/day_timeline.dart';
import 'package:hayati/domain/device_reminders.dart';
import 'package:hayati/domain/planner.dart';
import 'package:hayati/domain/prayer_times.dart';
import 'package:hayati/l10n/app_localizations.dart';

import 'helpers.dart';

const riyadh = PrayerSettings(enabled: true, place: 'الرياض', latitude: 24.7136, longitude: 46.6753);

void main() {
  final l = lookupAppLocalizations(const Locale('ar'));

  group('prayer times', () {
    test('off or without a place: nothing is shown', () {
      expect(prayerDay(const PrayerSettings(), DateTime(2026, 10, 26)), isNull);
      expect(prayerDay(const PrayerSettings(enabled: true), DateTime(2026, 10, 26)), isNull);
      expect(nextPrayer(const PrayerSettings(enabled: true), DateTime(2026, 10, 26)), isNull);
    });

    test('Riyadh, Umm al-Qura: plausible order and known relationships', () {
      final d = prayerDay(riyadh, DateTime(2026, 10, 26))!;
      final order = [d[Prayer.fajr], d.sunrise, d[Prayer.dhuhr], d[Prayer.asr], d[Prayer.maghrib], d[Prayer.isha]];
      for (var i = 1; i < order.length; i++) {
        expect(order[i].isAfter(order[i - 1]), isTrue, reason: '$i');
      }
      // Umm al-Qura: Isha is a fixed 90 minutes after Maghrib.
      expect(d[Prayer.isha].difference(d[Prayer.maghrib]).inMinutes, 90);
      // Dhuhr follows solar noon: ~08:38 UTC in Riyadh in late October.
      final dhuhr = d[Prayer.dhuhr].toUtc();
      final minutes = dhuhr.hour * 60 + dhuhr.minute;
      expect(minutes, inInclusiveRange(8 * 60 + 30, 8 * 60 + 45));
    });

    test('Hanafi Asr is later', () {
      final day = DateTime(2026, 10, 26);
      final shafi = prayerDay(riyadh, day)![Prayer.asr];
      final hanafi = prayerDay(riyadh.copyWith(hanafiAsr: true), day)![Prayer.asr];
      expect(hanafi.isAfter(shafi), isTrue);
    });

    test('next and current prayer, including after Isha', () {
      final day = DateTime(2026, 10, 26);
      final t = prayerDay(riyadh, day)!;
      final afterDhuhr = t[Prayer.dhuhr].add(const Duration(minutes: 5));
      expect(currentPrayer(riyadh, afterDhuhr), Prayer.dhuhr);
      expect(nextPrayer(riyadh, afterDhuhr)!.$1, Prayer.asr);
      final late = t[Prayer.isha].add(const Duration(hours: 1));
      final next = nextPrayer(riyadh, late)!;
      expect(next.$1, Prayer.fajr);
      expect(next.$2.isAfter(late), isTrue);
    });
  });

  group('planning around prayers', () {
    test('the planner keeps prayer time free', () {
      final day = DateTime(2026, 10, 26);
      final t = prayerDay(riyadh, day)!;
      final settings = const UserSettings(prayer: riyadh);
      final tasks = [
        for (var i = 0; i < 12; i++)
          Task(
            id: 't$i',
            title: 'Task $i',
            estimatedMinutes: 45,
            dueDate: dayKey(day),
            createdAt: day,
            updatedAt: day,
          ),
      ];
      final plan = const Planner().plan(day: day, now: day, tasks: tasks, events: const [], settings: settings);
      final prayers = plan.fixed.where((b) => b.kind == BlockKind.prayer).toList();
      // Fajr is before the default 07:00 day start; the other four are in.
      expect(prayers.map((b) => b.refId), containsAll(['dhuhr', 'asr', 'maghrib', 'isha']));
      for (final p in plan.planned) {
        for (final b in prayers) {
          final overlaps = p.start.isBefore(b.end) && p.end.isAfter(b.start);
          expect(overlaps, isFalse, reason: '${p.task.id} vs ${b.refId}');
        }
      }
      expect(prayers.firstWhere((b) => b.refId == 'dhuhr').start, t[Prayer.dhuhr]);
    });

    test('timeline: current and next, user-planned tasks keep their time', () {
      final now = DateTime(2026, 10, 26, 9, 10);
      final planned = Task(
        id: 'p',
        title: 'Planned',
        estimatedMinutes: 60,
        plannedStart: DateTime(2026, 10, 26, 9),
        createdAt: now,
        updatedAt: now,
      );
      final open = Task(id: 'o', title: 'Open', estimatedMinutes: 30, createdAt: now, updatedAt: now);
      final d = AppData(tasks: [planned, open], settings: const UserSettings(prayer: riyadh));
      final tl = buildTimeline(d, now);
      expect(tl.current?.task?.id, 'p');
      expect(tl.current!.suggested, isFalse);
      expect(tl.current!.end, DateTime(2026, 10, 26, 10));
      final suggested = tl.items.firstWhere((i) => i.task?.id == 'o');
      expect(suggested.suggested, isTrue);
      expect(suggested.start.isBefore(DateTime(2026, 10, 26, 10)), isFalse, reason: 'not on top of the planned task');
      expect(tl.items.where((i) => i.kind == TimelineKind.prayer), hasLength(5), reason: "Fajr too, though before day start");
      expect(tl.next, isNotNull);
    });
  });

  group('reminders and data', () {
    test('device reminders at prayer times, plus the early one', () {
      final now = DateTime(2026, 10, 26, 6);
      final d = AppData(settings: UserSettings(prayer: riyadh.copyWith(remindBefore: 10)));
      final r = planDeviceReminders(d, now, l);
      final dhuhr = prayerDay(riyadh, now)![Prayer.dhuhr];
      expect(r.where((x) => x.at == dhuhr).single.title, l.notifPrayerTitle(l.prayerDhuhr));
      expect(r.any((x) => x.at == dhuhr.subtract(const Duration(minutes: 10))), isTrue);
      // Two days of five prayers (+ early reminders), minus any already past.
      expect(r.length, lessThanOrEqualTo(20));
      final ids = r.map((x) => x.id).toSet();
      expect(ids.length, r.length, reason: 'stable unique ids');
      // Notifications off: none.
      expect(planDeviceReminders(AppData(settings: UserSettings(prayer: riyadh.copyWith(notify: false))), now, l), isEmpty);
    });

    test('settings and logs round-trip through JSON and server rows', () {
      final s = UserSettings(prayer: riyadh.copyWith(method: PrayerMethod.dubai, hanafiAsr: true, remindBefore: 15));
      final back = UserSettings.fromJson(s.toJson()).prayer;
      expect(back.method, PrayerMethod.dubai);
      expect(back.hanafiAsr, isTrue);
      expect(back.latitude, riyadh.latitude);
      final row = profileRow(s);
      expect((row['prayer_settings'] as Map)['method'], 'dubai');
      final fromRow = settingsFrom(row).prayer;
      expect(fromRow.remindBefore, 15);
      expect(fromRow.place, 'الرياض');
      const log = PrayerLog(id: 'x', day: '2026-10-26', prayer: Prayer.asr);
      expect(prayerLogFrom(prayerLogRow(log)).prayer, Prayer.asr);
      expect(PrayerLog.fromJson(log.toJson()).day, '2026-10-26');
    });

    test('the log is only what the user marks, never for a future day', () async {
      final c = await signedInContainer();
      addTearDown(c.dispose);
      final data = c.read(dataProvider.notifier);
      final today = dayKey(fixedNow);
      data.setPrayerLogged(Prayer.fajr, today, true);
      data.setPrayerLogged(Prayer.fajr, today, true); // no duplicate
      expect(c.read(dataProvider).prayerLogs, hasLength(1));
      expect(() => data.setPrayerLogged(Prayer.isha, dayKey(fixedNow.add(const Duration(days: 1))), true), throwsArgumentError);
      data.setPrayerLogged(Prayer.fajr, today, false);
      expect(c.read(dataProvider).prayerLogs, isEmpty);
    });
  });

  group('assistant', () {
    final now = DateTime(2026, 10, 26, 16);
    AssistantContext ctx(List<Task> tasks) =>
        AssistantContext(AppData(tasks: tasks), const AssistantPermissions());

    test('"I have half an hour" suggests tasks that fit, without changing anything', () {
      final tasks = [
        Task(id: 'a', title: 'Quick call', estimatedMinutes: 15, createdAt: now, updatedAt: now),
        Task(id: 'b', title: 'Long report', estimatedMinutes: 120, createdAt: now, updatedAt: now),
      ];
      final r = LocalAssistantEngine(l).respond('عندي نص ساعة، وش أنجز؟', ctx(tasks), now);
      expect(r.calls, isEmpty);
      expect(r.text, contains('Quick call'));
      expect(r.text, isNot(contains('Long report')));
    });

    test('"I\'m running late" re-plans the rest of the day', () {
      final tasks = [Task(id: 'a', title: 'Read', estimatedMinutes: 30, createdAt: now, updatedAt: now)];
      final r = LocalAssistantEngine(l).respond(l.aiChipLate, ctx(tasks), now);
      expect(r.calls.single.tool, 'plan_task');
    });
  });
}
