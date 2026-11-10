import '../../core/utils/dates.dart';
import '../../data/app_data.dart';
import '../../data/models/assistant.dart';
import '../../data/models/fitness.dart';
import '../../data/models/goal.dart';
import '../../data/models/health.dart';
import '../../data/models/settings.dart';
import '../../data/models/task.dart';
import '../fitness/exercises.dart';

/// The assistant may only call these tools, with these argument shapes.
/// The cloud model sees the same list (`toolDeclarations` in catalog.dart);
/// every call is validated here against the user's own records before it
/// runs on the device.
abstract final class Tools {
  // Time
  static const createTask = 'create_task';
  static const updateTask = 'update_task';
  static const deleteTask = 'delete_task';
  static const planTask = 'plan_task';
  static const moveTask = 'move_task';
  static const createEvent = 'create_event';
  static const deleteEvent = 'delete_event';
  static const createAlarm = 'create_alarm';
  static const deleteAlarm = 'delete_alarm';
  // Goals, habits, notes
  static const createGoal = 'create_goal';
  static const addMilestones = 'add_milestones';
  static const setGoalStatus = 'set_goal_status';
  static const createHabit = 'create_habit';
  static const logHabit = 'log_habit';
  static const addNote = 'add_note';
  // Money
  static const addExpense = 'add_expense';
  static const addIncome = 'add_income';
  static const addRecurring = 'add_recurring';
  static const setBudget = 'set_budget';
  // Health and fitness
  static const logWater = 'log_water';
  static const addAppointment = 'add_appointment';
  static const addMeasurement = 'add_measurement';
  static const logSleep = 'log_sleep';
  static const setWorkoutPlan = 'set_workout_plan';
  // Learning and settings
  static const setWeeklyLessons = 'set_weekly_lessons';
  static const setNotifications = 'set_notifications';
  static const openScreen = 'open_screen';

  static const all = {
    createTask, updateTask, deleteTask, planTask, moveTask, createEvent, deleteEvent, createAlarm, deleteAlarm,
    createGoal, addMilestones, setGoalStatus, createHabit, logHabit, addNote,
    addExpense, addIncome, addRecurring, setBudget,
    logWater, addAppointment, addMeasurement, logSleep, setWorkoutPlan,
    setWeeklyLessons, setNotifications, openScreen,
  };
}

/// Screens the assistant can open, by name.
const assistantScreens = <String, String>{
  'home': '/home',
  'tasks': '/time?tab=tasks',
  'calendar': '/time?tab=calendar',
  'planner': '/time?tab=planner',
  'goals': '/goals',
  'habits': '/habits',
  'notes': '/notes',
  'money': '/expenses',
  'alarms': '/alarms',
  'progress': '/progress',
  'fitness': '/fitness',
  'exercise_library': '/fitness/library',
  'nutrition': '/nutrition',
  'activity': '/activity',
  'sleep': '/health/sleep',
  'vitals': '/health/vitals',
  'appointments': '/health/appointments',
  'prayer': '/prayer',
  'english': '/english',
  'settings': '/settings',
  'notification_settings': '/settings/notifications',
};

/// Capability tiers from section 16.
enum Tier { autoAllowed, approvalRequired }

class ToolPolicy {
  const ToolPolicy(this.perms);
  final AssistantPermissions perms;

  /// Tier for a whole batch. More than one call is a bulk change and always
  /// needs approval; deletes, money, plans and settings always need approval.
  Tier tierOf(List<ToolCall> calls) {
    if (calls.length != 1) return Tier.approvalRequired;
    switch (calls.single.tool) {
      case Tools.createTask:
        return perms.autoCreateTasks ? Tier.autoAllowed : Tier.approvalRequired;
      case Tools.addNote:
        return perms.autoAddNotes ? Tier.autoAllowed : Tier.approvalRequired;
      case Tools.logHabit:
        return perms.autoLogHabits ? Tier.autoAllowed : Tier.approvalRequired;
      // The user asked for exactly this, and it is undone with one tap.
      case Tools.logWater:
      case Tools.openScreen:
        return Tier.autoAllowed;
      case Tools.planTask:
      case Tools.moveTask:
        return perms.approveReschedule ? Tier.approvalRequired : Tier.autoAllowed;
      default:
        return Tier.approvalRequired;
    }
  }
}

