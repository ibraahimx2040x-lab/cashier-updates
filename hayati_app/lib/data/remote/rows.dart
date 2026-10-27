/// Mapping between app models and the Supabase tables in
/// `supabase/migrations`. Server-managed columns (user_id, updated_at)
/// are never sent; RLS fills user_id from the session.
library;

import '../../core/utils/dates.dart';
import '../app_data.dart';
import '../models/accountability.dart';
import '../models/fitness.dart';
import '../models/goal.dart';
import '../models/health.dart';
import '../models/learning.dart';
import '../models/misc.dart';
import '../models/nutrition.dart';
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

Row activityRow(DailyActivity a) => {
      'id': a.id,
      'day': a.day,
      'source': a.source.name,
      'steps': a.steps,
      'distance_m': a.distanceM,
      'active_minutes': a.activeMinutes,
      'updated_at': a.updatedAt.toUtc().toIso8601String(),
    };

DailyActivity activityFrom(Row r) => DailyActivity(
      id: r['id'] as String,
      day: r['day'] as String,
      source: ActivitySource.values.byName(r['source'] as String),
      steps: r['steps'] as int,
      distanceM: r['distance_m'] as int?,
      activeMinutes: r['active_minutes'] as int?,
      updatedAt: DateTime.parse(r['updated_at'] as String).toLocal(),
    );

Row sleepRow(SleepSession x) => {
      'id': x.id,
      'source': x.source.name,
      'start_at': x.start.toUtc().toIso8601String(),
      'end_at': x.end.toUtc().toIso8601String(),
      'quality': x.quality,
      'updated_at': x.updatedAt.toUtc().toIso8601String(),
    };

SleepSession sleepFrom(Row r) => SleepSession(
      id: r['id'] as String,
      source: ActivitySource.values.byName(r['source'] as String),
      start: DateTime.parse(r['start_at'] as String).toLocal(),
      end: DateTime.parse(r['end_at'] as String).toLocal(),
      quality: r['quality'] as int?,
      updatedAt: DateTime.parse(r['updated_at'] as String).toLocal(),
    );

const _metricKinds = {
  MetricKind.weight: 'weight',
  MetricKind.waist: 'waist',
  MetricKind.restingHr: 'resting_hr',
  MetricKind.bp: 'bp',
  MetricKind.bodyFat: 'body_fat',
};

Row bodyMetricRow(BodyMetric x) => {
      'id': x.id,
      'kind': _metricKinds[x.kind],
      'value': x.value,
      'value2': x.value2,
      'source': x.source.name,
      'measured_at': x.measuredAt.toUtc().toIso8601String(),
      'note': x.note,
    };

BodyMetric bodyMetricFrom(Row r) => BodyMetric(
      id: r['id'] as String,
      kind: _metricKinds.entries.firstWhere((e) => e.value == r['kind']).key,
      value: (r['value'] as num).toDouble(),
      value2: (r['value2'] as num?)?.toDouble(),
      source: ActivitySource.values.byName(r['source'] as String),
      measuredAt: DateTime.parse(r['measured_at'] as String).toLocal(),
      note: (r['note'] as String?) ?? '',
    );

Row deviceWorkoutRow(DeviceWorkout x) => {
      'id': x.id,
      'source': x.source.name,
      'activity': x.activity,
      'start_at': x.start.toUtc().toIso8601String(),
      'end_at': x.end.toUtc().toIso8601String(),
      'kcal': x.kcal,
      'distance_m': x.distanceM,
      'steps': x.steps,
      'updated_at': x.updatedAt.toUtc().toIso8601String(),
    };

DeviceWorkout deviceWorkoutFrom(Row r) => DeviceWorkout(
      id: r['id'] as String,
      source: ActivitySource.values.byName(r['source'] as String),
      activity: r['activity'] as String,
      start: DateTime.parse(r['start_at'] as String).toLocal(),
      end: DateTime.parse(r['end_at'] as String).toLocal(),
      kcal: r['kcal'] as int?,
      distanceM: r['distance_m'] as int?,
      steps: r['steps'] as int?,
      updatedAt: DateTime.parse(r['updated_at'] as String).toLocal(),
    );

Row customFoodRow(CustomFood f) => {
      'id': f.id,
      'name': f.name,
      'portion': f.portion,
      'grams': f.grams,
      'kcal': f.per.kcal,
      'protein': f.per.protein,
      'carbs': f.per.carbs,
      'fat': f.per.fat,
      'barcode': f.barcode,
      'created_at': f.createdAt.toUtc().toIso8601String(),
    };

