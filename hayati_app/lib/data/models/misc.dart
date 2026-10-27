import '../../core/utils/dates.dart';

class Note {
  const Note({
    required this.id,
    required this.title,
    this.body = '',
    this.category = '',
    this.pinned = false,
    this.archived = false,
    this.goalId,
    this.taskId,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final bool pinned;
  final bool archived;
  final String? goalId;
  final String? taskId;
  final DateTime updatedAt;

  Note copyWith({
    String? title,
    String? body,
    String? category,
    bool? pinned,
    bool? archived,
    String? Function()? goalId,
    DateTime? updatedAt,
  }) =>
      Note(
        id: id,
        title: title ?? this.title,
        body: body ?? this.body,
        category: category ?? this.category,
        pinned: pinned ?? this.pinned,
        archived: archived ?? this.archived,
        goalId: goalId != null ? goalId() : this.goalId,
        taskId: taskId,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'category': category,
        'pinned': pinned,
        'archived': archived,
        'goalId': goalId,
        'taskId': taskId,
        'updatedAt': encodeInstant(updatedAt),
      };

  factory Note.fromJson(Map<String, Object?> j) => Note(
        id: j['id'] as String,
        title: j['title'] as String,
        body: (j['body'] as String?) ?? '',
        category: (j['category'] as String?) ?? '',
        pinned: (j['pinned'] as bool?) ?? false,
        archived: (j['archived'] as bool?) ?? false,
        goalId: j['goalId'] as String?,
        taskId: j['taskId'] as String?,
        updatedAt: decodeInstant(j['updatedAt'])!,
      );
}

const defaultExpenseCategories = [
  'food',
  'transport',
  'shopping',
  'education',
  'bills',
  'entertainment',
  'other',
];

/// Amounts are stored in minor units (e.g. halalas, cents) to avoid floating
/// point error. Every record keeps its own currency; totals are never summed
/// across currencies.
class Expense {
  const Expense({
    required this.id,
    required this.amountMinor,
    required this.currency,
    required this.category,
    required this.spentAt,
    this.description = '',
  }) : assert(amountMinor > 0);

  final String id;
  final int amountMinor;
  final String currency;
  final String category;
  final DateTime spentAt;
  final String description;

  Map<String, Object?> toJson() => {
        'id': id,
        'amountMinor': amountMinor,
        'currency': currency,
        'category': category,
        'spentAt': encodeInstant(spentAt),
        'description': description,
      };

  factory Expense.fromJson(Map<String, Object?> j) => Expense(
        id: j['id'] as String,
        amountMinor: j['amountMinor'] as int,
        currency: j['currency'] as String,
        category: j['category'] as String,
        spentAt: decodeInstant(j['spentAt'])!,
        description: (j['description'] as String?) ?? '',
      );
}

/// A simple monthly budget for one currency (optionally one category).
class Budget {
  const Budget({
    required this.id,
    required this.currency,
    required this.limitMinor,
    this.category,
  });

  final String id;
  final String currency;
  final int limitMinor;
  final String? category;

  Map<String, Object?> toJson() =>
      {'id': id, 'currency': currency, 'limitMinor': limitMinor, 'category': category};

  factory Budget.fromJson(Map<String, Object?> j) => Budget(
        id: j['id'] as String,
        currency: j['currency'] as String,
        limitMinor: j['limitMinor'] as int,
        category: j['category'] as String?,
      );
}

enum NotificationType { task, event, habit, plan, assistant, billing, accountability }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    this.body = '',
    required this.createdAt,
    this.read = false,
    this.refId,
    required this.dedupeKey,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String? refId;

  /// Prevents the same reminder being delivered twice.
  final String dedupeKey;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        read: read ?? this.read,
        refId: refId,
        dedupeKey: dedupeKey,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'body': body,
        'createdAt': encodeInstant(createdAt),
        'read': read,
        'refId': refId,
        'dedupeKey': dedupeKey,
      };

  factory AppNotification.fromJson(Map<String, Object?> j) => AppNotification(
        id: j['id'] as String,
        type: NotificationType.values.byName(j['type'] as String),
        title: j['title'] as String,
        body: (j['body'] as String?) ?? '',
        createdAt: decodeInstant(j['createdAt'])!,
        read: (j['read'] as bool?) ?? false,
        refId: j['refId'] as String?,
        dedupeKey: j['dedupeKey'] as String,
      );
}

/// A support report saved locally until a backend is connected.
class SupportReport {
  const SupportReport({
    required this.id,
    required this.kind,
    required this.description,
    this.steps = '',
    this.techInfo,
    required this.createdAt,
  });

  final String id;
  final String kind;
  final String description;
  final String steps;
  final String? techInfo;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind,
        'description': description,
        'steps': steps,
        'techInfo': techInfo,
        'createdAt': encodeInstant(createdAt),
      };

  factory SupportReport.fromJson(Map<String, Object?> j) => SupportReport(
        id: j['id'] as String,
        kind: j['kind'] as String,
        description: j['description'] as String,
        steps: (j['steps'] as String?) ?? '',
        techInfo: j['techInfo'] as String?,
        createdAt: decodeInstant(j['createdAt'])!,
      );
}
