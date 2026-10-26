// End-to-end tests of the Supabase connection against a running Supabase
// (e.g. `supabase start` in the repo root). Skipped unless configured:
//
//   SUPABASE_TEST_URL=http://127.0.0.1:54321 SUPABASE_TEST_ANON_KEY=... \
//     flutter test test/supabase_integration_test.dart
//
// The cloud assistant test also needs the Edge Function served against a
// fake Messages API (see supabase/README.md) and ASSISTANT_TEST=1.
import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/core/config.dart';
import 'package:hayati/core/utils/dates.dart';
import 'package:hayati/data/auth.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/accountability.dart';
import 'package:hayati/data/models/assistant.dart';
import 'package:hayati/data/models/fitness.dart';
import 'package:hayati/data/models/goal.dart';
import 'package:hayati/data/models/learning.dart';
import 'package:hayati/data/models/misc.dart';
import 'package:hayati/data/models/prayer.dart';
import 'package:hayati/data/models/task.dart';
import 'package:hayati/data/remote/sync.dart';
import 'package:hayati/data/store/local_store.dart';
import 'package:hayati/domain/assistant/assistant_service.dart';
import 'package:hayati/domain/fitness/plan_generator.dart';
import 'package:hayati/domain/assistant/executor.dart';
import 'package:hayati/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthClientOptions, AuthFlowType, SupabaseClient;

final url = Platform.environment['SUPABASE_TEST_URL'];
final key = Platform.environment['SUPABASE_TEST_ANON_KEY'];

/// One simulated device: its own client (session) and its own storage.
class Device {
  Device._(this.client, this.c);
  final SupabaseClient client;
  final ProviderContainer c;

  static Device create({String? baseUrl}) {
    final client = SupabaseClient(baseUrl ?? url!, key!, authOptions: const AuthClientOptions(
      autoRefreshToken: false,
      // The app's Supabase.initialize supplies PKCE storage; a bare client needs this.
      authFlowType: AuthFlowType.implicit,
    ));
    final c = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(LocalStore.memory()),
      supabaseClientProvider.overrideWithValue(client),
    ]);
    return Device._(client, c);
  }

  AuthController get auth => c.read(authProvider.notifier);
  DataController get data => c.read(dataProvider.notifier);
  SyncState get sync => c.read(syncProvider);

  Future<void> open() async {
    await auth.restore();
    c.read(dataProvider);
  }

  /// Waits until nothing is pending and no sync is running.
  Future<void> settle() async {
    final end = DateTime.now().add(const Duration(seconds: 15));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    while (DateTime.now().isBefore(end)) {
      final s = sync;
      if (s.pending == 0 && s.phase != SyncPhase.syncing && s.ready) return;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    fail('sync did not settle: ${sync.phase} pending=${sync.pending}');
  }

  void dispose() {
    c.dispose();
    client.dispose();
  }
}

String email() => 'it${Random().nextInt(1 << 30)}@example.com';

