import '../core/utils/dates.dart';
import '../data/app_data.dart';
import '../data/models/health.dart';
import 'activity.dart';
import 'nutrition/summary.dart';
import 'sleep.dart';

/// The health part of the progress report (spec 6): a line per section
/// that is on, worded descriptively ("goal reached 4 days of 7"), never as
/// a judgement. Days after today are left out.
class HealthReport {
  const HealthReport({this.goalDays, this.stepDays = 0, this.sleepAvg, this.sleepNights = 0, this.foodDays = 0, this.kcalAvg, this.waterAvg});

  /// Days the step goal was reached, of [stepDays] counted.
  final int? goalDays;
  final int stepDays;
  final int? sleepAvg;
  final int sleepNights;
  final int foodDays;
  final int? kcalAvg;
  final int? waterAvg;

  bool get isEmpty => goalDays == null && sleepAvg == null && foodDays == 0;

  static HealthReport build(AppData d, DateTime from, DateTime to, DateTime now) {
    final h = d.settings.health;
    final last = to.isAfter(dateOnly(now).add(const Duration(days: 1))) ? dateOnly(now).add(const Duration(days: 1)) : to;
    final days = [for (var x = dateOnly(from); x.isBefore(last); x = x.add(const Duration(days: 1))) dayKey(x)];
    if (days.isEmpty) return const HealthReport();
    int? goalDays;
    if (h.has(HealthModule.activity) && d.activity.isNotEmpty) {
      goalDays = days.where((k) => activityDay(d, k).steps >= h.stepGoal).length;
    }
    int? sleepAvg;
    var nights = 0;
    if (h.has(HealthModule.sleep)) {
      final s = [for (final k in days) sleepDay(d, k)].where((x) => x.hasData).toList();
      nights = s.length;
      if (s.isNotEmpty) sleepAvg = (s.fold(0, (a, x) => a + x.minutes) / s.length).round();
    }
    var foodDays = 0;
    int? kcal;
    int? water;
    if (h.has(HealthModule.nutrition)) {
      final n = [for (final k in days) nutritionDay(d, k)].where((x) => x.items > 0).toList();
      foodDays = n.length;
      if (n.isNotEmpty) kcal = (n.fold(0.0, (a, x) => a + x.total.kcal) / n.length).round();
      final w = [for (final k in days) d.waterOn(k)].where((x) => x > 0).toList();
      if (w.isNotEmpty) water = (w.reduce((a, b) => a + b) / w.length).round();
    }
    return HealthReport(goalDays: goalDays, stepDays: days.length, sleepAvg: sleepAvg, sleepNights: nights, foodDays: foodDays, kcalAvg: kcal, waterAvg: water);
  }
}
