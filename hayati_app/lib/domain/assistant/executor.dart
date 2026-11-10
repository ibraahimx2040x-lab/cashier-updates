import '../../core/utils/dates.dart';
import '../../data/data_controller.dart';
import '../../data/models/alarm.dart';
import '../../data/models/assistant.dart';
import '../../data/models/fitness.dart';
import '../../data/models/goal.dart';
import '../../data/models/health.dart';
import '../../data/models/misc.dart';
import '../../data/models/money.dart';
import '../../data/models/settings.dart';
import '../../data/models/task.dart';
import '../../data/models/womens.dart';
import '../fitness/plan_generator.dart';
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
    final d = data.snapshot;
    final currency = d.settings.currency;
    int minor(Object? v) => ((v as num) * 100).round();
    DateTime at(Object? v) => DateTime.parse(v as String).toLocal();
    DateTime dayOr(Object? v) {
      if (v == null) return now();
      final n = now();
      return atMinutes(parseDayKey(v as String), n.hour * 60 + n.minute);
    }

    switch (c.tool) {
      case Tools.updateTask:
        final t = d.task(a['taskId'] as String)!;
        data.saveTask(t.copyWith(
          title: (a['title'] as String?)?.trim(),
          dueDate: a.containsKey('dueDate') ? () => a['dueDate'] as String? : null,
          dueTime: a.containsKey('dueTime') ? () => a['dueTime'] as int? : null,
          estimatedMinutes: a.containsKey('estimatedMinutes') ? () => a['estimatedMinutes'] as int? : null,
          priority: a['priority'] == null ? null : Priority.values.byName(a['priority'] as String),
        ));
        if (a['status'] != null) data.setTaskStatus(t.id, TaskStatus.values.byName(a['status'] as String));
      case Tools.createEvent:
        data.saveEvent(CalendarEvent(
          id: newId(),
          title: (a['title'] as String).trim(),
          start: at(a['start']),
          end: at(a['end']),
          location: (a['location'] as String?) ?? '',
          reminderMinutesBefore: a['reminderMinutes'] as int?,
          updatedAt: now(),
        ));
      case Tools.deleteEvent:
        data.deleteEvent(a['eventId'] as String);
      case Tools.createAlarm:
        final days = ((a['weekdays'] as List?) ?? const []).cast<int>().toSet();
        final minutes = a['time'] as int;
        final n = now();
        // A one-time alarm with no date rings at the next occurrence.
        final onDate = days.isNotEmpty
            ? null
            : (a['date'] as String?) ?? dayKey(minutes > n.hour * 60 + n.minute ? n : n.add(const Duration(days: 1)));
        data.saveAlarm(Alarm(
          id: newId(),
          label: (a['label'] as String?)?.trim() ?? '',
          minutes: minutes,
          weekdays: days,
          onDate: onDate,
          updatedAt: n,
        ));
      case Tools.deleteAlarm:
        data.deleteAlarm(a['alarmId'] as String);
      case Tools.setGoalStatus:
        data.setGoalStatus(a['goalId'] as String, GoalStatus.values.byName(a['status'] as String));
      case Tools.createHabit:
        data.saveHabit(Habit(
          id: newId(),
          name: (a['name'] as String).trim(),
          weekdays: (a['weekdays'] as List).cast<int>().toSet(),
          startDate: dayKey(now()),
          reminderMinutes: a['reminderTime'] as int?,
        ));
      case Tools.addExpense:
        data.addExpense(Expense(
          id: newId(),
          amountMinor: minor(a['amount']),
          currency: currency,
          category: a['category'] as String,
          spentAt: dayOr(a['date']),
          description: (a['description'] as String?)?.trim() ?? '',
        ));
      case Tools.addIncome:
        data.saveIncome(Income(
          id: newId(),
          amountMinor: minor(a['amount']),
          currency: currency,
          source: (a['source'] as String?)?.trim() ?? '',
          receivedAt: dayOr(a['date']),
        ));
      case Tools.addRecurring:
        data.saveRecurring(RecurringItem(
          id: newId(),
          kind: RecurringKind.values.byName(a['kind'] as String),
          amountMinor: minor(a['amount']),
          currency: currency,
          category: (a['category'] as String?) ?? 'other',
          title: (a['title'] as String).trim(),
          dayOfMonth: a['dayOfMonth'] as int,
          startsOn: dayKey(now()),
          updatedAt: now(),
        ));
      case Tools.setBudget:
        final cat = a['category'] as String?;
        final existing = d.budgets.where((b) => b.currency == currency && b.category == cat).firstOrNull;
        data.saveBudget(Budget(id: existing?.id ?? newId(), currency: currency, limitMinor: minor(a['limit']), category: cat));
      case Tools.addMeasurement:
        data.addMetric(
          kind: MetricKind.values.byName(a['kind'] as String),
          value: (a['value'] as num).toDouble(),
          value2: (a['value2'] as num?)?.toDouble(),
        );
      case Tools.logSleep:
        data.addSleep(start: at(a['start']), end: at(a['end']), quality: a['quality'] as int?);
      case Tools.setWorkoutPlan:
        _setWorkoutPlan(a);
      case Tools.setWeeklyLessons:
        data.setWeeklyLessons(a['lessons'] as int);
      case Tools.setNotifications:
        final section = NotifySection.values.byName(a['section'] as String);
        data.updateSettings((s) {
          final on = a['enabled'] as bool;
          final off = {...s.notify.off};
          on ? off.remove(section) : off.add(section);
          final times = {...s.notify.times};
          if (a['time'] != null) times[section] = a['time'] as int;
          return s.copyWith(notify: s.notify.copyWith(off: off, times: times));
        });
      case Tools.openScreen:
        break; // The screen opens it after the batch runs.
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

  /// Replaces the weekly plan for one place with the user's own days; keeps
  /// the rest of the training profile, or starts one.
  void _setWorkoutPlan(Map<String, Object?> a) {
    final place = WorkoutPlace.values.byName(a['place'] as String);
    final days = [
      for (final raw in (a['days'] as List).cast<Map>())
        () {
          final list = [
            for (final x in (raw['exercises'] as List).cast<Map>())
              PlannedExercise(
                exerciseId: x['exerciseId'] as String,
                sets: x['sets'] as int,
                reps: x['reps'] as int?,
                seconds: x['seconds'] as int?,
                restSeconds: (x['rest'] as int?) ?? 45,
              ),
          ];
          return WorkoutDay(
            weekday: raw['weekday'] as int,
            focus: raw['focus'] == null ? DayFocus.fullBody : DayFocus.values.byName(raw['focus'] as String),
            exercises: list,
            minutes: PlanGenerator.minutesOf(list),
          );
        }(),
    ]..sort((x, y) => x.weekday.compareTo(y.weekday));
    final old = data.snapshot.settings.fitness;
    final minutes = days.map((x) => x.minutes).reduce((m, x) => x > m ? x : m);
    final profile = FitnessProfile(
      goal: old?.goal ?? FitnessGoal.general,
      level: old?.level ?? FitnessLevel.beginner,
      daysPerWeek: days.length,
      minutesPerSession: old?.minutesPerSession ?? minutes,
      weekdays: [for (final x in days) x.weekday],
      places: {...?old?.places, place},
      homeEquipment: old?.homeEquipment ?? const {},
      preferredPlace: place,
    );
    data.saveFitness(profile, {place: days});
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
