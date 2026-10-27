import '../../data/models/nutrition.dart';

enum FoodGroup { grains, dishes, protein, dairy, fruit, vegetables, drinks, snacks, extras }

/// A built-in food with one typical portion. Values are rounded averages
/// from common food-composition tables (cooked weights for cooked foods);
/// home recipes vary, so the app always calls them estimates and lets the
/// user change portions or save their own version.
class BuiltinFood {
  const BuiltinFood(this.id, this.group, this.ar, this.en, this.portionAr, this.portionEn, this.grams, this.per,
      {this.match = const []});

  final String id;
  final FoodGroup group;
  final String ar;
  final String en;
  final String portionAr;
  final String portionEn;
  final double? grams;
  final Nutrients per;

  /// Lower-case names the on-device classifier may give this food.
  final List<String> match;

  String name(String lang) => lang == 'ar' ? ar : en;
  String portion(String lang) => lang == 'ar' ? portionAr : portionEn;
}


const builtinFoods = <BuiltinFood>[
  // Bread and grains.
  BuiltinFood('arabic_bread', FoodGroup.grains, 'خبز عربي', 'Arabic bread', 'رغيف', 'loaf', 60, Nutrients(kcal: 165, protein: 5.5, carbs: 33, fat: 0.7), match: ['pita', 'pita bread', 'khubz']),
  BuiltinFood('tamees', FoodGroup.grains, 'خبز تميس', 'Tamees bread', 'قطعة', 'piece', 100, Nutrients(kcal: 280, protein: 8, carbs: 55, fat: 3), match: ['tamees', 'naan']),
  BuiltinFood('toast', FoodGroup.grains, 'توست أبيض', 'White toast', 'شريحة', 'slice', 25, Nutrients(kcal: 67, protein: 2.3, carbs: 12.5, fat: 0.8), match: ['toast', 'white bread']),
  BuiltinFood('white_rice', FoodGroup.grains, 'رز أبيض مطبوخ', 'Cooked white rice', 'كوب', 'cup', 160, Nutrients(kcal: 205, protein: 4.3, carbs: 45, fat: 0.4), match: ['rice', 'steamed rice', 'white rice']),
  BuiltinFood('brown_rice', FoodGroup.grains, 'رز بني مطبوخ', 'Cooked brown rice', 'كوب', 'cup', 195, Nutrients(kcal: 216, protein: 5, carbs: 45, fat: 1.8), match: ['brown rice']),
  BuiltinFood('pasta', FoodGroup.grains, 'مكرونة مطبوخة', 'Cooked pasta', 'كوب', 'cup', 140, Nutrients(kcal: 220, protein: 8, carbs: 43, fat: 1.3), match: ['pasta', 'spaghetti', 'macaroni', 'penne']),
  BuiltinFood('oats', FoodGroup.grains, 'شوفان', 'Oats', 'نصف كوب جاف', '½ cup dry', 40, Nutrients(kcal: 150, protein: 5, carbs: 27, fat: 2.5), match: ['oatmeal', 'porridge']),
  BuiltinFood('cornflakes', FoodGroup.grains, 'كورن فليكس', 'Cornflakes', 'كوب', 'cup', 30, Nutrients(kcal: 110, protein: 2, carbs: 25, fat: 0.2), match: ['cereal', 'corn flakes']),
  // Dishes.
  BuiltinFood('chicken_kabsa', FoodGroup.dishes, 'كبسة دجاج', 'Chicken kabsa', 'صحن', 'plate', 350, Nutrients(kcal: 600, protein: 30, carbs: 70, fat: 20), match: ['kabsa', 'machboos', 'biryani']),
  BuiltinFood('meat_kabsa', FoodGroup.dishes, 'كبسة لحم', 'Meat kabsa', 'صحن', 'plate', 350, Nutrients(kcal: 700, protein: 32, carbs: 70, fat: 30)),
  BuiltinFood('chicken_mandi', FoodGroup.dishes, 'مندي دجاج', 'Chicken mandi', 'صحن', 'plate', 350, Nutrients(kcal: 620, protein: 35, carbs: 68, fat: 22), match: ['mandi', 'kabsa']),
  BuiltinFood('biryani', FoodGroup.dishes, 'برياني دجاج', 'Chicken biryani', 'صحن', 'plate', 350, Nutrients(kcal: 620, protein: 30, carbs: 75, fat: 20), match: ['biryani', 'hyderabadi biryani', 'pulao']),
  BuiltinFood('jareesh', FoodGroup.dishes, 'جريش', 'Jareesh', 'صحن', 'plate', 250, Nutrients(kcal: 300, protein: 10, carbs: 45, fat: 8)),
  BuiltinFood('harees', FoodGroup.dishes, 'هريس', 'Harees', 'صحن', 'plate', 250, Nutrients(kcal: 330, protein: 18, carbs: 40, fat: 11), match: ['harees', 'haleem']),
  BuiltinFood('saleeg', FoodGroup.dishes, 'سليق', 'Saleeg', 'صحن', 'plate', 300, Nutrients(kcal: 420, protein: 22, carbs: 50, fat: 14), match: ['saleeg']),
  BuiltinFood('mutabbaq', FoodGroup.dishes, 'مطبق', 'Mutabbaq', 'قطعة', 'piece', 150, Nutrients(kcal: 400, protein: 12, carbs: 40, fat: 21), match: ['murtabak']),
  BuiltinFood('chicken_shawarma', FoodGroup.dishes, 'شاورما دجاج', 'Chicken shawarma', 'ساندويتش', 'sandwich', 200, Nutrients(kcal: 450, protein: 25, carbs: 40, fat: 20), match: ['shawarma', 'doner kebab', 'gyro', 'wrap']),
  BuiltinFood('falafel', FoodGroup.dishes, 'فلافل', 'Falafel', 'حبة', 'piece', 17, Nutrients(kcal: 57, protein: 2.3, carbs: 5.4, fat: 3), match: ['falafel']),
  BuiltinFood('hummus', FoodGroup.dishes, 'حمص بالطحينة', 'Hummus', 'نصف كوب', '½ cup', 120, Nutrients(kcal: 200, protein: 6, carbs: 17, fat: 12), match: ['hummus']),
  BuiltinFood('foul', FoodGroup.dishes, 'فول مدمس', 'Foul medames', 'كوب', 'cup', 250, Nutrients(kcal: 230, protein: 13, carbs: 33, fat: 5), match: ['ful medames', 'foul', 'fava beans']),
  BuiltinFood('samosa', FoodGroup.dishes, 'سمبوسة لحم', 'Meat samosa', 'حبة', 'piece', 50, Nutrients(kcal: 150, protein: 5, carbs: 12, fat: 9), match: ['samosa', 'sambusa']),
  BuiltinFood('lentil_soup', FoodGroup.dishes, 'شوربة عدس', 'Lentil soup', 'كوب', 'cup', 250, Nutrients(kcal: 180, protein: 11, carbs: 28, fat: 3), match: ['lentil soup', 'soup']),
  BuiltinFood('salad', FoodGroup.dishes, 'سلطة خضار', 'Green salad', 'صحن (بدون صوص)', 'plate (no dressing)', 150, Nutrients(kcal: 35, protein: 1.5, carbs: 7, fat: 0.3), match: ['salad', 'green salad', 'garden salad']),
  BuiltinFood('tabbouleh', FoodGroup.dishes, 'تبولة', 'Tabbouleh', 'صحن', 'plate', 150, Nutrients(kcal: 180, protein: 3, carbs: 15, fat: 12), match: ['tabbouleh']),
  BuiltinFood('fattoush', FoodGroup.dishes, 'فتوش', 'Fattoush', 'صحن', 'plate', 150, Nutrients(kcal: 160, protein: 3, carbs: 14, fat: 10), match: ['fattoush']),
  BuiltinFood('pizza', FoodGroup.dishes, 'بيتزا', 'Pizza', 'شريحة', 'slice', 107, Nutrients(kcal: 285, protein: 12, carbs: 36, fat: 10), match: ['pizza']),
  BuiltinFood('burger', FoodGroup.dishes, 'برجر لحم', 'Beef burger', 'ساندويتش', 'sandwich', 220, Nutrients(kcal: 540, protein: 25, carbs: 40, fat: 29), match: ['hamburger', 'cheeseburger', 'burger']),
  BuiltinFood('fries', FoodGroup.dishes, 'بطاطس مقلية', 'French fries', 'حصة متوسطة', 'medium serving', 115, Nutrients(kcal: 365, protein: 4, carbs: 48, fat: 17), match: ['french fries', 'fries', 'chips']),
  // Protein.
  BuiltinFood('boiled_egg', FoodGroup.protein, 'بيض مسلوق', 'Boiled egg', 'حبة', 'egg', 50, Nutrients(kcal: 78, protein: 6.3, carbs: 0.6, fat: 5.3), match: ['boiled egg', 'egg']),
  BuiltinFood('fried_egg', FoodGroup.protein, 'بيض مقلي', 'Fried egg', 'حبة', 'egg', 46, Nutrients(kcal: 90, protein: 6.3, carbs: 0.4, fat: 7), match: ['fried egg', 'omelette', 'scrambled eggs']),
  BuiltinFood('grilled_chicken', FoodGroup.protein, 'صدر دجاج مشوي', 'Grilled chicken breast', '100 غ', '100 g', 100, Nutrients(kcal: 165, protein: 31, carbs: 0, fat: 3.6), match: ['grilled chicken', 'chicken breast', 'roast chicken', 'chicken']),
  BuiltinFood('lamb', FoodGroup.protein, 'لحم غنم مطبوخ', 'Cooked lamb', '100 غ', '100 g', 100, Nutrients(kcal: 290, protein: 25, carbs: 0, fat: 21), match: ['lamb', 'mutton']),
  BuiltinFood('grilled_fish', FoodGroup.protein, 'سمك مشوي', 'Grilled fish', '100 غ', '100 g', 100, Nutrients(kcal: 130, protein: 22, carbs: 0, fat: 4), match: ['grilled fish', 'fish', 'salmon']),
  BuiltinFood('tuna', FoodGroup.protein, 'تونة بالماء', 'Tuna in water', 'علبة مصفاة', 'drained can', 120, Nutrients(kcal: 130, protein: 29, carbs: 0, fat: 1), match: ['tuna']),
  // Dairy.
  BuiltinFood('white_cheese', FoodGroup.dairy, 'جبنة بيضاء', 'White cheese', 'شريحة', 'slice', 30, Nutrients(kcal: 80, protein: 5, carbs: 1, fat: 6.5), match: ['cheese', 'feta']),
  BuiltinFood('labneh', FoodGroup.dairy, 'لبنة', 'Labneh', 'ملعقتين', '2 tbsp', 30, Nutrients(kcal: 55, protein: 2.5, carbs: 1.5, fat: 4.5), match: ['labneh']),
  BuiltinFood('yogurt', FoodGroup.dairy, 'زبادي', 'Yogurt', 'علبة', 'cup', 170, Nutrients(kcal: 105, protein: 6, carbs: 8, fat: 5.5), match: ['yogurt', 'yoghurt']),
  BuiltinFood('laban', FoodGroup.dairy, 'لبن قليل الدسم', 'Low-fat laban', 'كوب', 'cup', 240, Nutrients(kcal: 100, protein: 8, carbs: 12, fat: 2.5), match: ['buttermilk', 'ayran']),
  BuiltinFood('full_milk', FoodGroup.dairy, 'حليب كامل الدسم', 'Whole milk', 'كوب', 'cup', 240, Nutrients(kcal: 150, protein: 8, carbs: 12, fat: 8), match: ['milk']),
  BuiltinFood('lowfat_milk', FoodGroup.dairy, 'حليب قليل الدسم', 'Low-fat milk', 'كوب', 'cup', 240, Nutrients(kcal: 105, protein: 8, carbs: 12, fat: 2.5)),
  // Fruit.
  BuiltinFood('dates', FoodGroup.fruit, 'تمر', 'Dates', 'حبة', 'date', 10, Nutrients(kcal: 28, protein: 0.2, carbs: 7.5, fat: 0), match: ['dates', 'date fruit']),
  BuiltinFood('banana', FoodGroup.fruit, 'موز', 'Banana', 'حبة متوسطة', 'medium', 118, Nutrients(kcal: 105, protein: 1.3, carbs: 27, fat: 0.4), match: ['banana']),
  BuiltinFood('apple', FoodGroup.fruit, 'تفاح', 'Apple', 'حبة متوسطة', 'medium', 180, Nutrients(kcal: 95, protein: 0.5, carbs: 25, fat: 0.3), match: ['apple']),
  BuiltinFood('orange', FoodGroup.fruit, 'برتقال', 'Orange', 'حبة', 'fruit', 130, Nutrients(kcal: 62, protein: 1.2, carbs: 15.4, fat: 0.2), match: ['orange']),
  BuiltinFood('grapes', FoodGroup.fruit, 'عنب', 'Grapes', 'كوب', 'cup', 150, Nutrients(kcal: 104, protein: 1.1, carbs: 27, fat: 0.2), match: ['grapes', 'grape']),
  BuiltinFood('watermelon', FoodGroup.fruit, 'بطيخ', 'Watermelon', 'كوب مقطع', 'cup, diced', 150, Nutrients(kcal: 46, protein: 0.9, carbs: 11.5, fat: 0.2), match: ['watermelon']),
  BuiltinFood('mango', FoodGroup.fruit, 'مانجو', 'Mango', 'كوب مقطع', 'cup, sliced', 165, Nutrients(kcal: 99, protein: 1.4, carbs: 25, fat: 0.6), match: ['mango']),
  // Vegetables.
  BuiltinFood('cucumber', FoodGroup.vegetables, 'خيار', 'Cucumber', 'حبة', 'piece', 200, Nutrients(kcal: 30, protein: 1.3, carbs: 7, fat: 0.2), match: ['cucumber']),
  BuiltinFood('tomato', FoodGroup.vegetables, 'طماطم', 'Tomato', 'حبة', 'piece', 120, Nutrients(kcal: 22, protein: 1.1, carbs: 4.8, fat: 0.2), match: ['tomato']),
  BuiltinFood('boiled_potato', FoodGroup.vegetables, 'بطاطس مسلوقة', 'Boiled potato', 'حبة متوسطة', 'medium', 170, Nutrients(kcal: 145, protein: 3, carbs: 33, fat: 0.2), match: ['potato', 'baked potato', 'mashed potato']),
  // Drinks.
  BuiltinFood('arabic_coffee', FoodGroup.drinks, 'قهوة عربية', 'Arabic coffee', 'فنجال', 'small cup', 30, Nutrients(kcal: 2, protein: 0, carbs: 0.3, fat: 0)),
  BuiltinFood('tea_sugar', FoodGroup.drinks, 'شاي بسكر', 'Tea with sugar', 'كوب (ملعقتين سكر)', 'cup (2 tsp sugar)', 240, Nutrients(kcal: 32, protein: 0, carbs: 8, fat: 0), match: ['tea']),
  BuiltinFood('tea_plain', FoodGroup.drinks, 'شاي بدون سكر', 'Tea, no sugar', 'كوب', 'cup', 240, Nutrients(kcal: 2, protein: 0, carbs: 0.5, fat: 0)),
  BuiltinFood('latte', FoodGroup.drinks, 'لاتيه', 'Latte', 'كوب وسط', 'medium cup', 350, Nutrients(kcal: 190, protein: 10, carbs: 15, fat: 10), match: ['latte', 'cappuccino', 'coffee']),
  BuiltinFood('orange_juice', FoodGroup.drinks, 'عصير برتقال طبيعي', 'Fresh orange juice', 'كوب', 'cup', 240, Nutrients(kcal: 112, protein: 1.7, carbs: 26, fat: 0.5), match: ['orange juice', 'juice']),
  BuiltinFood('soda', FoodGroup.drinks, 'مشروب غازي', 'Soft drink', 'علبة 330 مل', '330 ml can', 330, Nutrients(kcal: 140, protein: 0, carbs: 35, fat: 0), match: ['cola', 'soda', 'soft drink']),
  // Snacks and sweets.
  BuiltinFood('almonds', FoodGroup.snacks, 'لوز', 'Almonds', 'حفنة', 'handful', 28, Nutrients(kcal: 164, protein: 6, carbs: 6, fat: 14), match: ['almond', 'almonds']),
  BuiltinFood('mixed_nuts', FoodGroup.snacks, 'مكسرات مشكلة', 'Mixed nuts', 'حفنة', 'handful', 28, Nutrients(kcal: 170, protein: 5, carbs: 6, fat: 15), match: ['nuts', 'mixed nuts', 'cashew', 'pistachio']),
  BuiltinFood('chocolate', FoodGroup.snacks, 'شوكولاتة بالحليب', 'Milk chocolate', 'قطعة', 'bar', 40, Nutrients(kcal: 215, protein: 3, carbs: 24, fat: 12), match: ['chocolate']),
  BuiltinFood('kunafa', FoodGroup.snacks, 'كنافة', 'Kunafa', 'قطعة', 'piece', 100, Nutrients(kcal: 350, protein: 6, carbs: 40, fat: 18), match: ['knafeh', 'kunafa', 'kanafeh']),
  BuiltinFood('basbousa', FoodGroup.snacks, 'بسبوسة', 'Basbousa', 'قطعة', 'piece', 60, Nutrients(kcal: 210, protein: 3, carbs: 33, fat: 8), match: ['basbousa']),
  BuiltinFood('luqaimat', FoodGroup.snacks, 'لقيمات', 'Luqaimat', '5 حبات', '5 pieces', 60, Nutrients(kcal: 250, protein: 3, carbs: 30, fat: 13), match: ['luqaimat', 'loukoumades', 'doughnut']),
  BuiltinFood('biscuits', FoodGroup.snacks, 'بسكويت', 'Biscuits', 'حبتين', '2 pieces', 20, Nutrients(kcal: 95, protein: 1.2, carbs: 13.5, fat: 4), match: ['cookie', 'biscuit']),
  // Extras.
  BuiltinFood('olive_oil', FoodGroup.extras, 'زيت زيتون', 'Olive oil', 'ملعقة كبيرة', 'tbsp', 14, Nutrients(kcal: 119, protein: 0, carbs: 0, fat: 13.5)),
  BuiltinFood('honey', FoodGroup.extras, 'عسل', 'Honey', 'ملعقة كبيرة', 'tbsp', 21, Nutrients(kcal: 64, protein: 0.1, carbs: 17, fat: 0), match: ['honey']),
  BuiltinFood('sugar', FoodGroup.extras, 'سكر', 'Sugar', 'ملعقة صغيرة', 'tsp', 4, Nutrients(kcal: 16, protein: 0, carbs: 4, fat: 0)),
  BuiltinFood('peanut_butter', FoodGroup.extras, 'زبدة فول سوداني', 'Peanut butter', 'ملعقة كبيرة', 'tbsp', 16, Nutrients(kcal: 95, protein: 3.6, carbs: 3.5, fat: 8), match: ['peanut butter']),
];

final _byId = {for (final f in builtinFoods) f.id: f};
BuiltinFood? builtinFood(String? id) => id == null ? null : _byId[id];

/// Case- and accent-light search over Arabic and English names.
List<BuiltinFood> searchBuiltin(String query) {
  final q = _norm(query);
  if (q.isEmpty) return builtinFoods;
  return builtinFoods.where((f) => _norm(f.ar).contains(q) || _norm(f.en).contains(q)).toList();
}

/// Built-in foods matching a classifier label, best first.
List<BuiltinFood> foodsForLabel(String label) {
  final l = label.trim().toLowerCase();
  if (l.isEmpty) return const [];
  final exact = builtinFoods.where((f) => f.match.contains(l) || f.en.toLowerCase() == l);
  final partial = builtinFoods.where((f) => !exact.contains(f) && f.match.any((m) => l.contains(m) || m.contains(l)));
  return [...exact, ...partial];
}

/// Folds the Arabic letter variants people type interchangeably.
String _norm(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[أإآ]'), 'ا')
    .replaceAll('ة', 'ه')
    .replaceAll('ى', 'ي')
    .replaceAll(RegExp('[ً-ْ]'), '')
    .trim();
