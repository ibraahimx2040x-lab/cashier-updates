import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/health_reader.dart';
import 'auth.dart';
import 'data_controller.dart';
import 'models/health.dart';
import 'store/local_store.dart';

class HealthSyncState {
  const HealthSyncState({
    this.availability,
    this.kinds = const {},
    this.busy = false,
    this.failed = false,
    this.lastSync,
  });

  /// Null until checked.
  final HealthAvailability? availability;

  /// What this device reads from its health store. Kept per device: a
  /// permission granted on one phone says nothing about another.
  final Set<HealthKind> kinds;
  final bool busy;
  final bool failed;
  final DateTime? lastSync;

  bool get linked => kinds.isNotEmpty;
  bool reads(HealthKind k) => kinds.contains(k);

  HealthSyncState copyWith({HealthAvailability? availability, Set<HealthKind>? kinds, bool? busy, bool? failed, DateTime? lastSync}) =>
      HealthSyncState(
        availability: availability ?? this.availability,
        kinds: kinds ?? this.kinds,
        busy: busy ?? this.busy,
        failed: failed ?? this.failed,
        lastSync: lastSync ?? this.lastSync,
      );
}

class HealthSyncController extends Notifier<HealthSyncState> {
  HealthReader get _reader => ref.read(healthReaderProvider);
  LocalStore get _store => ref.read(localStoreProvider);
  String get _uid => '${ref.read(authProvider).user?.id}';
  String get _key => 'hayati.health.kinds.$_uid';

  /// Days re-read on each sync, so late uploads from a watch are picked up;
  /// the first read after connecting goes back further.
  static const days = 7;
  static const firstDays = 30;
  static const minInterval = Duration(minutes: 10);

  @override
  HealthSyncState build() {
    ref.watch(authProvider.select((s) => s.user?.id));
    Future.microtask(_check);
    return HealthSyncState(kinds: _load());
  }

  Set<HealthKind> _load() {
    final raw = _store.readString(_key);
    if (raw == null) {
      // Phase 07 kept a single "steps linked" flag.
      return _store.readString('hayati.health.linked.$_uid') == '1' ? {HealthKind.steps} : {};
    }
    return {
      for (final n in raw.split(',')) ?HealthKind.values.where((k) => k.name == n).firstOrNull,
    };
  }

  Future<void> _save(Set<HealthKind> kinds) async {
    await _store.writeString(_key, (kinds.map((k) => k.name).toList()..sort()).join(','));
    state = state.copyWith(kinds: kinds);
  }

  Future<void> _check() async {
    final a = await _reader.availability();
    state = state.copyWith(availability: a);
  }

  /// Asks for permission to read [kinds] and, when given, adds them and
  /// reads the last [firstDays] days.
  Future<bool> connect(Set<HealthKind> kinds) async {
    if (_reader.source == null || kinds.isEmpty) return false;
    if (await _reader.availability() == HealthAvailability.needsInstall) {
      await _reader.install();
      await _check();
      return false;
    }
    final ok = await _reader.requestAccess(kinds);
    if (!ok) return false;
    state = state.copyWith(availability: HealthAvailability.ready);
    await _save({...state.kinds, ...kinds});
    await sync(force: true, back: firstDays);
    return true;
  }

  /// Stops reading [kind] on this device. What was imported stays.
  Future<void> stop(HealthKind kind) => _save({...state.kinds}..remove(kind));

  Future<void> disconnect() => _save({});

  /// Whether [kind] is wanted at all: its health section is on.
  bool _wanted(HealthKind k) {
    final h = ref.read(settingsProvider).health;
    return switch (k) {
      HealthKind.sleep => h.has(HealthModule.sleep),
      _ => h.has(HealthModule.activity),
    };
  }

  /// Copies what the health store has into the app. Throttled unless
  /// [force]d. One failing kind doesn't stop the others.
  Future<void> sync({bool force = false, int back = days}) async {
    final source = _reader.source;
    if (!state.linked || state.busy || source == null) return;
    final kinds = state.kinds.where(_wanted).toSet();
    if (kinds.isEmpty) return;
    final last = state.lastSync;
    final now = ref.read(clockProvider)();
    if (!force && last != null && now.difference(last) < minInterval) return;
    state = state.copyWith(busy: true, failed: false);
    final c = ref.read(dataProvider.notifier);
    final from = DateTime(now.year, now.month, now.day).subtract(Duration(days: back - 1));
    var failed = false;
    Future<void> run(HealthKind k, Future<void> Function() f) async {
      if (!kinds.contains(k)) return;
      try {
        await f();
      } catch (_) {
        failed = true;
      }
    }

    await run(HealthKind.steps, () async {
      for (final d in await _reader.readDays(from, now)) {
        c.recordActivity(d.day, source, steps: d.steps.clamp(0, DailyActivity.maxSteps));
      }
    });
    // A night that started the evening before the window still counts.
    await run(HealthKind.sleep, () async {
      final segments = await _reader.readSleep(from.subtract(const Duration(hours: 12)), now);
      c.importSleep(source, segments, from: from);
    });
    await run(HealthKind.heartRate, () async => c.importRestingHeart(source, await _reader.readRestingHeart(from, now)));
    await run(HealthKind.workouts, () async => c.importWorkouts(source, await _reader.readWorkouts(from, now), from: from));
    state = state.copyWith(busy: false, failed: failed, lastSync: now);
  }
}

final healthSyncProvider = NotifierProvider<HealthSyncController, HealthSyncState>(HealthSyncController.new);
