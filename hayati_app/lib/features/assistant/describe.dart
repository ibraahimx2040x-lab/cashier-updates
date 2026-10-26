import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/app_data.dart';
import '../../data/models/assistant.dart';
import '../../data/models/task.dart';
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
  }
  return CallDescription(c.tool, '', const []);
}
