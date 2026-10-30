import '../../core/utils/dates.dart';
import '../../data/data_controller.dart';
import '../../data/models/assistant.dart';
import '../../data/models/goal.dart';
import '../../data/models/misc.dart';
import '../../data/models/task.dart';
import '../../data/models/womens.dart';
import 'tools.dart';

enum ExecOutcome { executed, alreadyExecuted, stale, invalid, failed, notPending }

class ExecResult {
  const ExecResult(this.outcome, {this.count = 0, this.error, this.undo = const []});
  final ExecOutcome outcome;
  final int count;
  final String? error;

  /// Tasks as they were before execution, for "undo" on reschedules.
  final List<Task> undo;
  bool get ok => outcome == ExecOutcome.executed || outcome == ExecOutcome.alreadyExecuted;
}

/// Executes assistant tool calls. All calls of a proposal are validated
/// first, then applied in a single transaction: either all succeed or none.
class AssistantExecutor {
  AssistantExecutor(this.data, this.now);

  final DataController data;
  final DateTime Function() now;

  /// Approves and runs a saved proposal.
  ExecResult executeProposal(String proposalId) {
    final p = data.snapshot.proposal(proposalId);
    if (p == null) return const ExecResult(ExecOutcome.invalid, error: 'not_found');
    if (p.status == ProposalStatus.executed) return const ExecResult(ExecOutcome.alreadyExecuted);
    if (p.status != ProposalStatus.pending) return const ExecResult(ExecOutcome.notPending);

    // Data changed since the preview was generated → re-verify.
    for (final e in p.snapshot.entries) {
      if (versionOf(data.snapshot, e.key) != e.value) {
        data.saveProposal(p.copyWith(status: ProposalStatus.stale, decidedAt: now()));
        return const ExecResult(ExecOutcome.stale);
      }
    }
    final r = run(p.calls, proposalId: p.id);
    data.saveProposal(p.copyWith(
      status: r.ok ? ProposalStatus.executed : ProposalStatus.failed,
      decidedAt: now(),
      result: r.error ?? '${r.count}',
    ));
    return r;
  }

  void reject(String proposalId) {
    final p = data.snapshot.proposal(proposalId);
    if (p == null || p.status != ProposalStatus.pending) return;
    data.saveProposal(p.copyWith(status: ProposalStatus.rejected, decidedAt: now()));
  }

  /// Validates then applies [calls] atomically.
  ExecResult run(List<ToolCall> calls, {String? proposalId, bool auto = false}) {
    for (final c in calls) {
      final err = validateCall(c, data.snapshot);
      if (err != null) {
        _log(c.tool, false, proposalId, auto, err);
        return ExecResult(ExecOutcome.invalid, error: '${c.tool}:$err');
      }
    }
    final touched = <Task>[
      for (final c in calls)
        if (c.args['taskId'] is String) data.snapshot.task(c.args['taskId'] as String)!,
    ];
    try {
      data.transaction(() {
        for (final c in calls) {
          _apply(c);
        }
      });
    } catch (e) {
      for (final c in calls) {
        _log(c.tool, false, proposalId, auto, 'rolled_back');
      }
      return ExecResult(ExecOutcome.failed, error: e.toString());
    }
    for (final c in calls) {
      _log(c.tool, true, proposalId, auto, null);
    }
    return ExecResult(ExecOutcome.executed, count: calls.length, undo: touched);
  }

  void _apply(ToolCall c) {
    final a = c.args;
    switch (c.tool) {
      case Tools.createTask:
        data.saveTask(data.newTask(
          title: (a['title'] as String).trim(),
          dueDate: a['dueDate'] as String?,
          dueTime: a['dueTime'] as int?,
          estimatedMinutes: a['estimatedMinutes'] as int?,
          priority: a['priority'] == null ? Priority.medium : Priority.values.byName(a['priority'] as String),
          goalId: a['goalId'] as String?,
        ));
      case Tools.addNote:
        final body = (a['body'] as String).trim();
        data.saveNote(Note(
          id: newId(),
          title: (a['title'] as String?)?.trim().isNotEmpty == true
              ? (a['title'] as String).trim()
              : (body.length > 40 ? '${body.substring(0, 40)}…' : body),
          body: body,
          updatedAt: now(),
        ));
      case Tools.logHabit:
        data.setHabitDone(a['habitId'] as String, a['day'] as String, true);
      case Tools.planTask:
        final t = data.snapshot.task(a['taskId'] as String)!;
        data.saveTask(t.copyWith(plannedStart: () => DateTime.parse(a['plannedStart'] as String).toLocal()));
      case Tools.moveTask:
        final t = data.snapshot.task(a['taskId'] as String)!;
        data.saveTask(t.copyWith(dueDate: () => a['dueDate'] as String));
      case Tools.deleteTask:
        data.deleteTask(a['taskId'] as String);
      case Tools.logWater:
        data.addWater((a['day'] as String?) ?? dayKey(now()), a['ml'] as int);
      case Tools.addAppointment:
        data.saveAppointment(HealthAppointment(
          id: newId(),
          title: (a['title'] as String).trim(),
          at: DateTime.parse(a['at'] as String).toLocal(),
          reminderMinutes: 60,
          updatedAt: now(),
        ));
      case Tools.addMilestones:
        final g = data.snapshot.goal(a['goalId'] as String)!;
        final existing = data.snapshot.milestonesOf(g.id);
        data.saveGoal(g, [
          ...existing,
          for (final t in (a['titles'] as List).cast<String>())
            Milestone(id: newId(), goalId: g.id, title: t, order: 0),
        ]);
      case Tools.createGoal:
        final n = now();
        final goal = Goal(
          id: newId(),
          title: (a['title'] as String).trim(),
          why: (a['why'] as String?) ?? '',
          category: a['category'] == null
              ? GoalCategory.learning
              : GoalCategory.values.byName(a['category'] as String),
          startDate: dayKey(n),
          targetDate: a['targetDate'] as String?,
          createdAt: n,
          updatedAt: n,
        );
        final ms = [
          for (final t in (a['milestones'] as List).cast<String>())
            Milestone(id: newId(), goalId: goal.id, title: t, order: 0),
        ];
        data.saveGoal(goal, ms);
        final saved = data.snapshot.milestonesOf(goal.id);
        for (final raw in ((a['tasks'] as List?) ?? const [])) {
          final t = (raw as Map).cast<String, Object?>();
          final mi = t['milestone'] as int?;
          data.saveTask(data.newTask(
            title: t['title'] as String,
            dueDate: t['dueDate'] as String?,
            estimatedMinutes: t['estimatedMinutes'] as int?,
            goalId: goal.id,
            milestoneId: mi != null && mi < saved.length ? saved[mi].id : null,
          ));
        }
      default:
        throw StateError('unknown tool ${c.tool}');
    }
  }

  void _log(String tool, bool ok, String? proposalId, bool auto, String? error) => data.logAction(ActionLog(
        id: newId(),
        tool: tool,
        ok: ok,
        at: now(),
        proposalId: proposalId,
        auto: auto,
        error: error,
      ));
}
