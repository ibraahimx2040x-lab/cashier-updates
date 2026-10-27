import '../../core/utils/dates.dart';
import '../../data/app_data.dart';
import '../../data/models/nutrition.dart';

class NutritionDay {
  const NutritionDay({required this.day, required this.total, required this.byMeal, required this.waterMl, required this.items});
  final String day;
  final Nutrients total;
  final Map<MealType, List<FoodLog>> byMeal;
  final int waterMl;
  final int items;

  bool get hasFood => items > 0;
}

NutritionDay nutritionDay(AppData d, String day) {
  final logs = d.foodLogs.where((f) => f.day == day).toList()..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
  return NutritionDay(
    day: day,
    total: logs.fold(Nutrients.zero, (a, f) => a + f.total),
    byMeal: {for (final m in MealType.values) m: [for (final f in logs) if (f.meal == m) f]},
    waterMl: d.waterOn(day),
    items: logs.length,
  );
}

/// [days] consecutive days ending on [last], oldest first.
List<NutritionDay> nutritionSeries(AppData d, DateTime last, int days) => [
      for (var i = days - 1; i >= 0; i--) nutritionDay(d, dayKey(dateOnly(last).subtract(Duration(days: i)))),
    ];

class NutritionWeek {
  const NutritionWeek({required this.average, required this.daysLogged, required this.waterAverage, required this.top});

  /// Over days with something logged, so an empty day doesn't pull it down.
  final Nutrients average;
  final int daysLogged;
  final int waterAverage;

  /// Most-logged names, most first.
  final List<(String, int)> top;

  /// Share of energy from protein, carbs and fat (4/4/9 kcal per gram).
  (double, double, double) get split {
    final p = average.protein * 4, c = average.carbs * 4, f = average.fat * 9;
    final sum = p + c + f;
    return sum == 0 ? (0, 0, 0) : (p / sum, c / sum, f / sum);
  }
}

NutritionWeek nutritionWeek(AppData d, DateTime last) {
  final series = nutritionSeries(d, last, 7);
  final logged = series.where((x) => x.hasFood).toList();
  final sum = logged.fold(Nutrients.zero, (a, x) => a + x.total);
  final withWater = series.where((x) => x.waterMl > 0).toList();
  final counts = <String, int>{};
  for (final x in logged) {
    for (final items in x.byMeal.values) {
      for (final f in items) {
        counts[f.name] = (counts[f.name] ?? 0) + 1;
      }
    }
  }
  final top = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return NutritionWeek(
    average: logged.isEmpty ? Nutrients.zero : sum.times(1 / logged.length),
    daysLogged: logged.length,
    waterAverage: withWater.isEmpty ? 0 : (withWater.fold(0, (a, x) => a + x.waterMl) / withWater.length).round(),
    top: [for (final e in top.take(5)) (e.key, e.value)],
  );
}

/// What was logged most often, for quick re-adding.
List<FoodLog> recentFoods(AppData d, {int limit = 8}) {
  final seen = <String>{};
  final out = <FoodLog>[];
  for (final f in [...d.foodLogs]..sort((a, b) => b.loggedAt.compareTo(a.loggedAt))) {
    if (seen.add(f.name)) out.add(f);
    if (out.length >= limit) break;
  }
  return out;
}

/// Meal suggested for the time of day.
MealType mealFor(DateTime t) => switch (t.hour) {
      >= 4 && < 11 => MealType.breakfast,
      >= 11 && < 16 => MealType.lunch,
      >= 18 && < 23 => MealType.dinner,
      _ => MealType.snack,
    };
