import 'dart:io';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/core/utils/dates.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/fitness.dart';
import 'package:hayati/data/models/health.dart';
import 'package:hayati/data/models/settings.dart';
import 'package:hayati/data/remote/rows.dart';
import 'package:hayati/domain/assistant/engine.dart';
import 'package:hayati/domain/day_timeline.dart';
import 'package:hayati/domain/fitness/exercise_info.dart';
import 'package:hayati/domain/fitness/exercises.dart';
import 'package:hayati/domain/fitness/plan_generator.dart';
import 'package:hayati/l10n/app_localizations.dart';

import 'helpers.dart';

FitnessProfile profile({
  FitnessGoal goal = FitnessGoal.general,
  FitnessLevel level = FitnessLevel.beginner,
  int days = 3,
  int minutes = 45,
  Set<WorkoutPlace> places = const {WorkoutPlace.home},
  Set<Equipment> equipment = const {},
}) =>
    FitnessProfile(
      goal: goal,
      level: level,
      daysPerWeek: days,
      minutesPerSession: minutes,
      weekdays: PlanGenerator.defaultWeekdays(days, 7),
      places: places,
      homeEquipment: equipment,
    );

void main() {
  const g = PlanGenerator();

  group('exercise library', () {
    test('photos: every listed one is bundled, and every bundled one is listed', () {
      final listed = {for (final e in exercises) ...exercisePhotos(e)};
      expect(listed.length, greaterThanOrEqualTo(80));
      for (final p in listed) {
        expect(File(p).existsSync(), isTrue, reason: p);
      }
      final bundled = {for (final f in Directory('assets/exercises').listSync()) if (f.path.endsWith('.jpg')) 'assets/exercises/${f.uri.pathSegments.last}'};
      expect(bundled, listed);
      // A near match is worse than none: these have no photo of their movement.
      expect(exercisePhotos(exerciseById('bird_dog')!), isEmpty);
      expect(exercisePhotos(exerciseById('quad_stretch')!), isEmpty);
    });

    test('every exercise has target muscles, goals and cautions', () {
      for (final e in exercises) {
        final (main, helpers) = targetsOf(e);
        expect(main, isNotEmpty, reason: e.id);
        expect(main.toSet().intersection(helpers.toSet()), isEmpty, reason: e.id);
        expect(goalsOf(e), contains(FitnessGoal.general), reason: e.id);
        expect(cautionsOf(e).last, Caution.stopIfPain, reason: e.id);
      }
      expect(cautionsOf(exerciseById('barbell_squat')!), containsAll([Caution.knees, Caution.back, Caution.heavyLoad]));
      expect(cautionsOf(exerciseById('treadmill')!), contains(Caution.heart));
      expect(cautionsOf(exerciseById('pelvic_floor_hold')!, sex: Sex.female), contains(Caution.pregnancy));
      expect(cautionsOf(exerciseById('plank')!, sex: Sex.male), isNot(contains(Caution.pregnancy)));
      expect(goalsOf(exerciseById('brisk_walk')!), contains(FitnessGoal.fatLoss));
      expect(goalsOf(exerciseById('cat_cow')!), isNot(contains(FitnessGoal.strength)));
    });

    test('suggested dosage for each level grows with the level', () {
      final d = dosageOf(exerciseById('goblet_squat')!, FitnessGoal.strength);
      expect(d.keys, FitnessLevel.values);
      expect(d[FitnessLevel.beginner]!.sets, lessThan(d[FitnessLevel.advanced]!.sets));
      expect(dosageOf(exerciseById('plank')!, FitnessGoal.general)[FitnessLevel.beginner]!.seconds, isNotNull);
    });

    test('filters by muscle, level, goal, place and name', () {
      expect(filterExercises().length, exercises.length);
      expect(filterExercises(muscle: Muscle.chest).every((e) => e.muscle == Muscle.chest), isTrue);
      expect(filterExercises(level: 3).every((e) => e.difficulty == 3), isTrue);
      expect(filterExercises(goal: FitnessGoal.mobility).map((e) => e.id), containsAll(['cat_cow', 'single_leg_stand']));
      final home = filterExercises(place: WorkoutPlace.home);
      expect(home.any((e) => e.gymOnly.isNotEmpty || e.equipment.isNotEmpty), isFalse);
      expect(filterExercises(place: WorkoutPlace.home, home: {Equipment.dumbbells}).map((e) => e.id), contains('db_row'));
      expect(filterExercises(query: 'سكوات').map((e) => e.id), containsAll(['bw_squat', 'goblet_squat']));
      expect(filterExercises(query: 'PUSH').map((e) => e.id), contains('pushup'));
      expect(filterExercises(muscle: Muscle.chest, level: 3), isEmpty);
      final all = filterExercises();
      for (var i = 1; i < all.length; i++) {
        expect(all[i - 1].muscle.index, lessThanOrEqualTo(all[i].muscle.index));
      }
    });

    test('ids are unique and alternatives exist', () {
      final ids = exercises.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final e in exercises) {
        expect(e.stepsAr, hasLength(e.stepsEn.length), reason: e.id);
        for (final a in e.alternatives) {
          expect(exerciseById(a), isNotNull, reason: '${e.id} → $a');
        }
      }
    });
  });

  group('plan generator', () {
    test('every combination gives safe, balanced, available days', () {
      for (final goal in FitnessGoal.values) {
        for (final level in FitnessLevel.values) {
          for (var days = 2; days <= 6; days++) {
            for (final (place, eq) in [
              (WorkoutPlace.home, <Equipment>{}),
              (WorkoutPlace.home, Equipment.values.toSet()),
              (WorkoutPlace.gym, <Equipment>{}),
            ]) {
              final p = profile(goal: goal, level: level, days: days, equipment: eq);
              final plan = g.build(p, place);
              final why = '$goal $level $days $place ${eq.length}';
              expect(plan, hasLength(days), reason: why);
              for (final d in plan) {
                expect(d.exercises.length, greaterThanOrEqualTo(2), reason: why);
                final ids = d.exercises.map((x) => x.exerciseId).toList();
                expect(ids.toSet().length, ids.length, reason: '$why: no repeats in a day');
                for (final x in d.exercises) {
                  final e = exerciseById(x.exerciseId)!;
                  expect(e.availableAt(place, eq), isTrue, reason: '$why: ${e.id} available');
                  expect(e.difficulty, lessThanOrEqualTo(PlanGenerator.levelMax(level)), reason: '$why: ${e.id} level');
                  expect(x.sets, inInclusiveRange(1, 5));
                }
                // Core work in every session — no separate "abs day".
                expect(d.exercises.any((x) => exerciseById(x.exerciseId)!.pattern == Pattern.core), isTrue, reason: why);
              }
            }
          }
        }
      }
    });

    test('split follows the number of days', () {
      expect(PlanGenerator.focusesFor(FitnessGoal.muscle, 3), everyElement(DayFocus.fullBody));
      expect(PlanGenerator.focusesFor(FitnessGoal.muscle, 4), [DayFocus.upper, DayFocus.lower, DayFocus.upper, DayFocus.lower]);
      expect(PlanGenerator.focusesFor(FitnessGoal.fatLoss, 5), contains(DayFocus.conditioning));
      expect(PlanGenerator.focusesFor(FitnessGoal.mobility, 2).first, DayFocus.mobility);
    });

    test('sessions fit the time the user has', () {
      final p = profile(goal: FitnessGoal.muscle, level: FitnessLevel.advanced, days: 4, minutes: 30);
      for (final d in g.build(p, WorkoutPlace.gym)) {
        expect(d.minutes, lessThanOrEqualTo(45), reason: 'trimmed toward 30 min');
        expect(d.exercises.length, lessThan(7));
      }
    });

    test('default days leave rest between full-body sessions', () {
      expect(PlanGenerator.defaultWeekdays(3, 7), [7, 2, 4]); // Sun, Tue, Thu
      final ok = g.build(profile(days: 3), WorkoutPlace.home);
      expect(PlanGenerator.needsMoreRecovery(ok), isFalse);
      final tight = g.build(
        FitnessProfile(
          goal: FitnessGoal.general,
          level: FitnessLevel.beginner,
          daysPerWeek: 2,
          minutesPerSession: 45,
          weekdays: const [7, 1],
          places: const {WorkoutPlace.home},
        ),
        WorkoutPlace.home,
      );
      expect(PlanGenerator.needsMoreRecovery(tight), isTrue);
    });
  });

  group('gym day at home', () {
    test('uses alternatives, and says when there is none', () {
      final p = profile(places: {WorkoutPlace.gym, WorkoutPlace.home});
      const day = WorkoutDay(weekday: 1, focus: DayFocus.fullBody, minutes: 45, exercises: [
        PlannedExercise(exerciseId: 'barbell_squat', sets: 3, reps: 8, restSeconds: 90),
        PlannedExercise(exerciseId: 'lat_pulldown', sets: 3, reps: 10, restSeconds: 60),
        PlannedExercise(exerciseId: 'plank', sets: 3, seconds: 30, restSeconds: 45),
      ]);
      final swaps = homeVersion(day, p);
      expect(swaps[0].kind, SwapKind.alternative);
      expect(swaps[0].replacement!.exerciseId, 'bw_squat');
      expect(swaps[1].kind, SwapKind.none, reason: 'no vertical pull at home without equipment');
      expect(swaps[2].kind, SwapKind.same);
      // With bands, the pulldown has a real alternative.
      final withBands = homeVersion(day, profile(places: {WorkoutPlace.gym, WorkoutPlace.home}, equipment: {Equipment.bands}));
      expect(withBands[1].replacement!.exerciseId, 'band_pulldown');
    });
  });

  group('data', () {
    test('saving creates versions; sessions keep the plan they followed', () async {
      final c = await signedInContainer();
      addTearDown(c.dispose);
      final data = c.read(dataProvider.notifier);
      final p = profile(places: {WorkoutPlace.home, WorkoutPlace.gym});
      data.saveFitness(p, {WorkoutPlace.home: g.build(p, WorkoutPlace.home), WorkoutPlace.gym: g.build(p, WorkoutPlace.gym)});
      final v1 = c.read(dataProvider).activePlan(WorkoutPlace.home)!;
      data.logWorkout(WorkoutSession(
        id: 's1',
        planId: v1.id,
        day: dayKey(fixedNow),
        place: WorkoutPlace.home,
        focus: DayFocus.fullBody,
        status: SessionStatus.partial,
        sets: const [SetLog(exerciseId: 'bw_squat', setIndex: 0, reps: 10)],
        createdAt: fixedNow,
      ));
      data.saveFitness(p, {WorkoutPlace.home: g.build(p, WorkoutPlace.home)});
      final d = c.read(dataProvider);
      final home = d.workoutPlans.where((x) => x.place == WorkoutPlace.home).toList();
      expect(home.map((x) => x.version), [1, 2]);
      expect(home.where((x) => x.active).single.version, 2);
      expect(d.activePlan(WorkoutPlace.gym)!.version, 1, reason: 'gym plan untouched');
      expect(d.plan(d.workoutSessions.single.planId)!.version, 1);
      expect(
        () => data.logWorkout(WorkoutSession(
          id: 's2',
          day: dayKey(fixedNow.add(const Duration(days: 1))),
          place: WorkoutPlace.home,
          focus: DayFocus.fullBody,
          status: SessionStatus.completed,
          createdAt: fixedNow,
        )),
        throwsArgumentError,
      );
    });

    test('rows and JSON round-trip', () {
      final p = profile(goal: FitnessGoal.strength, equipment: {Equipment.dumbbells});
      final plan = WorkoutPlan(
        id: 'p1',
        place: WorkoutPlace.home,
        version: 3,
        active: true,
        goal: FitnessGoal.strength,
        days: g.build(p, WorkoutPlace.home),
        createdAt: fixedNow,
      );
      final back = workoutPlanFrom({...workoutPlanRow(plan), 'created_at': fixedNow.toUtc().toIso8601String()});
      expect(back.days.first.exercises.first.exerciseId, plan.days.first.exercises.first.exerciseId);
      expect(WorkoutPlan.fromJson(plan.toJson()).version, 3);
      final s = WorkoutSession(
        id: 's',
        planId: 'p1',
        day: '2026-03-10',
        place: WorkoutPlace.home,
        focus: DayFocus.upper,
        status: SessionStatus.completed,
        difficulty: 4,
        sets: const [SetLog(exerciseId: 'db_row', setIndex: 1, reps: 10, weightKg: 12.5)],
        substituted: true,
        createdAt: fixedNow,
      );
      final sb = workoutSessionFrom({...workoutSessionRow(s), 'created_at': fixedNow.toUtc().toIso8601String()});
      expect(sb.sets.single.weightKg, 12.5);
      expect(sb.substituted, isTrue);
      final settings = UserSettings(fitness: p);
      expect(settingsFrom(profileRow(settings)).fitness!.homeEquipment, {Equipment.dumbbells});
      expect(UserSettings.fromJson(settings.toJson()).fitness!.goal, FitnessGoal.strength);
      expect(settingsFrom(profileRow(const UserSettings())).fitness, isNull);
    });
  });

  group('day and assistant', () {
    final now = DateTime(2026, 3, 10, 8); // Tuesday
    AppData withPlan(WorkoutPlace place, {List<WorkoutSession> sessions = const []}) {
      final p = FitnessProfile(
        goal: FitnessGoal.general,
        level: FitnessLevel.beginner,
        daysPerWeek: 2,
        minutesPerSession: 30,
        weekdays: const [2, 5],
        places: {place, WorkoutPlace.home},
        preferredPlace: place,
      );
      return AppData(
        settings: UserSettings(fitness: p),
        workoutPlans: [
          WorkoutPlan(id: 'p', place: place, version: 1, active: true, goal: p.goal, days: g.build(p, place), createdAt: now),
        ],
        workoutSessions: sessions,
      );
    }

    test("today's workout is a flexible item in the timeline until it's logged", () {
      final d = withPlan(WorkoutPlace.home);
      final tl = buildTimeline(d, now);
      final w = tl.items.where((i) => i.kind == TimelineKind.workout).single;
      expect(w.suggested, isTrue);
      expect(w.start.isBefore(now), isFalse);
      final done = withPlan(WorkoutPlace.home, sessions: [
        WorkoutSession(
          id: 's',
          day: dayKey(now),
          place: WorkoutPlace.home,
          focus: DayFocus.fullBody,
          status: SessionStatus.completed,
          createdAt: now,
        ),
      ]);
      expect(buildTimeline(done, now).items.where((i) => i.kind == TimelineKind.workout), isEmpty);
    });

    test('"I can\'t go to the gym" lists the home version, no changes made', () {
      final l = lookupAppLocalizations(const Locale('ar'));
      final ctx = AssistantContext(withPlan(WorkoutPlace.gym), const AssistantPermissions());
      final r = LocalAssistantEngine(l).respond('ما اقدر اروح النادي اليوم', ctx, now);
      expect(r.calls, isEmpty);
      expect(r.text, startsWith(l.aiGymAtHome));
      final off = AssistantContext(withPlan(WorkoutPlace.gym), const AssistantPermissions(shareFitness: false));
      expect(LocalAssistantEngine(l).respond('ما اقدر اروح النادي اليوم', off, now).text, l.aiNeedsSharing(l.navFitness));
    });
  });
}