Nutrients _nutrientsFrom(Row r) => Nutrients(
      kcal: (r['kcal'] as num).toDouble(),
      protein: (r['protein'] as num).toDouble(),
      carbs: (r['carbs'] as num).toDouble(),
      fat: (r['fat'] as num).toDouble(),
    );

CustomFood customFoodFrom(Row r) => CustomFood(
      id: r['id'] as String,
      name: r['name'] as String,
      portion: r['portion'] as String,
      grams: (r['grams'] as num?)?.toDouble(),
      per: _nutrientsFrom(r),
      barcode: r['barcode'] as String?,
      createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
    );

Row foodLogRow(FoodLog f) => {
      'id': f.id,
      'day': f.day,
      'meal': f.meal.name,
      'name': f.name,
      'food_ref': f.foodRef,
      'portions': f.portions,
      'kcal': f.total.kcal,
      'protein': f.total.protein,
      'carbs': f.total.carbs,
      'fat': f.total.fat,
      'logged_at': f.loggedAt.toUtc().toIso8601String(),
    };

FoodLog foodLogFrom(Row r) => FoodLog(
      id: r['id'] as String,
      day: r['day'] as String,
      meal: MealType.values.byName(r['meal'] as String),
      name: r['name'] as String,
      foodRef: r['food_ref'] as String?,
      portions: (r['portions'] as num).toDouble(),
      total: _nutrientsFrom(r),
      loggedAt: DateTime.parse(r['logged_at'] as String).toLocal(),
    );

Row waterRow(WaterDay w) => {'id': w.id, 'day': w.day, 'ml': w.ml};
WaterDay waterFrom(Row r) => WaterDay(id: r['id'] as String, day: r['day'] as String, ml: r['ml'] as int);

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
      'program_id': s.programId,
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
      programId: r['program_id'] as String?,
      createdAt: _dt(r['created_at'])!,
    );

Row learningPathRow(LearningPath p) =>
    {'id': p.id, 'subject': 'english', 'level': p.level.name, 'weekly_goal': p.weeklyGoal, 'started_at': _ts(p.startedAt)};

LearningPath learningPathFrom(Row r) => LearningPath(
      id: r['id'] as String,
      level: Cefr.values.byName(r['level'] as String),
      weeklyGoal: r['weekly_goal'] as int,
      startedAt: _dt(r['started_at'])!,
    );

Row lessonProgressRow(LessonProgress p) =>
    {'id': p.id, 'lesson_id': p.lessonId, 'best_score': p.bestScore, 'attempts': p.attempts, 'last_at': _ts(p.lastAt)};

LessonProgress lessonProgressFrom(Row r) => LessonProgress(
      id: r['id'] as String,
      lessonId: r['lesson_id'] as String,
      bestScore: r['best_score'] as int,
      attempts: r['attempts'] as int,
      lastAt: _dt(r['last_at'])!,
    );

Row assessmentRow(Assessment a) {
  final j = a.toJson();
  return {
    'id': a.id,
    'kind': a.kind.name,
    'level': a.level.name,
    'scores': j['scores'],
    'skill_levels': j['skillLevels'],
    'passed': a.passed,
    'taken_at': _ts(a.takenAt),
  };
}

Assessment assessmentFrom(Row r) => Assessment.fromJson({
      'id': r['id'],
      'kind': r['kind'],
      'level': r['level'],
      'scores': r['scores'],
      'skillLevels': r['skill_levels'],
      'passed': r['passed'],
      'takenAt': _dt(r['taken_at'])!.toUtc().toIso8601String(),
    });

Row vocabReviewRow(VocabReview v) => {'id': v.id, 'word_id': v.wordId, 'box': v.box, 'due': v.due};

VocabReview vocabReviewFrom(Row r) =>
    VocabReview(id: r['id'] as String, wordId: r['word_id'] as String, box: r['box'] as int, due: r['due'] as String);

Row ruleRow(AccountabilityRule r) => {
      'id': r.id,
      'task_id': r.taskId,
      'grace_days': r.graceDays,
      'consequence': r.consequence.name,
      'custom_text': r.customText,
      'active': r.active,
      'created_at': _ts(r.createdAt),
    };

AccountabilityRule ruleFrom(Row r) => AccountabilityRule(
      id: r['id'] as String,
      taskId: r['task_id'] as String,
      graceDays: r['grace_days'] as int,
      consequence: Consequence.values.byName(r['consequence'] as String),
      customText: r['custom_text'] as String,
      active: r['active'] as bool,
      createdAt: _dt(r['created_at'])!,
    );

