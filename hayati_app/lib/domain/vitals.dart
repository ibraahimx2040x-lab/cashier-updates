import '../core/utils/dates.dart';
import '../data/app_data.dart';
import '../data/models/health.dart';

/// Measurements of one kind, newest first.
List<BodyMetric> metricsOf(AppData d, MetricKind kind) =>
    [for (final m in d.bodyMetrics) if (m.kind == kind) m]..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));

/// General guidance only (no diagnosis), from the NHS's thresholds.
enum BpAdvice { none, seeDoctor, urgent }

/// Urgent when the latest reading is 180/120 or higher; see a doctor when
/// the last three average 140/90 or higher.
BpAdvice bpAdvice(AppData d) {
  final bp = metricsOf(d, MetricKind.bp);
  if (bp.isEmpty) return BpAdvice.none;
  final last = bp.first;
  if (last.value >= 180 || (last.value2 ?? 0) >= 120) return BpAdvice.urgent;
  if (bp.length < 3) return BpAdvice.none;
  final three = bp.take(3).toList();
  final sys = three.fold(0.0, (a, m) => a + m.value) / 3;
  final dia = three.fold(0.0, (a, m) => a + (m.value2 ?? 0)) / 3;
  return sys >= 140 || dia >= 90 ? BpAdvice.seeDoctor : BpAdvice.none;
}

/// Change from the oldest to the newest reading within [days] of [now].
double? metricChange(AppData d, MetricKind kind, DateTime now, {int days = 30}) {
  final from = now.subtract(Duration(days: days));
  final list = metricsOf(d, kind).where((m) => m.measuredAt.isAfter(from)).toList();
  if (list.length < 2) return null;
  return list.first.value - list.last.value;
}

/// The week's averages of the daily check-ins (null where none).
class CheckinAverages {
  const CheckinAverages({this.energy, this.fatigue, this.recovery, this.mood, required this.days});
  final double? energy;
  final double? fatigue;
  final double? recovery;
  final double? mood;
  final int days;
}

CheckinAverages checkinAverages(AppData d, DateTime now, {int days = 7}) {
  final keys = {for (var i = 0; i < days; i++) dayKey(dateOnly(now).subtract(Duration(days: i)))};
  final list = d.checkins.where((c) => keys.contains(c.day)).toList();
  double? avg(int? Function(WellbeingCheckin) f) {
    final v = [for (final c in list) ?f(c)];
    return v.isEmpty ? null : v.reduce((a, b) => a + b) / v.length;
  }

  return CheckinAverages(
    energy: avg((c) => c.energy),
    fatigue: avg((c) => c.fatigue),
    recovery: avg((c) => c.recovery),
    mood: avg((c) => c.mood),
    days: list.length,
  );
}
