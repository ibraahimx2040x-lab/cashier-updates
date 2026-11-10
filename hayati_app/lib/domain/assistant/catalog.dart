import '../../core/utils/dates.dart';
import '../../data/app_data.dart';
import '../../data/models/fitness.dart';
import '../../data/models/goal.dart';
import '../../data/models/health.dart';
import '../../data/models/settings.dart';
import '../../data/models/task.dart';
import '../fitness/exercises.dart';
import 'tools.dart';

// Function declarations for the cloud model (Gemini function calling, an
// OpenAPI schema subset). Names and arguments match tools.dart, which
// validates every call before it runs.

Map<String, Object?> _str([String? d, List<String>? values]) =>
    {'type': 'STRING', 'description': ?d, 'enum': ?values};
Map<String, Object?> _int([String? d]) => {'type': 'INTEGER', 'description': ?d};
Map<String, Object?> _num([String? d]) => {'type': 'NUMBER', 'description': ?d};
Map<String, Object?> _arr(Map<String, Object?> items, [String? d]) => {'type': 'ARRAY', 'items': items, 'description': ?d};
Map<String, Object?> _obj(Map<String, Object?> props, [List<String> required = const []]) =>
    {'type': 'OBJECT', 'properties': props, if (required.isNotEmpty) 'required': required};
Map<String, Object?> _fn(String name, String description, Map<String, Object?> props, [List<String> required = const []]) =>
    {'name': name, 'description': description, 'parameters': _obj(props, required)};

final _day = _str('Calendar day YYYY-MM-DD in the user\'s time zone.');
final _instant = _str('Local date-time YYYY-MM-DDTHH:MM:SS with the user\'s UTC offset, e.g. 2026-11-10T20:00:00+03:00.');
final _minutes = _int('Minutes after midnight, e.g. 20:30 = 1230.');
final _weekdays = _arr(_int(), 'ISO weekdays: 1 = Monday … 7 = Sunday.');

