import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// The phone's own unlock (fingerprint, face or passcode), used to lock the
/// health sections. The app never sees or stores any of it.
abstract interface class DeviceAuth {
  /// False on the web and on phones with no screen lock set up.
  Future<bool> available();
  Future<bool> authenticate(String reason);
}

class NoDeviceAuth implements DeviceAuth {
  const NoDeviceAuth();
  @override
  Future<bool> available() async => false;
  @override
  Future<bool> authenticate(String reason) async => false;
}

class PhoneDeviceAuth implements DeviceAuth {
  final _auth = LocalAuthentication();

  @override
  Future<bool> available() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
    } catch (_) {
      return false;
    }
  }
}

/// Overridden in tests.
final deviceAuthProvider = Provider<DeviceAuth>((ref) {
  if (kIsWeb) return const NoDeviceAuth();
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => PhoneDeviceAuth(),
    _ => const NoDeviceAuth(),
  };
});

/// Whether the health sections are open in this run of the app. Locks again
/// when the app goes to the background.
class HealthUnlock extends Notifier<bool> {
  @override
  bool build() => false;

  Future<bool> unlock(String reason) async {
    final ok = await ref.read(deviceAuthProvider).authenticate(reason);
    if (ok) state = true;
    return ok;
  }

  void lock() => state = false;
}

final healthUnlockProvider = NotifierProvider<HealthUnlock, bool>(HealthUnlock.new);

final deviceAuthAvailableProvider = FutureProvider<bool>((ref) => ref.watch(deviceAuthProvider).available());
