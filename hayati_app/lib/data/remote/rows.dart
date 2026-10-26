/// Mapping between app models and the Supabase tables in
/// `supabase/migrations`. Server-managed columns (user_id, updated_at)
/// are never sent; RLS fills user_id from the session.
library;

import '../../core/utils/dates.dart';
import '../app_data.dart';
import '../models/fitness.dart';
import '../models/goal.dart';
import '../models/misc.dart';
import '../models/prayer.dart';
import '../models/settings.dart';
import '../models/task.dart';

typedef Row = Map<String, Object?>;

String? _ts(DateTime? d) => encodeInstant(d);
DateTime? _dt(Object? v) => v == null ? null : DateTime.parse(v as String).toLocal();
String? _hm(int? m) => m == null ? null : minutesToHm(m);
int? _min(Object? v) => v == null ? null : hmToMinutes((v as String).substring(0, 5));

const _status = {TaskStatus.todo: 'todo', TaskStatus.inProgress: 'in_progress', TaskStatus.done: 'done', TaskStatus.cancelled: 'cancelled'};

Row taskRow(Task t) => {
      'id': t.id,
      'title': t.title,
      'description': t.description,
      'due_date': t.dueDate,
      'due_time': t.dueDate == null ? null : _hm(t.dueTime),
      'estimated_minutes': t.estimatedMinutes,
      'priority': t.priority.name,
      'status': _status[t.status],
      'goal_id': t.goalId,
      'milestone_id': t.goalId == null ? null : t.milestoneId,
      'reminder_at': _ts(t.reminderAt),
      'planned_start': _ts(t.plannedStart),
      'completed_at': t.isDone ? _ts(t.completedAt ?? t.updatedAt) : null,
      'archived': t.archived,
      'created_at': _ts(t.createdAt),
    };

Task taskFrom(Row r) => Task(
      id: r['id'] as String,
      title: r['title'] as String,
      description: r['description'] as String,
      dueDate: r['due_date'] as String?,
      dueTime: _min(r['due_time']),
      estimatedMinutes: r['estimated_minutes'] as int?,
      priority: Priority.values.byName(r['priority'] as String),
      status: _status.entries.firstWhere((e) => e.value == r['status']).key,
      goalId: r['goal_id'] as String?,
      milestoneId: r['milestone_id'] as String?,
      reminderAt: _dt(r['reminder_at']),
      plannedStart: _dt(r['planned_start']),
      completedAt: _dt(r['completed_at']),
      archived: r['archived'] as bool,
      createdAt: _dt(r['created_at'])!,
      updatedAt: _dt(r['updated_at'])!,
    );

Row eventRow(CalendarEvent e) => {
      'id': e.id,
      'title': e.title,
      'starts_at': _ts(e.start),
      'ends_at': _ts(e.end),
      'location': e.location,
      'notes': e.notes,
      'reminder_minutes_before': e.reminderMinutesBefore,
    };

CalendarEvent eventFrom(Row r) => CalendarEvent(
      id: r['id'] as String,
      title: r['title'] as String,
      start: _dt(r['starts_at'])!,
      end: _dt(r['ends_at'])!,
      location: r['location'] as String,
      notes: r['notes'] as String,
      reminderMinutesBefore: r['reminder_minutes_before'] as int?,
      updatedAt: _dt(r['updated_at'])!,
    );

Row goalRow(Goal g) => {
      'id': g.id,
      'title': g.title,
      'description': g.description,
      'category': g.category.name,
      'start_date': g.startDate,
      'target_date': g.targetDate,
      'why': g.why,
      'progress_mode': g.progressMode.name,
      'manual_progress': g.manualProgress,
      'status': g.status.name,
      'created_at': _ts(g.createdAt),
    };

Goal goalFrom(Row r) => Goal(
      id: r['id'] as String,
      title: r['title'] as String,
      description: r['description'] as String,
      category: GoalCategory.values.byName(r['category'] as String),
      startDate: r['start_date'] as String?,
      targetDate: r['target_date'] as String?,
      why: r['why'] as String,
      progressMode: ProgressMode.values.byName(r['progress_mode'] as String),
      manualProgress: r['manual_progress'] as int,
      status: GoalStatus.values.byName(r['status'] as String),
      createdAt: _dt(r['created_at'])!,
      updatedAt: _dt(r['updated_at'])!,
    );

Row milestoneRow(Milestone m) => {'id': m.id, 'goal_id': m.goalId, 'title': m.title, 'done': m.done, 'position': m.order};

Milestone milestoneFrom(Row r) => Milestone(
      id: r['id'] as String,
      goalId: r['goal_id'] as String,
      title: r['title'] as String,
      done: r['done'] as bool,
      order: r['position'] as int,
    );

Row habitRow(Habit h) => {
      'id': h.id,
      'name': h.name,
      'description': h.description,
      'weekdays': (h.weekdays.toList()..sort()),
      'start_date': h.startDate,
      'reminder_time': _hm(h.reminderMinutes),
      'active': h.active,
    };

