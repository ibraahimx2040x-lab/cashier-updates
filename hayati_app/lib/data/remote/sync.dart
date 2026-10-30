import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config.dart';
import '../app_data.dart';
import '../auth.dart' show authProvider;
import '../store/local_store.dart';
import 'rows.dart';

enum SyncPhase { idle, syncing, offline, error }

class SyncState {
  const SyncState({this.phase = SyncPhase.idle, this.pending = 0, this.rejected = 0, this.ready = true, this.lastSynced});
  final SyncPhase phase;

  /// Changes saved on the device that the server hasn't confirmed yet.
  final int pending;

  /// Changes the server refused (e.g. a constraint). They are dropped and
  /// the device reloads the server's version.
  final int rejected;

  /// False until the first server load for a user with no local cache, so
  /// a new device doesn't flash onboarding for an existing account.
  final bool ready;
  final DateTime? lastSynced;

  SyncState copyWith({SyncPhase? phase, int? pending, int? rejected, bool? ready, DateTime? lastSynced}) => SyncState(
        phase: phase ?? this.phase,
        pending: pending ?? this.pending,
        rejected: rejected ?? this.rejected,
        ready: ready ?? this.ready,
        lastSynced: lastSynced ?? this.lastSynced,
      );
}

/// One pending write. Ops run in order; each is idempotent (upsert by id,
/// delete by id, profile update), so retrying after a crash is safe.
class SyncOp {
  const SyncOp(this.table, this.kind, this.payload);
  final String table;
  final String kind; // upsert | delete | profile
  final Object payload; // Row, id, or Row

  Map<String, Object?> toJson() => {'t': table, 'k': kind, 'p': payload};
  factory SyncOp.fromJson(Map<String, Object?> j) => SyncOp(j['t'] as String, j['k'] as String, j['p']!);
}

/// Computes the writes that turn [prev] into [next]: deletes children-first,
/// then upserts parents-first, then the profile.
List<SyncOp> diff(AppData prev, AppData next) {
  final deletes = <SyncOp>[];
  final upserts = <SyncOp>[];
  final wasLocal = prev.settings.health.cycleLocalOnly;
  final isLocal = next.settings.health.cycleLocalOnly;
  for (final t in syncTables) {
    if (t.cycle && isLocal) {
      // Switching to "this device only" removes the server's copy.
      if (!wasLocal) {
        for (final r in t.rows(prev)) {
          deletes.add(SyncOp(t.name, 'delete', r['id'] as String));
        }
      }
      continue;
    }
    // Switching back uploads everything kept on the device.
    final before = {
      if (!(t.cycle && wasLocal))
        for (final r in t.rows(prev)) r['id'] as String: jsonEncode(r),
    };
    final after = {for (final r in t.rows(next)) r['id'] as String: r};
    for (final id in before.keys) {
      if (!after.containsKey(id)) deletes.add(SyncOp(t.name, 'delete', id));
    }
    for (final e in after.entries) {
      if (before[e.key] != jsonEncode(e.value)) upserts.add(SyncOp(t.name, 'upsert', e.value));
    }
  }
  final ops = [...deletes.reversed, ...upserts];
  final p = profileRow(next.settings);
  if (jsonEncode(profileRow(prev.settings)) != jsonEncode(p)) ops.add(SyncOp('profiles', 'profile', p));
  return ops;
}

class SyncController extends Notifier<SyncState> {
  SupabaseClient? _client;
  String? _userId;
  List<SyncOp> _queue = [];
  bool _flushing = false;
  Timer? _retry;
  int _backoff = 2;
  void Function(AppData Function(AppData))? _apply;

  LocalStore get _store => ref.read(localStoreProvider);
  String get _queueKey => 'hayati.syncq.$_userId';

  @override
  SyncState build() {
    _client = ref.watch(supabaseClientProvider);
    _userId = ref.watch(authProvider.select((s) => s.user?.id));
    _retry?.cancel();
    ref.onDispose(() => _retry?.cancel());
    _queue = [];
    if (_client == null || _userId == null) return const SyncState();
    final raw = _store.readString(_queueKey);
    if (raw != null) {
      _queue = [for (final o in jsonDecode(raw) as List) SyncOp.fromJson((o as Map).cast())];
    }
    return SyncState(pending: _queue.length);
  }

