import 'models/accountability.dart';
import 'models/assistant.dart';
import 'models/fitness.dart';
import 'models/goal.dart';
import 'models/health.dart';
import 'models/learning.dart';
import 'models/misc.dart';
import 'models/nutrition.dart';
import 'models/prayer.dart';
import 'models/settings.dart';
import 'models/task.dart';
import 'models/womens.dart';

/// Immutable snapshot of everything one signed-in user owns.
class AppData {
  const AppData({
    this.settings = const UserSettings(),
    this.tasks = const [],
    this.events = const [],
    this.goals = const [],
    this.milestones = const [],
    this.habits = const [],
    this.habitLogs = const [],
    this.prayerLogs = const [],
    this.workoutPlans = const [],
    this.workoutSessions = const [],
    this.learningPaths = const [],
    this.lessonProgresses = const [],
    this.assessments = const [],
    this.vocabReviews = const [],
    this.accountabilityRules = const [],
    this.accountabilityEvents = const [],
    this.activity = const [],
    this.foodLogs = const [],
    this.customFoods = const [],
    this.water = const [],
    this.sleep = const [],
    this.bodyMetrics = const [],
    this.deviceWorkouts = const [],
    this.periods = const [],
    this.cycleLogs = const [],
    this.appointments = const [],
    this.notes = const [],
    this.expenses = const [],
    this.budgets = const [],
    this.notifications = const [],
    this.conversations = const [],
    this.messages = const [],
    this.proposals = const [],
    this.actionLogs = const [],
    this.reports = const [],
    this.usageDay = '',
    this.usageCount = 0,
  });

  final UserSettings settings;
  final List<Task> tasks;
  final List<CalendarEvent> events;
  final List<Goal> goals;
  final List<Milestone> milestones;
  final List<Habit> habits;
  final List<HabitLog> habitLogs;
  final List<PrayerLog> prayerLogs;
  final List<WorkoutPlan> workoutPlans;
  final List<WorkoutSession> workoutSessions;

  /// At most one (English); a list so it syncs like other tables.
  final List<LearningPath> learningPaths;
  final List<LessonProgress> lessonProgresses;
  final List<Assessment> assessments;
  final List<VocabReview> vocabReviews;
  final List<AccountabilityRule> accountabilityRules;
  final List<AccountabilityEvent> accountabilityEvents;

  /// One row per day and source; see `domain/activity.dart` for which one
  /// counts.
  final List<DailyActivity> activity;
  final List<FoodLog> foodLogs;
  final List<CustomFood> customFoods;
  final List<WaterDay> water;

  /// Imported from the health store (phase 10), one record per session,
  /// measurement or workout.
  final List<SleepSession> sleep;
  final List<BodyMetric> bodyMetrics;
  final List<DeviceWorkout> deviceWorkouts;

  /// Women's health (phase 11) and health appointments.
  final List<CyclePeriod> periods;
  final List<CycleDayLog> cycleLogs;
  final List<HealthAppointment> appointments;

  CycleDayLog? cycleLog(String day) => cycleLogs.where((x) => x.day == day).firstOrNull;
  HealthAppointment? appointment(String? id) => _find(appointments, id, (e) => e.id);

  CustomFood? customFood(String? id) => _find(customFoods, id, (e) => e.id);
  int waterOn(String day) => water.where((w) => w.day == day).firstOrNull?.ml ?? 0;
  final List<Note> notes;
  final List<Expense> expenses;
  final List<Budget> budgets;
  final List<AppNotification> notifications;
  final List<Conversation> conversations;
  final List<ChatMessage> messages;
  final List<ActionProposal> proposals;
  final List<ActionLog> actionLogs;
  final List<SupportReport> reports;

  /// Assistant requests used today (local display only — the server is the
  /// source of truth for limits in production).
  final String usageDay;
  final int usageCount;

  Task? task(String? id) => _find(tasks, id, (t) => t.id);
  Goal? goal(String? id) => _find(goals, id, (g) => g.id);
  Habit? habit(String? id) => _find(habits, id, (h) => h.id);
  Note? note(String? id) => _find(notes, id, (n) => n.id);
  CalendarEvent? event(String? id) => _find(events, id, (e) => e.id);
  ActionProposal? proposal(String? id) => _find(proposals, id, (p) => p.id);

  List<Milestone> milestonesOf(String goalId) =>
      milestones.where((m) => m.goalId == goalId).toList()..sort((a, b) => a.order.compareTo(b.order));

  List<Task> tasksOfGoal(String goalId) => tasks.where((t) => t.goalId == goalId).toList();

  bool habitDoneOn(String habitId, String day) =>
      habitLogs.any((l) => l.habitId == habitId && l.day == day);

  /// The plan currently followed at [place], if any.
  WorkoutPlan? activePlan(WorkoutPlace place) =>
      workoutPlans.where((p) => p.place == place && p.active).firstOrNull;

  WorkoutPlan? plan(String? id) => _find(workoutPlans, id, (p) => p.id);

