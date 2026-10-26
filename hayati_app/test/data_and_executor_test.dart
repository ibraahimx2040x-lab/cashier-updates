import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/core/utils/dates.dart';
import 'package:hayati/data/auth.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/assistant.dart';
import 'package:hayati/data/models/goal.dart';
import 'package:hayati/data/models/misc.dart';
import 'package:hayati/data/models/task.dart';
import 'package:hayati/domain/assistant/executor.dart';
import 'package:hayati/domain/assistant/tools.dart';
import 'package:hayati/domain/metrics.dart';

import 'helpers.dart';

void main() {
  group('auth', () {
    test('rejects wrong password and duplicate email', () async {
      final c = await signedInContainer();
      final auth = c.read(authProvider.notifier);
      await auth.signOut();
      expect(() => auth.signIn('a@example.com', 'wrongpass1'), throwsA(isA<AuthException>()));
      expect(() => auth.signUp('a@example.com', 'password1'), throwsA(isA<AuthException>()));
      await auth.signIn('A@Example.com ', 'password1');
      expect(c.read(authProvider).signedIn, isTrue);
    });

    test('weak password is rejected', () async {
      final c = await signedInContainer();
      expect(() => c.read(authProvider.notifier).signUp('b@example.com', 'short'), throwsA(isA<AuthException>()));
    });

    test('accounts cannot see each other\'s data', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      data.saveTask(data.newTask(title: 'private'));
      expect(c.read(dataProvider).tasks, hasLength(1));
      await c.read(authProvider.notifier).signOut();
      await c.read(authProvider.notifier).signUp('b@example.com', 'password1');
      expect(c.read(dataProvider).tasks, isEmpty);
      await c.read(authProvider.notifier).signOut();
      await c.read(authProvider.notifier).signIn('a@example.com', 'password1');
      expect(c.read(dataProvider).tasks.single.title, 'private');
    });

    test('delete account wipes data', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      data.saveTask(data.newTask(title: 'x'));
      await data.wipe();
      await c.read(authProvider.notifier).deleteAccount();
      expect(() => c.read(authProvider.notifier).signIn('a@example.com', 'password1'), throwsA(isA<AuthException>()));
    });
  });

  group('data rules', () {
    test('task must have a title and positive duration', () async {
      final c = await signedInContainer();
      final d = c.read(dataProvider.notifier);
      expect(() => d.saveTask(d.newTask(title: '  ')), throwsArgumentError);
      expect(() => d.saveTask(d.newTask(title: 'a', estimatedMinutes: 0)), throwsArgumentError);
    });

    test('task cannot link to a goal that does not exist', () async {
      final c = await signedInContainer();
      final d = c.read(dataProvider.notifier);
      expect(() => d.saveTask(d.newTask(title: 'a', goalId: 'nope')), throwsArgumentError);
    });

    test('habit logs are never duplicated and future days are refused', () async {
      final c = await signedInContainer();
      final d = c.read(dataProvider.notifier);
      d.saveHabit(Habit(id: 'h', name: 'Read', weekdays: {1, 2, 3, 4, 5, 6, 7}, startDate: '2026-03-01'));
      d.setHabitDone('h', '2026-03-10', true);
      d.setHabitDone('h', '2026-03-10', true);
      expect(c.read(dataProvider).habitLogs, hasLength(1));
      expect(() => d.setHabitDone('h', '2026-03-11', true), throwsArgumentError);
    });

    test('expense must be positive', () async {
      final c = await signedInContainer();
      final d = c.read(dataProvider.notifier);
      expect(
        () => d.addExpense(Expense(id: 'e', amountMinor: 0, currency: 'SAR', category: 'food', spentAt: fixedNow)),
        throwsA(anything),
      );
    });

    test('completing the last task of a milestone completes it', () async {
      final c = await signedInContainer();
      final d = c.read(dataProvider.notifier);
      final g = Goal(id: 'g', title: 'Flutter', createdAt: fixedNow, updatedAt: fixedNow);
      d.saveGoal(g, [const Milestone(id: 'm1', goalId: 'g', title: 'Dart', order: 0), const Milestone(id: 'm2', goalId: 'g', title: 'UI', order: 1)]);
      final t1 = d.newTask(title: 't1', goalId: 'g', milestoneId: 'm1');
      final t2 = d.newTask(title: 't2', goalId: 'g', milestoneId: 'm1');
      d.saveTask(t1);
      d.saveTask(t2);
      d.setTaskStatus(t1.id, TaskStatus.done);
      expect(GoalProgress.of(g, c.read(dataProvider).milestonesOf('g')).percent, 0);
      d.setTaskStatus(t2.id, TaskStatus.done);
      final p = GoalProgress.of(g, c.read(dataProvider).milestonesOf('g'));
      expect(p.percent, 50);
      // Goal is not auto-completed.
      expect(c.read(dataProvider).goal('g')!.status, GoalStatus.active);
    });

    test('notifications are deduplicated', () async {
      final c = await signedInContainer();
      final d = c.read(dataProvider.notifier);
      AppNotification n(String id) => AppNotification(id: id, type: NotificationType.task, title: 't', createdAt: fixedNow, dedupeKey: 'k');
      expect(d.notify(n('1')), isTrue);
      expect(d.notify(n('2')), isFalse);
      d.markAllNotificationsRead();
      d.clearReadNotifications();
      expect(d.notify(n('3')), isFalse, reason: 'cleared reminders are not re-delivered');
      expect(c.read(dataProvider).visibleNotifications, isEmpty);
    });
  });

  group('executor', () {
    test('executes a proposal exactly once', () async {
      final c = await signedInContainer();
      final d = c.read(dataProvider.notifier);
      final ex = AssistantExecutor(d, () => fixedNow);
      d.saveProposal(ActionProposal(
        id: 'p',
        conversationId: 'c',
        reason: 'r',
        calls: const [ToolCall(Tools.createTask, {'title': 'A'})],
        idempotencyKey: 'k',
        createdAt: fixedNow,
      ));
      expect(ex.executeProposal('p').outcome, ExecOutcome.executed);
      expect(ex.executeProposal('p').outcome, ExecOutcome.alreadyExecuted);
      expect(c.read(dataProvider).tasks, hasLength(1));
      expect(c.read(dataProvider).actionLogs.where((l) => l.ok), hasLength(1));
    });

    test('stale proposal is not executed', () async {
      final c = await signedInContainer();
      final d = c.read(dataProvider.notifier);
      final t = d.newTask(title: 'x');
      d.saveTask(t);
      final saved = c.read(dataProvider).task(t.id)!;
      d.saveProposal(ActionProposal(
        id: 'p',
        conversationId: 'c',
        reason: 'r',
        calls: [ToolCall(Tools.moveTask, {'taskId': t.id, 'dueDate': '2026-03-12'})],
        idempotencyKey: 'k',
        snapshot: {t.id: encodeInstant(saved.updatedAt)!.replaceFirst('2026', '2025')},
        createdAt: fixedNow,
      ));
      expect(AssistantExecutor(d, () => fixedNow).executeProposal('p').outcome, ExecOutcome.stale);
      expect(c.read(dataProvider).task(t.id)!.dueDate, isNull);
    });

    test('a failing call rolls back the whole batch', () async {
      final c = await signedInContainer();
      final d = c.read(dataProvider.notifier);
      d.saveHabit(Habit(id: 'h', name: 'Read', weekdays: {1, 2, 3, 4, 5, 6, 7}, startDate: '2026-03-01'));
      final r = AssistantExecutor(d, () => fixedNow).run(const [
        ToolCall(Tools.createTask, {'title': 'A'}),
        // Valid by schema, but the data layer refuses future habit logs.
        ToolCall(Tools.logHabit, {'habitId': 'h', 'day': '2027-01-01'}),
      ]);
      expect(r.outcome, ExecOutcome.failed);
      expect(c.read(dataProvider).tasks, isEmpty);
      expect(c.read(dataProvider).habitLogs, isEmpty);
    });

    test('invalid call is refused before anything runs', () async {
      final c = await signedInContainer();
      final d = c.read(dataProvider.notifier);
      final r = AssistantExecutor(d, () => fixedNow).run(const [
        ToolCall(Tools.createTask, {'title': 'A'}),
        ToolCall(Tools.deleteTask, {'taskId': 'not-mine'}),
      ]);
      expect(r.outcome, ExecOutcome.invalid);
      expect(c.read(dataProvider).tasks, isEmpty);
    });

    test('create_goal builds goal, milestones and linked tasks', () async {
      final c = await signedInContainer();
      final d = c.read(dataProvider.notifier);
      AssistantExecutor(d, () => fixedNow).run([
        const ToolCall(Tools.createGoal, {
          'title': 'Learn English',
          'milestones': ['Level', 'Basics'],
          'tasks': [
            {'title': 's1', 'estimatedMinutes': 30, 'milestone': 0},
          ],
        }),
      ]);
      final data = c.read(dataProvider);
      final g = data.goals.single;
      expect(data.milestonesOf(g.id), hasLength(2));
      expect(data.tasks.single.milestoneId, data.milestonesOf(g.id).first.id);
    });
  });

  group('metrics', () {
    test('non-due days are not failures; a missed day keeps history', () {
      // Mon/Wed only.
      const h = Habit(id: 'h', name: 'Gym', weekdays: {1, 3}, startDate: '2026-03-01');
      // 2026-03-02 Mon, 03-04 Wed, 03-09 Mon done; 03-11 Wed missed.
      final logs = {'2026-03-02', '2026-03-04', '2026-03-09'};
      final s = HabitStats.compute(h, logs, DateTime(2026, 3, 1), DateTime(2026, 3, 12));
      expect(s.dueDays, 4);
      expect(s.doneDays, 3);
      expect(s.streak, 0);
      final before = HabitStats.compute(h, logs, DateTime(2026, 3, 1), DateTime(2026, 3, 10));
      expect(before.streak, 3);
    });

    test('goal with no milestones has no percent; manual uses its value', () {
      final g = Goal(id: 'g', title: 'x', createdAt: fixedNow, updatedAt: fixedNow);
      expect(GoalProgress.of(g, const []).percent, isNull);
      expect(GoalProgress.of(g.copyWith(progressMode: ProgressMode.manual, manualProgress: 40), const []).percent, 40);
    });

    test('totals never mix currencies', () {
      final t = totalsByCurrency([
        Expense(id: '1', amountMinor: 1000, currency: 'SAR', category: 'food', spentAt: fixedNow),
        Expense(id: '2', amountMinor: 500, currency: 'USD', category: 'food', spentAt: fixedNow),
        Expense(id: '3', amountMinor: 250, currency: 'SAR', category: 'food', spentAt: fixedNow),
      ]);
      expect(t, {'SAR': 1250, 'USD': 500});
    });

    test('report excludes cancelled tasks and reports no data honestly', () async {
      final c = await signedInContainer();
      final d = c.read(dataProvider.notifier);
      final from = DateTime(2026, 3, 9), to = DateTime(2026, 3, 16);
      expect(PeriodReport.build(c.read(dataProvider), from, to, fixedNow).hasData, isFalse);
      final a = d.newTask(title: 'a', dueDate: '2026-03-10');
      final b = d.newTask(title: 'b', dueDate: '2026-03-10');
      d.saveTask(a);
      d.saveTask(b);
      d.setTaskStatus(a.id, TaskStatus.done);
      d.setTaskStatus(b.id, TaskStatus.cancelled);
      final r = PeriodReport.build(c.read(dataProvider), from, to, fixedNow);
      expect(r.dueInPeriod, 1);
      expect(r.completionRate, 1.0);
    });
  });
}
