import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

import '../core/utils/dates.dart';
import '../data/models/health.dart';

enum HealthAvailability {
  /// No health source on this platform (web, desktop): manual entry only.
  unsupported,

  /// Android without Health Connect (or an outdated one): offer to install.
  needsInstall,
  ready,
}

class StepDay {
  const StepDay(this.day, this.steps);
  final String day;
  final int steps;
}

/// Reads from the phone's health store: Health Connect on Android,
/// HealthKit on iPhone. Both already merge the user's apps and devices
/// (a watch, a scale, the phone itself), so the store is one source.
abstract interface class HealthReader {
  ActivitySource? get source;
  Future<HealthAvailability> availability();

  /// Shows the system permission sheet for [kinds]. True when given (iOS
  /// never says whether reading was allowed, so there it means "asked").
  Future<bool> requestAccess(Set<HealthKind> kinds);

  /// Opens the store page for Health Connect.
  Future<void> install();

  /// Daily step totals, one entry per local day from [from] to [to].
  Future<List<StepDay>> readDays(DateTime from, DateTime to);

  /// Sleep as the store keeps it: sessions on Android, stage segments on
  /// iPhone (merged by the app).
  Future<List<(DateTime, DateTime)>> readSleep(DateTime from, DateTime to);

  /// Resting heart rate samples (bpm).
  Future<List<(DateTime, double)>> readRestingHeart(DateTime from, DateTime to);

  /// Workouts, with the store's own id in [DeviceWorkout.id].
  Future<List<DeviceWorkout>> readWorkouts(DateTime from, DateTime to);

  /// Weight (kg) and blood pressure (systolic, diastolic) readings.
  Future<List<BodyReading>> readBody(DateTime from, DateTime to);
}

/// One measurement read from the store.
class BodyReading {
  const BodyReading(this.at, this.kind, this.value, [this.value2]);
  final DateTime at;
  final MetricKind kind;
  final double value;
  final double? value2;
}

class UnsupportedHealthReader implements HealthReader {
  const UnsupportedHealthReader();
  @override
  ActivitySource? get source => null;
  @override
  Future<HealthAvailability> availability() async => HealthAvailability.unsupported;
  @override
  Future<bool> requestAccess(Set<HealthKind> kinds) async => false;
  @override
  Future<void> install() async {}
  @override
  Future<List<StepDay>> readDays(DateTime from, DateTime to) async => const [];
  @override
  Future<List<(DateTime, DateTime)>> readSleep(DateTime from, DateTime to) async => const [];
  @override
  Future<List<(DateTime, double)>> readRestingHeart(DateTime from, DateTime to) async => const [];
  @override
  Future<List<DeviceWorkout>> readWorkouts(DateTime from, DateTime to) async => const [];
  @override
  Future<List<BodyReading>> readBody(DateTime from, DateTime to) async => const [];
}

class StoreHealthReader implements HealthReader {
  StoreHealthReader(this._android);
  final bool _android;
  final _health = Health();
  bool _configured = false;

  Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  List<HealthDataType> get _sleepTypes => _android
      ? const [HealthDataType.SLEEP_SESSION]
      : const [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_LIGHT, HealthDataType.SLEEP_DEEP, HealthDataType.SLEEP_REM];

  /// On Android the plugin adds distance, calories and steps to each
  /// workout, and needs read access to those as well.
  List<HealthDataType> get _workoutTypes => _android
      ? const [HealthDataType.WORKOUT, HealthDataType.DISTANCE_DELTA, HealthDataType.TOTAL_CALORIES_BURNED, HealthDataType.STEPS]
      : const [HealthDataType.WORKOUT];

  static const _bodyTypes = [HealthDataType.WEIGHT, HealthDataType.BLOOD_PRESSURE_SYSTOLIC, HealthDataType.BLOOD_PRESSURE_DIASTOLIC];

  List<HealthDataType> _types(HealthKind k) => switch (k) {
        HealthKind.steps => const [HealthDataType.STEPS],
        HealthKind.sleep => _sleepTypes,
        HealthKind.heartRate => const [HealthDataType.RESTING_HEART_RATE],
        HealthKind.workouts => _workoutTypes,
        HealthKind.body => _bodyTypes,
      };

  @override
  ActivitySource get source => _android ? ActivitySource.healthConnect : ActivitySource.healthKit;