  List<WorkoutSession> sessionsOn(String day) => workoutSessions.where((s) => s.day == day).toList();

  AccountabilityRule? rule(String? id) => _find(accountabilityRules, id, (r) => r.id);
  AccountabilityRule? ruleForTask(String taskId) => accountabilityRules.where((r) => r.taskId == taskId).firstOrNull;
  AccountabilityEvent? accountabilityEvent(String? id) => _find(accountabilityEvents, id, (e) => e.id);

  LearningPath? get learningPath => learningPaths.firstOrNull;
  LessonProgress? lessonProgress(String lessonId) => _find(lessonProgresses, lessonId, (p) => p.lessonId);

  bool prayerLogged(Prayer p, String day) => prayerLogs.any((l) => l.prayer == p && l.day == day);

  int get unreadNotifications => notifications.where((n) => !n.read).length;

  /// Cleared notifications remain as empty tombstones (to keep their dedupe
  /// key) and are hidden.
  List<AppNotification> get visibleNotifications =>
      notifications.where((n) => n.title.isNotEmpty).toList();

  static T? _find<T>(List<T> list, String? id, String Function(T) key) {
    if (id == null) return null;
    for (final e in list) {
      if (key(e) == id) return e;
    }
    return null;
  }

  AppData copyWith({
    UserSettings? settings,
    List<Task>? tasks,
    List<CalendarEvent>? events,
    List<Goal>? goals,
    List<Milestone>? milestones,
    List<Habit>? habits,
    List<HabitLog>? habitLogs,
    List<PrayerLog>? prayerLogs,
    List<WorkoutPlan>? workoutPlans,
    List<WorkoutSession>? workoutSessions,
    List<LearningPath>? learningPaths,
    List<LessonProgress>? lessonProgresses,
    List<Assessment>? assessments,
    List<VocabReview>? vocabReviews,
    List<AccountabilityRule>? accountabilityRules,
    List<AccountabilityEvent>? accountabilityEvents,
    List<DailyActivity>? activity,
    List<FoodLog>? foodLogs,
    List<CustomFood>? customFoods,
    List<WaterDay>? water,
    List<SleepSession>? sleep,
    List<BodyMetric>? bodyMetrics,
    List<DeviceWorkout>? deviceWorkouts,
    List<CyclePeriod>? periods,
    List<CycleDayLog>? cycleLogs,
    List<HealthAppointment>? appointments,
    List<Note>? notes,
    List<Expense>? expenses,
    List<Budget>? budgets,
    List<AppNotification>? notifications,
    List<Conversation>? conversations,
    List<ChatMessage>? messages,
    List<ActionProposal>? proposals,
    List<ActionLog>? actionLogs,
    List<SupportReport>? reports,
    String? usageDay,
    int? usageCount,
  }) =>
      AppData(
        settings: settings ?? this.settings,
        tasks: tasks ?? this.tasks,
        events: events ?? this.events,
        goals: goals ?? this.goals,
        milestones: milestones ?? this.milestones,
        habits: habits ?? this.habits,
        habitLogs: habitLogs ?? this.habitLogs,
        prayerLogs: prayerLogs ?? this.prayerLogs,
        workoutPlans: workoutPlans ?? this.workoutPlans,
        workoutSessions: workoutSessions ?? this.workoutSessions,
        learningPaths: learningPaths ?? this.learningPaths,
        lessonProgresses: lessonProgresses ?? this.lessonProgresses,
        assessments: assessments ?? this.assessments,
        vocabReviews: vocabReviews ?? this.vocabReviews,
        accountabilityRules: accountabilityRules ?? this.accountabilityRules,
        accountabilityEvents: accountabilityEvents ?? this.accountabilityEvents,
        activity: activity ?? this.activity,
        foodLogs: foodLogs ?? this.foodLogs,
        customFoods: customFoods ?? this.customFoods,
        water: water ?? this.water,
        sleep: sleep ?? this.sleep,
        bodyMetrics: bodyMetrics ?? this.bodyMetrics,
        deviceWorkouts: deviceWorkouts ?? this.deviceWorkouts,
        periods: periods ?? this.periods,
        cycleLogs: cycleLogs ?? this.cycleLogs,
        appointments: appointments ?? this.appointments,
        notes: notes ?? this.notes,
        expenses: expenses ?? this.expenses,
        budgets: budgets ?? this.budgets,
        notifications: notifications ?? this.notifications,
        conversations: conversations ?? this.conversations,
        messages: messages ?? this.messages,
        proposals: proposals ?? this.proposals,
        actionLogs: actionLogs ?? this.actionLogs,
        reports: reports ?? this.reports,
        usageDay: usageDay ?? this.usageDay,
        usageCount: usageCount ?? this.usageCount,
      );

