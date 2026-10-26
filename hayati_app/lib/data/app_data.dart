import 'models/assistant.dart';
import 'models/fitness.dart';
import 'models/goal.dart';
import 'models/misc.dart';
import 'models/prayer.dart';
import 'models/settings.dart';
import 'models/task.dart';

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