Row eventRowA(AccountabilityEvent e) => {
      'id': e.id,
      'rule_id': e.ruleId,
      'task_id': e.taskId,
      'due_date': e.dueDate,
      'triggered_on': e.triggeredOn,
      'reason': e.reason?.name,
      'outcome': e.outcome.name,
      'new_due_date': e.newDueDate,
      'note': e.note,
      'resolved_at': _ts(e.resolvedAt),
    };

AccountabilityEvent eventFromA(Row r) => AccountabilityEvent(
      id: r['id'] as String,
      ruleId: r['rule_id'] as String?,
      taskId: r['task_id'] as String?,
      dueDate: r['due_date'] as String,
      triggeredOn: r['triggered_on'] as String,
      reason: r['reason'] == null ? null : DelayReason.values.byName(r['reason'] as String),
      outcome: EventOutcome.values.byName(r['outcome'] as String),
      newDueDate: r['new_due_date'] as String?,
      note: r['note'] as String,
      resolvedAt: _dt(r['resolved_at']),
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
      'sex': s.sex?.name,
      'health_settings': s.health.toJson(),
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
    sex: Sex.values.where((x) => x.name == r['sex']).firstOrNull,
    health: HealthSettings.fromJson((r['health_settings'] as Map?)?.cast<String, Object?>()),
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
  SyncTable('daily_activity', (d) => [for (final x in d.activity) activityRow(x)], activityFrom),
  SyncTable('sleep_sessions', (d) => [for (final x in d.sleep) sleepRow(x)], sleepFrom),
  SyncTable('body_metrics', (d) => [for (final x in d.bodyMetrics) bodyMetricRow(x)], bodyMetricFrom),
  SyncTable('device_workouts', (d) => [for (final x in d.deviceWorkouts) deviceWorkoutRow(x)], deviceWorkoutFrom),
  SyncTable('custom_foods', (d) => [for (final x in d.customFoods) customFoodRow(x)], customFoodFrom),
  SyncTable('food_logs', (d) => [for (final x in d.foodLogs) foodLogRow(x)], foodLogFrom),
  SyncTable('water_intake', (d) => [for (final x in d.water) waterRow(x)], waterFrom),
  SyncTable('workout_plans', (d) => [for (final x in d.workoutPlans) workoutPlanRow(x)], workoutPlanFrom),
  SyncTable('workout_sessions', (d) => [for (final x in d.workoutSessions) workoutSessionRow(x)], workoutSessionFrom),
  SyncTable('learning_paths', (d) => [for (final x in d.learningPaths) learningPathRow(x)], learningPathFrom),
  SyncTable('lesson_progress', (d) => [for (final x in d.lessonProgresses) lessonProgressRow(x)], lessonProgressFrom),
  SyncTable('assessments', (d) => [for (final x in d.assessments) assessmentRow(x)], assessmentFrom),
  SyncTable('vocab_reviews', (d) => [for (final x in d.vocabReviews) vocabReviewRow(x)], vocabReviewFrom),
  SyncTable('accountability_rules', (d) => [for (final x in d.accountabilityRules) ruleRow(x)], ruleFrom),
  SyncTable('accountability_events', (d) => [for (final x in d.accountabilityEvents) eventRowA(x)], eventFromA),
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
    activity: read('daily_activity', activityFrom),
    sleep: read('sleep_sessions', sleepFrom),
    bodyMetrics: read('body_metrics', bodyMetricFrom),
    deviceWorkouts: read('device_workouts', deviceWorkoutFrom),
    customFoods: read('custom_foods', customFoodFrom),
    foodLogs: read('food_logs', foodLogFrom),
    water: read('water_intake', waterFrom),
    workoutPlans: read('workout_plans', workoutPlanFrom),
    workoutSessions: read('workout_sessions', workoutSessionFrom),
    learningPaths: read('learning_paths', learningPathFrom),
    lessonProgresses: read('lesson_progress', lessonProgressFrom),
    assessments: read('assessments', assessmentFrom),
    vocabReviews: read('vocab_reviews', vocabReviewFrom),
    accountabilityRules: read('accountability_rules', ruleFrom),
    accountabilityEvents: read('accountability_events', eventFromA),
    notes: read('notes', noteFrom),
    expenses: read('expenses', expenseFrom),
    budgets: read('budgets', budgetFrom),
  );
}
