import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/fitness.dart';
import 'package:hayati/data/models/health.dart';
import 'package:hayati/data/models/settings.dart';
import 'package:hayati/data/remote/rows.dart';
import 'package:hayati/domain/fitness/exercises.dart';
import 'package:hayati/domain/fitness/programs.dart';
import 'package:hayati/domain/fitness/progress.dart';

import 'helpers.dart';

WorkoutSession session(String id, String day, List<SetLog> sets, {String? programId, int minute = 0}) => WorkoutSession(
      id: id,
      day: day,
      place: WorkoutPlace.home,
      focus: DayFocus.fullBody,
      status: SessionStatus.completed,
      sets: sets,
      programId: programId,
      createdAt: fixedNow.add(Duration(minutes: minute)),
    );

void main() {
  group('programs', () {
    test('ids unique, every exercise exists, names and timings sane', () {
      expect(programs.map((p) => p.id).toSet().length, programs.length);
      for (final p in programs) {
        expect(RegExp(r'^[a-z0-9_]{1,40}$').hasMatch(p.id), isTrue, reason: p.id);
        expect(p.items, isNotEmpty, reason: p.id);
        for (final x in p.items) {
          expect(exerciseById(x.exerciseId), isNotNull, reason: '${p.id}/${x.exerciseId}');
        }
        expect(p.name('ar').isNotEmpty && p.name('en').isNotEmpty && p.about('ar').isNotEmpty, isTrue, reason: p.id);
        expect(p.minutes, inInclusiveRange(3, 45), reason: p.id);
        final day = p.asDay(3);
        expect((day.weekday, day.exercises.length), (3, p.items.length), reason: p.id);
      }
    });

    test('women see their programs, men see theirs, never the other', () {
      const base = UserSettings();
      ids(UserSettings s) => programsFor(s).map((p) => p.id).toSet();
      final female = base.copyWith(sex: Sex.female, health: const HealthSettings(modules: {HealthModule.womens}));
      final male = base.copyWith(sex: Sex.male, health: const HealthSettings(modules: {HealthModule.mens}));
      final shared = {for (final p in programs) if (p.audience == Audience.all) p.id};
      final women = {for (final p in programs) if (p.audience == Audience.female) p.id};
      final men = {for (final p in programs) if (p.audience == Audience.male) p.id};
      expect(women, containsAll(['pelvic_floor_women', 'pregnancy_t1', 'postpartum_early']));
      expect(men, containsAll(['pelvic_floor_men', 'back_posture_men']));
      expect(ids(female), {...shared, ...women});
      expect(ids(male), {...shared, ...men});
      expect(ids(base), shared, reason: 'sex not set');
      // A section switched off hides its programs, and a mismatched module never opens them.
      expect(ids(female.copyWith(health: const HealthSettings(modules: {}))), shared);
      expect(ids(male.copyWith(health: const HealthSettings(modules: {HealthModule.womens}))), shared);
      expect(programVisible(programById('pregnancy_t2')!, male), isFalse);
      expect(programVisible(programById('back_posture_men')!, female), isFalse);
      expect(programById('nope'), isNull);
      expect(programById(null), isNull);
    });

    test('pregnancy and after-birth programs wait for the doctor\'s go-ahead', () async {
      final c = await signedInContainer(sex: Sex.female);
      final data = c.read(dataProvider.notifier);
      data.setSex(Sex.female);
      final preg = programById('pregnancy_t1')!;
      final post = programById('postpartum_early')!;
      expect(clearedFor(programById('pelvic_floor_women')!, c.read(settingsProvider).health), isTrue);
      expect(clearedFor(preg, c.read(settingsProvider).health), isFalse);
      data.updateHealth((h) => h.copyWith(pregnancyCleared: true));
      final h = c.read(settingsProvider).health;
      expect((clearedFor(preg, h), clearedFor(post, h)), (true, false));
      final back = HealthSettings.fromJson(h.toJson());
      expect((back.pregnancyCleared, back.postpartumCleared), (true, false));
    });
  });

  group('progress log', () {
    test('best set per session, by weight, reps or time; newest first', () {
      final d = AppData(workoutSessions: [
        session('a', '2026-03-01', const [
          SetLog(exerciseId: 'goblet_squat', setIndex: 0, reps: 10, weightKg: 12),
          SetLog(exerciseId: 'goblet_squat', setIndex: 1, reps: 12, weightKg: 12),
          SetLog(exerciseId: 'push_up', setIndex: 0, reps: 8),
        ]),
        session('b', '2026-03-05', const [
          SetLog(exerciseId: 'goblet_squat', setIndex: 0, reps: 8, weightKg: 16),
          SetLog(exerciseId: 'plank', setIndex: 0, seconds: 40),
          SetLog(exerciseId: 'push_up', setIndex: 0, reps: 6),
        ], minute: 1),
        session('c', '2026-03-08', const [SetLog(exerciseId: 'plank', setIndex: 0, seconds: 0), SetLog(exerciseId: 'push_up', setIndex: 0, reps: 9)], programId: 'flexibility', minute: 2),
      ]);
      final list = exerciseProgress(d);
      expect(list.first.exerciseId, 'push_up', reason: 'done most recently');
      expect(list, hasLength(3));
      final squat = list.firstWhere((p) => p.exerciseId == 'goblet_squat');
      expect(squat.kind, ProgressKind.weight);
      expect([for (final x in squat.points) (x.value, x.reps)], [(12.0, 12), (16.0, 8)]);
      expect((squat.best.value, squat.change), (16.0, 4.0));
      final push = list.firstWhere((p) => p.exerciseId == 'push_up');
      expect((push.kind, push.best.value, push.change), (ProgressKind.reps, 9.0, 1.0));
      final plank = list.firstWhere((p) => p.exerciseId == 'plank');
      expect((plank.kind, plank.points.length, plank.change), (ProgressKind.seconds, 1, 0.0), reason: 'empty sets are skipped');
      expect(exerciseProgress(const AppData()), isEmpty);
    });
  });

  test('program id round-trips through rows and JSON', () {
    final s = session('s', '2026-03-10', const [], programId: 'balance');
    expect(workoutSessionFrom({...workoutSessionRow(s)}).programId, 'balance');
    expect(WorkoutSession.fromJson(s.toJson()).programId, 'balance');
    expect(workoutSessionFrom({...workoutSessionRow(session('t', '2026-03-10', const []))}).programId, isNull);
  });
}
