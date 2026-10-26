import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config.dart';
import 'core/utils/format.dart';
import 'data/store/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  configureDigits();
  final prefs = await SharedPreferences.getInstance();
  SupabaseClient? client;
  if (AppConfig.remote) {
    await Supabase.initialize(url: AppConfig.supabaseUrl, publishableKey: AppConfig.supabaseAnonKey);
    client = Supabase.instance.client;
  }
  runApp(ProviderScope(
    overrides: [
      localStoreProvider.overrideWithValue(LocalStore(prefs)),
      supabaseClientProvider.overrideWithValue(client),
    ],
    child: const HayatiApp(),
  ));
}
