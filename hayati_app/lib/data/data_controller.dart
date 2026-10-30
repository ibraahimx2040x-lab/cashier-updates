import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/dates.dart';
import '../domain/sleep.dart';
import '../domain/womens/cycle.dart';
import 'app_data.dart';
import 'auth.dart';
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
import 'remote/sync.dart';
import 'store/local_store.dart';

/// Injectable clock so planning, reminders and reports are testable.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

String newId() => const Uuid().v4();

/// Owns the signed-in user's data and every mutation of it. Each mutation
/// validates its input, updates state and persists.
///
/// Rules enforced here (not in the UI) so the assistant executor gets the
/// same guarantees as manual edits:
/// * a task may only link to a goal/milestone the same user owns;
/// * one habit log per habit per day;
/// * expenses must be positive;
/// * completing the last open task of a milestone completes the milestone.
class DataController extends Notifier<AppData> {
  String? _userId;

  LocalStore get _store => ref.read(localStoreProvider);
  DateTime get _now => ref.read(clockProvider)();

  String get _key => 'hayati.data.$_userId';

  /// Current data for non-widget callers (executor, reminders).
  AppData get snapshot => state;

  @override
  AppData build() {
    _userId = ref.watch(authProvider.select((s) => s.user?.id));
    if (_userId == null) return const AppData();
    final raw = _store.readJson(_key);
    final data = raw == null ? const AppData() : AppData.fromJson(raw);
    // Connected mode: the device copy is a cache. Start syncing once built
    // (providers can't be modified during build).
    final user = _userId;
    Future.microtask(() {
      if (_userId == user) ref.read(syncProvider.notifier).start(hasCache: raw != null, apply: _applyRemote);
    });
    return _applyRetention(data);
  }

  /// Applies a server snapshot without queueing it back to the server.
  void _applyRemote(AppData Function(AppData) merge) {
    if (_userId == null) return;
    state = merge(state);
    _store.writeJson(_key, state.toJson());
  }

  AppData _applyRetention(AppData d) {
    final days = d.settings.assistant.retentionDays;
    if (days <= 0) return d;
    final cutoff = _now.subtract(Duration(days: days));
    final expired = d.conversations.where((c) => c.updatedAt.isBefore(cutoff)).map((c) => c.id).toSet();
    if (expired.isEmpty) return d;
    return d.copyWith(
      conversations: d.conversations.where((c) => !expired.contains(c.id)).toList(),
      messages: d.messages.where((m) => !expired.contains(m.conversationId)).toList(),
      proposals: d.proposals.where((p) => !expired.contains(p.conversationId)).toList(),
    );
  }

  void _set(AppData next) {
    final prev = state;
    state = next;
    if (_userId == null) return;
    _store.writeJson(_key, next.toJson());
    ref.read(syncProvider.notifier).enqueue(prev, next);
  }

  static List<T> _upsert<T>(List<T> list, T item, String Function(T) id) {
    final i = list.indexWhere((e) => id(e) == id(item));
    final copy = [...list];
    if (i < 0) {
      copy.add(item);
    } else {
      copy[i] = item;
    }
    return copy;
  }

  /// Runs [body] atomically: if it throws, every change it made is rolled
  /// back and the error is rethrown.
  T transaction<T>(T Function() body) {
    final before = state;
    try {
      return body();
    } catch (_) {
      _set(before);
      rethrow;
    }
  }

  // ---------------------------------------------------------------- settings

  void updateSettings(UserSettings Function(UserSettings) f) =>
      _set(state.copyWith(settings: f(state.settings)));

  /// Records the user's sex and turns on the matching health section
  /// (switching it over if it changes). Other sections stay as they are.
  void setSex(Sex sex) => updateSettings((s) {
        final modules = {...s.health.modules}..removeAll({HealthModule.womens, HealthModule.mens});
        modules.add(sex == Sex.female ? HealthModule.womens : HealthModule.mens);
        return s.copyWith(sex: sex, health: s.health.copyWith(modules: modules));
      });

  // ------------------------------------------------------------------- tasks