  Map<String, Object?> toJson() => {
        'version': 1,
        'settings': settings.toJson(),
        'tasks': tasks.map((e) => e.toJson()).toList(),
        'events': events.map((e) => e.toJson()).toList(),
        'goals': goals.map((e) => e.toJson()).toList(),
        'milestones': milestones.map((e) => e.toJson()).toList(),
        'habits': habits.map((e) => e.toJson()).toList(),
        'habitLogs': habitLogs.map((e) => e.toJson()).toList(),
        'prayerLogs': prayerLogs.map((e) => e.toJson()).toList(),
        'workoutPlans': workoutPlans.map((e) => e.toJson()).toList(),
        'workoutSessions': workoutSessions.map((e) => e.toJson()).toList(),
        'learningPaths': learningPaths.map((e) => e.toJson()).toList(),
        'lessonProgresses': lessonProgresses.map((e) => e.toJson()).toList(),
        'assessments': assessments.map((e) => e.toJson()).toList(),
        'vocabReviews': vocabReviews.map((e) => e.toJson()).toList(),
        'accountabilityRules': accountabilityRules.map((e) => e.toJson()).toList(),
        'accountabilityEvents': accountabilityEvents.map((e) => e.toJson()).toList(),
        'activity': activity.map((e) => e.toJson()).toList(),
        'foodLogs': foodLogs.map((e) => e.toJson()).toList(),
        'customFoods': customFoods.map((e) => e.toJson()).toList(),
        'water': water.map((e) => e.toJson()).toList(),
        'sleep': sleep.map((e) => e.toJson()).toList(),
        'bodyMetrics': bodyMetrics.map((e) => e.toJson()).toList(),
        'deviceWorkouts': deviceWorkouts.map((e) => e.toJson()).toList(),
        'periods': periods.map((e) => e.toJson()).toList(),
        'cycleLogs': cycleLogs.map((e) => e.toJson()).toList(),
        'appointments': appointments.map((e) => e.toJson()).toList(),
        'notes': notes.map((e) => e.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'budgets': budgets.map((e) => e.toJson()).toList(),
        'notifications': notifications.map((e) => e.toJson()).toList(),
        'conversations': conversations.map((e) => e.toJson()).toList(),
        'messages': messages.map((e) => e.toJson()).toList(),
        'proposals': proposals.map((e) => e.toJson()).toList(),
        'actionLogs': actionLogs.map((e) => e.toJson()).toList(),
        'reports': reports.map((e) => e.toJson()).toList(),
        'usageDay': usageDay,
        'usageCount': usageCount,
      };

  factory AppData.fromJson(Map<String, Object?> j) {
    List<T> list<T>(String k, T Function(Map<String, Object?>) f) =>
        ((j[k] as List?) ?? const []).map((e) => f((e as Map).cast<String, Object?>())).toList();
    return AppData(
      settings: j['settings'] == null
          ? const UserSettings()
          : UserSettings.fromJson((j['settings'] as Map).cast()),
      tasks: list('tasks', Task.fromJson),
      events: list('events', CalendarEvent.fromJson),
      goals: list('goals', Goal.fromJson),
      milestones: list('milestones', Milestone.fromJson),
      habits: list('habits', Habit.fromJson),
      habitLogs: list('habitLogs', HabitLog.fromJson),
      prayerLogs: list('prayerLogs', PrayerLog.fromJson),
      workoutPlans: list('workoutPlans', WorkoutPlan.fromJson),
      workoutSessions: list('workoutSessions', WorkoutSession.fromJson),
      learningPaths: list('learningPaths', LearningPath.fromJson),
      lessonProgresses: list('lessonProgresses', LessonProgress.fromJson),
      assessments: list('assessments', Assessment.fromJson),
      vocabReviews: list('vocabReviews', VocabReview.fromJson),
      accountabilityRules: list('accountabilityRules', AccountabilityRule.fromJson),
      accountabilityEvents: list('accountabilityEvents', AccountabilityEvent.fromJson),
      activity: list('activity', DailyActivity.fromJson),
      foodLogs: list('foodLogs', FoodLog.fromJson),
      customFoods: list('customFoods', CustomFood.fromJson),
      water: list('water', WaterDay.fromJson),
      sleep: list('sleep', SleepSession.fromJson),
      bodyMetrics: list('bodyMetrics', BodyMetric.fromJson),
      deviceWorkouts: list('deviceWorkouts', DeviceWorkout.fromJson),
      periods: list('periods', CyclePeriod.fromJson),
      cycleLogs: list('cycleLogs', CycleDayLog.fromJson),
      appointments: list('appointments', HealthAppointment.fromJson),
      notes: list('notes', Note.fromJson),
      expenses: list('expenses', Expense.fromJson),
      budgets: list('budgets', Budget.fromJson),
      notifications: list('notifications', AppNotification.fromJson),
      conversations: list('conversations', Conversation.fromJson),
      messages: list('messages', ChatMessage.fromJson),
      proposals: list('proposals', ActionProposal.fromJson),
      actionLogs: list('actionLogs', ActionLog.fromJson),
      reports: list('reports', SupportReport.fromJson),
      usageDay: (j['usageDay'] as String?) ?? '',
      usageCount: (j['usageCount'] as int?) ?? 0,
    );
  }
}
