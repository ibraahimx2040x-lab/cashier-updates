import '../../core/utils/dates.dart';
import '../../data/app_data.dart';
import '../../data/models/assistant.dart';
import '../../data/models/settings.dart';
import '../../data/models/task.dart';

/// The assistant may only call these tools, with these argument shapes.
/// The same contract is enforced server-side in
/// `supabase/functions/assistant/tools.ts`.
abstract final class Tools {
  static const createTask = 'create_task';
  static const addNote = 'add_note';
  static const logHabit = 'log_habit';
  static const planTask = 'plan_task';
  static const moveTask = 'move_task';
  static const createGoal = 'create_goal';
  static const addMilestones = 'add_milestones';
  static const deleteTask = 'delete_task';
  static const logWater = 'log_water';
  static const addAppointment = 'add_appointment';

  static const all = {
    createTask,
    addNote,
    logHabit,
    planTask,
    moveTask,
    createGoal,
    addMilestones,
    deleteTask,
    logWater,
    addAppointment,
  };
}

/// Capability tiers from section 16.
enum Tier { autoAllowed, approvalRequired }

class ToolPolicy {
  const ToolPolicy(this.perms);
  final AssistantPermissions perms;

  /// Tier for a whole batch. More than one call is a bulk change and always
  /// needs approval; deletes and goal changes always need approval.
  Tier tierOf(List<ToolCall> calls) {
    if (calls.length != 1) return Tier.approvalRequired;
    switch (calls.single.tool) {
      case Tools.createTask:
        return perms.autoCreateTasks ? Tier.autoAllowed : Tier.approvalRequired;
      case Tools.addNote:
        return perms.autoAddNotes ? Tier.autoAllowed : Tier.approvalRequired;
      case Tools.logHabit:
        return perms.autoLogHabits ? Tier.autoAllowed : Tier.approvalRequired;
      // The user asked for exactly this; it's a glass of water and can be
      // taken back with one tap.
      case Tools.logWater:
        return Tier.autoAllowed;
      case Tools.planTask:
      case Tools.moveTask:
        return perms.approveReschedule ? Tier.approvalRequired : Tier.autoAllowed;
      default:
        return Tier.approvalRequired;
    }
  }
}

/// Validates one call against its schema and the user's own records.
/// Returns an error code or null.
String? validateCall(ToolCall c, AppData data) {
  final a = c.args;
  bool isStr(String k, {bool required = true}) {
    final v = a[k];
    if (v == null) return !required;
    return v is String && v.trim().isNotEmpty;
  }

  bool isInt(String k, {int min = 0, int max = 1 << 31}) {
    final v = a[k];
    if (v == null) return true;
    return v is int && v >= min && v <= max;
  }

  bool isDay(String k) {
    final v = a[k];
    if (v == null) return true;
    return v is String && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v);
  }

  bool ownsTask(String k) => data.task(a[k] as String?) != null;

  final unknown = a.keys.toSet().difference(_allowedArgs[c.tool] ?? const {});
  if (!Tools.all.contains(c.tool)) return 'unknown_tool';
  if (unknown.isNotEmpty) return 'unknown_args';

  switch (c.tool) {
    case Tools.createTask:
      if (!isStr('title') || (a['title'] as String).length > 200) return 'title';
      if (!isDay('dueDate')) return 'dueDate';
      if (!isInt('dueTime', max: 1439)) return 'dueTime';
      if (!isInt('estimatedMinutes', min: 1, max: 24 * 60)) return 'estimatedMinutes';
      final p = a['priority'];
      if (p != null && !Priority.values.any((e) => e.name == p)) return 'priority';
      if (a['goalId'] != null && data.goal(a['goalId'] as String?) == null) return 'goalId';
      return null;
    case Tools.addNote:
      if (!isStr('body')) return 'body';
      return null;
    case Tools.logHabit:
      if (data.habit(a['habitId'] as String?) == null) return 'habitId';
      if (!isDay('day') || a['day'] == null) return 'day';
      return null;
    case Tools.planTask:
      if (!ownsTask('taskId')) return 'taskId';
      final s = a['plannedStart'];
      if (s is! String || DateTime.tryParse(s) == null) return 'plannedStart';
      return null;
    case Tools.moveTask:
      if (!ownsTask('taskId')) return 'taskId';
      if (a['dueDate'] == null || !isDay('dueDate')) return 'dueDate';
      return null;
    case Tools.createGoal:
      if (!isStr('title')) return 'title';
      if (!isDay('targetDate')) return 'targetDate';
      final ms = a['milestones'];
      if (ms is! List || ms.any((e) => e is! String) || ms.length > 20) return 'milestones';
      final ts = a['tasks'];
      if (ts != null && (ts is! List || ts.length > 50)) return 'tasks';
      return null;
    case Tools.addMilestones:
      if (data.goal(a['goalId'] as String?) == null) return 'goalId';
      final ms = a['titles'];
      if (ms is! List || ms.isEmpty || ms.any((e) => e is! String)) return 'titles';
      return null;
    case Tools.logWater:
      if (!isDay('day') || !isInt('ml', min: 50, max: 1000) || a['ml'] == null) return 'ml';
      if (a['day'] != null && (a['day'] as String).compareTo(dayKey(DateTime.now())) > 0) return 'day';
      return null;
    case Tools.addAppointment:
      if (!isStr('title') || (a['title'] as String).length > 120) return 'title';
      final at = DateTime.tryParse('${a['at']}');
      if (at == null) return 'at';
      return null;
    case Tools.deleteTask:
      if (!ownsTask('taskId')) return 'taskId';
      return null;
  }
  return 'unknown_tool';
}

const _allowedArgs = <String, Set<String>>{
  Tools.createTask: {'title', 'dueDate', 'dueTime', 'estimatedMinutes', 'priority', 'goalId'},
  Tools.addNote: {'title', 'body'},
  Tools.logHabit: {'habitId', 'day'},
  Tools.planTask: {'taskId', 'plannedStart'},
  Tools.moveTask: {'taskId', 'dueDate'},
  Tools.createGoal: {'title', 'category', 'targetDate', 'milestones', 'tasks', 'why'},
  Tools.addMilestones: {'goalId', 'titles'},
  Tools.deleteTask: {'taskId'},
  Tools.logWater: {'day', 'ml'},
  Tools.addAppointment: {'title', 'at'},
};

/// Record ids a call depends on, for staleness checks.
Iterable<String> referencedIds(ToolCall c) sync* {
  for (final k in const ['taskId', 'goalId', 'habitId']) {
    final v = c.args[k];
    if (v is String) yield v;
  }
}

/// `updatedAt` fingerprint for a record id, or null if not versioned.
String? versionOf(AppData d, String id) =>
    encodeInstant(d.task(id)?.updatedAt) ?? encodeInstant(d.goal(id)?.updatedAt);
