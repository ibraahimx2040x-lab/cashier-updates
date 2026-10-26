import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin JSON key/value store on the device.
///
/// In local mode it holds everything; in connected mode it is the offline
/// cache and the pending-sync queue. Data is namespaced per user id so one
/// account on a shared device never reads another account's records.
class LocalStore {
  LocalStore(SharedPreferences prefs) : _prefs = prefs, _mem = null;

  /// Non-persistent store (tests, simulated devices).
  LocalStore.memory() : _prefs = null, _mem = {};

  final SharedPreferences? _prefs;
  final Map<String, String>? _mem;

  Map<String, Object?>? readJson(String key) {
    final raw = readString(key);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as Map).cast<String, Object?>();
    } on FormatException {
      return null;
    }
  }

  Future<void> writeJson(String key, Map<String, Object?> value) => writeString(key, jsonEncode(value));

  String? readString(String key) => _mem != null ? _mem[key] : _prefs!.getString(key);

  Future<void> writeString(String key, String value) async {
    if (_mem != null) {
      _mem[key] = value;
    } else {
      await _prefs!.setString(key, value);
    }
  }

  Future<void> remove(String key) async {
    if (_mem != null) {
      _mem.remove(key);
    } else {
      await _prefs!.remove(key);
    }
  }
}

/// Overridden in `main()` once SharedPreferences has loaded.
final localStoreProvider = Provider<LocalStore>(
  (ref) => throw UnimplementedError('localStoreProvider must be overridden'),
);

/// Device-level preferences that exist before sign-in (language).
class DevicePrefs {
  static const localeKey = 'hayati.locale';
}
