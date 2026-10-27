import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/models/nutrition.dart';

/// A packaged product's label, from Open Food Facts.
class ProductInfo {
  const ProductInfo({required this.barcode, required this.name, required this.portion, this.grams, required this.per});
  final String barcode;
  final String name;
  final String portion;
  final double? grams;

  /// Per [portion] (one serving when the label gives it, else 100 g).
  final Nutrients per;
}

enum LookupFailure { notFound, network }

class LookupResult {
  const LookupResult.found(ProductInfo this.product) : failure = null;
  const LookupResult.failed(LookupFailure this.failure) : product = null;
  final ProductInfo? product;
  final LookupFailure? failure;
}

/// Looks up a barcode in Open Food Facts (free, open data, ODbL). Only the
/// barcode is sent.
abstract interface class BarcodeLookup {
  Future<LookupResult> find(String barcode, {required String lang});
}

class OpenFoodFactsLookup implements BarcodeLookup {
  OpenFoodFactsLookup([http.Client? client]) : _http = client ?? http.Client();
  final http.Client _http;

  @override
  Future<LookupResult> find(String barcode, {required String lang}) async {
    final uri = Uri.https('world.openfoodfacts.org', '/api/v2/product/$barcode.json', {
      'fields': 'product_name,product_name_ar,product_name_en,brands,serving_size,serving_quantity,nutriments',
    });
    try {
      final r = await _http.get(uri, headers: {'User-Agent': 'Hayati/1.0 (personal planner app)'}).timeout(const Duration(seconds: 15));
      if (r.statusCode == 404) return const LookupResult.failed(LookupFailure.notFound);
      if (r.statusCode != 200) return const LookupResult.failed(LookupFailure.network);
      final j = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, Object?>;
      final p = j['product'];
      if (j['status'] != 1 || p is! Map) return const LookupResult.failed(LookupFailure.notFound);
      final info = parseProduct(barcode, p.cast<String, Object?>(), lang: lang);
      return info == null ? const LookupResult.failed(LookupFailure.notFound) : LookupResult.found(info);
    } catch (_) {
      return const LookupResult.failed(LookupFailure.network);
    }
  }
}

/// Reads an Open Food Facts product. Prefers per-serving values when the
/// label has them; otherwise per 100 g. Null when there's no energy value.
ProductInfo? parseProduct(String barcode, Map<String, Object?> p, {required String lang}) {
  final n = (p['nutriments'] as Map?)?.cast<String, Object?>() ?? const {};
  double? v(String k) => switch (n[k]) { final num x => x.toDouble(), final String s => double.tryParse(s), _ => null };
  String s(String k) => (p[k] as String?)?.trim() ?? '';
  var name = lang == 'ar' ? s('product_name_ar') : s('product_name_en');
  if (name.isEmpty) name = s('product_name');
  if (name.isEmpty) name = s('brands');
  if (name.isEmpty) name = barcode;
  if (name.length > 120) name = name.substring(0, 120);

  final serving = v('energy-kcal_serving');
  final servingGrams = switch (p['serving_quantity']) { final num x => x.toDouble(), final String t => double.tryParse(t), _ => null };
  if (serving != null) {
    final portion = s('serving_size');
    return ProductInfo(
      barcode: barcode,
      name: name,
      portion: portion.length > 60 ? portion.substring(0, 60) : portion,
      grams: servingGrams != null && servingGrams > 0 && servingGrams <= 5000 ? servingGrams : null,
      per: Nutrients(kcal: serving, protein: v('proteins_serving') ?? 0, carbs: v('carbohydrates_serving') ?? 0, fat: v('fat_serving') ?? 0),
    );
  }
  final kcal = v('energy-kcal_100g') ?? (v('energy_100g') != null ? v('energy_100g')! / 4.184 : null);
  if (kcal == null) return null;
  return ProductInfo(
    barcode: barcode,
    name: name,
    portion: '100 g',
    grams: 100,
    per: Nutrients(kcal: kcal, protein: v('proteins_100g') ?? 0, carbs: v('carbohydrates_100g') ?? 0, fat: v('fat_100g') ?? 0),
  );
}

/// Overridden in tests.
final barcodeLookupProvider = Provider<BarcodeLookup>((ref) => OpenFoodFactsLookup());
