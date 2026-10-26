import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/accountability.dart';
import 'package:hayati/data/models/misc.dart';
import 'package:hayati/data/models/task.dart';
import 'package:hayati/data/remote/rows.dart';
import 'package:hayati/domain/accountability.dart';
import 'package:hayati/l10n/app_localizations.dart';

import 'helpers.dart';

void main() {
  group('safety filter', () {
    test('rejects anything touching sleep, food, prayer, health or exercise', () {
      for (final bad in [
        'ما أنام قبل ما أخلصها',
        'أترك وجبة العشاء',
        'أأخر الصلاة',
        'أوقف الدواء',
        'تمرين إضافي ساعة',
        'No sleep until done',
        'skip meals',
        'Skip praying',
        'cancel my doctor visit',
        'Do an extra workout',
        'punishment push-ups',
        'بدون أكل',
        'أسهر والنوم بعدين',
        'أروح للطبيب بعدين',
      ]) {
        expect(unsafeConsequence(bad), 'unsafe', reason: bad);
      }
    });

    test('allows harmless wording, including words that merely contain a stem', () {
      for (final ok in ['Repeat the outline once', 'Create a checklist', 'أرتب مكتبي 10 دقائق', 'أحل المشاكل أولًا', 'أرتب المجلد', 'No games until the first step']) {
        expect(unsafeConsequence(ok), isNull, reason: ok);
      }
      expect(unsafeConsequence('  '), 'empty');
      expect(unsafeConsequence('x' * 201), 'long');
    });
  });

  group('rules and events', () {
    Future<(DataController, Task)> setup({String due = '2026-03-01'}) async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      final task = data.newTask(title: 'Report', dueDate: due);
      data.saveTask(task);
      return (data, task);
    }

    AccountabilityRule rule(Task t, {int grace = 7, Consequence c = Consequence.planningSession, String custom = ''}) =>
        AccountabilityRule(id: 'r1', taskId: t.id, graceDays: grace, consequence: c, customText: custom, createdAt: fixedNow);

    test('saveRule validates the task, grace days and custom text', () async {
      final (data, task) = await setup();
      expect(() => data.saveRule(rule(task, grace: 0)), throwsArgumentError);
      expect(() => data.saveRule(rule(task, c: Consequence.custom, custom: 'no sleep')), throwsArgumentError);
      final noDue = data.newTask(title: 'No date');
      data.saveTask(noDue);
      expect(() => data.saveRule(rule(noDue)), throwsArgumentError);
      data.saveRule(rule(task));
      expect(data.snapshot.ruleForTask(task.id)?.id, 'r1');
    });

    test('triggers once the grace period runs out, once per deadline', () async {
      // fixedNow is 2026-03-10: 9 days past 2026-03-01.
      final (data, task) = await setup();
      data.saveRule(rule(task, grace: 10));
      expect(dueAccountability(data.snapshot, fixedNow), isEmpty);
      data.saveRule(rule(task, grace: 7));
      final l = lookupAppLocalizations(const Locale('en'));
      final notes = syncAccountability(data, fixedNow, l);
      expect(notes.single.type, NotificationType.accountability);
      expect(data.snapshot.accountabilityEvents.single.dueDate, '2026-03-01');
      expect(syncAccountability(data, fixedNow, l), isEmpty);
      expect(data.snapshot.accountabilityEvents, hasLength(1));
      // A paused rule never triggers.
      data.saveRule(rule(task).copyWith(active: false));
      expect(dueAccountability(data.snapshot.copyWith(accountabilityEvents: const []), fixedNow), isEmpty);
    });

    test('done or cancelled tasks never trigger', () async {
      final (data, task) = await setup();
      data.saveRule(rule(task));
      data.saveTask(task.copyWith(status: TaskStatus.done));
      expect(dueAccountability(data.snapshot, fixedNow), isEmpty);
    });

    String trigger(DataController data) {
      syncAccountability(data, fixedNow, lookupAppLocalizations(const Locale('en')));
      return data.snapshot.accountabilityEvents.single.id;
    }

    test('postponed: consequence task added and new deadline set', () async {
      final (data, task) = await setup();
      data.saveRule(rule(task));
      final id = trigger(data);
      expect(() => data.resolveAccountability(id, DelayReason.postponed), throwsArgumentError);
      final extra = data.newTask(title: 'Plan the steps: Report', dueDate: '2026-03-10', estimatedMinutes: 15);
      data.resolveAccountability(id, DelayReason.postponed, newDueDate: '2026-03-13', consequenceTask: extra);
      final d = data.snapshot;
      expect(d.accountabilityEvent(id)!.outcome, EventOutcome.consequenceAccepted);
      expect(d.task(task.id)!.dueDate, '2026-03-13');
      expect(d.task(extra.id), isNotNull);
      // The new deadline isn't late yet.
      expect(dueAccountability(d, fixedNow), isEmpty);
    });

    test('emergency or illness: new date, never a consequence', () async {
      for (final reason in [DelayReason.emergency, DelayReason.illness]) {
        final (data, task) = await setup();
        data.saveRule(rule(task));
        final id = trigger(data);
        final extra = data.newTask(title: 'should not be added');
        data.resolveAccountability(id, reason, newDueDate: '2026-03-15', consequenceTask: extra);
        final d = data.snapshot;
        expect(d.accountabilityEvent(id)!.outcome, EventOutcome.rescheduled);
        expect(d.task(task.id)!.dueDate, '2026-03-15');
        expect(d.task(extra.id), isNull, reason: '$reason');
      }
    });

    test('no longer important: task cancelled, rule paused', () async {
      final (data, task) = await setup();
      data.saveRule(rule(task));
      final id = trigger(data);
      data.resolveAccountability(id, DelayReason.notImportant);
      final d = data.snapshot;
      expect(d.accountabilityEvent(id)!.outcome, EventOutcome.dropped);
      expect(d.task(task.id)!.status, TaskStatus.cancelled);
      expect(d.rule('r1')!.active, isFalse);
    });

    test('deleting a rule keeps its history', () async {
      final (data, task) = await setup();
      data.saveRule(rule(task));
      final id = trigger(data);
      data.deleteRule('r1');
      expect(data.snapshot.accountabilityRules, isEmpty);
      expect(data.snapshot.accountabilityEvent(id)!.ruleId, isNull);
    });
  });

  test('rows and JSON round-trip', () {
    final r = AccountabilityRule(
        id: 'r', taskId: 't', graceDays: 3, consequence: Consequence.custom, customText: 'Tidy desk', createdAt: fixedNow);
    final rb = ruleFrom({...ruleRow(r)});
    expect((rb.graceDays, rb.consequence, rb.customText, rb.active), (3, Consequence.custom, 'Tidy desk', true));
    expect(AccountabilityRule.fromJson(r.toJson()).customText, 'Tidy desk');
    final e = const AccountabilityEvent(id: 'e', ruleId: 'r', taskId: 't', dueDate: '2026-03-01', triggeredOn: '2026-03-08')
        .resolve(DelayReason.illness, EventOutcome.rescheduled, newDueDate: '2026-03-12', note: 'flu', at: fixedNow);
    final eb = eventFromA({...eventRowA(e)});
    expect((eb.reason, eb.outcome, eb.newDueDate, eb.note), (DelayReason.illness, EventOutcome.rescheduled, '2026-03-12', 'flu'));
    final j = AccountabilityEvent.fromJson(e.toJson());
    expect(j.resolvedAt, fixedNow);
    final d = AppData.fromJson(AppData(accountabilityRules: [r], accountabilityEvents: [e]).toJson());
    expect(d.accountabilityEvents.single.reason, DelayReason.illness);
  });
}
