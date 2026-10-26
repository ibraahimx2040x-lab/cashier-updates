import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin JSON key/value store over SharedPreferences.
///
/// This is the *local mode* persistence used until the Supabase backend in
/// `/supabase` is connected. Data is namespaced per user id so one account
/// on a shared device can never read another account's records.
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  Map<String, Object?>? readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as Map).cast<String, Object?>();
    } on FormatException {
      return null;
    }
  }

  Future<void> writeJson(String key, Map<String, Object?> value) =>
      _prefs.setString(key, jsonEncode(value));

  String? readString(String key) => _prefs.getString(key);
  Future<void> writeString(String key, String value) => _prefs.setString(key, value);
  Future<void> remove(String key) => _prefs.remove(key);
}

/// Overridden in `main()` once SharedPreferences has loaded.
final localStoreProvider = Provider<LocalStore>(
  (ref) => throw UnimplementedError('localStoreProvider must be overridden'),
);

/// Device-level preferences that exist before sign-in (language).
class DevicePrefs {
  static const localeKey = 'hayati.locale';
}