final _dayRe = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// Validates one call against its schema and the user's own records.
/// Returns an error code or null.
String? validateCall(ToolCall c, AppData data) {
  final a = c.args;
  if (!Tools.all.contains(c.tool)) return 'unknown_tool';
  final unknown = a.keys.toSet().difference(_allowedArgs[c.tool] ?? const {});
  if (unknown.isNotEmpty) return 'unknown_args';

  bool isStr(String k, {bool required = true, int max = 200}) {
    final v = a[k];
    if (v == null) return !required;
    return v is String && v.trim().isNotEmpty && v.length <= max;
  }

  bool isInt(String k, {int min = 0, int max = 1 << 31, bool required = false}) {
    final v = a[k];
    if (v == null) return !required;
    return v is int && v >= min && v <= max;
  }

  bool isNum(String k, {double min = 0, double max = 1e9, bool required = true}) {
    final v = a[k];
    if (v == null) return !required;
    return v is num && v > min && v <= max;
  }

  bool isDay(String k, {bool required = false}) {
    final v = a[k];
    if (v == null) return !required;
    return v is String && _dayRe.hasMatch(v);
  }

  bool isInstant(String k) => a[k] is String && DateTime.tryParse(a[k] as String) != null;
  bool isOneOf(String k, Iterable<String> values, {bool required = true}) {
    final v = a[k];
    if (v == null) return !required;
    return values.contains(v);
  }

  bool isWeekdays(String k, {bool required = false}) {
    final v = a[k];
    if (v == null) return !required;
    return v is List && v.isNotEmpty && v.every((x) => x is int && x >= 1 && x <= 7) && v.toSet().length == v.length;
  }

  bool ownsTask(String k) => data.task(a[k] as String?) != null;
  bool notFuture(String k) => a[k] == null || (a[k] as String).compareTo(dayKey(DateTime.now())) <= 0;

  switch (c.tool) {
    case Tools.createTask:
      if (!isStr('title')) return 'title';
      if (!isDay('dueDate')) return 'dueDate';
      if (!isInt('dueTime', max: 1439)) return 'dueTime';
      if (!isInt('estimatedMinutes', min: 1, max: 24 * 60)) return 'estimatedMinutes';
      if (!isOneOf('priority', Priority.values.map((e) => e.name), required: false)) return 'priority';
      if (a['goalId'] != null && data.goal(a['goalId'] as String?) == null) return 'goalId';
      return null;
    case Tools.updateTask:
      if (!ownsTask('taskId')) return 'taskId';
      if (!isStr('title', required: false)) return 'title';
      if (!isDay('dueDate')) return 'dueDate';
      if (!isInt('dueTime', max: 1439)) return 'dueTime';
      if (!isInt('estimatedMinutes', min: 1, max: 24 * 60)) return 'estimatedMinutes';
      if (!isOneOf('priority', Priority.values.map((e) => e.name), required: false)) return 'priority';
      if (!isOneOf('status', TaskStatus.values.map((e) => e.name), required: false)) return 'status';
      if (a.length < 2) return 'nothing';
      return null;
    case Tools.deleteTask:
      return ownsTask('taskId') ? null : 'taskId';
    case Tools.planTask:
      if (!ownsTask('taskId')) return 'taskId';
      return isInstant('plannedStart') ? null : 'plannedStart';
    case Tools.moveTask:
      if (!ownsTask('taskId')) return 'taskId';
      return isDay('dueDate', required: true) ? null : 'dueDate';
    case Tools.createEvent:
      if (!isStr('title')) return 'title';
      if (!isInstant('start')) return 'start';
      if (!isInstant('end') || !DateTime.parse(a['end'] as String).isAfter(DateTime.parse(a['start'] as String))) return 'end';
      if (!isStr('location', required: false)) return 'location';
      if (!isInt('reminderMinutes', max: 7 * 24 * 60)) return 'reminderMinutes';
      return null;
    case Tools.deleteEvent:
      return data.event(a['eventId'] as String?) == null ? 'eventId' : null;
    case Tools.createAlarm:
      if (!isInt('time', max: 1439, required: true)) return 'time';
      if (!isStr('label', required: false, max: 80)) return 'label';
      if (!isWeekdays('weekdays')) return 'weekdays';
      if (!isDay('date')) return 'date';
      return null;
    case Tools.deleteAlarm:
      return data.alarms.any((x) => x.id == a['alarmId']) ? null : 'alarmId';
    case Tools.createGoal:
      if (!isStr('title')) return 'title';
      if (!isDay('targetDate')) return 'targetDate';
      if (!isOneOf('category', GoalCategory.values.map((e) => e.name), required: false)) return 'category';
      final ms = a['milestones'];
      if (ms is! List || ms.any((e) => e is! String) || ms.length > 20) return 'milestones';
      final ts = a['tasks'];
      if (ts != null && (ts is! List || ts.length > 50 || ts.any((t) => t is! Map || t['title'] is! String))) return 'tasks';
      return null;
    case Tools.addMilestones:
      if (data.goal(a['goalId'] as String?) == null) return 'goalId';
      final ms = a['titles'];
      if (ms is! List || ms.isEmpty || ms.length > 20 || ms.any((e) => e is! String)) return 'titles';
      return null;
    case Tools.setGoalStatus:
      if (data.goal(a['goalId'] as String?) == null) return 'goalId';
      return isOneOf('status', const ['active', 'paused', 'completed']) ? null : 'status';
    case Tools.createHabit:
      if (!isStr('name', max: 80)) return 'name';
      if (!isWeekdays('weekdays', required: true)) return 'weekdays';
      if (!isInt('reminderTime', max: 1439)) return 'reminderTime';
      return null;
    case Tools.logHabit:
      if (data.habit(a['habitId'] as String?) == null) return 'habitId';
      return isDay('day', required: true) && notFuture('day') ? null : 'day';
    case Tools.addNote:
      if (!isStr('title', required: false)) return 'title';
      return isStr('body', max: 20000) ? null : 'body';
    case Tools.addExpense:
      if (!isNum('amount')) return 'amount';
      if (!isOneOf('category', expenseCategoryIds)) return 'category';
      if (!isStr('description', required: false)) return 'description';
      return isDay('date') && notFuture('date') ? null : 'date';
    case Tools.addIncome:
      if (!isNum('amount')) return 'amount';
      if (!isStr('source', required: false)) return 'source';
      return isDay('date') && notFuture('date') ? null : 'date';
    case Tools.addRecurring:
      if (!isOneOf('kind', const ['expense', 'income'])) return 'kind';
      if (!isNum('amount')) return 'amount';
      if (!isStr('title')) return 'title';
      if (!isOneOf('category', expenseCategoryIds, required: false)) return 'category';
      return isInt('dayOfMonth', min: 1, max: 28, required: true) ? null : 'dayOfMonth';
    case Tools.setBudget:
      if (!isNum('limit')) return 'limit';
      return isOneOf('category', expenseCategoryIds, required: false) ? null : 'category';
    case Tools.logWater:
      if (!isInt('ml', min: 50, max: 1000, required: true)) return 'ml';
      return isDay('day') && notFuture('day') ? null : 'day';
    case Tools.addAppointment:
      if (!isStr('title', max: 120)) return 'title';
      return isInstant('at') ? null : 'at';
    case Tools.addMeasurement:
      if (!isOneOf('kind', MetricKind.values.map((e) => e.name))) return 'kind';
      if (!isNum('value', max: 1000)) return 'value';
      return isNum('value2', max: 1000, required: false) ? null : 'value2';
    case Tools.logSleep:
      if (!isInstant('start') || !isInstant('end')) return 'time';
      final h = DateTime.parse(a['end'] as String).difference(DateTime.parse(a['start'] as String)).inMinutes;
      if (h < 30 || h > 16 * 60) return 'duration';
      return isInt('quality', min: 1, max: 5) ? null : 'quality';
    case Tools.setWorkoutPlan:
      if (!isOneOf('place', WorkoutPlace.values.map((e) => e.name))) return 'place';
      final days = a['days'];
      if (days is! List || days.isEmpty || days.length > 7) return 'days';
      final seen = <int>{};
      for (final raw in days) {
        if (raw is! Map) return 'days';
        final w = raw['weekday'];
        if (w is! int || w < 1 || w > 7 || !seen.add(w)) return 'weekday';
        if (raw['focus'] != null && !DayFocus.values.any((f) => f.name == raw['focus'])) return 'focus';
        final xs = raw['exercises'];
        if (xs is! List || xs.isEmpty || xs.length > 12) return 'exercises';
        for (final x in xs) {
          if (x is! Map || exerciseById('${x['exerciseId']}') == null) return 'exerciseId';
          final sets = x['sets'], reps = x['reps'], secs = x['seconds'];
          if (sets is! int || sets < 1 || sets > 10) return 'sets';
          if ((reps == null) == (secs == null)) return 'reps';
          if (reps != null && (reps is! int || reps < 1 || reps > 100)) return 'reps';
          if (secs != null && (secs is! int || secs < 5 || secs > 3600)) return 'seconds';
        }
      }
      return null;
    case Tools.setWeeklyLessons:
      if (data.learningPath == null) return 'not_started';
      return isInt('lessons', min: 1, max: 7, required: true) ? null : 'lessons';
    case Tools.setNotifications:
      if (!isOneOf('section', NotifySection.values.map((e) => e.name))) return 'section';
      if (a['enabled'] is! bool) return 'enabled';
      return isInt('time', max: 1439) ? null : 'time';
    case Tools.openScreen:
      return isOneOf('screen', assistantScreens.keys) ? null : 'screen';
  }
  return 'unknown_tool';
}