Habit habitFrom(Row r) => Habit(
      id: r['id'] as String,
      name: r['name'] as String,
      description: r['description'] as String,
      weekdays: (r['weekdays'] as List).cast<int>().toSet(),
      startDate: r['start_date'] as String,
      reminderMinutes: _min(r['reminder_time']),
      active: r['active'] as bool,
    );

Row habitLogRow(HabitLog l) => {'id': l.id, 'habit_id': l.habitId, 'day': l.day};

HabitLog habitLogFrom(Row r) => HabitLog(id: r['id'] as String, habitId: r['habit_id'] as String, day: r['day'] as String);

Row prayerLogRow(PrayerLog l) => {'id': l.id, 'day': l.day, 'prayer': l.prayer.name};

PrayerLog prayerLogFrom(Row r) =>
    PrayerLog(id: r['id'] as String, day: r['day'] as String, prayer: Prayer.values.byName(r['prayer'] as String));

Row workoutPlanRow(WorkoutPlan p) => {
      'id': p.id,
      'place': p.place.name,
      'version': p.version,
      'active': p.active,
      'goal': p.goal.name,
      'days': [for (final d in p.days) d.toJson()],
      'created_at': _ts(p.createdAt),
    };

WorkoutPlan workoutPlanFrom(Row r) => WorkoutPlan(
      id: r['id'] as String,
      place: WorkoutPlace.values.byName(r['place'] as String),
      version: r['version'] as int,
      active: r['active'] as bool,
      goal: FitnessGoal.values.byName(r['goal'] as String),
      days: [for (final d in r['days'] as List) WorkoutDay.fromJson((d as Map).cast())],
      createdAt: _dt(r['created_at'])!,
    );

Row workoutSessionRow(WorkoutSession s) => {
      'id': s.id,
      'plan_id': s.planId,
      'day': s.day,
      'place': s.place.name,
      'focus': s.focus.name,
      'status': s.status.name,
      'difficulty': s.difficulty,
      'note': s.note,
      'sets': [for (final x in s.sets) x.toJson()],
      'substituted': s.substituted,
      'created_at': _ts(s.createdAt),
    };

WorkoutSession workoutSessionFrom(Row r) => WorkoutSession(
      id: r['id'] as String,
      planId: r['plan_id'] as String?,
      day: r['day'] as String,
      place: WorkoutPlace.values.byName(r['place'] as String),
      focus: DayFocus.values.byName(r['focus'] as String),
      status: SessionStatus.values.byName(r['status'] as String),
      difficulty: r['difficulty'] as int?,
      note: r['note'] as String,
      sets: [for (final x in r['sets'] as List) SetLog.fromJson((x as Map).cast())],
      substituted: r['substituted'] as bool,
      createdAt: _dt(r['created_at'])!,
    );

Row noteRow(Note n) => {
      'id': n.id,
      'title': n.title,
      'body': n.body,
      'category': n.category,
      'pinned': n.pinned,
      'archived': n.archived,
      'goal_id': n.goalId,
      'task_id': n.taskId,
    };

Note noteFrom(Row r) => Note(
      id: r['id'] as String,
      title: r['title'] as String,
      body: r['body'] as String,
      category: r['category'] as String,
      pinned: r['pinned'] as bool,
      archived: r['archived'] as bool,
      goalId: r['goal_id'] as String?,
      taskId: r['task_id'] as String?,
      updatedAt: _dt(r['updated_at'])!,
    );

Row expenseRow(Expense e) => {
      'id': e.id,
      'amount_minor': e.amountMinor,
      'currency': e.currency,
      'category': e.category,
      'spent_at': _ts(e.spentAt),
      'description': e.description,
    };

Expense expenseFrom(Row r) => Expense(
      id: r['id'] as String,
      amountMinor: r['amount_minor'] as int,
      currency: (r['currency'] as String).trim(),
      category: r['category'] as String,
      spentAt: _dt(r['spent_at'])!,
      description: r['description'] as String,
    );

Row budgetRow(Budget b) => {'id': b.id, 'currency': b.currency, 'category': b.category, 'limit_minor': b.limitMinor};

Budget budgetFrom(Row r) => Budget(
      id: r['id'] as String,
      currency: (r['currency'] as String).trim(),
      limitMinor: r['limit_minor'] as int,
      category: r['category'] as String?,
    );

/// Settings ↔ the caller's `profiles` row (updated, never inserted: the
/// signup trigger creates it).
Row profileRow(UserSettings s) => {
      'display_name': s.displayName,
      'show_name_in_greeting': s.showNameInGreeting,
      'theme_mode': s.themeMode,
      'currency': s.currency,
      'week_start': s.weekStart,
      'use_24h': s.use24h,
      'day_start': s.dayStart,
      'day_end': s.dayEnd,
      'work_start': s.work?.start,
      'work_end': s.work?.end,
      'work_days': s.workDays.toList()..sort(),
      'breaks': [for (final b in s.breaks) b.toJson()],
      'modules': [for (final m in s.modules) m.name]..sort(),
      'onboarding_done': s.onboardingDone,
      'home_sections': {'events': s.homeShowEvents, 'habits': s.homeShowHabits, 'goals': s.homeShowGoals},
      'assistant_permissions': {
        for (final e in s.assistant.toJson().entries)
          if (e.key != 'retentionDays') e.key: e.value,
      },
      'chat_retention_days': s.assistant.retentionDays,
      'prayer_settings': s.prayer.toJson(),
      'fitness_profile': s.fitness?.toJson() ?? const <String, Object?>{},
    };

