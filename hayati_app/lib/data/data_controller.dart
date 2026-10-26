import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/dates.dart';
import 'app_data.dart';
import 'auth.dart';
import 'models/assistant.dart';
import 'models/goal.dart';
import 'models/misc.dart';
import 'models/settings.dart';
import 'models/task.dart';
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
