/// Women's health (spec v3, phase 11): periods the user records, how each
/// day felt, and health appointments (shared with men's health). Cycle data
/// is sensitive: it can stay on the device only, its notifications never
/// say what they are about, and it is never inferred or diagnosed.
library;

enum FlowLevel { none, light, medium, heavy }

/// A fixed list, so logs can be counted; anything else goes in free text.
enum Symptom { cramps, headache, backPain, bloating, breastTenderness, acne, fatigue, nausea, cravings, insomnia, moodSwings, spotting }

enum CycleMood { calm, happy, low, irritable, anxious }

/// One period, as the user recorded it. [end] is null while it is going on.
class CyclePeriod {
  const CyclePeriod({required this.id, required this.start, this.end, required this.updatedAt});

  final String id;

  /// YYYY-MM-DD.
  final String start;
  final String? end;
  final DateTime updatedAt;

  /// The longest a recorded period can run (the database checks it too).
  static const maxDays = 15;

  CyclePeriod copyWith({String? start, String? Function()? end, DateTime? updatedAt}) => CyclePeriod(
        id: id,
        start: start ?? this.start,
        end: end != null ? end() : this.end,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toJson() => {'id': id, 'start': start, 'end': end, 'updatedAt': updatedAt.toUtc().toIso8601String()};

  factory CyclePeriod.fromJson(Map<String, Object?> j) => CyclePeriod(
        id: j['id'] as String,
        start: j['start'] as String,
        end: j['end'] as String?,
        updatedAt: DateTime.parse(j['updatedAt'] as String).toLocal(),
      );
}

/// How one day went. One per day.
class CycleDayLog {
  const CycleDayLog({
    required this.id,
    required this.day,
    this.flow,
    this.pain,
    this.symptoms = const {},
    this.otherSymptoms = '',
    this.mood,
    this.energy,
    this.note = '',
    required this.updatedAt,
  });

  final String id;
  final String day;
  final FlowLevel? flow;

  /// 0–10.
  final int? pain;
  final Set<Symptom> symptoms;
  final String otherSymptoms;
  final CycleMood? mood;

  /// 1–5.
  final int? energy;
  final String note;
  final DateTime updatedAt;

  bool get isEmpty =>
      flow == null && pain == null && symptoms.isEmpty && otherSymptoms.trim().isEmpty && mood == null && energy == null && note.trim().isEmpty;

  bool get valid =>
      (pain == null || (pain! >= 0 && pain! <= 10)) &&
      (energy == null || (energy! >= 1 && energy! <= 5)) &&
      otherSymptoms.length <= 200 &&
      note.length <= 1000;

  Map<String, Object?> toJson() => {
        'id': id,
        'day': day,
        'flow': flow?.name,
        'pain': pain,
        'symptoms': [for (final s in symptoms) s.name]..sort(),
        'otherSymptoms': otherSymptoms,
        'mood': mood?.name,
        'energy': energy,
        'note': note,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory CycleDayLog.fromJson(Map<String, Object?> j) {
    T? pick<T extends Enum>(List<T> values, Object? name) => values.where((v) => v.name == name).firstOrNull;
    return CycleDayLog(
      id: j['id'] as String,
      day: j['day'] as String,
      flow: pick(FlowLevel.values, j['flow']),
      pain: j['pain'] as int?,
      symptoms: {for (final s in (j['symptoms'] as List? ?? const [])) ?pick(Symptom.values, s)},
      otherSymptoms: (j['otherSymptoms'] as String?) ?? '',
      mood: pick(CycleMood.values, j['mood']),
      energy: j['energy'] as int?,
      note: (j['note'] as String?) ?? '',
      updatedAt: DateTime.parse(j['updatedAt'] as String).toLocal(),
    );
  }
}

enum AppointmentKind { checkup, test, followup, other }

/// A health appointment or test (screen 46), for women and men alike.
class HealthAppointment {
  const HealthAppointment({
    required this.id,
    required this.title,
    this.kind = AppointmentKind.checkup,
    required this.at,
    this.place = '',
    this.notes = '',
    this.questions = const [],
    this.reminderMinutes,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final AppointmentKind kind;
  final DateTime at;
  final String place;
  final String notes;

  /// What to ask the doctor.
  final List<String> questions;

  /// Minutes before [at]; null for no reminder.
  final int? reminderMinutes;
  final DateTime updatedAt;

  static const maxQuestions = 30;

  bool get valid =>
      title.trim().isNotEmpty &&
      title.length <= 120 &&
      place.length <= 120 &&
      notes.length <= 2000 &&
      questions.length <= maxQuestions &&
      questions.every((q) => q.trim().isNotEmpty && q.length <= 300) &&
      (reminderMinutes == null || (reminderMinutes! >= 0 && reminderMinutes! <= 10080));

  HealthAppointment copyWith({DateTime? updatedAt}) => HealthAppointment(
        id: id,
        title: title,
        kind: kind,
        at: at,
        place: place,
        notes: notes,
        questions: questions,
        reminderMinutes: reminderMinutes,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'kind': kind.name,
        'at': at.toUtc().toIso8601String(),
        'place': place,
        'notes': notes,
        'questions': questions,
        'reminderMinutes': reminderMinutes,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory HealthAppointment.fromJson(Map<String, Object?> j) => HealthAppointment(
        id: j['id'] as String,
        title: j['title'] as String,
        kind: AppointmentKind.values.where((k) => k.name == j['kind']).firstOrNull ?? AppointmentKind.other,
        at: DateTime.parse(j['at'] as String).toLocal(),
        place: (j['place'] as String?) ?? '',
        notes: (j['notes'] as String?) ?? '',
        questions: [for (final q in (j['questions'] as List? ?? const [])) q as String],
        reminderMinutes: j['reminderMinutes'] as int?,
        updatedAt: DateTime.parse(j['updatedAt'] as String).toLocal(),
      );
}
