import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/step_reader.dart';
import 'auth.dart';
import 'data_controller.dart';
import 'models/health.dart';
import 'store/local_store.dart';

class ActivitySyncState {
  const ActivitySyncState({
    this.availability,
    this.linked = false,
    this.busy = false,
    this.failed = false,
    this.lastSync,
  });

  /// Null until checked.
  final StepAvailability? availability;

  /// This device reads steps from the health store. Kept per device: a
  /// permission granted on one phone says nothing about another.
  final bool linked;
  final bool busy;
  final bool failed;
  final DateTime? lastSync;

  ActivitySyncState copyWith({StepAvailability? availability, bool? linked, bool? busy, bool? failed, DateTime? lastSync}) =>
      ActivitySyncState(
        availability: availability ?? this.availability,
        linked: linked ?? this.linked,
        busy: busy ?? this.busy,
        failed: failed ?? this.failed,
        lastSync: lastSync ?? this.lastSync,
      );
}

class ActivitySyncController extends Notifier<ActivitySyncState> {
  StepReader get _reader => ref.read(stepReaderProvider);
  LocalStore get _store => ref.read(localStoreProvider);
  String get _key => 'hayati.health.linked.${ref.read(authProvider).user?.id}';

  /// Days re-read on each sync, so late uploads from a watch are picked up.
  static const days = 7;
  static const minInterval = Duration(minutes: 10);

  @override
  ActivitySyncState build() {
    ref.watch(authProvider.select((s) => s.user?.id));
    Future.microtask(_check);
    return ActivitySyncState(linked: _store.readString(_key) == '1');
  }

  Future<void> _check() async {
    final a = await _reader.availability();
    state = state.copyWith(availability: a);
  }

  /// Asks for permission and, when given, reads the last [days] days.
  Future<bool> connect() async {
    if (_reader.source == null) return false;
    if (await _reader.availability() == StepAvailability.needsInstall) {
      await _reader.install();
      await _check();
      return false;
    }
    final ok = await _reader.requestAccess();
    if (!ok) return false;
    await _store.writeString(_key, '1');
    state = state.copyWith(linked: true, availability: StepAvailability.ready);
    await sync(force: true);
    return true;
  }

  Future<void> disconnect() async {
    await _store.writeString(_key, '0');
    state = state.copyWith(linked: false);
  }

  /// Copies the health store's daily totals into the app. Throttled unless
  /// [force]d; does nothing when the activity section is off.
  Future<void> sync({bool force = false}) async {
    final source = _reader.source;
    if (!state.linked || state.busy || source == null) return;
    if (!ref.read(settingsProvider).health.has(HealthModule.activity)) return;
    final last = state.lastSync;
    final now = ref.read(clockProvider)();
    if (!force && last != null && now.difference(last) < minInterval) return;
    state = state.copyWith(busy: true, failed: false);
    try {
      final read = await _reader.readDays(now.subtract(const Duration(days: days - 1)), now);
      final c = ref.read(dataProvider.notifier);
      for (final d in read) {
        c.recordActivity(d.day, source, steps: d.steps.clamp(0, DailyActivity.maxSteps));
      }
      state = state.copyWith(busy: false, lastSync: now);
    } catch (_) {
      state = state.copyWith(busy: false, failed: true);
    }
  }
}

final activitySyncProvider = NotifierProvider<ActivitySyncController, ActivitySyncState>(ActivitySyncController.new);
