import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/data/activity_sync.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/auth.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/health.dart';
import 'package:hayati/data/models/settings.dart';
import 'package:hayati/data/remote/rows.dart';
import 'package:hayati/domain/activity.dart';
import 'package:hayati/domain/device_reminders.dart';
import 'package:hayati/l10n/app_localizations.dart';
import 'package:hayati/services/step_reader.dart';

import 'helpers.dart';

class FakeStepReader implements StepReader {
  FakeStepReader({this.grant = true, this.days = const []});
  bool grant;
  List<StepDay> days;
  int reads = 0;

  @override
  ActivitySource get source => ActivitySource.healthConnect;
  @override
  Future<StepAvailability> availability() async => StepAvailability.ready;
  @override
  Future<bool> requestAccess() async => grant;
  @override
  Future<void> install() async {}
  @override
  Future<List<StepDay>> readDays(DateTime from, DateTime to) async {
    reads++;
    return days;
  }
}

DailyActivity row(String day, ActivitySource s, int steps, {int? distance}) =>
    DailyActivity(id: '$day-${s.name}', day: day, source: s, steps: steps, distanceM: distance, updatedAt: fixedNow);

void main() {
  group('sex', () {
    test('chosen at sign-up is kept with the account and adopted by the app', () async {
      final c = await signedInContainer(sex: Sex.female);
      expect(c.read(authProvider).user!.sex, Sex.female);
      // The shell adopts it after the first sync (see app_flow_test).
      c.read(dataProvider.notifier).setSex(c.read(authProvider).user!.sex!);
      final s = c.read(settingsProvider);
      expect(s.sex, Sex.female);
      expect(s.health.has(HealthModule.womens), isTrue);
      expect(s.health.has(HealthModule.mens), isFalse);
      // Restored on the next launch.
      final again = await c.read(authBackendProvider).restore();
      expect(again!.sex, Sex.female);
    });

    test('changing it switches the matching section and keeps the others', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier)..setSex(Sex.female);
      data.updateHealth((h) => h.copyWith(modules: {...h.modules}..remove(HealthModule.nutrition)));
      data.setSex(Sex.male);
      final h = c.read(settingsProvider).health;
      expect(h.has(HealthModule.mens), isTrue);
      expect(h.has(HealthModule.womens), isFalse);
      expect(h.has(HealthModule.nutrition), isFalse, reason: 'other choices kept');
    });

    test('accounts without it stay unset until asked', () async {
      final c = await signedInContainer();
      await Future<void>.delayed(Duration.zero);
      expect(c.read(settingsProvider).sex, isNull);
    });

    test('profile row and JSON round-trip', () {
      const s = UserSettings(sex: Sex.male, health: HealthSettings(stepGoal: 9000, heightCm: 175, moveReminders: true, preferredSource: ActivitySource.manual));
      for (final back in [settingsFrom({...profileRow(s), 'currency': 'SAR'}), UserSettings.fromJson(s.toJson())]) {
        expect(back.sex, Sex.male);
        expect((back.health.stepGoal, back.health.heightCm, back.health.moveReminders, back.health.preferredSource),
            (9000, 175, true, ActivitySource.manual));
      }
      expect(HealthSettings.fromJson(const {}).stepGoal, 8000);
      expect(HealthSettings.fromJson(const {'modules': ['activity', 'unknown']}).modules, {HealthModule.activity});
    });
  });

  group('activity', () {
    test('one source per day, never a sum; preferred source first', () {
      final d = AppData(activity: [
        row('2026-03-09', ActivitySource.manual, 3000),
        row('2026-03-09', ActivitySource.healthConnect, 7000),
        row('2026-03-08', ActivitySource.manual, 4200),
      ]);
      expect(activityDay(d, '2026-03-09').steps, 7000);
      expect(activityDay(d, '2026-03-08').source, ActivitySource.manual);
      final pref = d.copyWith(settings: const UserSettings(health: HealthSettings(preferredSource: ActivitySource.manual)));
      expect(activityDay(pref, '2026-03-09').steps, 3000);
      expect(activityDay(d, '2026-03-07').hasData, isFalse);
    });

    test('distance: from the source, else estimated from height', () {
      expect(estimateDistanceM(10000, null), 7500);
      expect(estimateDistanceM(10000, 180), 7470);
      final d = AppData(activity: [row('2026-03-09', ActivitySource.healthKit, 1000, distance: 820)]);
      final a = activityDay(d, '2026-03-09');
      expect((a.distanceM, a.distanceEstimated), (820, false));
    });

    test('series, stats and streak', () {
      final d = AppData(activity: [
        row('2026-03-10', ActivitySource.manual, 9000),
        row('2026-03-09', ActivitySource.manual, 8000),
        row('2026-03-08', ActivitySource.manual, 12000),
        row('2026-03-06', ActivitySource.manual, 2000),
      ]);
      final series = activitySeries(d, fixedNow, 7);
      expect(series.first.day, '2026-03-04');
      expect(series.last.day, '2026-03-10');
      final st = activityStats(series, 8000);
      expect((st.total, st.average, st.goalDays, st.daysWithData, st.best!.day), (31000, 7750, 3, 4, '2026-03-08'));
      expect(goalStreak(d, fixedNow, 8000), 3);
      // An unfinished today doesn't break yesterday's streak.
      final open = d.copyWith(activity: [...d.activity.where((a) => a.day != '2026-03-10'), row('2026-03-10', ActivitySource.manual, 100)]);
      expect(goalStreak(open, fixedNow, 8000), 2);
    });

    test('recording validates and replaces the same day and source', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      expect(() => data.recordActivity('2026-03-11', ActivitySource.manual, steps: 10), throwsArgumentError);
      expect(() => data.recordActivity('2026-03-10', ActivitySource.manual, steps: 200000), throwsArgumentError);
      data.recordActivity('2026-03-10', ActivitySource.healthConnect, steps: 5000);
      final id = data.snapshot.activity.single.id;
      data.recordActivity('2026-03-10', ActivitySource.healthConnect, steps: 6500);
      expect(data.snapshot.activity.single.id, id);
      expect(data.snapshot.activity.single.steps, 6500);
      data.recordActivity('2026-03-10', ActivitySource.manual, steps: 100);
      expect(data.snapshot.activity, hasLength(2));
      expect(() => data.updateHealth((h) => h.copyWith(stepGoal: 10)), throwsArgumentError);
    });

    test('the same day and source gets the same id on another device', () async {
      final a = await signedInContainer();
      a.read(dataProvider.notifier).recordActivity('2026-03-09', ActivitySource.healthConnect, steps: 1);
      final idA = a.read(dataProvider).activity.single.id;
      final b = await signedInContainer();
      b.read(dataProvider.notifier).recordActivity('2026-03-09', ActivitySource.healthConnect, steps: 1);
      // Different accounts never collide.
      expect(b.read(dataProvider).activity.single.id, isNot(idA));
      final again = a.read(dataProvider.notifier)..deleteActivity(idA);
      again.recordActivity('2026-03-09', ActivitySource.healthConnect, steps: 2);
      expect(a.read(dataProvider).activity.single.id, idA);
    });

    test('sync reads the health store once linked, only with the section on', () async {
      final reader = FakeStepReader(days: const [StepDay('2026-03-09', 7300), StepDay('2026-03-10', 1200)]);
      final c = await signedInContainer(overrides: [stepReaderProvider.overrideWithValue(reader)]);
      final sync = c.read(activitySyncProvider.notifier);
      await sync.sync(force: true);
      expect(reader.reads, 0, reason: 'not linked yet');
      reader.grant = false;
      expect(await sync.connect(), isFalse);
      expect(c.read(activitySyncProvider).linked, isFalse);
      reader.grant = true;
      expect(await sync.connect(), isTrue);
      expect(activityDay(c.read(dataProvider), '2026-03-09').steps, 7300);
      expect(c.read(dataProvider).activity.every((a) => a.source == ActivitySource.healthConnect), isTrue);
      // Throttled unless forced.
      await sync.sync();
      expect(reader.reads, 1);
      c.read(dataProvider.notifier).updateHealth((h) => h.copyWith(modules: {}));
      await sync.sync(force: true);
      expect(reader.reads, 1);
      await sync.disconnect();
      expect(c.read(activitySyncProvider).linked, isFalse);
    });

    test('move reminders within the hours, none today once the goal is met', () {
      final l = lookupAppLocalizations(const Locale('ar'));
      const h = HealthSettings(moveReminders: true, moveStart: 10 * 60, moveEnd: 14 * 60, moveEvery: 120);
      final d = AppData(settings: const UserSettings(health: h));
      final move = planDeviceReminders(d, fixedNow, l).where((r) => r.title == l.notifMoveTitle).toList();
      // 10:00, 12:00, 14:00 today and tomorrow.
      expect(move.map((r) => r.at.hour), [10, 12, 14, 10, 12, 14]);
      final met = d.copyWith(activity: [row('2026-03-10', ActivitySource.manual, 9000)]);
      final after = planDeviceReminders(met, fixedNow, l).where((r) => r.title == l.notifMoveTitle);
      expect(after.every((r) => r.at.day == 11), isTrue);
      expect(planDeviceReminders(AppData(settings: const UserSettings(health: HealthSettings())), fixedNow, l)
          .where((r) => r.title == l.notifMoveTitle), isEmpty);
    });
  });

  test('daily_activity rows round-trip', () {
    final a = DailyActivity(id: 'x', day: '2026-03-09', source: ActivitySource.healthKit, steps: 812, distanceM: 600, activeMinutes: 12, updatedAt: fixedNow);
    final b = activityFrom({...activityRow(a)});
    expect((b.day, b.source, b.steps, b.distanceM, b.activeMinutes, b.updatedAt), ('2026-03-09', ActivitySource.healthKit, 812, 600, 12, fixedNow));
    expect(DailyActivity.fromJson(a.toJson()).steps, 812);
    expect(AppData.fromJson(AppData(activity: [a]).toJson()).activity.single.source, ActivitySource.healthKit);
  });
}
