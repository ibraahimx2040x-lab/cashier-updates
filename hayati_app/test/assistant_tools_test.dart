import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/core/utils/dates.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/assistant.dart';
import 'package:hayati/data/models/fitness.dart';
import 'package:hayati/data/models/goal.dart';
import 'package:hayati/data/models/health.dart';
import 'package:hayati/data/models/settings.dart';
import 'package:hayati/data/models/task.dart';
import 'package:hayati/domain/assistant/catalog.dart';
import 'package:hayati/domain/assistant/executor.dart';
import 'package:hayati/domain/assistant/tools.dart';

import 'helpers.dart';

void main() {
  test('every tool has one declaration for the model, and the reverse', () {
    final names = [for (final t in toolDeclarations) t['name']];
    expect(names.toSet(), Tools.all);
    expect(names.length, Tools.all.length);
    // The server caps the payload; keep well under it.
    expect(jsonEncode(toolDeclarations).length, lessThan(40000));
    for (final t in toolDeclarations) {
      final params = t['parameters'] as Map;
      final props = (params['properties'] as Map).keys.toSet();
      expect(props.containsAll((params['required'] as List?) ?? const []), isTrue, reason: '${t['name']}');
    }
  });

  test('the context holds only what the user shares', () async {
    final c = await signedInContainer();
    final data = c.read(dataProvider.notifier);
    data.saveTask(data.newTask(title: 'Pay rent', dueDate: '2026-03-11'));
    data.updateSettings((s) => s.copyWith(assistant: const AssistantPermissions(shareTasks: false)));
    var ctx = assistantContext(c.read(dataProvider), 'ar', fixedNow);
    expect(ctx.containsKey('tasks'), isFalse);
    expect(ctx['exercise_catalog'], isNotEmpty);
    data.updateSettings((s) => s.copyWith(assistant: const AssistantPermissions()));
    ctx = assistantContext(c.read(dataProvider), 'ar', fixedNow);
    expect((ctx['tasks'] as List).single['title'], 'Pay rent');
    expect(jsonEncode(ctx).length, lessThan(150000));
  });

  test('model numbers and nulls are cleaned before validation', () {
    final c = compactCall(const ToolCall(Tools.createAlarm, {'time': 390.0, 'label': null, 'weekdays': [1.0, 2.0]}));
    expect(c.args, {'time': 390, 'weekdays': [1, 2]});
  });

  test('"90 days of abs, no rest day": a 7-day plan and a 90-day goal, applied after approval', () async {
    final c = await signedInContainer();
    final data = c.read(dataProvider.notifier);
    final calls = [
      ToolCall(Tools.setWorkoutPlan, {
        'place': 'home',
        'days': [
          for (var w = 1; w <= 7; w++)
            {
              'weekday': w,
              'exercises': [
                {'exerciseId': 'plank', 'sets': 3, 'seconds': 30},
                {'exerciseId': 'dead_bug', 'sets': 3, 'reps': 12},
                {'exerciseId': w.isEven ? 'side_plank' : 'bird_dog', 'sets': 2, 'seconds': 20},
              ],
            },
        ],
      }),
      ToolCall(Tools.createGoal, {
        'title': 'تمارين بطن 90 يوم',
        'category': 'health',
        'targetDate': dayKey(fixedNow.add(const Duration(days: 90))),
        'milestones': ['أول 30 يوم', '60 يوم', '90 يوم'],
      }),
    ];
    for (final x in calls) {
      expect(validateCall(x, c.read(dataProvider)), isNull);
    }
    expect(const ToolPolicy(AssistantPermissions()).tierOf(calls), Tier.approvalRequired);
    final r = AssistantExecutor(data, () => fixedNow).run(calls);
    expect(r.ok, isTrue, reason: r.error);
    final d = c.read(dataProvider);
    final plan = d.workoutPlans.singleWhere((p) => p.active);
    expect(plan.days.map((x) => x.weekday), [1, 2, 3, 4, 5, 6, 7]);
    expect(plan.days.first.exercises.first.seconds, 30);
    expect(d.settings.fitness!.weekdays.length, 7);
    expect(d.goals.single.targetDate, '2026-06-08');
  });

  test('a workout plan with an unknown exercise or a repeated day is refused', () async {
    final c = await signedInContainer();
    final d = c.read(dataProvider);
    ToolCall plan(List<Map<String, Object?>> days) => ToolCall(Tools.setWorkoutPlan, {'place': 'home', 'days': days});
    expect(validateCall(plan([
      {'weekday': 1, 'exercises': [{'exerciseId': 'crunch_9000', 'sets': 3, 'reps': 10}]},
    ]), d), 'exerciseId');
    expect(validateCall(plan([
      {'weekday': 1, 'exercises': [{'exerciseId': 'plank', 'sets': 3, 'seconds': 30}]},
      {'weekday': 1, 'exercises': [{'exerciseId': 'plank', 'sets': 3, 'seconds': 30}]},
    ]), d), 'weekday');
    expect(validateCall(plan([
      {'weekday': 2, 'exercises': [{'exerciseId': 'plank', 'sets': 3, 'reps': 10, 'seconds': 30}]},
    ]), d), 'reps');
  });

  test('time: edit and finish a task, add an event, set and delete an alarm', () async {
    final c = await signedInContainer();
    final data = c.read(dataProvider.notifier);
    final ex = AssistantExecutor(data, () => fixedNow);
    final t = data.newTask(title: 'Report');
    data.saveTask(t);
    expect(ex.run([ToolCall(Tools.updateTask, {'taskId': t.id, 'title': 'Final report', 'dueDate': '2026-03-12', 'priority': 'high'})]).ok, isTrue);
    var task = c.read(dataProvider).task(t.id)!;
    expect((task.title, task.dueDate, task.priority), ('Final report', '2026-03-12', Priority.high));
    expect(ex.run([ToolCall(Tools.updateTask, {'taskId': t.id, 'status': 'done'})]).ok, isTrue);
    expect(c.read(dataProvider).task(t.id)!.status, TaskStatus.done);
    expect(validateCall(const ToolCall(Tools.updateTask, {'taskId': 'nope', 'title': 'x'}), c.read(dataProvider)), 'taskId');

    expect(ex.run([
      const ToolCall(Tools.createEvent, {'title': 'Dentist', 'start': '2026-03-11T10:00:00+03:00', 'end': '2026-03-11T11:00:00+03:00'}),
      const ToolCall(Tools.createAlarm, {'time': 330, 'label': 'Fajr', 'weekdays': [1, 2, 3, 4, 5, 6, 7]}),
      const ToolCall(Tools.createAlarm, {'time': 420}),
    ]).ok, isTrue);
    final d = c.read(dataProvider);
    expect(d.events.single.title, 'Dentist');
    expect(d.alarms.map((a) => a.weekdays.length), containsAll([7, 0]));
    // A one-time alarm with no date rings the next time 07:00 comes (08:00 now → tomorrow).
    expect(d.alarms.firstWhere((a) => a.weekdays.isEmpty).onDate, '2026-03-11');
    expect(validateCall(const ToolCall(Tools.createEvent, {'title': 'x', 'start': '2026-03-11T10:00:00', 'end': '2026-03-11T09:00:00'}), d), 'end');

    expect(ex.run([ToolCall(Tools.deleteAlarm, {'alarmId': d.alarms.first.id}), ToolCall(Tools.deleteEvent, {'eventId': d.events.single.id})]).ok, isTrue);
    expect((c.read(dataProvider).alarms.length, c.read(dataProvider).events.length), (1, 0));
  });

  test('goals and habits: create a habit, pause a goal', () async {
    final c = await signedInContainer();
    final data = c.read(dataProvider.notifier);
    final ex = AssistantExecutor(data, () => fixedNow);
    expect(ex.run([const ToolCall(Tools.createHabit, {'name': 'Read', 'weekdays': [1, 3, 5], 'reminderTime': 1260})]).ok, isTrue);
    expect(c.read(dataProvider).habits.single.weekdays, {1, 3, 5});
    expect(ex.run([const ToolCall(Tools.createGoal, {'title': 'Run 5k', 'milestones': []})]).ok, isTrue);
    final g = c.read(dataProvider).goals.single;
    expect(ex.run([ToolCall(Tools.setGoalStatus, {'goalId': g.id, 'status': 'paused'})]).ok, isTrue);
    expect(c.read(dataProvider).goal(g.id)!.status, GoalStatus.paused);
  });

  test('money: expense, income, monthly bill and budget in the user\'s currency', () async {
    final c = await signedInContainer();
    final data = c.read(dataProvider.notifier);
    final ex = AssistantExecutor(data, () => fixedNow);
    expect(ex.run([
      const ToolCall(Tools.addExpense, {'amount': 25.5, 'category': 'food', 'description': 'Lunch'}),
      const ToolCall(Tools.addIncome, {'amount': 300, 'source': 'Freelance'}),
      const ToolCall(Tools.addRecurring, {'kind': 'expense', 'amount': 120, 'title': 'Internet', 'category': 'bills', 'dayOfMonth': 5}),
      const ToolCall(Tools.setBudget, {'limit': 2000}),
    ]).ok, isTrue);
    final d = c.read(dataProvider);
    expect(d.expenses.where((e) => e.recurringId == null).single.amountMinor, 2550);
    expect(d.incomes.single.amountMinor, 30000);
    expect(d.recurring.single.title, 'Internet');
    expect(d.budgets.single.limitMinor, 200000);
    expect(d.expenses.first.currency, d.settings.currency);
    expect(validateCall(const ToolCall(Tools.addExpense, {'amount': -5, 'category': 'food'}), d), 'amount');
    expect(validateCall(const ToolCall(Tools.addExpense, {'amount': 5, 'category': 'cars'}), d), 'category');
  });

  test('health, learning and settings: weight, sleep, notifications', () async {
    final c = await signedInContainer();
    final data = c.read(dataProvider.notifier);
    final ex = AssistantExecutor(data, () => fixedNow);
    expect(ex.run([
      const ToolCall(Tools.addMeasurement, {'kind': 'weight', 'value': 82.4}),
      ToolCall(Tools.logSleep, {
        'start': encodeInstant(fixedNow.subtract(const Duration(hours: 9))),
        'end': encodeInstant(fixedNow.subtract(const Duration(hours: 1))),
        'quality': 4,
      }),
      const ToolCall(Tools.setNotifications, {'section': 'water', 'enabled': true, 'time': 600}),
    ]).ok, isTrue, reason: 'batch');
    final d = c.read(dataProvider);
    expect(d.bodyMetrics.single.kind, MetricKind.weight);
    expect(d.sleep.single.quality, 4);
    expect((d.settings.notify.on(NotifySection.water), d.settings.notify.timeOf(NotifySection.water)), (true, 600));
    // English isn't started yet, so the weekly target can't be set.
    expect(validateCall(const ToolCall(Tools.setWeeklyLessons, {'lessons': 3}), d), 'not_started');
  });

  test('opening a screen needs no approval and changes nothing', () async {
    final c = await signedInContainer();
    const open = ToolCall(Tools.openScreen, {'screen': 'money'});
    expect(validateCall(open, c.read(dataProvider)), isNull);
    expect(validateCall(const ToolCall(Tools.openScreen, {'screen': 'admin'}), c.read(dataProvider)), 'screen');
    expect(const ToolPolicy(AssistantPermissions()).tierOf([open]), Tier.autoAllowed);
    expect(assistantScreens['money'], '/expenses');
    expect(WorkoutPlace.values, isNotEmpty);
  });
}
