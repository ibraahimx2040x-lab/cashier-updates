import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/core/utils/dates.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/auth.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/health_sync.dart';
import 'package:hayati/data/models/health.dart';
import 'package:hayati/data/models/settings.dart';
import 'package:hayati/data/remote/rows.dart';
import 'package:hayati/data/store/local_store.dart';
import 'package:hayati/domain/sleep.dart';
import 'package:hayati/services/health_reader.dart';

import 'helpers.dart';

DateTime at(int day, int h, [int m = 0]) => DateTime(2026, 3, day, h, m);

DeviceWorkout run(String id, DateTime start, {int minutes = 30, int? kcal = 300}) => DeviceWorkout(
      id: id,
      source: ActivitySource.healthConnect,
      activity: 'RUNNING',
      start: start,
      end: start.add(Duration(minutes: minutes)),
      kcal: kcal,
      distanceM: 5000,
      updatedAt: fixedNow,
    );

void main() {
  group('sleep segments', () {
    test('overlapping and close segments join; short and empty ones go', () {
      final s = mergeSleepSegments([
        (at(9, 23), at(10, 1)), // core
        (at(10, 0, 30), at(10, 3)), // deep, overlaps (watch and phone)
        (at(10, 3, 40), at(10, 6, 30)), // after a 40 min wake: same night
        (at(10, 12), at(10, 12, 10)), // 10 min doze on its own: dropped
        (at(10, 15), at(10, 15, 45)), // nap
        (at(10, 16), at(10, 16)), // empty
      ]);
      expect(s, [(at(9, 23), at(10, 6, 30)), (at(10, 15), at(10, 15, 45))]);
      expect(mergeSleepSegments(const []), isEmpty);
    });

    test('a night counts for the day you wake; one source, never added up', () {
      SleepSession ss(String id, ActivitySource src, DateTime a, DateTime b) =>
          SleepSession(id: id, source: src, start: a, end: b, updatedAt: fixedNow);
      final d = AppData(sleep: [
        ss('a', ActivitySource.healthConnect, at(9, 23), at(10, 7)),
        ss('b', ActivitySource.healthConnect, at(10, 14), at(10, 15)),
        ss('c', ActivitySource.manual, at(9, 22), at(10, 6)),
      ]);
      final day = sleepDay(d, '2026-03-10');
      expect((day.source, day.minutes, day.main!.id, day.sessions.length), (ActivitySource.healthConnect, 540, 'a', 2));
      final manual = sleepDay(d.copyWith(settings: const UserSettings(health: HealthSettings(sleepSource: ActivitySource.manual))), '2026-03-10');
      expect((manual.source, manual.minutes), (ActivitySource.manual, 480));
      expect(sleepDay(d, '2026-03-09').hasData, isFalse);
      expect(averageSleepMinutes(sleepSeries(d, fixedNow, 7)), 540, reason: 'empty days are left out');
    });
  });

  group('importing', () {
    test('sleep: same night keeps its id, deleted in the store goes, older nights stay', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      const src = ActivitySource.healthKit;
      data.importSleep(src, [(at(2, 23), at(3, 7))], from: DateTime(2026, 3, 3));
      data.importSleep(src, [(at(8, 23), at(9, 6)), (at(9, 6, 20), at(9, 7)), (at(9, 23), at(10, 6))], from: DateTime(2026, 3, 4));
      var sleep = c.read(dataProvider).sleep;
      expect(sleep, hasLength(3), reason: 'the 3 March night is before the window and kept');
      final id = sleep.firstWhere((s) => s.end == at(9, 7)).id;
      final before = c.read(dataProvider);
      data.importSleep(src, [(at(8, 23), at(9, 6)), (at(9, 6, 20), at(9, 7)), (at(9, 23), at(10, 6))], from: DateTime(2026, 3, 4));
      expect(identical(before, c.read(dataProvider)), isTrue, reason: 'nothing changed, nothing to sync');
      // The 10 March night was removed in the store; a future one is ignored.
      data.importSleep(src, [(at(8, 23), at(9, 7)), (at(10, 23), at(11, 7))], from: DateTime(2026, 3, 4));
      sleep = c.read(dataProvider).sleep;
      expect(sleep.map((s) => s.end).toList()..sort(), [at(3, 7), at(9, 7)]);
      expect(sleep.firstWhere((s) => s.end == at(9, 7)).id, id);
    });

    test('resting heart rate: one per day, averaged, nonsense dropped', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      data.importRestingHeart(ActivitySource.healthConnect, [
        (at(9, 6), 60),
        (at(9, 7), 63),
        (at(10, 6), 57),
        (at(10, 7), 400), // a glitch
        (at(11, 6), 55), // tomorrow
      ]);
      final d = c.read(dataProvider);
      expect(d.bodyMetrics.map((m) => (dayKey(m.measuredAt), m.value)).toList()..sort((a, b) => a.$1.compareTo(b.$1)),
          [('2026-03-09', 62.0), ('2026-03-10', 57.0)]);
      expect(d.bodyMetrics.every((m) => m.kind == MetricKind.restingHr && m.valid), isTrue);
      final (latest, avg) = restingHeartSummary(d, fixedNow);
      expect((latest!.value, avg), (57.0, 60));
      data.importRestingHeart(ActivitySource.healthConnect, [(at(10, 6), 57)]);
      expect(c.read(dataProvider).bodyMetrics, hasLength(2));
    });

    test('workouts: stable ids, nonsense cleaned, removed ones go', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      final from = DateTime(2026, 3, 4);
      data.importWorkouts(ActivitySource.healthConnect, [
        run('w1', at(8, 18)),
        run('w2', at(9, 18), kcal: -3),
        run('w3', at(9, 1), minutes: 60 * 30), // over a day
        run('w4', at(11, 18)), // future
      ], from: from);
      var list = recentDeviceWorkouts(c.read(dataProvider));
      expect(list.map((w) => w.start), [at(9, 18), at(8, 18)]);
      expect(list.first.kcal, isNull);
      final id = list.last.id;
      data.importWorkouts(ActivitySource.healthConnect, [run('w1', at(8, 18))], from: from);
      list = c.read(dataProvider).deviceWorkouts;
      expect(list.single.id, id);
    });

    test('removing a source deletes only what came from it', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      data.recordActivity('2026-03-10', ActivitySource.healthConnect, steps: 5000);
      data.recordActivity('2026-03-10', ActivitySource.manual, steps: 3000);
      data.importSleep(ActivitySource.healthConnect, [(at(9, 23), at(10, 6))], from: DateTime(2026, 3, 4));
      data.importRestingHeart(ActivitySource.healthConnect, [(at(10, 6), 58)]);
      data.importWorkouts(ActivitySource.healthConnect, [run('w', at(9, 18))], from: DateTime(2026, 3, 4));
      expect(sourceSummaries(c.read(dataProvider)).map((s) => (s.source, s.total)),
          [(ActivitySource.healthConnect, 4), (ActivitySource.manual, 1)]);
      expect(sourcesWith(c.read(dataProvider), HealthKind.sleep), {ActivitySource.healthConnect});
      data.deleteSourceData(ActivitySource.healthConnect);
      final d = c.read(dataProvider);
      expect(d.activity.single.source, ActivitySource.manual);
      expect(d.sleep.length + d.bodyMetrics.length + d.deviceWorkouts.length, 0);
    });
  });

  group('sync', () {
    test('asks only for what is turned on and reads each kind', () async {
      final reader = FakeHealthReader(
        days: const [StepDay('2026-03-10', 4200)],
        sleep: [(at(9, 23), at(10, 6))],
        heart: [(at(10, 6), 59)],
        workouts: [run('w', at(9, 18))],
      );
      final c = await signedInContainer(overrides: [healthReaderProvider.overrideWithValue(reader)]);
      final sync = c.read(healthSyncProvider.notifier);
      expect(await sync.connect(const {HealthKind.sleep}), isTrue);
      expect(reader.asked.single, {HealthKind.sleep});
      var d = c.read(dataProvider);
      expect((d.sleep.length, d.activity.length, d.bodyMetrics.length), (1, 0, 0), reason: 'only sleep was allowed');
      await sync.connect(const {HealthKind.steps, HealthKind.heartRate, HealthKind.workouts});
      d = c.read(dataProvider);
      expect((d.activity.single.steps, d.bodyMetrics.single.value, d.deviceWorkouts.length), (4200, 59.0, 1));
      reader.body = [BodyReading(at(10, 7), MetricKind.weight, 81.36), BodyReading(at(10, 7), MetricKind.bp, 121, 79), BodyReading(at(10, 8), MetricKind.bp, 400, 79)];
      await sync.connect(const {HealthKind.body});
      expect(c.read(healthSyncProvider).kinds, HealthKind.values.toSet());
      d = c.read(dataProvider);
      expect(d.bodyMetrics.where((m) => m.kind == MetricKind.weight).single.value, 81.4);
      expect(d.bodyMetrics.where((m) => m.kind == MetricKind.bp).single.value2, 79, reason: 'the out-of-range reading is dropped');
      await sync.sync(force: true);
      expect(c.read(dataProvider).bodyMetrics, hasLength(3), reason: 're-reading adds nothing');

      // One kind failing doesn't stop the others.
      reader
        ..failSleep = StateError('denied')
        ..days = const [StepDay('2026-03-10', 5100)];
      await sync.sync(force: true);
      expect((c.read(healthSyncProvider).failed, c.read(dataProvider).activity.single.steps), (true, 5100));

      // Turned off on this device: no longer read, what came in stays.
      await sync.stop(HealthKind.steps);
      reader.days = const [StepDay('2026-03-10', 9999)];
      await sync.sync(force: true);
      expect(c.read(dataProvider).activity.single.steps, 5100);
      // Sleep needs the sleep section.
      c.read(dataProvider.notifier).updateHealth((h) => h.copyWith(modules: {HealthModule.activity}));
      reader
        ..failSleep = null
        ..sleep = [(at(8, 23), at(9, 6)), (at(9, 23), at(10, 6))];
      await sync.sync(force: true);
      expect(c.read(dataProvider).sleep, hasLength(1));
    });

    test('what a device reads is kept per device, and older step links carry over', () async {
      final reader = FakeHealthReader();
      final c = await signedInContainer(overrides: [healthReaderProvider.overrideWithValue(reader)]);
      final uid = c.read(authProvider).user!.id;
      final store = c.read(localStoreProvider);
      await store.writeString('hayati.health.linked.$uid', '1');
      c.invalidate(healthSyncProvider);
      expect(c.read(healthSyncProvider).kinds, {HealthKind.steps});
      await c.read(healthSyncProvider.notifier).connect(const {HealthKind.workouts});
      expect(store.readString('hayati.health.kinds.$uid'), 'steps,workouts');
      reader.grant = false;
      expect(await c.read(healthSyncProvider.notifier).connect(const {HealthKind.sleep}), isFalse);
      expect(c.read(healthSyncProvider).reads(HealthKind.sleep), isFalse);
      await c.read(healthSyncProvider.notifier).disconnect();
      expect(c.read(healthSyncProvider).linked, isFalse);
    });
  });

  test('rows, JSON and settings round-trip', () {
    final s = SleepSession(id: 's', source: ActivitySource.healthKit, start: at(9, 23), end: at(10, 6), quality: 4, updatedAt: fixedNow);
    final sb = sleepFrom({...sleepRow(s)});
    expect((sb.start, sb.end, sb.quality, sb.source), (s.start, s.end, 4, ActivitySource.healthKit));
    final m = BodyMetric(id: 'm', kind: MetricKind.bp, value: 120, value2: 80, source: ActivitySource.manual, measuredAt: fixedNow, note: 'x');
    final mb = bodyMetricFrom({...bodyMetricRow(m)});
    expect((bodyMetricRow(m)['kind'], mb.kind, mb.value2, mb.note), ('bp', MetricKind.bp, 80.0, 'x'));
    expect(bodyMetricFrom({...bodyMetricRow(BodyMetric(id: 'r', kind: MetricKind.restingHr, value: 58, source: ActivitySource.healthConnect, measuredAt: fixedNow))}).kind,
        MetricKind.restingHr);
    expect((m.valid, BodyMetric(id: 'x', kind: MetricKind.bp, value: 120, source: ActivitySource.manual, measuredAt: fixedNow).valid), (true, false));
    final w = run('w', at(9, 18));
    final wb = deviceWorkoutFrom({...deviceWorkoutRow(w)});
    expect((wb.activity, wb.minutes, wb.kcal, wb.distanceM), ('RUNNING', 30, 300, 5000));
    final d = AppData.fromJson(AppData(sleep: [s], bodyMetrics: [m], deviceWorkouts: [w]).toJson());
    expect((d.sleep.single.quality, d.bodyMetrics.single.value2, d.deviceWorkouts.single.activity), (4, 80.0, 'RUNNING'));
    const h = HealthSettings(sleepSource: ActivitySource.manual, heartSource: ActivitySource.healthKit);
    final hb = HealthSettings.fromJson(h.toJson());
    expect((hb.preferredFor(HealthKind.sleep), hb.preferredFor(HealthKind.heartRate), hb.preferredFor(HealthKind.workouts)),
        (ActivitySource.manual, ActivitySource.healthKit, null));
  });
}