  Task newTask({
    required String title,
    String description = '',
    String? dueDate,
    int? dueTime,
    int? estimatedMinutes,
    Priority priority = Priority.medium,
    String? goalId,
    String? milestoneId,
    DateTime? reminderAt,
    DateTime? plannedStart,
  }) {
    final now = _now;
    return Task(
      id: newId(),
      title: title,
      description: description,
      dueDate: dueDate,
      dueTime: dueTime,
      estimatedMinutes: estimatedMinutes,
      priority: priority,
      goalId: goalId,
      milestoneId: milestoneId,
      reminderAt: reminderAt,
      plannedStart: plannedStart,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Throws [ArgumentError] on invalid input.
  void saveTask(Task t) {
    if (t.title.trim().isEmpty) throw ArgumentError('title');
    if (t.estimatedMinutes != null && t.estimatedMinutes! <= 0) {
      throw ArgumentError('estimatedMinutes');
    }
    if (t.goalId != null && state.goal(t.goalId) == null) throw ArgumentError('goalId');
    if (t.milestoneId != null &&
        !state.milestones.any((m) => m.id == t.milestoneId && m.goalId == t.goalId)) {
      throw ArgumentError('milestoneId');
    }
    _set(state.copyWith(tasks: _upsert(state.tasks, t.copyWith(updatedAt: _now), (e) => e.id)));
  }

  void setTaskStatus(String id, TaskStatus status) {
    final t = state.task(id);
    if (t == null) return;
    final now = _now;
    final updated = t.copyWith(
      status: status,
      completedAt: () => status == TaskStatus.done ? (t.completedAt ?? now) : null,
      updatedAt: now,
    );
    var next = state.copyWith(tasks: _upsert(state.tasks, updated, (e) => e.id));
    // Milestone auto-completion: progress follows recorded completions.
    if (status == TaskStatus.done && updated.milestoneId != null) {
      final linked = next.tasks
          .where((x) => x.milestoneId == updated.milestoneId && x.status != TaskStatus.cancelled);
      if (linked.every((x) => x.isDone)) {
        next = next.copyWith(
          milestones: next.milestones
              .map((m) => m.id == updated.milestoneId ? m.copyWith(done: true) : m)
              .toList(),
        );
      }
    }
    _set(next);
  }

  void toggleTaskDone(String id) {
    final t = state.task(id);
    if (t == null) return;
    setTaskStatus(id, t.isDone ? TaskStatus.todo : TaskStatus.done);
  }

  void archiveTask(String id, {bool archived = true}) {
    final t = state.task(id);
    if (t == null) return;
    _set(state.copyWith(
        tasks: _upsert(state.tasks, t.copyWith(archived: archived, updatedAt: _now), (e) => e.id)));
  }

  void deleteTask(String id) {
    _set(state.copyWith(
      tasks: state.tasks.where((t) => t.id != id).toList(),
      notifications: state.notifications.where((n) => n.refId != id).toList(),
    ));
  }

  /// Restores tasks to earlier values (undo for plan application).
  void restoreTasks(List<Task> previous) {
    var tasks = state.tasks;
    for (final t in previous) {
      tasks = _upsert(tasks, t, (e) => e.id);
    }
    _set(state.copyWith(tasks: tasks));
  }

  // ------------------------------------------------------------------ events

  void saveEvent(CalendarEvent e) {
    if (e.title.trim().isEmpty) throw ArgumentError('title');
    if (!e.end.isAfter(e.start)) throw ArgumentError('end');
    _set(state.copyWith(events: _upsert(state.events, e.copyWith(updatedAt: _now), (x) => x.id)));
  }

  void deleteEvent(String id) => _set(state.copyWith(
        events: state.events.where((e) => e.id != id).toList(),
        notifications: state.notifications.where((n) => n.refId != id).toList(),
      ));

  /// Events overlapping [start, end) other than [exceptId].
  List<CalendarEvent> conflicts(DateTime start, DateTime end, {String? exceptId}) =>
      state.events.where((e) => e.id != exceptId && e.overlaps(start, end)).toList();

  // ------------------------------------------------------------------- goals

  void saveGoal(Goal g, List<Milestone> milestones) {
    if (g.title.trim().isEmpty) throw ArgumentError('title');
    if (g.manualProgress < 0 || g.manualProgress > 100) throw ArgumentError('manualProgress');
    final ids = milestones.map((m) => m.id).toSet();
    final removed = state.milestones.where((m) => m.goalId == g.id && !ids.contains(m.id)).map((m) => m.id).toSet();
    _set(state.copyWith(
      goals: _upsert(state.goals, g.copyWith(updatedAt: _now), (e) => e.id),
      milestones: [
        ...state.milestones.where((m) => m.goalId != g.id),
        for (var i = 0; i < milestones.length; i++) milestones[i].copyWith(order: i),
      ],
      // Tasks pointing at a removed milestone stay linked to the goal only.
      tasks: state.tasks
          .map((t) => removed.contains(t.milestoneId) ? t.copyWith(milestoneId: () => null) : t)
          .toList(),
    ));
  }

  void setGoalStatus(String id, GoalStatus status) {
    final g = state.goal(id);
    if (g == null) return;
    _set(state.copyWith(goals: _upsert(state.goals, g.copyWith(status: status, updatedAt: _now), (e) => e.id)));
  }

  void toggleMilestone(String id) => _set(state.copyWith(
        milestones: state.milestones.map((m) => m.id == id ? m.copyWith(done: !m.done) : m).toList(),
      ));

  /// Deletes a goal; its tasks are kept and unlinked.
  void deleteGoal(String id) => _set(state.copyWith(
        goals: state.goals.where((g) => g.id != id).toList(),
        milestones: state.milestones.where((m) => m.goalId != id).toList(),
        tasks: state.tasks
            .map((t) => t.goalId == id ? t.copyWith(goalId: () => null, milestoneId: () => null) : t)
            .toList(),
        notes: state.notes.map((n) => n.goalId == id ? n.copyWith(goalId: () => null) : n).toList(),
      ));

  // ------------------------------------------------------------------ habits

  void saveHabit(Habit h) {
    if (h.name.trim().isEmpty) throw ArgumentError('name');
    if (h.weekdays.isEmpty) throw ArgumentError('weekdays');
    _set(state.copyWith(habits: _upsert(state.habits, h, (e) => e.id)));
  }

  void deleteHabit(String id) => _set(state.copyWith(
        habits: state.habits.where((h) => h.id != id).toList(),
        habitLogs: state.habitLogs.where((l) => l.habitId != id).toList(),
      ));

  /// Records (or, if [done] is false, removes) a completion. Idempotent:
  /// logging the same day twice never creates a duplicate.
  void setHabitDone(String habitId, String day, bool done) {
    final exists = state.habitDoneOn(habitId, day);
    if (done == exists) return;
    if (done && dateOnly(parseDayKey(day)).isAfter(dateOnly(_now))) {
      throw ArgumentError('future');
    }
    _set(state.copyWith(
      habitLogs: done
          ? [...state.habitLogs, HabitLog(id: newId(), habitId: habitId, day: day)]
          : state.habitLogs.where((l) => !(l.habitId == habitId && l.day == day)).toList(),
    ));
  }

  /// Records (or un-records) a prayer the user says they prayed. Never
  /// called automatically when a prayer time passes.
  void setPrayerLogged(Prayer prayer, String day, bool logged) {
    if (logged == state.prayerLogged(prayer, day)) return;
    if (logged && dateOnly(parseDayKey(day)).isAfter(dateOnly(_now))) {
      throw ArgumentError('future');
    }
    _set(state.copyWith(
      prayerLogs: logged
          ? [...state.prayerLogs, PrayerLog(id: newId(), day: day, prayer: prayer)]
          : state.prayerLogs.where((l) => !(l.prayer == prayer && l.day == day)).toList(),
    ));
  }

  // ---------------------------------------------------------------- activity

  /// Records a day's activity from one source, replacing that source's
  /// previous numbers for the day. The id is derived from (user, day,
  /// source) so two devices reading the same source write the same row.
  void recordActivity(String day, ActivitySource source, {required int steps, int? distanceM, int? activeMinutes}) {
    if (dateOnly(parseDayKey(day)).isAfter(dateOnly(_now))) throw ArgumentError('future');
    if (steps < 0 || steps > DailyActivity.maxSteps) throw ArgumentError('steps');
    if ((distanceM ?? 0) < 0 || (activeMinutes ?? 0) < 0 || (activeMinutes ?? 0) > 1440) throw ArgumentError('value');
    final existing = state.activity.where((a) => a.day == day && a.source == source).firstOrNull;
    if (existing != null && existing.steps == steps && existing.distanceM == distanceM && existing.activeMinutes == activeMinutes) {
      return;
    }
    final row = DailyActivity(
      id: existing?.id ?? const Uuid().v5(Namespace.url.value, 'hayati:activity:$_userId:$day:${source.name}'),
      day: day,
      source: source,
      steps: steps,
      distanceM: distanceM,
      activeMinutes: activeMinutes,
      updatedAt: _now,
    );
    _set(state.copyWith(activity: _upsert(state.activity, row, (a) => a.id)));
  }

  void deleteActivity(String id) =>
      _set(state.copyWith(activity: state.activity.where((a) => a.id != id).toList()));

  /// Replaces what [source] holds for the window starting at [from] with
  /// what the health store returned: sessions it no longer has (deleted
  /// there) go, the rest keep their ids. Segments are merged first.
  void importSleep(ActivitySource source, List<(DateTime, DateTime)> segments, {required DateTime from}) {
    final now = _now;
    final merged = mergeSleepSegments([
      for (final s in segments)
        if (!s.$2.isAfter(now.add(const Duration(minutes: 10)))) s,
    ]);
    final kept = state.sleep.where((s) => s.source != source || s.end.isBefore(from)).toList();
    final old = {for (final s in state.sleep.where((s) => s.source == source)) s.id: s};
    final fresh = <SleepSession>[];
    for (final (start, end) in merged) {
      if (end.isBefore(from)) continue;
      final id = const Uuid().v5(Namespace.url.value, 'hayati:sleep:$_userId:${source.name}:${start.toUtc().toIso8601String()}');
      final prev = old[id];
      fresh.add(prev != null && prev.end == end
          ? prev
          : SleepSession(id: id, source: source, start: start, end: end, quality: prev?.quality, updatedAt: now));
    }
    final next = [...kept, ...fresh];
    if (_sameIds(next, state.sleep, (s) => '${s.id}${s.end}')) return;
    _set(state.copyWith(sleep: next));
  }

  /// One resting heart rate per day and [source]: the day's average.
  void importRestingHeart(ActivitySource source, List<(DateTime, double)> samples) {
    final byDay = <String, List<(DateTime, double)>>{};
    for (final x in samples) {
      final (lo, hi) = BodyMetric.range(MetricKind.restingHr);
      if (x.$2 < lo || x.$2 > hi || x.$1.isAfter(_now.add(const Duration(minutes: 10)))) continue;
      (byDay[dayKey(x.$1)] ??= []).add(x);
    }
    var list = state.bodyMetrics;
    for (final e in byDay.entries) {
      final avg = (e.value.fold(0.0, (a, x) => a + x.$2) / e.value.length).roundToDouble();
      final at = e.value.map((x) => x.$1).reduce((a, b) => a.isAfter(b) ? a : b);
      final id = const Uuid().v5(Namespace.url.value, 'hayati:metric:$_userId:restingHr:${source.name}:${e.key}');
      final prev = list.where((m) => m.id == id).firstOrNull;
      if (prev != null && prev.value == avg && prev.measuredAt == at) continue;
      list = _upsert(list, BodyMetric(id: id, kind: MetricKind.restingHr, value: avg, source: source, measuredAt: at), (m) => m.id);
    }
    if (!identical(list, state.bodyMetrics)) _set(state.copyWith(bodyMetrics: list));
  }

  /// Workouts [source] has from [from] on; ones it no longer has go.
  void importWorkouts(ActivitySource source, List<DeviceWorkout> workouts, {required DateTime from}) {
    final kept = state.deviceWorkouts.where((w) => w.source != source || w.start.isBefore(from)).toList();
    final fresh = [
      for (final w in workouts)
        if (!w.start.isBefore(from) && w.end.isAfter(w.start) && w.end.difference(w.start) <= const Duration(hours: 24) && !w.start.isAfter(_now))
          DeviceWorkout(
            id: const Uuid().v5(Namespace.url.value, 'hayati:workout:$_userId:${source.name}:${w.id}'),
            source: source,
            activity: w.activity,
            start: w.start,
            end: w.end,
            kcal: w.kcal == null || w.kcal! <= 0 ? null : w.kcal!.clamp(0, 10000),
            distanceM: w.distanceM == null || w.distanceM! <= 0 ? null : w.distanceM!.clamp(0, 1000000),
            steps: w.steps == null || w.steps! <= 0 ? null : w.steps!.clamp(0, 200000),
            updatedAt: _now,
          ),
    ];
    // Keep the stored copy when nothing changed, so a re-read doesn't resync.
    final old = {for (final w in state.deviceWorkouts) w.id: w};
    final merged = [
      for (final w in fresh)
        if (old[w.id] case final o? when o.end == w.end && o.kcal == w.kcal && o.distanceM == w.distanceM && o.steps == w.steps && o.activity == w.activity) o else w,
    ];
    final next = [...kept, ...merged];
    if (_sameIds(next, state.deviceWorkouts, (w) => '${w.id}${w.updatedAt}')) return;
    _set(state.copyWith(deviceWorkouts: next));
  }

  /// Removes everything that came from [source] (screen 40, "remove data").
  void deleteSourceData(ActivitySource source) => _set(state.copyWith(
        activity: state.activity.where((a) => a.source != source).toList(),
        sleep: state.sleep.where((s) => s.source != source).toList(),
        bodyMetrics: state.bodyMetrics.where((m) => m.source != source).toList(),
        deviceWorkouts: state.deviceWorkouts.where((w) => w.source != source).toList(),
      ));

  // ----------------------------------------------------------- women's health

  bool _overlaps(String start, String? end, {String? except}) {
    final s = parseDayKey(start);
    final e = end == null ? s.add(const Duration(days: CyclePeriod.maxDays - 1)) : parseDayKey(end);
    for (final p in state.periods) {
      if (p.id == except) continue;
      final ps = parseDayKey(p.start);
      final pe = p.end == null ? ps.add(const Duration(days: CyclePeriod.maxDays - 1)) : parseDayKey(p.end!);
      if (!s.isAfter(pe) && !ps.isAfter(e)) return true;
    }
    return false;
  }

  /// Saves a period after checking it isn't in the future, lasts at most
  /// [CyclePeriod.maxDays] and doesn't overlap another.
  void savePeriod(CyclePeriod p) {
    final today = dateOnly(_now);
    final s = parseDayKey(p.start);
    if (s.isAfter(today)) throw ArgumentError('future');
    if (p.end != null) {
      final e = parseDayKey(p.end!);
      if (e.isBefore(s) || e.isAfter(today) || e.difference(s).inDays >= CyclePeriod.maxDays) throw ArgumentError('end');
    }
    if (_overlaps(p.start, p.end, except: p.id)) throw ArgumentError('overlap');
    _set(state.copyWith(periods: _upsert(state.periods, p.copyWith(updatedAt: _now), (x) => x.id)));
  }

  /// "Started today" (or on [day]). An open period that has run past its
  /// limit is closed first at its last likely day.
  CyclePeriod startPeriod(String day) {
    final open = state.periods.where((p) => p.end == null).firstOrNull;
    if (open != null) {
      final s = parseDayKey(open.start);
      if (!parseDayKey(day).isAfter(s.add(const Duration(days: openPeriodLimit - 1)))) throw ArgumentError('open');
      final est = estimateCycle(state)?.periodLength ?? 5;
      savePeriod(open.copyWith(end: () => dayKey(s.add(Duration(days: est - 1)))));
    }
    final p = CyclePeriod(id: newId(), start: day, updatedAt: _now);
    savePeriod(p);
    return p;
  }

  /// "Ended today" (or on [day]) for the open period.
  void endPeriod(String day) {
    final open = state.periods.where((p) => p.end == null).firstOrNull;
    if (open == null) throw ArgumentError('none');
    savePeriod(open.copyWith(end: () => day));
  }

  void deletePeriod(String id) => _set(state.copyWith(periods: state.periods.where((p) => p.id != id).toList()));

  /// One log per day; an empty one removes the day.
  void saveCycleLog(CycleDayLog log) {
    if (parseDayKey(log.day).isAfter(dateOnly(_now))) throw ArgumentError('future');
    if (!log.valid) throw ArgumentError('log');
    final rest = state.cycleLogs.where((x) => x.day != log.day).toList();
    if (log.isEmpty) {
      _set(state.copyWith(cycleLogs: rest));
      return;
    }
    final id = state.cycleLog(log.day)?.id ?? const Uuid().v5(Namespace.url.value, 'hayati:cycle-log:$_userId:${log.day}');
    _set(state.copyWith(cycleLogs: [
      ...rest,
      CycleDayLog(
        id: id,
        day: log.day,
        flow: log.flow,
        pain: log.pain,
        symptoms: log.symptoms,
        otherSymptoms: log.otherSymptoms.trim(),
        mood: log.mood,
        energy: log.energy,
        note: log.note.trim(),
        updatedAt: _now,
      ),
    ]));
  }

  void saveAppointment(HealthAppointment a) {
    if (!a.valid) throw ArgumentError('appointment');
    _set(state.copyWith(appointments: _upsert(state.appointments, a.copyWith(updatedAt: _now), (x) => x.id)));
  }

  void deleteAppointment(String id) =>
      _set(state.copyWith(appointments: state.appointments.where((a) => a.id != id).toList()));

  /// The health sections only (screen 48), as JSON.
  String exportHealthJson() => const JsonEncoder.withIndent('  ').convert({
        'health': state.settings.health.toJson(),
        'sex': state.settings.sex?.name,
        'activity': [for (final x in state.activity) x.toJson()],
        'sleep': [for (final x in state.sleep) x.toJson()],
        'bodyMetrics': [for (final x in state.bodyMetrics) x.toJson()],
        'deviceWorkouts': [for (final x in state.deviceWorkouts) x.toJson()],
        'foodLogs': [for (final x in state.foodLogs) x.toJson()],
        'customFoods': [for (final x in state.customFoods) x.toJson()],
        'water': [for (final x in state.water) x.toJson()],
        'periods': [for (final x in state.periods) x.toJson()],
        'cycleLogs': [for (final x in state.cycleLogs) x.toJson()],
        'appointments': [for (final x in state.appointments) x.toJson()],
      });

  /// Deletes the health sections' data on every device, keeping the rest
  /// of the account and the settings.
  void deleteHealthData() => _set(state.copyWith(
        activity: const [],
        sleep: const [],
        bodyMetrics: const [],
        deviceWorkouts: const [],
        foodLogs: const [],
        customFoods: const [],
        water: const [],
        periods: const [],
        cycleLogs: const [],
        appointments: const [],
      ));

  static bool _sameIds<T>(List<T> a, List<T> b, String Function(T) key) {
    if (a.length != b.length) return false;
    final ka = a.map(key).toSet();
    return b.every((x) => ka.contains(key(x)));
  }

  void updateHealth(HealthSettings Function(HealthSettings) f) {
    final next = f(state.settings.health);
    if (next.stepGoal < HealthSettings.minStepGoal || next.stepGoal > HealthSettings.maxStepGoal) {
      throw ArgumentError('stepGoal');
    }
    if (next.heightCm != null && (next.heightCm! < 80 || next.heightCm! > 250)) throw ArgumentError('height');
    updateSettings((s) => s.copyWith(health: next));
  }

  // --------------------------------------------------------------- nutrition

  /// Logs [portions] of something with [per] nutrients per portion. The
  /// name and numbers are copied, so later edits to a saved food don't
  /// change what was logged.
  FoodLog logFood({
    required String day,
    required MealType meal,
    required String name,
    required Nutrients per,
    double portions = 1,
    String? foodRef,
  }) {
    if (dateOnly(parseDayKey(day)).isAfter(dateOnly(_now))) throw ArgumentError('future');
    if (name.trim().isEmpty || name.trim().length > 120) throw ArgumentError('name');
    if (portions <= 0 || portions > FoodLog.maxPortions) throw ArgumentError('portions');
    final total = per.times(portions);
    if (!per.valid || !total.valid) throw ArgumentError('nutrients');
    final log = FoodLog(
      id: newId(),
      day: day,
      meal: meal,
      name: name.trim(),
      foodRef: foodRef,
      portions: portions,
      total: total,
      loggedAt: _now,
    );
    _set(state.copyWith(foodLogs: [...state.foodLogs, log]));
    return log;
  }

  void deleteFoodLog(String id) =>
      _set(state.copyWith(foodLogs: state.foodLogs.where((f) => f.id != id).toList()));

  /// Saves a food of the user's own. A barcode is kept once per account:
  /// saving the same barcode again updates that food.
  CustomFood saveCustomFood(CustomFood f) {
    if (f.name.trim().isEmpty || f.name.trim().length > 120 || f.portion.length > 60) throw ArgumentError('name');
    if (!f.per.valid) throw ArgumentError('nutrients');
    if (f.grams != null && (f.grams! <= 0 || f.grams! > 5000)) throw ArgumentError('grams');
    if (f.barcode != null && !CustomFood.barcodePattern.hasMatch(f.barcode!)) throw ArgumentError('barcode');
    final same = f.barcode == null ? null : state.customFoods.where((x) => x.barcode == f.barcode && x.id != f.id).firstOrNull;
    final saved = same == null
        ? f
        : CustomFood(id: same.id, name: f.name, portion: f.portion, grams: f.grams, per: f.per, barcode: f.barcode, createdAt: same.createdAt);
    _set(state.copyWith(customFoods: _upsert(state.customFoods, saved, (x) => x.id)));
    return saved;
  }

  /// Deletes a saved food; meals already logged with it stay.
  void deleteCustomFood(String id) =>
      _set(state.copyWith(customFoods: state.customFoods.where((f) => f.id != id).toList()));

  /// Adds (or with a negative [deltaMl], removes) water for [day].
  void addWater(String day, int deltaMl) {
    if (dateOnly(parseDayKey(day)).isAfter(dateOnly(_now))) throw ArgumentError('future');
    final ml = (state.waterOn(day) + deltaMl).clamp(0, WaterDay.maxMl);
    final id = state.water.where((w) => w.day == day).firstOrNull?.id ??
        const Uuid().v5(Namespace.url.value, 'hayati:water:$_userId:$day');
    _set(state.copyWith(water: _upsert(state.water, WaterDay(id: id, day: day, ml: ml), (w) => w.id)));
  }

  // ----------------------------------------------------------------- fitness

  /// Saves the training profile and a new version of each generated plan.
  /// Previous versions are kept (inactive) so past sessions still show the
  /// plan that was followed.
  void saveFitness(FitnessProfile profile, Map<WorkoutPlace, List<WorkoutDay>> plans) {
    if (plans.isEmpty || plans.values.any((d) => d.isEmpty)) throw ArgumentError('empty');
    final now = _now;
    final updated = [
      // Deactivations first: the server allows one active plan per place.
      for (final p in state.workoutPlans) plans.containsKey(p.place) && p.active ? p.copyWith(active: false) : p,
      for (final e in plans.entries)
        WorkoutPlan(
          id: newId(),
          place: e.key,
          version: state.workoutPlans.where((p) => p.place == e.key).fold(0, (m, p) => p.version > m ? p.version : m) + 1,
          active: true,
          goal: profile.goal,
          days: e.value,
          createdAt: now,
        ),
    ];
    _set(state.copyWith(
      settings: state.settings.copyWith(fitness: () => profile),
      workoutPlans: updated,
    ));
  }

  /// Records a finished session (only sets the user entered).
  void logWorkout(WorkoutSession s) {
    if (dateOnly(parseDayKey(s.day)).isAfter(dateOnly(_now))) throw ArgumentError('future');
    _set(state.copyWith(workoutSessions: _upsert(state.workoutSessions, s, (e) => e.id)));
  }

  void deleteWorkout(String id) =>
      _set(state.copyWith(workoutSessions: state.workoutSessions.where((s) => s.id != id).toList()));

  // ---------------------------------------------------------- accountability

  /// Saves a rule the user agreed to. The task needs a deadline, and a
  /// custom consequence must pass the safety check.
  void saveRule(AccountabilityRule r) {
    final t = state.task(r.taskId);
    if (t == null || t.dueDate == null) throw ArgumentError('task');
    if (r.graceDays < 1 || r.graceDays > 30) throw ArgumentError('graceDays');
    if (r.consequence == Consequence.custom && unsafeConsequence(r.customText) != null) {
      throw ArgumentError('consequence');
    }
    _set(state.copyWith(accountabilityRules: _upsert(state.accountabilityRules, r, (e) => e.id)));
  }

  /// Deletes a rule; its past events stay in the history.
  void deleteRule(String id) => _set(state.copyWith(
        accountabilityRules: state.accountabilityRules.where((r) => r.id != id).toList(),
        accountabilityEvents: [
          for (final e in state.accountabilityEvents)
            e.ruleId == id
                ? AccountabilityEvent(
                    id: e.id,
                    taskId: e.taskId,
                    dueDate: e.dueDate,
                    triggeredOn: e.triggeredOn,
                    reason: e.reason,
                    outcome: e.outcome,
                    newDueDate: e.newDueDate,
                    note: e.note,
                    resolvedAt: e.resolvedAt,
                  )
                : e,
        ],
      ));

  void addAccountabilityEvent(AccountabilityEvent e) {
    if (state.accountabilityEvents.any((x) => x.ruleId == e.ruleId && x.dueDate == e.dueDate)) return;
    _set(state.copyWith(accountabilityEvents: [...state.accountabilityEvents, e]));
  }

  /// The user's answer to a triggered rule. Postponed: the agreed
  /// consequence (as [consequenceTask]) and a new date. Emergency or
  /// illness: a new date only. No longer important: the task is cancelled
  /// and its rule paused. Changes the task only with this explicit answer.
  void resolveAccountability(String eventId, DelayReason reason, {String? newDueDate, String note = '', Task? consequenceTask}) {
    final e = state.accountabilityEvent(eventId);
    if (e == null || !e.pending) return;
    if (reason != DelayReason.notImportant && newDueDate == null) throw ArgumentError('newDueDate');
    final outcome = switch (reason) {
      DelayReason.postponed => EventOutcome.consequenceAccepted,
      DelayReason.emergency || DelayReason.illness => EventOutcome.rescheduled,
      DelayReason.notImportant => EventOutcome.dropped,
    };
    final now = _now;
    final t = state.task(e.taskId);
    final tasks = [
      for (final x in state.tasks)
        if (x.id != e.taskId)
          x
        else if (reason == DelayReason.notImportant)
          x.copyWith(status: TaskStatus.cancelled, updatedAt: now)
        else
          x.copyWith(dueDate: () => newDueDate, dueTime: () => null, updatedAt: now),
      if (reason == DelayReason.postponed && consequenceTask != null && t != null) consequenceTask,
    ];
    _set(state.copyWith(
      tasks: tasks,
      accountabilityEvents: _upsert(
        state.accountabilityEvents,
        e.resolve(reason, outcome, newDueDate: reason == DelayReason.notImportant ? null : newDueDate, note: note, at: now),
        (x) => x.id,
      ),
      accountabilityRules: reason == DelayReason.notImportant
          ? [for (final r in state.accountabilityRules) r.id == e.ruleId ? r.copyWith(active: false) : r]
          : null,
    ));
  }

  // ---------------------------------------------------------------- learning

  /// Starts (or restarts) the English path at [level], keeping history.
  void startLearning(Cefr level, int weeklyGoal, {Assessment? placement}) {
    if (weeklyGoal < 1 || weeklyGoal > 7) throw ArgumentError('weeklyGoal');
    final current = state.learningPath;
    _set(state.copyWith(
      learningPaths: [
        current == null
            ? LearningPath(id: newId(), level: level, weeklyGoal: weeklyGoal, startedAt: _now)
            : current.copyWith(level: level, weeklyGoal: weeklyGoal),
      ],
      assessments: placement == null ? null : [...state.assessments, placement],
    ));
  }

  void setWeeklyLessons(int goal) {
    final p = state.learningPath;
    if (p == null || goal < 1 || goal > 7) return;
    _set(state.copyWith(learningPaths: [p.copyWith(weeklyGoal: goal)]));
  }

  /// Records a lesson quiz (best score kept). The lesson's words join the
  /// review schedule the first time it's taken.
  void recordLesson(String lessonId, int score, List<String> wordIds) {
    if (score < 0 || score > 100) throw ArgumentError('score');
    final old = state.lessonProgress(lessonId);
    final p = LessonProgress(
      id: old?.id ?? newId(),
      lessonId: lessonId,
      bestScore: old == null || score > old.bestScore ? score : old.bestScore,
      attempts: (old?.attempts ?? 0) + 1,
      lastAt: _now,
    );
    final known = {for (final r in state.vocabReviews) r.wordId};
    final tomorrow = dayKey(dateOnly(_now).add(const Duration(days: 1)));
    _set(state.copyWith(
      lessonProgresses: _upsert(state.lessonProgresses, p, (e) => e.id),
      vocabReviews: [
        ...state.vocabReviews,
        for (final w in wordIds)
          if (!known.contains(w)) VocabReview(id: newId(), wordId: w, box: 1, due: tomorrow),
      ],
    ));
  }

  /// Moves a reviewed word to its next box (or back to 1 when missed).
  void reviewWord(String wordId, int box, String due) {
    final r = state.vocabReviews.where((x) => x.wordId == wordId).firstOrNull;
    if (r == null) return;
    _set(state.copyWith(
      vocabReviews: _upsert(state.vocabReviews, VocabReview(id: r.id, wordId: wordId, box: box, due: due), (e) => e.id),
    ));
  }

  /// Saves an end-of-level check; passing moves the path to [next].
  void recordLevelCheck(Assessment a, {Cefr? next}) {
    final p = state.learningPath;
    _set(state.copyWith(
      assessments: [...state.assessments, a],
      learningPaths: p != null && a.passed && next != null ? [p.copyWith(level: next)] : null,
    ));
  }

  // ------------------------------------------------------------------- notes

  void saveNote(Note n) {
    if (n.title.trim().isEmpty && n.body.trim().isEmpty) throw ArgumentError('empty');
    _set(state.copyWith(notes: _upsert(state.notes, n.copyWith(updatedAt: _now), (e) => e.id)));
  }

  void deleteNote(String id) => _set(state.copyWith(notes: state.notes.where((n) => n.id != id).toList()));

  // ---------------------------------------------------------------- expenses

  void addExpense(Expense e) {
    if (e.amountMinor <= 0) throw ArgumentError('amount');
    _set(state.copyWith(expenses: _upsert(state.expenses, e, (x) => x.id)));
  }

  void deleteExpense(String id) =>
      _set(state.copyWith(expenses: state.expenses.where((e) => e.id != id).toList()));

  void saveBudget(Budget b) {
    if (b.limitMinor <= 0) throw ArgumentError('limit');
    // One budget per currency+category.
    final others = state.budgets.where((x) => !(x.currency == b.currency && x.category == b.category) || x.id == b.id);
    _set(state.copyWith(budgets: _upsert(others.toList(), b, (x) => x.id)));
  }

  void deleteBudget(String id) =>
      _set(state.copyWith(budgets: state.budgets.where((b) => b.id != id).toList()));

  // ----------------------------------------------------------- notifications

  /// Adds a notification unless one with the same dedupe key exists.
  bool notify(AppNotification n) {
    if (state.notifications.any((x) => x.dedupeKey == n.dedupeKey)) return false;
    _set(state.copyWith(notifications: [n, ...state.notifications]));
    return true;
  }

  void markNotificationRead(String id) => _set(state.copyWith(
      notifications: state.notifications.map((n) => n.id == id ? n.copyWith(read: true) : n).toList()));

  void markAllNotificationsRead() => _set(
      state.copyWith(notifications: state.notifications.map((n) => n.copyWith(read: true)).toList()));

  /// Clears read notifications. Dedupe keys of cleared items are kept as
  /// hidden tombstones so the same reminder is not re-delivered.
  void clearReadNotifications() {
    _set(state.copyWith(
      notifications: state.notifications
          .map((n) => n.read ? AppNotification(
                id: n.id,
                type: n.type,
                title: '',
                createdAt: n.createdAt,
                read: true,
                dedupeKey: n.dedupeKey,
              ) : n)
          .toList(),
    ));
  }

  // --------------------------------------------------------------- assistant

  Conversation createConversation(String title) {
    final c = Conversation(id: newId(), title: title, updatedAt: _now);
    _set(state.copyWith(conversations: [c, ...state.conversations]));
    return c;
  }

  void deleteConversation(String id) => _set(state.copyWith(
        conversations: state.conversations.where((c) => c.id != id).toList(),
        messages: state.messages.where((m) => m.conversationId != id).toList(),
        proposals: state.proposals.where((p) => p.conversationId != id).toList(),
      ));

  void deleteAllConversations() =>
      _set(state.copyWith(conversations: const [], messages: const [], proposals: const []));

  ChatMessage addMessage(String conversationId, MessageRole role, String text,
      {MessageKind kind = MessageKind.text, String? proposalId}) {
    final m = ChatMessage(
      id: newId(),
      conversationId: conversationId,
      role: role,
      text: text,
      kind: kind,
      proposalId: proposalId,
      createdAt: _now,
    );
    _set(state.copyWith(
      messages: [...state.messages, m],
      conversations: state.conversations
          .map((c) => c.id == conversationId ? c.copyWith(updatedAt: _now) : c)
          .toList(),
    ));
    return m;
  }

  void renameConversation(String id, String title) => _set(state.copyWith(
      conversations: state.conversations.map((c) => c.id == id ? c.copyWith(title: title) : c).toList()));

  void saveProposal(ActionProposal p) =>
      _set(state.copyWith(proposals: _upsert(state.proposals, p, (e) => e.id)));

  void logAction(ActionLog l) => _set(state.copyWith(actionLogs: [l, ...state.actionLogs].take(500).toList()));

  void clearActionLogs() => _set(state.copyWith(actionLogs: const []));

  /// Returns false when today's local allowance is used up.
  bool consumeAssistantRequest(int dailyLimit) {
    final today = dayKey(_now);
    final count = state.usageDay == today ? state.usageCount : 0;
    if (count >= dailyLimit) return false;
    _set(state.copyWith(usageDay: today, usageCount: count + 1));
    return true;
  }

  int assistantUsageToday() => state.usageDay == dayKey(_now) ? state.usageCount : 0;

  // ----------------------------------------------------------------- support

  void addReport(SupportReport r) => _set(state.copyWith(reports: [r, ...state.reports]));

  // -------------------------------------------------------------------- data

  /// Everything the user owns, as pretty JSON (screen 24 export).
  String exportJson() => const JsonEncoder.withIndent('  ').convert(state.toJson());

  Future<void> wipe() async {
    await ref.read(syncProvider.notifier).clear();
    if (_userId != null) await _store.remove(_key);
    state = const AppData();
  }
}

final dataProvider = NotifierProvider<DataController, AppData>(DataController.new);
final settingsProvider = Provider<UserSettings>((ref) => ref.watch(dataProvider.select((d) => d.settings)));