final List<Map<String, Object?>> toolDeclarations = [
  _fn(Tools.createTask, 'Create a task. If the hour is ambiguous (AM/PM unclear), ask instead.', {
    'title': _str(),
    'dueDate': _day,
    'dueTime': _minutes,
    'estimatedMinutes': _int(),
    'priority': _str(null, ['low', 'medium', 'high']),
    'goalId': _str('Id of one of the user\'s goals.'),
  }, ['title']),
  _fn(Tools.updateTask, 'Change fields of an existing task, or mark it done (status "done") or cancelled.', {
    'taskId': _str(),
    'title': _str(),
    'dueDate': _day,
    'dueTime': _minutes,
    'estimatedMinutes': _int(),
    'priority': _str(null, ['low', 'medium', 'high']),
    'status': _str(null, TaskStatus.values.map((e) => e.name).toList()),
  }, ['taskId']),
  _fn(Tools.deleteTask, 'Delete one task.', {'taskId': _str()}, ['taskId']),
  _fn(Tools.planTask, 'Set when the user will work on a task (not its deadline). One call per task when planning a day; '
      'place tasks only in free time around events.', {'taskId': _str(), 'plannedStart': _instant}, ['taskId', 'plannedStart']),
  _fn(Tools.moveTask, 'Change a task\'s deadline day.', {'taskId': _str(), 'dueDate': _day}, ['taskId', 'dueDate']),
  _fn(Tools.createEvent, 'Add an appointment/event to the calendar.', {
    'title': _str(),
    'start': _instant,
    'end': _instant,
    'location': _str(),
    'reminderMinutes': _int('Remind this many minutes before.'),
  }, ['title', 'start', 'end']),
  _fn(Tools.deleteEvent, 'Delete one calendar event.', {'eventId': _str()}, ['eventId']),
  _fn(Tools.createAlarm, 'Set a sounding alarm. With weekdays it repeats; without, it rings once on date (or the next time it comes).', {
    'time': _minutes,
    'label': _str(),
    'weekdays': _weekdays,
    'date': _day,
  }, ['time']),
  _fn(Tools.deleteAlarm, 'Delete one alarm.', {'alarmId': _str()}, ['alarmId']),
  _fn(Tools.createGoal, 'Create a goal with ordered milestones and optionally its first tasks (at most the first week). '
      'Each task\'s milestone is the 0-based index of its milestone.', {
    'title': _str(),
    'category': _str(null, GoalCategory.values.map((e) => e.name).toList()),
    'targetDate': _day,
    'why': _str(),
    'milestones': _arr(_str()),
    'tasks': _arr(_obj({'title': _str(), 'dueDate': _day, 'estimatedMinutes': _int(), 'milestone': _int()}, ['title'])),
  }, ['title', 'milestones']),
  _fn(Tools.addMilestones, 'Append milestones to an existing goal.', {'goalId': _str(), 'titles': _arr(_str())}, ['goalId', 'titles']),
  _fn(Tools.setGoalStatus, 'Pause, resume or complete a goal.', {
    'goalId': _str(),
    'status': _str(null, ['active', 'paused', 'completed']),
  }, ['goalId', 'status']),
  _fn(Tools.createHabit, 'Create a habit to track on given weekdays.', {
    'name': _str(),
    'weekdays': _weekdays,
    'reminderTime': _minutes,
  }, ['name', 'weekdays']),
  _fn(Tools.logHabit, 'Mark a habit done on a day (not in the future).', {'habitId': _str(), 'day': _day}, ['habitId', 'day']),
  _fn(Tools.addNote, 'Save a note.', {'title': _str(), 'body': _str()}, ['body']),
  _fn(Tools.addExpense, 'Record money the user spent, in their currency (major units, e.g. 25.5).', {
    'amount': _num(),
    'category': _str(null, expenseCategoryIds),
    'description': _str(),
    'date': _day,
  }, ['amount', 'category']),
  _fn(Tools.addIncome, 'Record money the user received (not the regular salary).', {
    'amount': _num(),
    'source': _str(),
    'date': _day,
  }, ['amount']),
  _fn(Tools.addRecurring, 'Add a monthly bill or monthly income that repeats on a day of the month.', {
    'kind': _str(null, ['expense', 'income']),
    'amount': _num(),
    'title': _str(),
    'category': _str('Expense category.', expenseCategoryIds),
    'dayOfMonth': _int('1–28.'),
  }, ['kind', 'amount', 'title', 'dayOfMonth']),
  _fn(Tools.setBudget, 'Set a monthly spending limit, overall or for one category.', {
    'limit': _num(),
    'category': _str(null, expenseCategoryIds),
  }, ['limit']),
  _fn(Tools.logWater, 'Log water the user drank.', {'ml': _int('50–1000'), 'day': _day}, ['ml']),
  _fn(Tools.addAppointment, 'Add a medical appointment.', {'title': _str(), 'at': _instant}, ['title', 'at']),
  _fn(Tools.addMeasurement, 'Record a body measurement: weight (kg), waist (cm), restingHr (bpm), bp (value=systolic, value2=diastolic), bodyFat (%).', {
    'kind': _str(null, MetricKind.values.map((e) => e.name).toList()),
    'value': _num(),
    'value2': _num(),
  }, ['kind', 'value']),
  _fn(Tools.logSleep, 'Record a night\'s sleep.', {'start': _instant, 'end': _instant, 'quality': _int('1–5')}, ['start', 'end']),
  _fn(
    Tools.setWorkoutPlan,
    'Replace the user\'s weekly workout plan for home or gym. Each day lists exercises by id from the exercise catalog '
        '(use only those ids) with sets and either reps or seconds. The plan repeats every week; for a plan with a length '
        '(e.g. 90 days) also create a goal with that target date.',
    {
      'place': _str(null, WorkoutPlace.values.map((e) => e.name).toList()),
      'days': _arr(_obj({
        'weekday': _int('1 = Monday … 7 = Sunday'),
        'focus': _str(null, DayFocus.values.map((e) => e.name).toList()),
        'exercises': _arr(_obj({
          'exerciseId': _str(),
          'sets': _int(),
          'reps': _int(),
          'seconds': _int('For timed exercises instead of reps.'),
          'rest': _int('Rest seconds between sets.'),
        }, ['exerciseId', 'sets'])),
      }, ['weekday', 'exercises'])),
    },
    ['place', 'days'],
  ),
  _fn(Tools.setWeeklyLessons, 'Set how many English lessons a week the user aims for.', {'lessons': _int('1–7')}, ['lessons']),
  _fn(Tools.setNotifications, 'Turn a section\'s notifications on or off, optionally with its daily time.', {
    'section': _str(null, NotifySection.values.map((e) => e.name).toList()),
    'enabled': {'type': 'BOOLEAN'},
    'time': _minutes,
  }, ['section', 'enabled']),
  _fn(Tools.openScreen, 'Open a screen of the app for the user.', {
    'screen': _str(null, assistantScreens.keys.toList()),
  }, ['screen']),
];

