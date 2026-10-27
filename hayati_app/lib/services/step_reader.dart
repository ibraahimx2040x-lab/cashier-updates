import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

import '../core/utils/dates.dart';
import '../data/models/health.dart';

enum StepAvailability {
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

/// Reads daily step totals from the phone's health store: Health Connect on
/// Android, HealthKit on iPhone (which includes the iPhone's own count).
/// Totals come from the platform's aggregate, which already merges the
/// user's apps and devices without counting a step twice.
abstract interface class StepReader {
  ActivitySource? get source;
  Future<StepAvailability> availability();

  /// Shows the system permission sheet. True when steps can be read.
  Future<bool> requestAccess();

  /// Opens the store page for Health Connect.
  Future<void> install();

  /// One entry per local day from [from] to [to] inclusive.
  Future<List<StepDay>> readDays(DateTime from, DateTime to);
}

class UnsupportedStepReader implements StepReader {
  const UnsupportedStepReader();
  @override
  ActivitySource? get source => null;
  @override
  Future<StepAvailability> availability() async => StepAvailability.unsupported;
  @override
  Future<bool> requestAccess() async => false;
  @override
  Future<void> install() async {}
  @override
  Future<List<StepDay>> readDays(DateTime from, DateTime to) async => const [];
}

class HealthStepReader implements StepReader {
  HealthStepReader(this._android);
  final bool _android;
  final _health = Health();
  bool _configured = false;

  static const _types = [HealthDataType.STEPS];
  static const _read = [HealthDataAccess.READ];

  Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  ActivitySource get source => _android ? ActivitySource.healthConnect : ActivitySource.healthKit;

  @override
  Future<StepAvailability> availability() async {
    if (!_android) return StepAvailability.ready;
    try {
      await _configure();
      final s = await _health.getHealthConnectSdkStatus();
      return s == HealthConnectSdkStatus.sdkAvailable ? StepAvailability.ready : StepAvailability.needsInstall;
    } catch (_) {
      return StepAvailability.needsInstall;
    }
  }

  @override
  Future<bool> requestAccess() async {
    try {
      await _configure();
      return await _health.requestAuthorization(_types, permissions: _read);
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
}

/// Overridden in tests.
final stepReaderProvider = Provider<StepReader>((ref) {
  if (kIsWeb) return const UnsupportedStepReader();
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => HealthStepReader(true),
    TargetPlatform.iOS => HealthStepReader(false),
    _ => const UnsupportedStepReader(),
  };
});
