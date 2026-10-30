import '../../core/utils/dates.dart';

/// The bundled alarm sounds (android/app/src/main/res/raw/alarm_*.ogg).
enum AlarmTone { dawn, chime, bells, pulse }

/// A sounding alarm, separate from quiet notifications (v4 change 15): it
/// rings with its own tone until stopped or snoozed.
class Alarm {
  const Alarm({
    required this.id,
    this.label = '',
    required this.minutes,
    this.weekdays = const {},
    this.onDate,
    this.tone = AlarmTone.dawn,
    this.vibrate = true,
    this.snoozeMinutes = 10,
    this.enabled = true,
    this.taskId,
    this.eventId,
    this.snoozedUntil,
    required this.updatedAt,
  });

  final String id;
  final String label;

  /// Time of day, minutes after midnight.
  final int minutes;

  /// Repeats on these days (DateTime.weekday). Empty: rings once, on [onDate].
  final Set<int> weekdays;

  /// `yyyy-MM-dd` for a one-time alarm.
  final String? onDate;
  final AlarmTone tone;
  final bool vibrate;
  final int snoozeMinutes;
  final bool enabled;

  /// The task or appointment it is for; tapping the alarm opens it.
  final String? taskId;
  final String? eventId;

  /// Set by "snooze": rings once more at this time.
  final DateTime? snoozedUntil;
  final DateTime updatedAt;

  bool get repeats => weekdays.isNotEmpty;

  /// The next times it rings after [now], within [days] days (snooze first).
  List<DateTime> nextRings(DateTime now, {int days = 7}) {
    if (!enabled) return const [];
    final out = <DateTime>[];
    if (snoozedUntil != null && snoozedUntil!.isAfter(now)) out.add(snoozedUntil!);
    if (repeats) {
      for (var i = 0; i <= days; i++) {
        final day = dateOnly(now).add(Duration(days: i));
        final at = atMinutes(day, minutes);
        if (weekdays.contains(day.weekday) && at.isAfter(now)) out.add(at);
      }
    } else if (onDate != null) {
      final at = atMinutes(parseDayKey(onDate!), minutes);
      if (at.isAfter(now)) out.add(at);
    }
    return out;
  }

  Alarm copyWith({
    String? label,
    int? minutes,
    Set<int>? weekdays,
    String? Function()? onDate,
    AlarmTone? tone,
    bool? vibrate,
    int? snoozeMinutes,
    bool? enabled,
    String? Function()? taskId,
    String? Function()? eventId,
    DateTime? Function()? snoozedUntil,
    DateTime? updatedAt,
  }) =>
      Alarm(
        id: id,
        label: label ?? this.label,
        minutes: minutes ?? this.minutes,
        weekdays: weekdays ?? this.weekdays,
        onDate: onDate != null ? onDate() : this.onDate,
        tone: tone ?? this.tone,
        vibrate: vibrate ?? this.vibrate,
        snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
        enabled: enabled ?? this.enabled,
        taskId: taskId != null ? taskId() : this.taskId,
        eventId: eventId != null ? eventId() : this.eventId,
        snoozedUntil: snoozedUntil != null ? snoozedUntil() : this.snoozedUntil,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'label': label,
        'minutes': minutes,
        'weekdays': (weekdays.toList()..sort()),
        'onDate': onDate,
        'tone': tone.name,
        'vibrate': vibrate,
        'snoozeMinutes': snoozeMinutes,
        'enabled': enabled,
        'taskId': taskId,
        'eventId': eventId,
        'snoozedUntil': encodeInstant(snoozedUntil),
        'updatedAt': encodeInstant(updatedAt),
      };

  factory Alarm.fromJson(Map<String, Object?> j) => Alarm(
        id: j['id'] as String,
        label: (j['label'] as String?) ?? '',
        minutes: j['minutes'] as int,
        weekdays: {...((j['weekdays'] as List?) ?? const []).cast<int>()},
        onDate: j['onDate'] as String?,
        tone: AlarmTone.values.where((t) => t.name == j['tone']).firstOrNull ?? AlarmTone.dawn,
        vibrate: (j['vibrate'] as bool?) ?? true,
        snoozeMinutes: (j['snoozeMinutes'] as int?) ?? 10,
        enabled: (j['enabled'] as bool?) ?? true,
        taskId: j['taskId'] as String?,
        eventId: j['eventId'] as String?,
        snoozedUntil: decodeInstant(j['snoozedUntil']),
        updatedAt: decodeInstant(j['updatedAt'])!,
      );
}