UserSettings settingsFrom(Row r) {
  final home = (r['home_sections'] as Map?)?.cast<String, Object?>() ?? const {};
  final perms = {...?(r['assistant_permissions'] as Map?)?.cast<String, Object?>(), 'retentionDays': r['chat_retention_days']};
  return UserSettings(
    displayName: r['display_name'] as String,
    showNameInGreeting: r['show_name_in_greeting'] as bool,
    themeMode: r['theme_mode'] as String,
    currency: (r['currency'] as String).trim(),
    weekStart: r['week_start'] as int,
    use24h: r['use_24h'] as bool,
    dayStart: r['day_start'] as int,
    dayEnd: r['day_end'] as int,
    work: r['work_start'] == null ? null : TimeRange(r['work_start'] as int, r['work_end'] as int),
    workDays: (r['work_days'] as List).cast<int>().toSet(),
    breaks: [for (final b in (r['breaks'] as List? ?? const [])) TimeRange.fromJson((b as Map).cast())],
    modules: {
      for (final m in (r['modules'] as List).cast<String>())
        if (AppModule.values.any((x) => x.name == m)) AppModule.values.byName(m),
    },
    onboardingDone: r['onboarding_done'] as bool,
    homeShowEvents: (home['events'] as bool?) ?? true,
    homeShowHabits: (home['habits'] as bool?) ?? true,
    homeShowGoals: (home['goals'] as bool?) ?? true,
    assistant: AssistantPermissions.fromJson(perms),
    prayer: PrayerSettings.fromJson((r['prayer_settings'] as Map?)?.cast<String, Object?>() ?? const {}),
    fitness: FitnessProfile.fromJson((r['fitness_profile'] as Map?)?.cast<String, Object?>()),
  );
}

/// A synced table: how to list its rows from [AppData] and how to read them
/// back. Ordered parents-first so upserts satisfy foreign keys; deletes run
/// in the reverse order.
class SyncTable<T> {
  const SyncTable(this.name, this.rows, this.from);
  final String name;
  final List<Row> Function(AppData) rows;
  final T Function(Row) from;
}

final syncTables = <SyncTable<Object>>[
  SyncTable('goals', (d) => [for (final x in d.goals) goalRow(x)], goalFrom),
  SyncTable('goal_milestones', (d) => [for (final x in d.milestones) milestoneRow(x)], milestoneFrom),
  SyncTable('tasks', (d) => [for (final x in d.tasks) taskRow(x)], taskFrom),
  SyncTable('events', (d) => [for (final x in d.events) eventRow(x)], eventFrom),
  SyncTable('habits', (d) => [for (final x in d.habits) habitRow(x)], habitFrom),
  SyncTable('habit_logs', (d) => [for (final x in d.habitLogs) habitLogRow(x)], habitLogFrom),
  SyncTable('prayer_logs', (d) => [for (final x in d.prayerLogs) prayerLogRow(x)], prayerLogFrom),
  SyncTable('workout_plans', (d) => [for (final x in d.workoutPlans) workoutPlanRow(x)], workoutPlanFrom),
  SyncTable('workout_sessions', (d) => [for (final x in d.workoutSessions) workoutSessionRow(x)], workoutSessionFrom),
  SyncTable('notes', (d) => [for (final x in d.notes) noteRow(x)], noteFrom),
  SyncTable('expenses', (d) => [for (final x in d.expenses) expenseRow(x)], expenseFrom),
  SyncTable('budgets', (d) => [for (final x in d.budgets) budgetRow(x)], budgetFrom),
];

/// Replaces the synced collections of [local] with server data, keeping the
/// device-only ones (notifications, assistant chats, support outbox).
AppData mergeRemote(AppData local, UserSettings settings, Map<String, List<Row>> rows) {
  List<T> read<T>(String t, T Function(Row) f) => [for (final r in rows[t] ?? const <Row>[]) f(r)];
  return local.copyWith(
    settings: settings,
    goals: read('goals', goalFrom),
    milestones: read('goal_milestones', milestoneFrom),
    tasks: read('tasks', taskFrom),
    events: read('events', eventFrom),
    habits: read('habits', habitFrom),
    habitLogs: read('habit_logs', habitLogFrom),
    prayerLogs: read('prayer_logs', prayerLogFrom),
    workoutPlans: read('workout_plans', workoutPlanFrom),
    workoutSessions: read('workout_sessions', workoutSessionFrom),
    notes: read('notes', noteFrom),
    expenses: read('expenses', expenseFrom),
    budgets: read('budgets', budgetFrom),
  );
}