  @override
  Future<HealthAvailability> availability() async {
    if (!_android) return HealthAvailability.ready;
    try {
      await _configure();
      final s = await _health.getHealthConnectSdkStatus();
      return s == HealthConnectSdkStatus.sdkAvailable ? HealthAvailability.ready : HealthAvailability.needsInstall;
    } catch (_) {
      return HealthAvailability.needsInstall;
    }
  }

  @override
  Future<bool> requestAccess(Set<HealthKind> kinds) async {
    final types = {for (final k in kinds) ..._types(k)}.toList();
    if (types.isEmpty) return false;
    try {
      await _configure();
      return await _health.requestAuthorization(types, permissions: [for (final _ in types) HealthDataAccess.READ]);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> install() async {
    try {
      await _configure();
      await _health.installHealthConnect();
    } catch (_) {}
  }

  @override
  Future<List<StepDay>> readDays(DateTime from, DateTime to) async {
    await _configure();
    final out = <StepDay>[];
    final now = DateTime.now();
    for (var d = dateOnly(from); !d.isAfter(dateOnly(to)); d = d.add(const Duration(days: 1))) {
      final end = d.add(const Duration(days: 1));
      final steps = await _health.getTotalStepsInInterval(d, end.isAfter(now) ? now : end);
      if (steps != null) out.add(StepDay(dayKey(d), steps));
    }
    return out;
  }

  Future<List<HealthDataPoint>> _read(List<HealthDataType> types, DateTime from, DateTime to) async {
    await _configure();
    return _health.getHealthDataFromTypes(types: types, startTime: from, endTime: to);
  }

  @override
  Future<List<(DateTime, DateTime)>> readSleep(DateTime from, DateTime to) async => [
        for (final p in await _read(_sleepTypes, from, to)) (p.dateFrom.toLocal(), p.dateTo.toLocal()),
      ];

  @override
  Future<List<(DateTime, double)>> readRestingHeart(DateTime from, DateTime to) async => [
        for (final p in await _read(const [HealthDataType.RESTING_HEART_RATE], from, to))
          if (p.value case NumericHealthValue(:final numericValue)) (p.dateFrom.toLocal(), numericValue.toDouble()),
      ];

  @override
  Future<List<DeviceWorkout>> readWorkouts(DateTime from, DateTime to) async {
    final now = DateTime.now();
    return [
      for (final p in await _read(const [HealthDataType.WORKOUT], from, to))
        if (p.value case final WorkoutHealthValue w)
          DeviceWorkout(
            id: p.uuid.isEmpty ? p.dateFrom.toUtc().toIso8601String() : p.uuid,
            source: source,
            activity: w.workoutActivityType.name,
            start: p.dateFrom.toLocal(),
            end: p.dateTo.toLocal(),
            kcal: w.totalEnergyBurned,
            distanceM: w.totalDistance,
            steps: w.totalSteps,
            updatedAt: now,
          ),
    ];
  }

  /// The store keeps blood pressure as two series; readings at the same
  /// moment are paired.
  @override
  Future<List<BodyReading>> readBody(DateTime from, DateTime to) async {
    final points = await _read(_bodyTypes, from, to);
    double? num(HealthDataPoint p) => p.value is NumericHealthValue ? (p.value as NumericHealthValue).numericValue.toDouble() : null;
    final out = <BodyReading>[];
    final dia = <int, double>{};
    for (final p in points) {
      if (p.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC && num(p) != null) dia[p.dateFrom.millisecondsSinceEpoch] = num(p)!;
    }
    for (final p in points) {
      final v = num(p);
      if (v == null) continue;
      if (p.type == HealthDataType.WEIGHT) out.add(BodyReading(p.dateFrom.toLocal(), MetricKind.weight, v));
      if (p.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
        final d = dia[p.dateFrom.millisecondsSinceEpoch];
        if (d != null) out.add(BodyReading(p.dateFrom.toLocal(), MetricKind.bp, v, d));
      }
    }
    return out;
  }
}

/// Overridden in tests.
final healthReaderProvider = Provider<HealthReader>((ref) {
  if (kIsWeb) return const UnsupportedHealthReader();
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => StoreHealthReader(true),
    TargetPlatform.iOS => StoreHealthReader(false),
    _ => const UnsupportedHealthReader(),
  };
});
