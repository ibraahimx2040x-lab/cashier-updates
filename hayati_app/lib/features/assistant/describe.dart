import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/app_data.dart';
import '../../data/models/assistant.dart';
import '../../data/models/fitness.dart';
import '../../data/models/health.dart';
import '../../data/models/settings.dart';
import '../../data/models/task.dart';
import '../../domain/fitness/exercises.dart';
import '../../domain/assistant/tools.dart';
import '../../l10n/app_localizations.dart';

class ChangeLine {
  const ChangeLine(this.label, this.next, {this.current});
  final String label;
  final String? current;
  final String next;
}

class CallDescription {
  const CallDescription(this.title, this.subject, this.lines);
  final String title;
  final String subject;
  final List<ChangeLine> lines;
}

/// Human-readable description of a tool call, with current → new values
/// for edits of existing records (screen 14).
CallDescription describeCall(ToolCall c, AppData d, AppLocalizations l, Fmt fmt) {
  final a = c.args;
  final task = d.task(a['taskId'] as String?);
  String dt(String? iso) => iso == null ? l.notSet : fmt.dateTime(DateTime.parse(iso).toLocal());
  String day(String? k) => k == null ? l.notSet : fmt.day(k);
  switch (c.tool) {
    case Tools.createTask:
      return CallDescription(l.toolName(c.tool), a['title'] as String, [
        if (a['dueDate'] != null) ChangeLine(l.deadlineDate, day(a['dueDate'] as String)),
        if (a['dueTime'] != null) ChangeLine(l.deadlineTime, fmt.minutesOfDay(a['dueTime'] as int)),
        if (a['estimatedMinutes'] != null) ChangeLine(l.estimatedMinutes, l.durationShort(a['estimatedMinutes'] as int)),
        if (a['priority'] != null) ChangeLine(l.priorityLabel, l.priority(Priority.values.byName(a['priority'] as String))),
      ]);
    case Tools.addNote:
      return CallDescription(l.toolName(c.tool), a['body'] as String, const []);
    case Tools.logHabit:
      return CallDescription(l.toolName(c.tool), d.habit(a['habitId'] as String?)?.name ?? '?', [
        ChangeLine(l.date, day(a['day'] as String?)),
      ]);
    case Tools.planTask:
      return CallDescription(l.toolName(c.tool), task?.title ?? '?', [
        ChangeLine(l.plannedTime, dt(a['plannedStart'] as String?), current: dt(encodeInstant(task?.plannedStart))),
      ]);
    case Tools.moveTask:
      return CallDescription(l.toolName(c.tool), task?.title ?? '?', [
        ChangeLine(l.deadlineDate, day(a['dueDate'] as String?), current: day(task?.dueDate)),
      ]);
    case Tools.deleteTask:
      return CallDescription(l.toolName(c.tool), task?.title ?? '?', const []);
    case Tools.logWater:
      return CallDescription(l.toolName(c.tool), l.waterMl('${a['ml']}'), [ChangeLine(l.date, day(a['day'] as String?))]);
    case Tools.addAppointment:
      return CallDescription(l.toolName(c.tool), a['title'] as String, [ChangeLine(l.date, dt(a['at'] as String?))]);
    case Tools.addMilestones:
      return CallDescription(l.toolName(c.tool), d.goal(a['goalId'] as String?)?.title ?? '?', [
        for (final t in (a['titles'] as List).cast<String>()) ChangeLine(l.milestone, t),
      ]);
    case Tools.createGoal:
      final tasks = (a['tasks'] as List?) ?? const [];
      final first = tasks.isEmpty ? null : (tasks.first as Map);
      return CallDescription(l.toolName(c.tool), a['title'] as String, [
        if (a['targetDate'] != null) ChangeLine(l.targetDate, day(a['targetDate'] as String)),
        for (final t in (a['milestones'] as List).cast<String>()) ChangeLine(l.milestone, t),
        if (tasks.isNotEmpty) ChangeLine(l.initialTasks, l.tasksCount(tasks.length)),
        if (first?['estimatedMinutes'] != null) ChangeLine(l.sessionLength, l.durationShort(first!['estimatedMinutes'] as int)),
      ]);
    case Tools.updateTask:
      return CallDescription(l.toolName(c.tool), task?.title ?? '?', [
        if (a['title'] != null) ChangeLine(l.fieldTitle, a['title'] as String, current: task?.title),
        if (a.containsKey('dueDate')) ChangeLine(l.deadlineDate, day(a['dueDate'] as String?), current: day(task?.dueDate)),
        if (a['dueTime'] != null) ChangeLine(l.deadlineTime, fmt.minutesOfDay(a['dueTime'] as int)),
        if (a['estimatedMinutes'] != null) ChangeLine(l.estimatedMinutes, l.durationShort(a['estimatedMinutes'] as int)),
        if (a['priority'] != null) ChangeLine(l.priorityLabel, l.priority(Priority.values.byName(a['priority'] as String))),
        if (a['status'] != null) ChangeLine(l.statusLabel, l.taskStatus(TaskStatus.values.byName(a['status'] as String))),
      ]);
    case Tools.createEvent:
      return CallDescription(l.toolName(c.tool), a['title'] as String, [
        ChangeLine(l.date, dt(a['start'] as String?)),
        if (a['location'] != null) ChangeLine(l.placeLabel, a['location'] as String),
      ]);
    case Tools.deleteEvent:
      return CallDescription(l.toolName(c.tool), d.event(a['eventId'] as String?)?.title ?? '?', const []);
    case Tools.createAlarm:
      final days = ((a['weekdays'] as List?) ?? const []).cast<int>();
      return CallDescription(l.toolName(c.tool), (a['label'] as String?) ?? fmt.minutesOfDay(a['time'] as int), [
        ChangeLine(l.time, fmt.minutesOfDay(a['time'] as int)),
        if (days.isNotEmpty) ChangeLine(l.repeatsOn, [for (final w in days) l.weekdayShort(w)].join('، ')),
        if (a['date'] != null) ChangeLine(l.date, day(a['date'] as String)),
      ]);
    case Tools.deleteAlarm:
      final al = d.alarms.where((x) => x.id == a['alarmId']).firstOrNull;
      return CallDescription(l.toolName(c.tool), al == null ? '?' : '${fmt.minutesOfDay(al.minutes)} ${al.label}', const []);
    case Tools.setGoalStatus:
      return CallDescription(l.toolName(c.tool), d.goal(a['goalId'] as String?)?.title ?? '?', [
        ChangeLine(l.statusLabel, '${a['status']}'),
      ]);
    case Tools.createHabit:
      return CallDescription(l.toolName(c.tool), a['name'] as String, [
        ChangeLine(l.repeatsOn, [for (final w in (a['weekdays'] as List).cast<int>()) l.weekdayShort(w)].join('، ')),
      ]);
    case Tools.addExpense:
    case Tools.addIncome:
    case Tools.addRecurring:
    case Tools.setBudget:
      final amount = ((a['amount'] ?? a['limit']) as num);
      return CallDescription(
        l.toolName(c.tool),
        (a['description'] ?? a['source'] ?? a['title'] ?? (a['category'] == null ? '' : l.expenseCategory(a['category'] as String))) as String,
        [
          ChangeLine(l.amountLabel, fmt.money((amount * 100).round(), d.settings.currency)),
          if (a['category'] != null) ChangeLine(l.category, l.expenseCategory(a['category'] as String)),
          if (a['dayOfMonth'] != null) ChangeLine(l.date, '${a['dayOfMonth']}'),
          if (a['date'] != null) ChangeLine(l.date, day(a['date'] as String)),
        ],
      );
    case Tools.addMeasurement:
      final kind = MetricKind.values.byName(a['kind'] as String);
      return CallDescription(l.toolName(c.tool), l.metricKind(kind), [
        ChangeLine(l.amountLabel, a['value2'] == null ? '${a['value']}' : '${a['value']}/${a['value2']}'),
      ]);
    case Tools.logSleep:
      return CallDescription(l.toolName(c.tool), '${dt(a['start'] as String?)} → ${dt(a['end'] as String?)}', const []);
    case Tools.setWorkoutPlan:
      final days = (a['days'] as List).cast<Map>();
      return CallDescription(l.toolName(c.tool), l.workoutPlace(WorkoutPlace.values.byName(a['place'] as String)), [
        for (final x in days)
          ChangeLine(
            l.weekdayShort(x['weekday'] as int),
            [for (final e in (x['exercises'] as List).cast<Map>()) exerciseById('${e['exerciseId']}')?.name(l.localeName) ?? '?'].join('، '),
          ),
      ]);
    case Tools.setWeeklyLessons:
      return CallDescription(l.toolName(c.tool), '${a['lessons']}', const []);
    case Tools.setNotifications:
      final section = NotifySection.values.byName(a['section'] as String);
      return CallDescription(l.toolName(c.tool), l.notifySection(section), [
        ChangeLine(l.statusLabel, a['enabled'] == true ? l.switchedOn : l.switchedOff),
        if (a['time'] != null) ChangeLine(l.time, fmt.minutesOfDay(a['time'] as int)),
      ]);
    case Tools.openScreen:
      return CallDescription(l.toolName(c.tool), '${a['screen']}', const []);
  }
  return CallDescription(c.tool, '', const []);
}