void main() {
  final skip = url == null || key == null ? 'set SUPABASE_TEST_URL and SUPABASE_TEST_ANON_KEY' : null;

  test('sign up, sync to the server, and load on a second device', () async {
    final a = Device.create();
    addTearDown(a.dispose);
    await a.open();
    final address = email();
    await a.auth.signUp(address, 'password1');
    a.c.read(dataProvider);
    await a.settle();
    expect(a.data.snapshot.settings.onboardingDone, isFalse, reason: 'profile row created by the signup trigger');

    final now = DateTime.now();
    a.data.updateSettings((s) => s.copyWith(onboardingDone: true, displayName: 'سارة', currency: 'AED'));
    final goal = Goal(id: newId(), title: 'تعلم الإنجليزية', createdAt: now, updatedAt: now);
    final ms = Milestone(id: newId(), goalId: goal.id, title: 'الأساسيات', order: 0);
    a.data.saveGoal(goal, [ms]);
    final t = a.data.newTask(title: 'مراجعة', dueDate: '2026-11-02', dueTime: 20 * 60, estimatedMinutes: 30, goalId: goal.id, milestoneId: ms.id);
    a.data.saveTask(t);
    a.data.saveEvent(CalendarEvent(id: newId(), title: 'محاضرة', start: now, end: now.add(const Duration(hours: 2)), reminderMinutesBefore: 30, updatedAt: now));
    a.data.saveHabit(Habit(id: newId(), name: 'مشي', weekdays: const {1, 2, 3}, startDate: '2026-01-01', reminderMinutes: 7 * 60));
    a.data.addExpense(Expense(id: newId(), amountMinor: 2550, currency: 'SAR', category: 'food', spentAt: now));
    a.data.setTaskStatus(t.id, TaskStatus.done);
    await a.settle();
    expect(a.sync.rejected, 0);

    // Server state, read directly through the API (RLS-scoped to the user).
    final rows = await a.client.from('tasks').select();
    expect(rows.single['title'], 'مراجعة');
    expect(rows.single['due_time'], '20:00:00');
    expect(rows.single['status'], 'done');
    final m = await a.client.from('goal_milestones').select().eq('id', ms.id).single();
    expect(m['done'], isTrue, reason: 'server trigger completes the milestone too');

    // A fresh device signing in gets everything, including settings.
    final b = Device.create();
    addTearDown(b.dispose);
    await b.open();
    await b.auth.signIn(address, 'password1');
    b.c.read(dataProvider);
    await b.settle();
    final d = b.data.snapshot;
    expect(d.settings.onboardingDone, isTrue);
    expect(d.settings.displayName, 'سارة');
    expect(d.settings.currency, 'AED');
    expect(d.tasks.single.dueTime, 20 * 60);
    expect(d.tasks.single.isDone, isTrue);
    expect(d.events.single.reminderMinutesBefore, 30);
    expect(d.habits.single.reminderMinutes, 7 * 60);
    expect(d.expenses.single.amountMinor, 2550);
    expect(d.milestonesOf(goal.id).single.done, isTrue);

    // Delete on device B, then device A picks it up on its next sync.
    b.data.deleteTask(t.id);
    await b.settle();
    await a.c.read(syncProvider.notifier).sync();
    await a.settle();
    expect(a.data.snapshot.tasks, isEmpty);
  }, skip: skip);

  test('prayer settings and the prayer log sync to another device', () async {
    final a = Device.create();
    addTearDown(a.dispose);
    await a.open();
    final address = email();
    await a.auth.signUp(address, 'password1');
    a.c.read(dataProvider);
    await a.settle();
    a.data.updateSettings((s) => s.copyWith(
          onboardingDone: true,
          prayer: s.prayer.copyWith(enabled: true, place: 'Riyadh', latitude: () => 24.7136, longitude: () => 46.6753, remindBefore: 10),
        ));
    final today = dayKey(DateTime.now());
    a.data.setPrayerLogged(Prayer.fajr, today, true);
    await a.settle();

    final b = Device.create();
    addTearDown(b.dispose);
    await b.open();
    await b.auth.signIn(address, 'password1');
    b.c.read(dataProvider);
    await b.settle();
    final p = b.data.snapshot.settings.prayer;
    expect(p.active, isTrue);
    expect(p.remindBefore, 10);
    expect(b.data.snapshot.prayerLogged(Prayer.fajr, today), isTrue);
  }, skip: skip);

  test('fitness plans (with versions) and workouts sync to another device', () async {
    final a = Device.create();
    addTearDown(a.dispose);
    await a.open();
    final address = email();
    await a.auth.signUp(address, 'password1');
    a.c.read(dataProvider);
    await a.settle();
    a.data.updateSettings((s) => s.copyWith(onboardingDone: true));
    const gen = PlanGenerator();
    final p = FitnessProfile(
      goal: FitnessGoal.muscle,
      level: FitnessLevel.intermediate,
      daysPerWeek: 4,
      minutesPerSession: 60,
      weekdays: PlanGenerator.defaultWeekdays(4, 7),
      places: const {WorkoutPlace.gym},
    );
    a.data.saveFitness(p, {WorkoutPlace.gym: gen.build(p, WorkoutPlace.gym)});
    await a.settle();
    final v1 = a.data.snapshot.activePlan(WorkoutPlace.gym)!;
    a.data.logWorkout(WorkoutSession(
      id: newId(),
      planId: v1.id,
      day: dayKey(DateTime.now()),
      place: WorkoutPlace.gym,
      focus: DayFocus.upper,
      status: SessionStatus.completed,
      difficulty: 4,
      sets: const [SetLog(exerciseId: 'lat_pulldown', setIndex: 0, reps: 10, weightKg: 40)],
      createdAt: DateTime.now(),
    ));
    // A new version: the old one is deactivated before the new one is inserted.
    a.data.saveFitness(p, {WorkoutPlace.gym: gen.build(p, WorkoutPlace.gym)});
    await a.settle();
    expect(a.sync.rejected, 0);

    final b = Device.create();
    addTearDown(b.dispose);
    await b.open();
    await b.auth.signIn(address, 'password1');
    b.c.read(dataProvider);
    await b.settle();
    final d = b.data.snapshot;
    expect(d.settings.fitness!.goal, FitnessGoal.muscle);
    expect(d.workoutPlans, hasLength(2));
    expect(d.activePlan(WorkoutPlace.gym)!.version, 2);
    final s = d.workoutSessions.single;
    expect(d.plan(s.planId)!.version, 1);
    expect(s.sets.single.weightKg, 40);
  }, skip: skip);

  test('english path, test results, lessons and reviews sync to another device', () async {
    final a = Device.create();
    addTearDown(a.dispose);
    await a.open();
    final address = email();
    await a.auth.signUp(address, 'password1');
    a.c.read(dataProvider);
    await a.settle();
    a.data.updateSettings((s) => s.copyWith(onboardingDone: true));
    a.data.startLearning(
      Cefr.a2,
      5,
      placement: Assessment(
        id: newId(),
        kind: AssessmentKind.placement,
        level: Cefr.a2,
        scores: const {Skill.grammar: SkillScore(3, 8)},
        skillLevels: const {Skill.grammar: Cefr.a2},
        passed: true,
        takenAt: DateTime.now(),
      ),
    );
    a.data.recordLesson('a2_past', 60, const ['w_yesterday', 'w_trip']);
    a.data.recordLesson('a2_past', 100, const ['w_yesterday', 'w_trip']);
    a.data.reviewWord('w_trip', 3, '2030-01-01');
    await a.settle();
    expect(a.sync.rejected, 0);

    final b = Device.create();
    addTearDown(b.dispose);
    await b.open();
    await b.auth.signIn(address, 'password1');
    b.c.read(dataProvider);
    await b.settle();
    final d = b.data.snapshot;
    expect(d.learningPath!.weeklyGoal, 5);
    expect(d.assessments.single.skillLevels[Skill.grammar], Cefr.a2);
    final p = d.lessonProgress('a2_past')!;
    expect((p.bestScore, p.attempts), (100, 2));
    expect(d.vocabReviews.firstWhere((r) => r.wordId == 'w_trip').box, 3);
    expect(d.vocabReviews, hasLength(2));
  }, skip: skip);

  test('commitments and their answers sync to another device', () async {
    final a = Device.create();
    addTearDown(a.dispose);
    await a.open();
    final address = email();
    await a.auth.signUp(address, 'password1');
    a.c.read(dataProvider);
    await a.settle();
    a.data.updateSettings((s) => s.copyWith(onboardingDone: true));
    final task = a.data.newTask(title: 'Essay', dueDate: '2026-01-01');
    a.data.saveTask(task);
    final rule = AccountabilityRule(
        id: newId(), taskId: task.id, graceDays: 3, consequence: Consequence.custom, customText: 'Tidy my desk', createdAt: DateTime.now());
    a.data.saveRule(rule);
    final eventId = newId();
    a.data.addAccountabilityEvent(
        AccountabilityEvent(id: eventId, ruleId: rule.id, taskId: task.id, dueDate: '2026-01-01', triggeredOn: '2026-01-04'));
    await a.settle();
    a.data.resolveAccountability(eventId, DelayReason.illness, newDueDate: '2030-01-10', note: 'flu');
    await a.settle();
    expect(a.sync.rejected, 0);

    final b = Device.create();
    addTearDown(b.dispose);
    await b.open();
    await b.auth.signIn(address, 'password1');
    b.c.read(dataProvider);
    await b.settle();
    final d = b.data.snapshot;
    expect(d.ruleForTask(task.id)!.customText, 'Tidy my desk');
    final e = d.accountabilityEvent(eventId)!;
    expect((e.reason, e.outcome, e.newDueDate, e.note), (DelayReason.illness, EventOutcome.rescheduled, '2030-01-10', 'flu'));
    expect(d.task(task.id)!.dueDate, '2030-01-10');
  }, skip: skip);

  test('another account sees nothing', () async {
    final a = Device.create();
    addTearDown(a.dispose);
    await a.open();
    await a.auth.signUp(email(), 'password1');
    a.c.read(dataProvider);
    await a.settle();
    a.data.saveTask(a.data.newTask(title: 'private'));
    await a.settle();

    final b = Device.create();
    addTearDown(b.dispose);
    await b.open();
    await b.auth.signUp(email(), 'password1');
    b.c.read(dataProvider);
    await b.settle();
    expect(b.data.snapshot.tasks, isEmpty);
    expect(await b.client.from('tasks').select(), isEmpty);
  }, skip: skip);

  test('a change the server refuses is dropped and replaced by the server version', () async {
    final address = email();
    final a = Device.create();
    addTearDown(a.dispose);
    await a.open();
    await a.auth.signUp(address, 'password1');
    a.c.read(dataProvider);
    await a.settle();

    final b = Device.create();
    addTearDown(b.dispose);
    await b.open();
    await b.auth.signIn(address, 'password1');
    b.c.read(dataProvider);
    await b.settle();

    // Both devices create a SAR budget; the server allows one per currency.
    a.data.saveBudget(Budget(id: newId(), currency: 'SAR', limitMinor: 100000));
    await a.settle();
    b.data.saveBudget(Budget(id: newId(), currency: 'SAR', limitMinor: 50000));
    await b.settle();
    expect(b.sync.rejected, 1);
    expect(b.sync.phase, SyncPhase.error);
    expect(b.data.snapshot.budgets.single.limitMinor, 100000);
  }, skip: skip);

  test('no connection is reported as a network error', () async {
    // Nothing listens on port 9: every request fails like a lost connection.
    final a = Device.create(baseUrl: 'http://127.0.0.1:9');
    addTearDown(a.dispose);
    await a.open();
    await expectLater(a.auth.signIn(email(), 'password1'), throwsA(isA<AuthException>().having((e) => e.code, 'code', AuthErrorCode.network)));
  }, skip: skip);

  test('wrong password and duplicate email map to app errors', () async {
    final address = email();
    final a = Device.create();
    addTearDown(a.dispose);
    await a.open();
    await a.auth.signUp(address, 'password1');
    await a.auth.signOut();
    await expectLater(a.auth.signIn(address, 'wrongpass9'), throwsA(isA<AuthException>().having((e) => e.code, 'code', AuthErrorCode.invalidCredentials)));
    await a.auth.signIn(address, 'password1');
    expect(await a.auth.verifyPassword('password1'), isTrue);
    expect(await a.auth.verifyPassword('nope12345'), isFalse);
    await a.auth.changePassword('password1', 'password2');
    await a.auth.signOut();
    await a.auth.signIn(address, 'password2');
    await a.auth.signOut();
    final b = Device.create();
    addTearDown(b.dispose);
    await b.open();
    await expectLater(b.auth.signUp(address, 'password1'), throwsA(isA<AuthException>().having((e) => e.code, 'code', AuthErrorCode.emailExists)));
  }, skip: skip);

  test('account deletion records a request and clears the device', () async {
    final a = Device.create();
    addTearDown(a.dispose);
    await a.open();
    await a.auth.signUp(email(), 'password1');
    a.c.read(dataProvider);
    await a.settle();
    final uid = a.c.read(authProvider).user!.id;
    a.data.saveTask(a.data.newTask(title: 'x'));
    await a.settle();
    final client = a.client;
    // Read the request as the user before signing out.
    await a.auth.deleteAccount(clearLocal: a.data.wipe);
    expect(a.c.read(authProvider).signedIn, isFalse);
    expect(a.c.read(localStoreProvider).readJson('hayati.data.$uid'), isNull);
    expect(client.auth.currentSession, isNull);
  }, skip: skip);

  test('cloud assistant: proposals run on the server only after approval', () async {
    final a = Device.create();
    addTearDown(a.dispose);
    await a.open();
    await a.auth.signUp(email(), 'password1');
    a.c.read(dataProvider);
    await a.settle();
    final l = lookupAppLocalizations(const Locale('ar'));
    final svc = a.c.read(assistantProvider.notifier);

    // The fake model answers "أضف" with a create_task call.
    final conv = await svc.send(null, 'أضف مهمة مراجعة', l);
    final p = a.data.snapshot.proposals.single;
    expect(p.remote, isTrue);
    expect(p.status, ProposalStatus.pending);
    expect(p.calls.single.tool, 'create_task');
    expect(a.data.snapshot.tasks, isEmpty, reason: 'nothing changes before approval');

    final r = await svc.approve(p.id);
    expect(r.outcome, ExecOutcome.executed);
    expect(r.count, 1);
    await a.settle();
    expect(a.data.snapshot.tasks.single.title, 'مراجعة');
    expect((await svc.approve(p.id)).outcome, ExecOutcome.alreadyExecuted);

    // "plan" → plan_task on the task the server knows about; rejected.
    await svc.send(conv, 'plan it', l);
    final plan = a.data.snapshot.proposals.firstWhere((x) => x.id != p.id);
    expect(plan.calls.single.args['taskId'], a.data.snapshot.tasks.single.id);
    await svc.reject(plan.id);
    expect(a.data.snapshot.proposal(plan.id)!.status, ProposalStatus.rejected);
    final row = await a.client.from('assistant_actions').select('status').eq('id', plan.remoteId!).single();
    expect(row['status'], 'rejected');
  }, skip: skip ?? (Platform.environment['ASSISTANT_TEST'] == '1' ? null : 'set ASSISTANT_TEST=1 with the function served'));
}
