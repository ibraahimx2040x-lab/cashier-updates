/// Food and drink (spec v3, phase 08). Everything is entered by the user —
/// from the built-in list, their own foods, or a product barcode — and
/// every number is an estimate they can change.
library;

enum MealType { breakfast, lunch, dinner, snack }

/// Energy and macros for one portion (or a total).
class Nutrients {
  const Nutrients({this.kcal = 0, this.protein = 0, this.carbs = 0, this.fat = 0});
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  static const zero = Nutrients();

  Nutrients operator +(Nutrients o) =>
      Nutrients(kcal: kcal + o.kcal, protein: protein + o.protein, carbs: carbs + o.carbs, fat: fat + o.fat);

  Nutrients times(double f) => Nutrients(kcal: kcal * f, protein: protein * f, carbs: carbs * f, fat: fat * f);

  Map<String, Object?> toJson() => {'kcal': kcal, 'protein': protein, 'carbs': carbs, 'fat': fat};

  factory Nutrients.fromJson(Map<String, Object?> j) => Nutrients(
        kcal: (j['kcal'] as num?)?.toDouble() ?? 0,
        protein: (j['protein'] as num?)?.toDouble() ?? 0,
        carbs: (j['carbs'] as num?)?.toDouble() ?? 0,
        fat: (j['fat'] as num?)?.toDouble() ?? 0,
      );

  static const maxKcal = 5000.0;
  static const maxGrams = 500.0;

  bool get valid =>
      kcal >= 0 && kcal <= maxKcal && [protein, carbs, fat].every((g) => g >= 0 && g <= maxGrams);
}

/// A food the user saved: typed in by hand, or found by barcode.
class CustomFood {
  const CustomFood({
    required this.id,
    required this.name,
    this.portion = '',
    this.grams,
    required this.per,
    this.barcode,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// How one portion is described ("قطعة"، "علبة 330 مل").
  final String portion;
  final double? grams;

  /// Per one portion.
  final Nutrients per;
  final String? barcode;
  final DateTime createdAt;

  static final barcodePattern = RegExp(r'^\d{6,14}$');

  CustomFood copyWith({String? name, String? portion, double? Function()? grams, Nutrients? per}) => CustomFood(
        id: id,
        name: name ?? this.name,
        portion: portion ?? this.portion,
        grams: grams != null ? grams() : this.grams,
        per: per ?? this.per,
        barcode: barcode,
        createdAt: createdAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'portion': portion,
        'grams': grams,
        'per': per.toJson(),
        'barcode': barcode,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory CustomFood.fromJson(Map<String, Object?> j) => CustomFood(
        id: j['id'] as String,
        name: j['name'] as String,
        portion: (j['portion'] as String?) ?? '',
        grams: (j['grams'] as num?)?.toDouble(),
        per: Nutrients.fromJson((j['per'] as Map).cast()),
        barcode: j['barcode'] as String?,
        createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
      );
}

/// One thing eaten or drunk. Name and numbers are copied in when logged,
/// so editing or deleting a saved food never rewrites the past.
class FoodLog {
  const FoodLog({
    required this.id,
    required this.day,
    required this.meal,
    required this.name,
    this.foodRef,
    this.portions = 1,
    required this.total,
    required this.loggedAt,
  });

  final String id;

  /// YYYY-MM-DD.
  final String day;
  final MealType meal;
  final String name;

  /// The built-in food id or saved food id it came from, if any.
  final String? foodRef;
  final double portions;

  /// For all [portions].
  final Nutrients total;
  final DateTime loggedAt;

  static const maxPortions = 20.0;

  Map<String, Object?> toJson() => {
        'id': id,
        'day': day,
        'meal': meal.name,
        'name': name,
        'foodRef': foodRef,
        'portions': portions,
        'total': total.toJson(),
        'loggedAt': loggedAt.toUtc().toIso8601String(),
      };

  factory FoodLog.fromJson(Map<String, Object?> j) => FoodLog(
        id: j['id'] as String,
        day: j['day'] as String,
        meal: MealType.values.byName(j['meal'] as String),
        name: j['name'] as String,
        foodRef: j['foodRef'] as String?,
        portions: (j['portions'] as num).toDouble(),
        total: Nutrients.fromJson((j['total'] as Map).cast()),
        loggedAt: DateTime.parse(j['loggedAt'] as String).toLocal(),
      );
}

/// Water drunk on one day (one row per day).
class WaterDay {
  const WaterDay({required this.id, required this.day, required this.ml});
  final String id;
  final String day;
  final int ml;

  static const maxMl = 10000;

  Map<String, Object?> toJson() => {'id': id, 'day': day, 'ml': ml};
  factory WaterDay.fromJson(Map<String, Object?> j) =>
      WaterDay(id: j['id'] as String, day: j['day'] as String, ml: j['ml'] as int);
}