/// What the model sees of the user's data: only shared sections, compact.
Map<String, Object?> assistantContext(AppData d, String lang, DateTime now) {
  final p = d.settings.assistant;
  final s = d.settings;
  final today = dayKey(now);
  final horizon = dayKey(now.add(const Duration(days: 14)));
  String hm(int m) => '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
  return {
    'today': today,
    'weekday': now.weekday,
    'currency': s.currency,
    'day_hours': {'wake': hm(s.dayStart), 'bed': hm(s.dayEnd % (24 * 60))},
    if (p.shareTasks)
      'tasks': [
        for (final t in d.tasks.where((t) => t.isOpen && !t.archived && (t.dueDate == null || t.dueDate!.compareTo(horizon) <= 0)).take(100))
          {
            'id': t.id,
            'title': t.title,
            'due': ?t.dueDate,
            if (t.dueTime != null) 'time': hm(t.dueTime!),
            'minutes': ?t.estimatedMinutes,
            'priority': t.priority.name,
            if (t.plannedStart != null) 'planned': encodeInstant(t.plannedStart),
            'goalId': ?t.goalId,
          },
      ],
    if (p.shareEvents)
      'events': [
        for (final e in d.events.where((e) => e.end.isAfter(now) && e.start.isBefore(now.add(const Duration(days: 14)))).take(100))
          {'id': e.id, 'title': e.title, 'start': encodeInstant(e.start), 'end': encodeInstant(e.end)},
      ],
    if (p.shareGoals)
      'goals': [
        for (final g in d.goals.where((g) => g.status == GoalStatus.active || g.status == GoalStatus.paused).take(30))
          {
            'id': g.id,
            'title': g.title,
            'status': g.status.name,
            'target': ?g.targetDate,
            'milestones': [for (final m in d.milestonesOf(g.id)) '${m.done ? '✓' : '·'} ${m.title}'],
          },
      ],
    if (p.shareHabits)
      'habits': [
        for (final h in d.habits.where((h) => h.active))
          {
            'id': h.id,
            'name': h.name,
            'weekdays': h.weekdays,
            'done_last_7_days': [
              for (var i = 0; i < 7; i++)
                if (d.habitLogs.any((x) => x.habitId == h.id && x.day == dayKey(now.subtract(Duration(days: i)))))
                  dayKey(now.subtract(Duration(days: i))),
            ],
          },
      ],
    if (p.shareNotes) 'note_titles': [for (final n in d.notes.take(50)) n.title],
    if (p.shareExpenses)
      'spent_last_31_days': [
        for (final e in d.expenses.where((e) => e.spentAt.isAfter(now.subtract(const Duration(days: 31)))).take(200))
          {'amount': e.amountMinor / 100, 'category': e.category, 'day': dayKey(e.spentAt)},
      ],
    'alarms': [
      for (final a in d.alarms)
        {'id': a.id, 'time': hm(a.minutes), 'label': a.label, 'weekdays': a.weekdays.toList()..sort(), 'on': a.enabled},
    ],
    'notifications_off': [for (final x in s.notify.off) x.name],
    if (p.shareNutrition) 'water_today_ml': d.waterOn(today),
    if (d.learningPath case final l?) 'english': {'level': l.level.name, 'weekly_lessons': l.weeklyGoal},
    'fitness': {
      if (s.fitness case final f?) 'profile': {'goal': f.goal.name, 'level': f.level.name, 'places': [for (final x in f.places) x.name]},
      'plans': [
        for (final plan in d.workoutPlans.where((x) => x.active))
          {
            'place': plan.place.name,
            'days': [
              for (final day in plan.days)
                {'weekday': day.weekday, 'exercises': [for (final x in day.exercises) x.exerciseId]},
            ],
          },
      ],
    },
    // id|name|muscle|difficulty|equipment ("-" = body weight, "gym" = gym only)
    'exercise_catalog': [
      for (final e in exercises)
        '${e.id}|${e.name(lang)}|${e.muscle.name}|${e.difficulty}|'
            '${e.gymOnly.isNotEmpty ? 'gym' : e.equipment.isEmpty ? '-' : e.equipment.map((q) => q.name).join('+')}'
            '${e.timed ? '|timed' : ''}',
    ],
    'screens': assistantScreens.keys.toList(),
  };
}
