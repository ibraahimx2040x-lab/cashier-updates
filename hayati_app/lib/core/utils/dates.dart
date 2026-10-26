/// Date helpers. Instants are stored as UTC ISO-8601 strings; calendar days
/// (due dates, habit logs) are stored as `yyyy-MM-dd` keys so they never
/// drift when the device time zone changes.
library;

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_pad2(d.month)}-${_pad2(d.day)}';

DateTime parseDayKey(String key) {
  final p = key.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

String monthKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${_pad2(d.month)}';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _pad2(int v) => v.toString().padLeft(2, '0');

String? encodeInstant(DateTime? d) => d?.toUtc().toIso8601String();

DateTime? decodeInstant(Object? v) =>
    v is String ? DateTime.parse(v).toLocal() : null;

/// Minutes since midnight <-> "HH:mm".
String minutesToHm(int m) => '${_pad2(m ~/ 60)}:${_pad2(m % 60)}';

int? hmToMinutes(String? hm) {
  if (hm == null) return null;
  final p = hm.split(':');
  if (p.length != 2) return null;
  final h = int.tryParse(p[0]), mi = int.tryParse(p[1]);
  if (h == null || mi == null) return null;
  return h * 60 + mi;
}

DateTime atMinutes(DateTime day, int minutes) =>
    DateTime(day.year, day.month, day.day).add(Duration(minutes: minutes));

/// Start of the week containing [d]. [weekStart] uses DateTime.weekday
/// numbering (1 = Monday … 7 = Sunday; 6 = Saturday).
DateTime startOfWeek(DateTime d, int weekStart) {
  final day = dateOnly(d);
  final diff = (day.weekday - weekStart) % 7;
  return day.subtract(Duration(days: diff));
}
