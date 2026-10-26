import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/utils/format.dart';
import 'data/store/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  configureDigits();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [localStoreProvider.overrideWithValue(LocalStore(prefs))],
    child: const HayatiApp(),
  ));
}
