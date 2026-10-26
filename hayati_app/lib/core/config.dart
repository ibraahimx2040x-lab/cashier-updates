import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Build-time configuration:
///
///   flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=...
///
/// Without both values the app runs in local mode (device-only data).
/// The anon/publishable key is safe to ship: every table is protected by
/// row-level security. Never put the service-role key in the app.
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get remote => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}

/// The Supabase client when the app is connected, otherwise null.
/// Overridden in `main()` (and in integration tests).
final supabaseClientProvider = Provider<SupabaseClient?>((ref) => null);
