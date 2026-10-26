import '../core/utils/dates.dart';
import '../data/app_data.dart';
import '../data/models/goal.dart';
import '../data/models/misc.dart';
import '../data/models/task.dart';

/// Goal progress, measured by exactly one method (section 11).
class GoalProgress {
  const GoalProgress({required this.mode, required this.percent, this.done = 0, this.total = 0});

  final ProgressMode mode;

  /// 0–100, or null when there is nothing to measure yet (no milestones).
  final int? percent;
  final int done;
  final int total;

  static GoalProgress of(Goal g, List<Milestone> milestones) {
    if (g.progressMode == ProgressMode.manual) {
      return GoalProgress(mode: g.progressMode, percent: g.manualProgress.clamp(0, 100));
    }
    final total = milestones.length;
    final done = milestones.where((m) => m.done).length;
    return GoalProgress(
      mode: g.progressMode,
      percent: total == 0 ? null : (done * 100 / total).round(),
      done: done,
      total: total,
    );
  }
}

/// Habit statistics where non-due days are neutral, not failures, and a
/// missed day never erases earlier completions.
class HabitStats {
  const HabitStats({required this.dueDays, required this.doneDays, required this.streak});

  final int dueDays;
  final int doneDays;

  /// Consecutive due days completed, counting back from the most recent due
  /// day (today counts only once logged).
  final int streak;

  double? get adherence => dueDays == 0 ? null : doneDays / dueDays;

  static HabitStats compute(Habit h, Set<String> loggedDays, DateTime from, DateTime to) {
    var due = 0, done = 0;
    for (var d = dateOnly(from); !d.isAfter(dateOnly(to)); d = d.add(const Duration(days: 1))) {
      if (!h.isDueOn(d)) continue;
      due++;
      if (loggedDays.contains(dayKey(d))) done++;
    }
    var streak = 0;
    var d = dateOnly(to);
    // Today not yet logged doesn't break the streak.
    if (h.isDueOn(d) && !loggedDays.contains(dayKey(d))) d = d.subtract(const Duration(days: 1));
    for (var i = 0; i < 366; i++, d = d.subtract(const Duration(days: 1))) {
      if (d.isBefore(parseDayKey(h.startDate))) break;
      if (!h.isDueOn(d)) continue;
      if (!loggedDays.contains(dayKey(d))) break;
      streak++;
    }
    return HabitStats(dueDays: due, doneDays: done, streak: streak);
  }
}

/// Sums per currency — never across currencies.
Map<String, int> totalsByCurrency(Iterable<Expense> expenses) {
  final out = <String, int>{};
  for (final e in expenses) {
    out[e.currency] = (out[e.currency] ?? 0) + e.amountMinor;
  }
  return out;
}

bool _inRange(DateTime t, DateTime from, DateTime toExclusive) =>
    !t.isBefore(from) && t.isBefore(toExclusive);

/// Weekly / period report computed only from recorded data (screen 17).
class PeriodReport {
  PeriodReport._({
    required this.from,
    required this.to,
    required this.completed,
    required this.dueInPeriod,
    required this.dueCompleted,
    required this.overdue,
    required this.habitDue,
    required this.habitDone,
    required this.spending,
    required this.goals,
    required this.highlights,
  });

  final DateTime from;

  /// Exclusive.
  final DateTime to;

  /// Tasks completed during the period (any deadline).
  final int completed;

  /// Tasks whose deadline falls in the period, excluding cancelled ones.
  final int dueInPeriod;
  final int dueCompleted;

  /// Due in the period, deadline passed, still open.
  final int overdue;
  final int habitDue;
  final int habitDone;
  final Map<String, int> spending;
  final List<(Goal, GoalProgress)> goals;
  final List<Task> highlights;

  double? get completionRate => dueInPeriod == 0 ? null : dueCompleted / dueInPeriod;
  double? get habitRate => habitDue == 0 ? null : habitDone / habitDue;

  bool get hasData =>
      completed > 0 || dueInPeriod > 0 || habitDue > 0 || spending.isNotEmpty || goals.isNotEmpty;

  static PeriodReport build(AppData data, DateTime from, DateTime toExclusive, DateTime now) {
    final completedTasks = data.tasks
        .where((t) => t.isDone && t.completedAt != null && _inRange(t.completedAt!, from, toExclusive))
        .toList()
      ..sort((a, b) => b.priority.index.compareTo(a.priority.index));

    final due = data.tasks.where((t) {
      final d = t.dueAt;
      return d != null && t.status != TaskStatus.cancelled && _inRange(d, from, toExclusive);
    }).toList();

    var habitDue = 0, habitDone = 0;
    final last = toExclusive.subtract(const Duration(days: 1));
    final until = last.isAfter(now) ? now : last;
    for (final h in data.habits) {
      final logged = data.habitLogs.where((l) => l.habitId == h.id).map((l) => l.day).toSet();
      final s = HabitStats.compute(h, logged, from, until);
      habitDue += s.dueDays;
      habitDone += s.doneDays;
    }

    return PeriodReport._(
      from: from,
      to: toExclusive,
      completed: completedTasks.length,
      dueInPeriod: due.length,
      dueCompleted: due.where((t) => t.isDone).length,
      overdue: due.where((t) => t.isOverdue(now)).length,
      habitDue: habitDue,
      habitDone: habitDone,
      spending: totalsByCurrency(data.expenses.where((e) => _inRange(e.spentAt, from, toExclusive))),
      goals: [
        for (final g in data.goals.where((g) => g.status == GoalStatus.active))
          (g, GoalProgress.of(g, data.milestonesOf(g.id))),
      ],
      highlights: completedTasks.take(3).toList(),
    );
  }
}