/// Expense categories the money screen knows.
const expenseCategoryIds = ['food', 'transport', 'shopping', 'education', 'bills', 'entertainment', 'other'];

const _allowedArgs = <String, Set<String>>{
  Tools.createTask: {'title', 'dueDate', 'dueTime', 'estimatedMinutes', 'priority', 'goalId'},
  Tools.updateTask: {'taskId', 'title', 'dueDate', 'dueTime', 'estimatedMinutes', 'priority', 'status'},
  Tools.deleteTask: {'taskId'},
  Tools.planTask: {'taskId', 'plannedStart'},
  Tools.moveTask: {'taskId', 'dueDate'},
  Tools.createEvent: {'title', 'start', 'end', 'location', 'reminderMinutes'},
  Tools.deleteEvent: {'eventId'},
  Tools.createAlarm: {'time', 'label', 'weekdays', 'date'},
  Tools.deleteAlarm: {'alarmId'},
  Tools.createGoal: {'title', 'category', 'targetDate', 'milestones', 'tasks', 'why'},
  Tools.addMilestones: {'goalId', 'titles'},
  Tools.setGoalStatus: {'goalId', 'status'},
  Tools.createHabit: {'name', 'weekdays', 'reminderTime'},
  Tools.logHabit: {'habitId', 'day'},
  Tools.addNote: {'title', 'body'},
  Tools.addExpense: {'amount', 'category', 'description', 'date'},
  Tools.addIncome: {'amount', 'source', 'date'},
  Tools.addRecurring: {'kind', 'amount', 'title', 'category', 'dayOfMonth'},
  Tools.setBudget: {'limit', 'category'},
  Tools.logWater: {'day', 'ml'},
  Tools.addAppointment: {'title', 'at'},
  Tools.addMeasurement: {'kind', 'value', 'value2'},
  Tools.logSleep: {'start', 'end', 'quality'},
  Tools.setWorkoutPlan: {'place', 'days'},
  Tools.setWeeklyLessons: {'lessons'},
  Tools.setNotifications: {'section', 'enabled', 'time'},
  Tools.openScreen: {'screen'},
};

/// Drops null optionals: the model sends unset values as null.
ToolCall compactCall(ToolCall c) {
  Object? clean(Object? v) => switch (v) {
        Map m => {for (final e in m.entries) if (e.value != null) '${e.key}': clean(e.value)},
        List l => [for (final x in l) clean(x)],
        double d when d == d.roundToDouble() && d.abs() < 1e12 => d.toInt(),
        _ => v,
      };
  return ToolCall(c.tool, (clean(c.args) as Map).cast<String, Object?>());
}

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
