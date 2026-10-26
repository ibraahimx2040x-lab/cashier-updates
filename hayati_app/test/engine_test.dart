import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/models/assistant.dart';
import 'package:hayati/data/models/goal.dart';
import 'package:hayati/data/models/settings.dart';
import 'package:hayati/data/models/task.dart';
import 'package:hayati/domain/assistant/engine.dart';
import 'package:hayati/domain/assistant/tools.dart';
import 'package:hayati/l10n/app_localizations.dart';

void main() {
  final now = DateTime(2026, 3, 10, 9); // Tuesday
  final ar = lookupAppLocalizations(const Locale('ar'));
  final en = lookupAppLocalizations(const Locale('en'));

  group('parseTaskRequest', () {
    test('Arabic: tomorrow at 8 pm', () {
      final p = parseTaskRequest('أضف مهمة مراجعة الإنجليزية غدًا الساعة 8 مساءً', now);
      expect(p.title, 'مراجعة الإنجليزية');
      expect(p.dueDate, '2026-03-11');
      expect(p.dueTime, 20 * 60);
      expect(p.ambiguousHour, isNull);
    });

    test('Arabic: hour without AM/PM is ambiguous', () {
      final p = parseTaskRequest('أضف مهمة مراجعة الإنجليزية غدًا الساعة 8', now);
      expect(p.ambiguousHour, 8);
      expect(p.dueTime, isNull);
    });

    test('Arabic-Indic digits and duration', () {
      final p = parseTaskRequest('أضف مهمة قراءة لمدة ٤٥ دقيقة اليوم الساعة ٧:٣٠ م', now);
      expect(p.title, 'قراءة');
      expect(p.minutes, 45);
      expect(p.dueDate, '2026-03-10');
      expect(p.dueTime, 19 * 60 + 30);
    });

    test('English: tomorrow at 8pm, urgent', () {
      final p = parseTaskRequest('add task call the bank tomorrow at 8pm urgent', now);
      expect(p.title, 'call the bank');
      expect(p.dueDate, '2026-03-11');
      expect(p.dueTime, 20 * 60);
      expect(p.highPriority, isTrue);
    });

    test('24h hour is not ambiguous', () {
      final p = parseTaskRequest('add task gym at 18:00', now);
      expect(p.dueTime, 18 * 60);
      expect(p.ambiguousHour, isNull);
    });
  });

  group('engine intents', () {
    AssistantContext ctx(AppData d, [AssistantPermissions p = const AssistantPermissions()]) => AssistantContext(d, p);

    test('add task proposes create_task', () {
      final r = LocalAssistantEngine(ar).respond('أضف مهمة مراجعة الإنجليزية غدًا الساعة 8 مساءً', ctx(const AppData()), now);
      expect(r.calls.single.tool, Tools.createTask);
      expect(r.calls.single.args['dueTime'], 20 * 60);
    });

    test('ambiguous time asks a question with two suggestions', () {
      final r = LocalAssistantEngine(ar).respond('أضف مهمة مراجعة غدًا الساعة 8', ctx(const AppData()), now);
      expect(r.calls, isEmpty);
      expect(r.suggestions, hasLength(2));
    });

    test('learn goal proposes create_goal with milestones and tasks (doc example)', () {
      final r = LocalAssistantEngine(ar).respond('أبي أتعلم الإنجليزية وأخصص لها 30 دقيقة كل يوم', ctx(const AppData()), now);
      final call = r.calls.single;
      expect(call.tool, Tools.createGoal);
      expect(call.args['title'], 'تعلم الإنجليزية');
      expect(call.args['milestones'], hasLength(4));
      expect((call.args['tasks'] as List).first['estimatedMinutes'], 30);
      expect(r.kind, MessageKind.proposal);
    });

    test('learn goal subject stops before numbers', () {
      final r = LocalAssistantEngine(ar).respond('أبي أتعلم الإنجليزية 30 دقيقة كل يوم', ctx(const AppData()), now);
      expect(r.calls.single.args['title'], 'تعلم الإنجليزية');
      final e = LocalAssistantEngine(en).respond('I want to learn Spanish 20 minutes every day for 60 days', ctx(const AppData()), now);
      expect(e.calls.single.args['title'], 'Learn Spanish');
      expect(((e.calls.single.args['tasks'] as List).first as Map)['estimatedMinutes'], 20);
      expect(e.calls.single.args['targetDate'], '2026-05-09');
    });

    test('plan day respects task sharing permission', () {
      final t = Task(id: 't', title: 'x', estimatedMinutes: 20, createdAt: now, updatedAt: now);
      final d = AppData(tasks: [t]);
      final off = LocalAssistantEngine(en).respond('plan my day', ctx(d, const AssistantPermissions(shareTasks: false)), now);
      expect(off.calls, isEmpty);
      final on = LocalAssistantEngine(en).respond('plan my day', ctx(d), now);
      expect(on.calls.single.tool, Tools.planTask);
    });

    test('engine never sees notes when sharing is off', () {
      final c = AssistantContext(AppData(goals: [Goal(id: 'g', title: 'G', createdAt: now, updatedAt: now)]),
          const AssistantPermissions(shareGoals: false));
      expect(c.goals, isEmpty);
      expect(c.filtered.notes, isEmpty);
    });

    test('unknown request is unsupported, not guessed', () {
      final r = LocalAssistantEngine(en).respond('book me a flight to Paris', ctx(const AppData()), now);
      expect(r.calls, isEmpty);
      expect(r.kind, MessageKind.info);
    });
  });

  group('policy', () {
    test('bulk changes always need approval', () {
      const p = ToolPolicy(AssistantPermissions(autoCreateTasks: true));
      expect(p.tierOf([const ToolCall(Tools.createTask, {'title': 'a'})]), Tier.autoAllowed);
      expect(
        p.tierOf([const ToolCall(Tools.createTask, {'title': 'a'}), const ToolCall(Tools.createTask, {'title': 'b'})]),
        Tier.approvalRequired,
      );
    });

    test('delete always needs approval', () {
      const p = ToolPolicy(AssistantPermissions(autoCreateTasks: true, approveReschedule: false));
      expect(p.tierOf([const ToolCall(Tools.deleteTask, {'taskId': 'x'})]), Tier.approvalRequired);
    });

    test('auto create is off by default', () {
      const p = ToolPolicy(AssistantPermissions());
      expect(p.tierOf([const ToolCall(Tools.createTask, {'title': 'a'})]), Tier.approvalRequired);
    });
  });

  test('validateCall rejects unknown tools and args', () {
    expect(validateCall(const ToolCall('run_sql', {}), const AppData()), 'unknown_tool');
    expect(validateCall(const ToolCall(Tools.createTask, {'title': 'a', 'userId': 'x'}), const AppData()), 'unknown_args');
    expect(validateCall(const ToolCall(Tools.createTask, {'title': ' '}), const AppData()), 'title');
    expect(validateCall(const ToolCall(Tools.deleteTask, {'taskId': 'someone-else'}), const AppData()), 'taskId');
  });
}
