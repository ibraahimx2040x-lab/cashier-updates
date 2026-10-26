import '../../core/utils/dates.dart';

enum Priority { low, medium, high }

enum TaskStatus { todo, inProgress, done, cancelled }

class Task {
  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.dueTime,
    this.estimatedMinutes,
    this.priority = Priority.medium,
    this.status = TaskStatus.todo,
    this.goalId,
    this.milestoneId,
    this.reminderAt,
    this.plannedStart,
    this.completedAt,
    this.archived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;

  /// The deadline day (`yyyy-MM-dd`). Optional.
  final String? dueDate;

  /// Optional deadline time on [dueDate], minutes since midnight.
  final int? dueTime;

  final int? estimatedMinutes;
  final Priority priority;
  final TaskStatus status;
  final String? goalId;
  final String? milestoneId;
  final DateTime? reminderAt;

  /// When the user (or an approved plan) intends to work on it.
  /// Distinct from the deadline.
  final DateTime? plannedStart;

  final DateTime? completedAt;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDone => status == TaskStatus.done;
  bool get isOpen => status == TaskStatus.todo || status == TaskStatus.inProgress;

  DateTime? get dueAt {
    if (dueDate == null) return null;
    final d = parseDayKey(dueDate!);
    return dueTime == null ? DateTime(d.year, d.month, d.day, 23, 59) : atMinutes(d, dueTime!);
  }

  /// Overdue = open, not archived, and the deadline has passed.
  bool isOverdue(DateTime now) {
    final due = dueAt;
    return isOpen && !archived && due != null && due.isBefore(now);
  }

  Task copyWith({
    String? title,
    String? description,
    String? Function()? dueDate,
    int? Function()? dueTime,
    int? Function()? estimatedMinutes,
    Priority? priority,
    TaskStatus? status,
    String? Function()? goalId,
    String? Function()? milestoneId,
    DateTime? Function()? reminderAt,
    DateTime? Function()? plannedStart,
    DateTime? Function()? completedAt,
    bool? archived,
    DateTime? updatedAt,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        dueDate: dueDate != null ? dueDate() : this.dueDate,
        dueTime: dueTime != null ? dueTime() : this.dueTime,
        estimatedMinutes: estimatedMinutes != null ? estimatedMinutes() : this.estimatedMinutes,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        goalId: goalId != null ? goalId() : this.goalId,
        milestoneId: milestoneId != null ? milestoneId() : this.milestoneId,
        reminderAt: reminderAt != null ? reminderAt() : this.reminderAt,
        plannedStart: plannedStart != null ? plannedStart() : this.plannedStart,
        completedAt: completedAt != null ? completedAt() : this.completedAt,
        archived: archived ?? this.archived,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate,
        'dueTime': dueTime,
        'estimatedMinutes': estimatedMinutes,
        'priority': priority.name,
        'status': status.name,
        'goalId': goalId,
        'milestoneId': milestoneId,
        'reminderAt': encodeInstant(reminderAt),
        'plannedStart': encodeInstant(plannedStart),
        'completedAt': encodeInstant(completedAt),
        'archived': archived,
        'createdAt': encodeInstant(createdAt),
        'updatedAt': encodeInstant(updatedAt),
      };

  factory Task.fromJson(Map<String, Object?> j) => Task(
        id: j['id'] as String,
        title: j['title'] as String,
        description: (j['description'] as String?) ?? '',
        dueDate: j['dueDate'] as String?,
        dueTime: j['dueTime'] as int?,
        estimatedMinutes: j['estimatedMinutes'] as int?,
        priority: Priority.values.byName(j['priority'] as String),
        status: TaskStatus.values.byName(j['status'] as String),
        goalId: j['goalId'] as String?,
        milestoneId: j['milestoneId'] as String?,
        reminderAt: decodeInstant(j['reminderAt']),
        plannedStart: decodeInstant(j['plannedStart']),
        completedAt: decodeInstant(j['completedAt']),
        archived: (j['archived'] as bool?) ?? false,
        createdAt: decodeInstant(j['createdAt'])!,
        updatedAt: decodeInstant(j['updatedAt'])!,
      );
}

class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.location = '',
    this.notes = '',
    this.reminderMinutesBefore,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String location;
  final String notes;
  final int? reminderMinutesBefore;
  final DateTime updatedAt;

  Duration get duration => end.difference(start);

  bool overlaps(DateTime s, DateTime e) => start.isBefore(e) && s.isBefore(end);

  CalendarEvent copyWith({
    String? title,
    DateTime? start,
    DateTime? end,
    String? location,
    String? notes,
    int? Function()? reminderMinutesBefore,
    DateTime? updatedAt,
  }) =>
      CalendarEvent(
        id: id,
        title: title ?? this.title,
        start: start ?? this.start,
        end: end ?? this.end,
        location: location ?? this.location,
        notes: notes ?? this.notes,
        reminderMinutesBefore:
            reminderMinutesBefore != null ? reminderMinutesBefore() : this.reminderMinutesBefore,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'start': encodeInstant(start),
        'end': encodeInstant(end),
        'location': location,
        'notes': notes,
        'reminderMinutesBefore': reminderMinutesBefore,
        'updatedAt': encodeInstant(updatedAt),
      };

  factory CalendarEvent.fromJson(Map<String, Object?> j) => CalendarEvent(
        id: j['id'] as String,
        title: j['title'] as String,
        start: decodeInstant(j['start'])!,
        end: decodeInstant(j['end'])!,
        location: (j['location'] as String?) ?? '',
        notes: (j['notes'] as String?) ?? '',
        reminderMinutesBefore: j['reminderMinutesBefore'] as int?,
        updatedAt: decodeInstant(j['updatedAt'])!,
      );
}
