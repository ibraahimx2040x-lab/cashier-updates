import '../../core/utils/dates.dart';

/// How a goal's progress is measured. The two are never mixed (section 11).
enum ProgressMode { milestones, manual }

enum GoalStatus { active, paused, completed, archived }

enum GoalCategory { learning, health, work, money, personal }

class Goal {
  const Goal({
    required this.id,
    required this.title,
    this.description = '',
    this.category = GoalCategory.personal,
    this.startDate,
    this.targetDate,
    this.why = '',
    this.progressMode = ProgressMode.milestones,
    this.manualProgress = 0,
    this.status = GoalStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final GoalCategory category;
  final String? startDate;
  final String? targetDate;
  final String why;
  final ProgressMode progressMode;

  /// 0–100, only meaningful when [progressMode] is manual.
  final int manualProgress;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal copyWith({
    String? title,
    String? description,
    GoalCategory? category,
    String? Function()? startDate,
    String? Function()? targetDate,
    String? why,
    ProgressMode? progressMode,
    int? manualProgress,
    GoalStatus? status,
    DateTime? updatedAt,
  }) =>
      Goal(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        startDate: startDate != null ? startDate() : this.startDate,
        targetDate: targetDate != null ? targetDate() : this.targetDate,
        why: why ?? this.why,
        progressMode: progressMode ?? this.progressMode,
        manualProgress: manualProgress ?? this.manualProgress,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'startDate': startDate,
        'targetDate': targetDate,
        'why': why,
        'progressMode': progressMode.name,
        'manualProgress': manualProgress,
        'status': status.name,
        'createdAt': encodeInstant(createdAt),
        'updatedAt': encodeInstant(updatedAt),
      };

  factory Goal.fromJson(Map<String, Object?> j) => Goal(
        id: j['id'] as String,
        title: j['title'] as String,
        description: (j['description'] as String?) ?? '',
        category: GoalCategory.values.byName(j['category'] as String),
        startDate: j['startDate'] as String?,
        targetDate: j['targetDate'] as String?,
        why: (j['why'] as String?) ?? '',
        progressMode: ProgressMode.values.byName(j['progressMode'] as String),
        manualProgress: (j['manualProgress'] as int?) ?? 0,
        status: GoalStatus.values.byName(j['status'] as String),
        createdAt: decodeInstant(j['createdAt'])!,
        updatedAt: decodeInstant(j['updatedAt'])!,
      );
}

class Milestone {
  const Milestone({
    required this.id,
    required this.goalId,
    required this.title,
    this.done = false,
    required this.order,
  });

  final String id;
  final String goalId;
  final String title;
  final bool done;
  final int order;

  Milestone copyWith({String? title, bool? done, int? order}) => Milestone(
        id: id,
        goalId: goalId,
        title: title ?? this.title,
        done: done ?? this.done,
        order: order ?? this.order,
      );

  Map<String, Object?> toJson() =>
      {'id': id, 'goalId': goalId, 'title': title, 'done': done, 'order': order};

  factory Milestone.fromJson(Map<String, Object?> j) => Milestone(
        id: j['id'] as String,
        goalId: j['goalId'] as String,
        title: j['title'] as String,
        done: (j['done'] as bool?) ?? false,
        order: (j['order'] as int?) ?? 0,
      );
}

class Habit {
  const Habit({
    required this.id,
    required this.name,
    this.description = '',
    required this.weekdays,
    required this.startDate,
    this.reminderMinutes,
    this.active = true,
  });

  final String id;
  final String name;
  final String description;

  /// DateTime.weekday values (1 = Monday … 7 = Sunday).
  final Set<int> weekdays;
  final String startDate;
  final int? reminderMinutes;
  final bool active;

  /// Is the habit expected on [day]? Days before the start date, or on
  /// weekdays the habit isn't scheduled, are "not due" — never failures.
  bool isDueOn(DateTime day) =>
      active && weekdays.contains(day.weekday) && !dateOnly(day).isBefore(parseDayKey(startDate));

  Habit copyWith({
    String? name,
    String? description,
    Set<int>? weekdays,
    String? startDate,
    int? Function()? reminderMinutes,
    bool? active,
  }) =>
      Habit(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        weekdays: weekdays ?? this.weekdays,
        startDate: startDate ?? this.startDate,
        reminderMinutes: reminderMinutes != null ? reminderMinutes() : this.reminderMinutes,
        active: active ?? this.active,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'weekdays': (weekdays.toList()..sort()),
        'startDate': startDate,
        'reminderMinutes': reminderMinutes,
        'active': active,
      };

  factory Habit.fromJson(Map<String, Object?> j) => Habit(
        id: j['id'] as String,
        name: j['name'] as String,
        description: (j['description'] as String?) ?? '',
        weekdays: ((j['weekdays'] as List?) ?? const []).cast<int>().toSet(),
        startDate: j['startDate'] as String,
        reminderMinutes: j['reminderMinutes'] as int?,
        active: (j['active'] as bool?) ?? true,
      );
}

/// One completion of a habit on a calendar day. (habitId, day) is unique.
class HabitLog {
  const HabitLog({required this.id, required this.habitId, required this.day});

  final String id;
  final String habitId;
  final String day;

  Map<String, Object?> toJson() => {'id': id, 'habitId': habitId, 'day': day};

  factory HabitLog.fromJson(Map<String, Object?> j) =>
      HabitLog(id: j['id'] as String, habitId: j['habitId'] as String, day: j['day'] as String);
}
