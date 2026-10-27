import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:hayati/data/auth.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/health.dart';
import 'package:hayati/data/store/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fixed "now": Tuesday 2026-03-10 08:00 local.
final fixedNow = DateTime(2026, 3, 10, 8);

/// A container with an in-memory store, fixed clock and a signed-in user.
Future<ProviderContainer> signedInContainer({DateTime? now, String email = 'a@example.com', Sex? sex, List<Override> overrides = const []}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: [
    localStoreProvider.overrideWithValue(LocalStore(prefs)),
    clockProvider.overrideWithValue(() => now ?? fixedNow),
    ...overrides,
  ]);
  await c.read(authProvider.notifier).restore();
  await c.read(authProvider.notifier).signUp(email, 'password1', sex: sex);
  c.read(dataProvider); // build for the signed-in user
  return c;
}
