import '../../core/utils/dates.dart';

/// One step in the fixed-salary history: from [effectiveFrom] on, the salary
/// is [amountMinor] paid on [payDay] of each month. A new rate never touches
/// the months before it. An amount of 0 means "no fixed salary from here"
/// (the user switched to variable income).
class SalaryRate {
  const SalaryRate({
    required this.id,
    required this.amountMinor,
    required this.currency,
    required this.effectiveFrom,
    this.payDay = 1,
    this.note = '',
    required this.updatedAt,
  });

  final String id;
  final int amountMinor;
  final String currency;

  /// `yyyy-MM-dd`.
  final String effectiveFrom;

  /// 1–31; months shorter than this are paid on their last day.
  final int payDay;
  final String note;
  final DateTime updatedAt;

  bool get isStop => amountMinor == 0;

  Map<String, Object?> toJson() => {
        'id': id,
        'amountMinor': amountMinor,
        'currency': currency,
        'effectiveFrom': effectiveFrom,
        'payDay': payDay,
        'note': note,
        'updatedAt': encodeInstant(updatedAt),
      };

  factory SalaryRate.fromJson(Map<String, Object?> j) => SalaryRate(
        id: j['id'] as String,
        amountMinor: j['amountMinor'] as int,
        currency: j['currency'] as String,
        effectiveFrom: j['effectiveFrom'] as String,
        payDay: (j['payDay'] as int?) ?? 1,
        note: (j['note'] as String?) ?? '',
        updatedAt: decodeInstant(j['updatedAt'])!,
      );
}

/// Where a received amount came from. [pay] is pay that changes each time
/// (variable income); [extra] is anything on top (bonus, side work, gift).
enum IncomeKind { pay, extra }

/// Money actually received, typed in by the user or made by a monthly
/// [RecurringItem].
class Income {
  const Income({
    required this.id,
    required this.amountMinor,
    required this.currency,
    this.kind = IncomeKind.extra,
    this.source = '',
    required this.receivedAt,
    this.recurringId,
    this.note = '',
  }) : assert(amountMinor > 0);

  final String id;
  final int amountMinor;
  final String currency;
  final IncomeKind kind;

  /// Free text: "Freelance", "Rent", employer name…
  final String source;
  final DateTime receivedAt;
  final String? recurringId;
  final String note;

  Map<String, Object?> toJson() => {
        'id': id,
        'amountMinor': amountMinor,
        'currency': currency,
        'kind': kind.name,
        'source': source,
        'receivedAt': encodeInstant(receivedAt),
        'recurringId': recurringId,
        'note': note,
      };

  factory Income.fromJson(Map<String, Object?> j) => Income(
        id: j['id'] as String,
        amountMinor: j['amountMinor'] as int,
        currency: j['currency'] as String,
        kind: IncomeKind.values.where((k) => k.name == j['kind']).firstOrNull ?? IncomeKind.extra,
        source: (j['source'] as String?) ?? '',
        receivedAt: decodeInstant(j['receivedAt'])!,
        recurringId: j['recurringId'] as String?,
        note: (j['note'] as String?) ?? '',
      );
}

enum RecurringKind { expense, income }

/// A monthly expense or income. Each month that falls due becomes an ordinary
/// [Expense] or [Income] record the user can edit or delete; [generatedThrough]
/// remembers the last month made so a deleted one does not come back.
class RecurringItem {
  const RecurringItem({
    required this.id,
    required this.kind,
    required this.amountMinor,
    required this.currency,
    this.category = 'other',
    this.title = '',
    this.dayOfMonth = 1,
    required this.startsOn,
    this.endsOn,
    this.generatedThrough,
    this.active = true,
    required this.updatedAt,
  }) : assert(amountMinor > 0);

  final String id;
  final RecurringKind kind;
  final int amountMinor;
  final String currency;

  /// Expense category (ignored for income).
  final String category;

  /// Description for an expense, source for an income.
  final String title;
  final int dayOfMonth;

  /// `yyyy-MM-dd`.
  final String startsOn;
  final String? endsOn;

  /// `yyyy-MM` of the last month generated.
  final String? generatedThrough;
  final bool active;
  final DateTime updatedAt;

  RecurringItem copyWith({
    int? amountMinor,
    String? currency,
    String? category,
    String? title,
    int? dayOfMonth,
    String? startsOn,
    String? Function()? endsOn,
    String? Function()? generatedThrough,
    bool? active,
    DateTime? updatedAt,
  }) =>
      RecurringItem(
        id: id,
        kind: kind,
        amountMinor: amountMinor ?? this.amountMinor,
        currency: currency ?? this.currency,
        category: category ?? this.category,
        title: title ?? this.title,
        dayOfMonth: dayOfMonth ?? this.dayOfMonth,
        startsOn: startsOn ?? this.startsOn,
        endsOn: endsOn != null ? endsOn() : this.endsOn,
        generatedThrough: generatedThrough != null ? generatedThrough() : this.generatedThrough,
        active: active ?? this.active,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.name,
        'amountMinor': amountMinor,
        'currency': currency,
        'category': category,
        'title': title,
        'dayOfMonth': dayOfMonth,
        'startsOn': startsOn,
        'endsOn': endsOn,
        'generatedThrough': generatedThrough,
        'active': active,
        'updatedAt': encodeInstant(updatedAt),
      };

  factory RecurringItem.fromJson(Map<String, Object?> j) => RecurringItem(
        id: j['id'] as String,
        kind: RecurringKind.values.byName(j['kind'] as String),
        amountMinor: j['amountMinor'] as int,
        currency: j['currency'] as String,
        category: (j['category'] as String?) ?? 'other',
        title: (j['title'] as String?) ?? '',
        dayOfMonth: (j['dayOfMonth'] as int?) ?? 1,
        startsOn: j['startsOn'] as String,
        endsOn: j['endsOn'] as String?,
        generatedThrough: j['generatedThrough'] as String?,
        active: (j['active'] as bool?) ?? true,
        updatedAt: decodeInstant(j['updatedAt'])!,
      );
}
