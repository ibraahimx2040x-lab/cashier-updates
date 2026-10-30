import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/core/utils/dates.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/health.dart';
import 'package:hayati/data/models/settings.dart';
import 'package:hayati/data/models/womens.dart';
import 'package:hayati/data/remote/rows.dart';
import 'package:hayati/data/remote/sync.dart';
import 'package:hayati/domain/device_reminders.dart';
import 'package:hayati/domain/womens/cycle.dart';
import 'package:hayati/l10n/app_localizations.dart';

import 'helpers.dart';

/// [fixedNow] is 2026-03-10.
String ago(int days) => dayKey(fixedNow.subtract(Duration(days: days)));

CyclePeriod period(String id, int startAgo, [int? endAgo]) =>
    CyclePeriod(id: id, start: ago(startAgo), end: endAgo == null ? null : ago(endAgo), updatedAt: fixedNow);

AppData withPeriods(List<CyclePeriod> p, {HealthSettings h = const HealthSettings()}) =>
    AppData(periods: p, settings: UserSettings(sex: Sex.female, health: h));

void main() {
  group('estimates', () {
    test('needs two periods, or a usual length the user set', () {
      expect(estimateCycle(withPeriods([period('a', 5, 1)])), isNull);
      expect(cycleStatus(withPeriods([period('a', 5, 1)]), fixedNow).canPredict, isFalse);
      final set = estimateCycle(withPeriods([period('a', 5, 1)], h: const HealthSettings(cycleLength: 30)))!;
      expect((set.cycleLength, set.minLength, set.maxLength, set.periodLength, set.fromSettings), (30, 28, 32, 5, true));
    });

    test('average of the last six cycles, with a range; missed months skipped', () {
      final d = withPeriods([
        period('0', 300, 296), // then a 120-day gap: missed logging
        period('1', 180, 176),
        period('2', 152, 148),
        period('3', 122, 118),
        period('4', 93, 89),
        period('5', 62, 58),
        period('6', 33, 29),
        period('7', 4),
      ]);
      final e = estimateCycle(d)!;
      expect(e.lengths, [28, 30, 29, 31, 29, 29]);
      expect((e.cycleLength, e.minLength, e.maxLength, e.periodLength), (29, 27, 31, 5));
      final s = cycleStatus(d, fixedNow);
      expect((s.dayOfCycle, s.inPeriod, s.periodDay), (5, true, 5));
      expect(dayKey(s.nextStart!), ago(4 - 29));
      expect((dayKey(s.windowStart!), dayKey(s.windowEnd!)), (ago(4 - 27), ago(4 - 31)));
      expect(irregular(e), isFalse);
      expect(cycleHistory(d).map((x) => x.$2), [28, 30, 29, 31, 29, 29]);
    });

    test('late, open periods, irregular cycles', () {
      final late = cycleStatus(withPeriods([period('a', 70, 66), period('b', 40, 36)]), fixedNow);
      expect((late.inPeriod, late.daysLate), (false, 40 - 32));
      // An open period counts as going on for 10 days at most.
      expect(cycleStatus(withPeriods([period('a', 12)]), fixedNow).inPeriod, isFalse);
      expect(irregular(estimateCycle(withPeriods([period('a', 100, 96), period('b', 82, 78), period('c', 50, 46), period('d', 30, 26)]))), isTrue,
          reason: '18-day cycle');
      expect(irregular(estimateCycle(withPeriods([period('a', 120, 116), period('b', 96, 92), period('c', 60, 56), period('d', 36, 32)]))), isTrue,
          reason: '24 to 36 days');
    });

    test('calendar: recorded days, then the next predicted periods only in the future', () {
      final d = withPeriods([period('a', 31, 27), period('b', 3)]);
      final m = calendarMarks(d, fixedNow);
      expect([for (var i = 3; i >= 0; i--) m[ago(i)]], List.filled(4, DayMark.period), reason: 'open period up to today');
      expect(m[ago(-1)], isNull, reason: 'not yet recorded, not predicted inside the period');
      // Next start: 3 days ago + 28.
      expect([for (var i = 0; i < 5; i++) m[ago(3 - 28 - i)]], List.filled(5, DayMark.predicted));
      expect(m.values.where((v) => v == DayMark.predicted), hasLength(15), reason: 'three cycles ahead');
    });

    test('symptoms: most frequent first, with the usual cycle day', () {
      CycleDayLog log(int a, Set<Symptom> s) => CycleDayLog(id: ago(a), day: ago(a), symptoms: s, updatedAt: fixedNow);
      final d = withPeriods([period('a', 31, 27), period('b', 3)]).copyWith(cycleLogs: [
        log(31, {Symptom.cramps, Symptom.fatigue}),
        log(29, {Symptom.cramps}),
        log(3, {Symptom.cramps, Symptom.headache}),
      ]);
      final s = symptomStats(d);
      expect([for (final x in s) (x.symptom, x.count, x.typicalDay)],
          [(Symptom.cramps, 3, 2), (Symptom.headache, 1, 1), (Symptom.fatigue, 1, 1)]);
    });
  });

  group('recording', () {
    test('start and end; no future, no overlap, no second open period', () async {
      final c = await signedInContainer(sex: Sex.female);
      final data = c.read(dataProvider.notifier);
      expect(() => data.startPeriod(ago(-1)), throwsArgumentError);
      data.startPeriod(ago(2));
      expect(() => data.startPeriod(ago(0)), throwsArgumentError, reason: 'one is going on');
      expect(() => data.endPeriod(ago(4)), throwsArgumentError, reason: 'before it started');
      data.endPeriod(ago(0));
      expect(c.read(dataProvider).periods.single.end, ago(0));
      expect(() => data.startPeriod(ago(1)), throwsArgumentError, reason: 'overlaps');
      expect(() => data.savePeriod(period('x', 40, 20)), throwsArgumentError, reason: 'over 15 days');
      data.savePeriod(period('x', 33, 29));
      expect(c.read(dataProvider).periods, hasLength(2));
    });

    test('a forgotten open period is closed when the next one starts', () async {
      final c = await signedInContainer(sex: Sex.female);
      final data = c.read(dataProvider.notifier);
      data.savePeriod(period('a', 30));
      data.startPeriod(ago(1));
      final p = sortedPeriods(c.read(dataProvider));
      expect((p.first.end, p.last.end), (ago(26), null));
    });

    test('one log per day; empty removes it; nonsense refused', () async {
      final c = await signedInContainer(sex: Sex.female);
      final data = c.read(dataProvider.notifier);
      data.saveCycleLog(CycleDayLog(id: '', day: ago(0), flow: FlowLevel.light, pain: 3, symptoms: const {Symptom.cramps}, note: '  tired ', updatedAt: fixedNow));
      final id = c.read(dataProvider).cycleLog(ago(0))!.id;
      data.saveCycleLog(CycleDayLog(id: '', day: ago(0), pain: 5, updatedAt: fixedNow));
      final log = c.read(dataProvider).cycleLogs.single;
      expect((log.id, log.pain, log.flow, log.note), (id, 5, null, ''));
      expect(() => data.saveCycleLog(CycleDayLog(id: '', day: ago(0), pain: 12, updatedAt: fixedNow)), throwsArgumentError);
      expect(() => data.saveCycleLog(CycleDayLog(id: '', day: ago(-1), pain: 1, updatedAt: fixedNow)), throwsArgumentError);
      data.saveCycleLog(CycleDayLog(id: '', day: ago(0), updatedAt: fixedNow));
      expect(c.read(dataProvider).cycleLogs, isEmpty);
    });

    test('appointments, export and deleting health data only', () async {
      final c = await signedInContainer(sex: Sex.female);
      final data = c.read(dataProvider.notifier);
      final a = HealthAppointment(id: 'ap', title: 'Checkup', at: fixedNow.add(const Duration(days: 2)), questions: const ['Q1'], reminderMinutes: 60, updatedAt: fixedNow);
      expect(() => data.saveAppointment(HealthAppointment(id: 'x', title: ' ', at: fixedNow, updatedAt: fixedNow)), throwsArgumentError);
      data.saveAppointment(a);
      data.startPeriod(ago(1));
      data.addWater(ago(0), 500);
      final task = data.newTask(title: 'Keep me');
      data.saveTask(task);
      expect(nextAppointment(c.read(dataProvider), fixedNow)!.title, 'Checkup');
      final json = data.exportHealthJson();
      expect(json.contains('Checkup') && json.contains('"periods"') && !json.contains('Keep me'), isTrue);
      data.deleteHealthData();
      final d = c.read(dataProvider);
      expect((d.appointments.isEmpty, d.periods.isEmpty, d.water.isEmpty, d.tasks.single.title), (true, true, true, 'Keep me'));
    });
  });

  group('this device only', () {
    final p = period('p1', 3);
    final log = CycleDayLog(id: 'l1', day: ago(1), symptoms: const {Symptom.backPain}, updatedAt: fixedNow);
    final synced = AppData(periods: [p], cycleLogs: [log], settings: const UserSettings(sex: Sex.female));
    final local = synced.copyWith(settings: const UserSettings(sex: Sex.female, health: HealthSettings(cycleLocalOnly: true)));

    test('turning it on deletes the server copy; nothing is sent while on', () {
      final on = diff(synced, local);
      expect({for (final o in on) '${o.table}:${o.kind}'}, {'cycle_periods:delete', 'cycle_day_logs:delete', 'profiles:profile'});
      final more = local.copyWith(periods: [p, period('p2', 40, 36)], cycleLogs: const []);
      expect(diff(local, more), isEmpty);
    });

    test('turning it off uploads everything kept on the device', () {
      final off = diff(local, synced);
      expect({for (final o in off) '${o.table}:${o.kind}'}, {'cycle_periods:upsert', 'cycle_day_logs:upsert', 'profiles:profile'});
    });

    test('a server snapshot leaves local cycle data alone', () {
      final merged = mergeRemote(local, local.settings, {
        'cycle_periods': [periodRow(period('server', 50, 46))],
      });
      expect(merged.periods.single.id, 'p1');
      expect(mergeRemote(synced, synced.settings, {'cycle_periods': [periodRow(period('server', 50, 46))]}).periods.single.id, 'server');
    });
  });

  test('reminders never say what they are about', () {
    for (final lang in ['ar', 'en']) {
      final l = lookupAppLocalizations(Locale(lang));
      const h = HealthSettings(modules: {HealthModule.womens}, cycleReminders: true);
      final d = withPeriods([period('a', 50, 46), period('b', 22, 18)], h: h).copyWith(appointments: [
        HealthAppointment(id: 'ap', title: 'Gynecologist', at: fixedNow.add(const Duration(days: 1)), reminderMinutes: 60, updatedAt: fixedNow),
      ]);
      final all = planDeviceReminders(d, fixedNow, l);
      final cycle = all.where((r) => r.route == '/womens').single;
      // Next start 22 days ago + 28; the reminder comes two days before the window opens (26 days).
      expect(dayKey(cycle.at), ago(22 - 26 + 2));
      expect((cycle.title, cycle.body), (l.notifNeutralTitle, l.notifNeutralBody));
      final ap = all.where((r) => r.route == '/health/appointments').single;
      expect(ap.title, l.notifAppointmentTitle);
      for (final r in all) {
        final text = '${r.title} ${r.body}'.toLowerCase();
        for (final w in ['period', 'cycle', 'دورة', 'الدورة', 'gynecologist']) {
          expect(text.contains(w), isFalse, reason: '"$text" says $w');
        }
      }
      // Off, or not a female account: no cycle reminder.
      expect(planDeviceReminders(d.copyWith(settings: d.settings.copyWith(health: h.copyWith(cycleReminders: false))), fixedNow, l)
          .where((r) => r.route == '/womens'), isEmpty);
      expect(planDeviceReminders(d.copyWith(settings: d.settings.copyWith(sex: Sex.male)), fixedNow, l).where((r) => r.route == '/womens'), isEmpty);
    }
  });

  test('rows and JSON round-trip', () {
    final log = CycleDayLog(
        id: 'l', day: '2026-03-09', flow: FlowLevel.heavy, pain: 7, symptoms: const {Symptom.backPain, Symptom.breastTenderness},
        otherSymptoms: 'dizzy', mood: CycleMood.irritable, energy: 2, note: 'n', updatedAt: fixedNow);
    final row = cycleLogRow(log);
    expect(row['symptoms'], ['back_pain', 'breast_tenderness']);
    final back = cycleLogFrom({...row});
    expect((back.flow, back.otherSymptoms, back.mood, back.energy), (FlowLevel.heavy, 'dizzy', CycleMood.irritable, 2));
    expect(back.symptoms, log.symptoms);
    final p = periodFrom({...periodRow(period('p', 3, 1))});
    expect((p.start, p.end), (ago(3), ago(1)));
    final a = HealthAppointment(id: 'a', title: 'T', kind: AppointmentKind.test, at: fixedNow, place: 'Clinic', questions: const ['q'], reminderMinutes: 30, updatedAt: fixedNow);
    final ab = appointmentFrom({...appointmentRow(a)});
    expect((ab.kind, ab.at, ab.place, ab.questions.single, ab.reminderMinutes), (AppointmentKind.test, fixedNow, 'Clinic', 'q', 30));
    final d = AppData.fromJson(AppData(periods: [period('p', 3)], cycleLogs: [log], appointments: [a]).toJson());
    expect((d.periods.single.end, d.cycleLogs.single.symptoms.length, d.appointments.single.title), (null, 2, 'T'));
    const h = HealthSettings(cycleLength: 30, periodLength: 6, cycleLocalOnly: true, hideFromHome: true, lockEnabled: true, cycleReminders: true);
    final hb = HealthSettings.fromJson(h.toJson());
    expect((hb.cycleLength, hb.periodLength, hb.cycleLocalOnly, hb.hideFromHome, hb.lockEnabled, hb.cycleReminders), (30, 6, true, true, true, true));
  });
}
