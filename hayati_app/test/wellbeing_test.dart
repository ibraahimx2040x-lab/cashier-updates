import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/core/utils/dates.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/health.dart';
import 'package:hayati/data/models/settings.dart';
import 'package:hayati/data/remote/rows.dart';
import 'package:hayati/domain/device_reminders.dart';
import 'package:hayati/domain/fitness/programs.dart' show Audience;
import 'package:hayati/domain/health_articles.dart';
import 'package:hayati/domain/sleep.dart';
import 'package:hayati/domain/vitals.dart';
import 'package:hayati/l10n/app_localizations.dart';

import 'helpers.dart';

DateTime at(int day, int h, [int m = 0]) => DateTime(2026, 3, day, h, m);

BodyMetric bp(String id, double s, double d, DateTime t) =>
    BodyMetric(id: id, kind: MetricKind.bp, value: s, value2: d, source: ActivitySource.manual, measuredAt: t);

void main() {
  group('measurements', () {
    test('typed in: bounds per kind, blood pressure needs both, nothing in the future', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      data.addMetric(kind: MetricKind.weight, value: 82.4, note: ' after gym ');
      expect(() => data.addMetric(kind: MetricKind.weight, value: 900), throwsArgumentError);
      expect(() => data.addMetric(kind: MetricKind.bp, value: 120), throwsArgumentError);
      expect(() => data.addMetric(kind: MetricKind.waist, value: 90, value2: 3), throwsArgumentError);
      expect(() => data.addMetric(kind: MetricKind.bodyFat, value: 20, at: fixedNow.add(const Duration(days: 1))), throwsArgumentError);
      final m = data.addMetric(kind: MetricKind.bp, value: 128, value2: 84, at: at(9, 8));
      expect(c.read(dataProvider).bodyMetrics.firstWhere((x) => x.kind == MetricKind.weight).note, 'after gym');
      data.deleteMetric(m.id);
      expect(c.read(dataProvider).bodyMetrics, hasLength(1));
    });

    test('blood pressure guidance: urgent on one very high reading, see a doctor on a high average of three', () {
      AppData d(List<BodyMetric> m) => AppData(bodyMetrics: m);
      expect(bpAdvice(d([bp('a', 150, 95, at(8, 8))])), BpAdvice.none, reason: 'one reading is not enough');
      expect(bpAdvice(d([bp('a', 150, 95, at(8, 8)), bp('b', 142, 88, at(9, 8)), bp('c', 138, 92, at(10, 8))])), BpAdvice.seeDoctor);
      expect(bpAdvice(d([bp('a', 150, 95, at(8, 8)), bp('b', 120, 80, at(9, 8)), bp('c', 118, 76, at(10, 8))])), BpAdvice.none);
      expect(bpAdvice(d([bp('a', 120, 80, at(8, 8)), bp('b', 182, 100, at(10, 8))])), BpAdvice.urgent);
      expect(bpAdvice(d([bp('b', 150, 121, at(10, 8))])), BpAdvice.urgent);
    });

    test('change over 30 days, newest first', () {
      BodyMetric w(String id, double v, DateTime t) => BodyMetric(id: id, kind: MetricKind.weight, value: v, source: ActivitySource.manual, measuredAt: t);
      final d = AppData(bodyMetrics: [w('a', 85, fixedNow.subtract(const Duration(days: 40))), w('b', 84, at(1, 8)), w('c', 82.5, at(9, 8))]);
      expect(metricsOf(d, MetricKind.weight).first.id, 'c');
      expect(metricChange(d, MetricKind.weight, fixedNow), -1.5);
    });
  });

  group('sleep and recovery', () {
    test('nights entered by hand: up to 24 h, no future, no overlap; imported ones stay', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      final s = data.addSleep(start: at(9, 23), end: at(10, 6, 30), quality: 4);
      expect(() => data.addSleep(start: at(10, 1), end: at(10, 5)), throwsArgumentError, reason: 'overlaps');
      expect(() => data.addSleep(start: at(8, 1), end: at(9, 5)), throwsArgumentError, reason: 'over 24 h');
      expect(() => data.addSleep(start: at(10, 22), end: at(11, 6)), throwsArgumentError, reason: 'future');
      expect(() => data.addSleep(start: at(8, 23), end: at(9, 6), quality: 6), throwsArgumentError);
      data.importSleep(ActivitySource.healthKit, [(at(9, 23), at(10, 6))], from: at(4, 0));
      expect(sleepDay(c.read(dataProvider), '2026-03-10').source, ActivitySource.healthKit, reason: 'the health app comes first');
      final imported = c.read(dataProvider).sleep.firstWhere((x) => x.source == ActivitySource.healthKit);
      data.rateSleep(imported.id, 3);
      data.deleteSleep(imported.id);
      expect(c.read(dataProvider).sleep.firstWhere((x) => x.source == ActivitySource.healthKit).quality, 3, reason: 'only typed-in nights can be deleted');
      data.deleteSleep(s.id);
      expect(c.read(dataProvider).sleep.single.source, ActivitySource.healthKit);
    });

    test('one check-in a day; empty removes it; week averages', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      data.saveCheckin(WellbeingCheckin(id: '', day: '2026-03-10', energy: 4, recovery: 3, updatedAt: fixedNow));
      final id = c.read(dataProvider).checkin('2026-03-10')!.id;
      data.saveCheckin(WellbeingCheckin(id: '', day: '2026-03-10', energy: 2, recovery: 3, mood: 5, updatedAt: fixedNow));
      data.saveCheckin(WellbeingCheckin(id: '', day: '2026-03-08', energy: 4, updatedAt: fixedNow));
      expect(c.read(dataProvider).checkin('2026-03-10')!.id, id);
      expect(() => data.saveCheckin(WellbeingCheckin(id: '', day: '2026-03-11', energy: 2, updatedAt: fixedNow)), throwsArgumentError);
      expect(() => data.saveCheckin(WellbeingCheckin(id: '', day: '2026-03-09', fatigue: 0, updatedAt: fixedNow)), throwsArgumentError);
      final a = checkinAverages(c.read(dataProvider), fixedNow);
      expect((a.days, a.energy, a.recovery, a.mood, a.fatigue), (2, 3.0, 3.0, 5.0, null));
      data.saveCheckin(WellbeingCheckin(id: '', day: '2026-03-08', updatedAt: fixedNow));
      expect(c.read(dataProvider).checkins, hasLength(1));
    });

    test('bedtime reminder each night, only with the sleep section on', () {
      final l = lookupAppLocalizations(const Locale('en'));
      final d = AppData(settings: const UserSettings(health: HealthSettings(bedtimeReminder: 22 * 60 + 30)));
      final r = planDeviceReminders(d, fixedNow, l).where((x) => x.title == l.notifBedtimeTitle).toList();
      expect(r.map((x) => x.at), [at(10, 22, 30), at(11, 22, 30)]);
      final off = d.copyWith(settings: const UserSettings(health: HealthSettings(bedtimeReminder: 22 * 60, modules: {HealthModule.activity})));
      expect(planDeviceReminders(off, fixedNow, l).where((x) => x.title == l.notifBedtimeTitle), isEmpty);
    });
  });

  group('health reading', () {
    test("men's topics for men, women's for women, the rest for everyone; every article has sources", () {
      ids(UserSettings s) => articlesFor(s).map((a) => a.id).toSet();
      final shared = {for (final a in healthArticles) if (a.audience == Audience.all) a.id};
      final male = ids(const UserSettings(sex: Sex.male, health: HealthSettings(modules: {HealthModule.mens})));
      final female = ids(const UserSettings(sex: Sex.female, health: HealthSettings(modules: {HealthModule.womens})));
      expect(male, {...shared, 'pelvic_floor_men', 'prostate_urinary', 'testicular_check'});
      expect(female, {...shared, 'pelvic_floor_women', 'exercise_pregnancy'});
      expect(ids(const UserSettings()), shared);
      for (final a in healthArticles) {
        expect(a.sources, isNotEmpty, reason: a.id);
        expect((a.bodyAr.length, a.ar.isNotEmpty, a.summaryAr.isNotEmpty), (a.bodyEn.length, true, true), reason: a.id);
      }
      expect(healthArticles.map((a) => a.id).toSet(), hasLength(healthArticles.length));
    });
  });

  test('rows and JSON round-trip', () {
    final c = WellbeingCheckin(id: 'w', day: '2026-03-10', energy: 4, fatigue: 2, recovery: 3, mood: 5, updatedAt: fixedNow);
    final b = checkinFrom({...checkinRow(c)});
    expect((b.day, b.energy, b.fatigue, b.recovery, b.mood), ('2026-03-10', 4, 2, 3, 5));
    final d = AppData.fromJson(AppData(checkins: [c]).toJson());
    expect(d.checkins.single.mood, 5);
    expect(HealthSettings.fromJson(const HealthSettings(bedtimeReminder: 1350).toJson()).bedtimeReminder, 1350);
    expect(dayKey(at(10, 1)), '2026-03-10');
  });
}
