import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:hayati/data/auth.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/health.dart';
import 'package:hayati/data/store/local_store.dart';
import 'package:hayati/services/health_reader.dart';
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

/// A health store with fixed data; [grant] decides the permission sheet.
class FakeHealthReader implements HealthReader {
  FakeHealthReader({
    this.grant = true,
    this.days = const [],
    this.sleep = const [],
    this.heart = const [],
    this.workouts = const [],
    this.source = ActivitySource.healthConnect,
  });
  bool grant;
  List<StepDay> days;
  List<(DateTime, DateTime)> sleep;
  List<(DateTime, double)> heart;
  List<DeviceWorkout> workouts;
  Object? failSleep;
  int reads = 0;
  final asked = <Set<HealthKind>>[];

  @override
  final ActivitySource source;
  @override
  Future<HealthAvailability> availability() async => HealthAvailability.ready;
  @override
  Future<bool> requestAccess(Set<HealthKind> kinds) async {
    asked.add(kinds);
    return grant;
  }

  @override
  Future<void> install() async {}
  @override
  Future<List<StepDay>> readDays(DateTime from, DateTime to) async {
    reads++;
    return days;
  }

  @override
  Future<List<(DateTime, DateTime)>> readSleep(DateTime from, DateTime to) async {
    if (failSleep != null) throw failSleep!;
    return sleep;
  }

  @override
  Future<List<(DateTime, double)>> readRestingHeart(DateTime from, DateTime to) async => heart;
  @override
  Future<List<DeviceWorkout>> readWorkouts(DateTime from, DateTime to) async => workouts;
}
