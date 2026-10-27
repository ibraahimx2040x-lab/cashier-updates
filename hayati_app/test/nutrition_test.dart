import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/nutrition.dart';
import 'package:hayati/data/remote/rows.dart';
import 'package:hayati/domain/nutrition/foods.dart';
import 'package:hayati/domain/nutrition/summary.dart';
import 'package:hayati/services/barcode_lookup.dart';

import 'helpers.dart';

FoodLog log(String day, MealType m, String name, double kcal, {double p = 0, double c = 0, double f = 0, int minute = 0}) => FoodLog(
      id: '$day-$name-$minute',
      day: day,
      meal: m,
      name: name,
      total: Nutrients(kcal: kcal, protein: p, carbs: c, fat: f),
      loggedAt: fixedNow.add(Duration(minutes: minute)),
    );

void main() {
  group('built-in foods', () {
    test('ids unique, values sane, energy matches the macros', () {
      expect(builtinFoods.map((f) => f.id).toSet().length, builtinFoods.length);
      for (final f in builtinFoods) {
        expect(f.per.valid, isTrue, reason: f.id);
        expect(f.ar.isNotEmpty && f.en.isNotEmpty && f.portionAr.isNotEmpty, isTrue, reason: f.id);
        // 4 kcal/g protein and carbs, 9 kcal/g fat — catches typos.
        final est = 4 * f.per.protein + 4 * f.per.carbs + 9 * f.per.fat;
        expect((est - f.per.kcal).abs(), lessThanOrEqualTo([25.0, 0.2 * f.per.kcal].reduce((a, b) => a > b ? a : b)), reason: f.id);
      }
    });

    test('search folds Arabic letter variants and English case', () {
      expect(searchBuiltin('كبسه').map((f) => f.id), containsAll(['chicken_kabsa', 'meat_kabsa']));
      expect(searchBuiltin('الشاي').isEmpty, isTrue);
      expect(searchBuiltin('شاي').map((f) => f.id), containsAll(['tea_sugar', 'tea_plain']));
      expect(searchBuiltin('SHAWARMA').single.id, 'chicken_shawarma');
      expect(searchBuiltin('  '), hasLength(builtinFoods.length));
    });

    test('classifier labels map to foods (exact first)', () {
      expect(foodsForLabel('Mandi').first.id, 'chicken_mandi');
      expect(foodsForLabel('Shawarma').single.id, 'chicken_shawarma');
      expect(foodsForLabel('New York-style pizza').first.id, 'pizza');
      expect(foodsForLabel('Hyderabadi biryani').first.id, 'biryani');
      expect(foodsForLabel('Ful medames').first.id, 'foul');
      expect(foodsForLabel('Saleeg').single.id, 'saleeg');
      expect(foodsForLabel('Harees').first.id, 'harees');
      expect(foodsForLabel(''), isEmpty);
      expect(foodsForLabel('Zzz unknown dish'), isEmpty);
    });
  });

  group('logging', () {
    test('validates and copies the numbers in', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      const per = Nutrients(kcal: 620, protein: 35, carbs: 68, fat: 22);
      expect(() => data.logFood(day: '2026-03-11', meal: MealType.lunch, name: 'x', per: per), throwsArgumentError);
      expect(() => data.logFood(day: '2026-03-10', meal: MealType.lunch, name: ' ', per: per), throwsArgumentError);
      expect(() => data.logFood(day: '2026-03-10', meal: MealType.lunch, name: 'x', per: per, portions: 0), throwsArgumentError);
      expect(() => data.logFood(day: '2026-03-10', meal: MealType.lunch, name: 'x', per: const Nutrients(kcal: 6000)), throwsArgumentError);
      final f = data.logFood(day: '2026-03-10', meal: MealType.lunch, name: 'Chicken mandi', per: per, portions: 1.5, foodRef: 'chicken_mandi');
      expect((f.total.kcal, f.total.protein), (930, 52.5));
      data.deleteFoodLog(f.id);
      expect(data.snapshot.foodLogs, isEmpty);
    });

    test('saved foods: one per barcode, deleting keeps logged meals', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      final a = data.saveCustomFood(CustomFood(id: 'a', name: 'Laban', portion: 'bottle', per: const Nutrients(kcal: 120), barcode: '6281007012345', createdAt: fixedNow));
      final b = data.saveCustomFood(CustomFood(id: 'b', name: 'Laban 1L', portion: 'cup', per: const Nutrients(kcal: 100), barcode: '6281007012345', createdAt: fixedNow));
      expect(b.id, a.id);
      expect(data.snapshot.customFoods.single.name, 'Laban 1L');
      expect(() => data.saveCustomFood(CustomFood(id: 'c', name: 'x', per: const Nutrients(), barcode: '12ab', createdAt: fixedNow)), throwsArgumentError);
      data.logFood(day: '2026-03-10', meal: MealType.snack, name: b.name, per: b.per, foodRef: b.id);
      data.deleteCustomFood(b.id);
      expect(data.snapshot.customFoods, isEmpty);
      expect(data.snapshot.foodLogs.single.name, 'Laban 1L');
    });

    test('water adds up, never below zero, one row per day', () async {
      final c = await signedInContainer();
      final data = c.read(dataProvider.notifier);
      data.addWater('2026-03-10', 250);
      data.addWater('2026-03-10', 250);
      data.addWater('2026-03-10', -1000);
      expect(data.snapshot.waterOn('2026-03-10'), 0);
      data.addWater('2026-03-10', 500);
      expect(data.snapshot.water, hasLength(1));
      expect(data.snapshot.waterOn('2026-03-10'), 500);
      expect(() => data.addWater('2026-03-11', 250), throwsArgumentError);
    });
  });

  group('summaries', () {
    final d = AppData(
      foodLogs: [
        log('2026-03-10', MealType.breakfast, 'Dates', 84, c: 22.5, minute: 1),
        log('2026-03-10', MealType.lunch, 'Chicken mandi', 620, p: 35, c: 68, f: 22, minute: 2),
        log('2026-03-09', MealType.dinner, 'Dates', 56, c: 15, minute: 3),
        log('2026-03-01', MealType.dinner, 'Old', 999),
      ],
      water: const [WaterDay(id: 'w', day: '2026-03-10', ml: 1500), WaterDay(id: 'v', day: '2026-03-08', ml: 500)],
    );

    test('a day groups by meal and adds up', () {
      final n = nutritionDay(d, '2026-03-10');
      expect(n.total.kcal, 704);
      expect(n.byMeal[MealType.lunch]!.single.name, 'Chicken mandi');
      expect(n.byMeal[MealType.snack], isEmpty);
      expect((n.waterMl, n.items), (1500, 2));
    });

    test('the week averages only logged days', () {
      final w = nutritionWeek(d, fixedNow);
      expect(w.daysLogged, 2);
      expect(w.average.kcal, 380);
      expect(w.waterAverage, 1000);
      expect(w.top.first, ('Dates', 2));
      final (p, c, f) = w.split;
      expect(p + c + f, closeTo(1, 1e-9));
    });

    test('recent foods are unique, newest first; meals by time', () {
      expect(recentFoods(d).map((f) => f.name), ['Dates', 'Chicken mandi', 'Old']);
      expect(mealFor(DateTime(2026, 3, 10, 7)), MealType.breakfast);
      expect(mealFor(DateTime(2026, 3, 10, 13)), MealType.lunch);
      expect(mealFor(DateTime(2026, 3, 10, 20)), MealType.dinner);
      expect(mealFor(DateTime(2026, 3, 10, 16, 30)), MealType.snack);
    });
  });

  group('Open Food Facts', () {
    test('per serving when the label has it', () {
      final p = parseProduct('6281007012345', {
        'product_name': 'Laban',
        'product_name_ar': 'لبن',
        'serving_size': '200 ml',
        'serving_quantity': 200,
        'nutriments': {'energy-kcal_serving': 92, 'proteins_serving': 6.2, 'carbohydrates_serving': '9.4', 'fat_serving': 3, 'energy-kcal_100g': 46},
      }, lang: 'ar')!;
      expect((p.name, p.portion, p.grams, p.per.kcal, p.per.carbs), ('لبن', '200 ml', 200, 92, 9.4));
    });

    test('per 100 g otherwise, kJ converted, name falls back', () {
      final p = parseProduct('123456', {
        'brands': 'Almarai',
        'nutriments': {'energy_100g': 418.4, 'proteins_100g': 3},
      }, lang: 'en')!;
      expect((p.name, p.portion, p.grams), ('Almarai', '100 g', 100));
      expect(p.per.kcal, closeTo(100, 0.01));
      expect(parseProduct('123456', {'product_name': 'No energy', 'nutriments': {}}, lang: 'en'), isNull);
    });
  });

  test('rows and JSON round-trip', () {
    final f = CustomFood(id: 'a', name: 'Laban', portion: 'bottle', grams: 200, per: const Nutrients(kcal: 92, protein: 6.2, carbs: 9.4, fat: 3), barcode: '6281007012345', createdAt: fixedNow);
    final fb = customFoodFrom({...customFoodRow(f)});
    expect((fb.name, fb.grams, fb.per.carbs, fb.barcode, fb.createdAt), ('Laban', 200, 9.4, '6281007012345', fixedNow));
    final l = log('2026-03-10', MealType.lunch, 'Mandi', 930, p: 52.5);
    final lb = foodLogFrom({...foodLogRow(l)});
    expect((lb.day, lb.meal, lb.name, lb.total.kcal, lb.total.protein), ('2026-03-10', MealType.lunch, 'Mandi', 930, 52.5));
    expect(waterFrom(waterRow(const WaterDay(id: 'w', day: '2026-03-10', ml: 750))).ml, 750);
    final d = AppData.fromJson(AppData(foodLogs: [l], customFoods: [f], water: const [WaterDay(id: 'w', day: '2026-03-10', ml: 1)]).toJson());
    expect((d.foodLogs.single.portions, d.customFoods.single.portion, d.water.single.ml), (1.0, 'bottle', 1));
  });
}
