/// Accountability (design doc v2, section 3-f): consequences the user agrees
/// to in advance for a late task, and what happened when it was late.
library;

/// Agreed outcomes. All are harmless by design: none touches sleep, food,
/// prayer, health care, or adds exercise.
enum Consequence {
  /// An extra weekly review session.
  extraReview,

  /// A short planning session to break the task down.
  planningSession,

  /// A small first step before optional leisure time.
  firstStepFirst,

  /// The user's own wording (checked against the safety rules).
  custom,
}

/// What makes a custom consequence unacceptable: it must never take away
/// sleep, food, prayer or health care, or push harmful exercise.
// Arabic words take prefixes (و، ف، ب، ل، ال، لل), so match from the start of
// a word: «المشاكل» or «المجلد» must not trip «اكل» or «جلد».
final _forbiddenAr = RegExp(
  '(^|[^\u0621-\u064A])(و|ف|ب|ل)?(ال|لل)?'
  '(نوم|انام|أنام|سهر|اسهر|أسهر|طعام|اكل|أكل|وجب|جوع|صيام|اصوم|أصوم|صلا|دواء|علاج|طبيب|مستشف|اضرب|أضرب|جلد|عقاب|تمرين إضافي|تمارين إضافية)',
);
final _forbiddenEn = RegExp(
  r'\b(sleep\w*|food|eat|eating|meals?|starv\w*|fasting|pray\w*|medic\w*|doctors?|hospital|hurt|punish\w*|extra (workout|exercise)s?)\b',
  caseSensitive: false,
);

/// Null when [text] is an acceptable custom consequence, else why not.
String? unsafeConsequence(String text) {
  final t = text.trim();
  if (t.isEmpty) return 'empty';
  if (t.length > 200) return 'long';
  if (_forbiddenAr.hasMatch(t) || _forbiddenEn.hasMatch(t)) return 'unsafe';
  return null;
}

/// "If [taskId] is [graceDays] days late, then [consequence]."
class AccountabilityRule {
  const AccountabilityRule({
    required this.id,
    required this.taskId,
    this.graceDays = 7,
    required this.consequence,
    this.customText = '',
    this.active = true,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final int graceDays;
  final Consequence consequence;
  final String customText;

  /// The user can pause a rule at any time.
  final bool active;
  final DateTime createdAt;

  AccountabilityRule copyWith({int? graceDays, Consequence? consequence, String? customText, bool? active}) =>
      AccountabilityRule(
        id: id,
        taskId: taskId,
        graceDays: graceDays ?? this.graceDays,
        consequence: consequence ?? this.consequence,
        customText: customText ?? this.customText,
        active: active ?? this.active,
        createdAt: createdAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'taskId': taskId,
        'graceDays': graceDays,
        'consequence': consequence.name,
        'customText': customText,
        'active': active,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory AccountabilityRule.fromJson(Map<String, Object?> j) => AccountabilityRule(
        id: j['id'] as String,
        taskId: j['taskId'] as String,
        graceDays: j['graceDays'] as int,
        consequence: Consequence.values.byName(j['consequence'] as String),
        customText: (j['customText'] as String?) ?? '',
        active: j['active'] as bool,
        createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
      );
}

/// Why the task slipped. Only a deliberate postponement brings the agreed
/// consequence; an emergency or illness never does.
enum DelayReason { postponed, emergency, illness, notImportant }

enum EventOutcome {
  /// Waiting for the user to say what happened.
  pending,

  /// Postponed: consequence accepted, new date set.
  consequenceAccepted,

  /// Emergency or illness: new date, no consequence.
  rescheduled,

  /// No longer important: the task was closed.
  dropped,
}

/// One time a rule was triggered.
class AccountabilityEvent {
  const AccountabilityEvent({
    required this.id,
    this.ruleId,
    this.taskId,
    required this.dueDate,
    required this.triggeredOn,
    this.reason,
    this.outcome = EventOutcome.pending,
    this.newDueDate,
    this.note = '',
    this.resolvedAt,
  });

  final String id;
  final String? ruleId;
  final String? taskId;

  /// The deadline that was missed (YYYY-MM-DD).
  final String dueDate;

  /// When the grace period ran out (YYYY-MM-DD).
  final String triggeredOn;
  final DelayReason? reason;
  final EventOutcome outcome;
  final String? newDueDate;
  final String note;
  final DateTime? resolvedAt;

  bool get pending => outcome == EventOutcome.pending;

  AccountabilityEvent resolve(DelayReason reason, EventOutcome outcome, {String? newDueDate, String note = '', required DateTime at}) =>
      AccountabilityEvent(
        id: id,
        ruleId: ruleId,
        taskId: taskId,
        dueDate: dueDate,
        triggeredOn: triggeredOn,
        reason: reason,
        outcome: outcome,
        newDueDate: newDueDate,
        note: note,
        resolvedAt: at,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'ruleId': ruleId,
        'taskId': taskId,
        'dueDate': dueDate,
        'triggeredOn': triggeredOn,
        'reason': reason?.name,
        'outcome': outcome.name,
        'newDueDate': newDueDate,
        'note': note,
        'resolvedAt': resolvedAt?.toUtc().toIso8601String(),
      };

  factory AccountabilityEvent.fromJson(Map<String, Object?> j) => AccountabilityEvent(
        id: j['id'] as String,
        ruleId: j['ruleId'] as String?,
        taskId: j['taskId'] as String?,
        dueDate: j['dueDate'] as String,
        triggeredOn: j['triggeredOn'] as String,
        reason: j['reason'] == null ? null : DelayReason.values.byName(j['reason'] as String),
        outcome: EventOutcome.values.byName(j['outcome'] as String),
        newDueDate: j['newDueDate'] as String?,
        note: (j['note'] as String?) ?? '',
        resolvedAt: j['resolvedAt'] == null ? null : DateTime.parse(j['resolvedAt'] as String).toLocal(),
      );
}