  bool get enabled => _client != null && _userId != null;

  /// Called by DataController after it loads a user's cache. [apply]
  /// replaces the data with a server snapshot.
  void start({required bool hasCache, required void Function(AppData Function(AppData)) apply}) {
    if (!enabled) return;
    _apply = apply;
    state = state.copyWith(ready: hasCache);
    unawaited(sync());
  }

  void enqueue(AppData prev, AppData next) {
    if (!enabled) return;
    final ops = diff(prev, next);
    if (ops.isEmpty) return;
    _queue.addAll(ops);
    _persist();
    state = state.copyWith(pending: _queue.length);
    unawaited(sync());
  }

  /// Pushes pending writes, then (only if all were accepted) reloads from
  /// the server so changes made on other devices appear.
  Future<void> sync() async {
    if (!enabled || _flushing) return;
    _flushing = true;
    state = state.copyWith(phase: SyncPhase.syncing);
    try {
      final rejectedBefore = state.rejected;
      final ok = await _flush();
      if (!ok) return;
      await _pull();
      _backoff = 2;
      state = state.copyWith(
        phase: state.rejected > rejectedBefore ? SyncPhase.error : SyncPhase.idle,
        ready: true,
        lastSynced: DateTime.now(),
      );
    } catch (_) {
      _scheduleRetry();
    } finally {
      _flushing = false;
      // Writes queued while we were busy.
      if (_queue.isNotEmpty && state.phase == SyncPhase.idle) unawaited(sync());
    }
  }

  Future<bool> _flush() async {
    final db = _client!;
    while (_queue.isNotEmpty) {
      final op = _queue.first;
      try {
        switch (op.kind) {
          case 'upsert':
            await db.from(op.table).upsert(op.payload as Map<String, Object?>);
          case 'delete':
            await db.from(op.table).delete().eq('id', op.payload);
          case 'profile':
            await db.from('profiles').update(op.payload as Map<String, Object?>).eq('user_id', _userId!);
        }
      } on PostgrestException catch (e) {
        if (_retryable(e)) {
          _scheduleRetry();
          return false;
        }
        // Refused by the server (constraint, RLS): drop it; the pull below
        // restores the server's version on this device.
        state = state.copyWith(rejected: state.rejected + 1);
      } on AuthException {
        _scheduleRetry();
        return false;
      }
      _queue.removeAt(0);
      _persist();
      state = state.copyWith(pending: _queue.length);
    }
    return true;
  }

  static bool _retryable(PostgrestException e) {
    final c = e.code ?? '';
    // PGRST301/302: JWT expired/invalid → session refresh, then retry.
    return c.isEmpty || c.startsWith('PGRST3') || c == '40001' || c == '57014' || c.startsWith('08');
  }

  Future<void> _pull() async {
    final db = _client!;
    final profile = await db.from('profiles').select().eq('user_id', _userId!).single();
    final settings = settingsFrom(profile.cast<String, Object?>());
    final rows = <String, List<Row>>{};
    for (final t in syncTables) {
      if (t.cycle && settings.health.cycleLocalOnly) continue;
      rows[t.name] = [for (final r in await db.from(t.name).select()) r.cast<String, Object?>()];
    }
    // Writes made while pulling win: skip applying a now-stale snapshot.
    if (_queue.isNotEmpty) return;
    _apply?.call((local) => mergeRemote(local, settings, rows));
  }

  void _scheduleRetry() {
    _retry?.cancel();
    state = state.copyWith(phase: SyncPhase.offline, ready: true);
    _retry = Timer(Duration(seconds: _backoff), () => unawaited(sync()));
    _backoff = (_backoff * 2).clamp(2, 120);
  }

  void _persist() => _store.writeString(_queueKey, jsonEncode([for (final o in _queue) o.toJson()]));

  /// Drops everything pending for this user (account deletion).
  Future<void> clear() async {
    _queue = [];
    _retry?.cancel();
    if (_userId != null) await _store.remove(_queueKey);
    state = const SyncState();
  }
}

final syncProvider = NotifierProvider<SyncController, SyncState>(SyncController.new);
