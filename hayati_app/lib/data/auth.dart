import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/config.dart';
import '../core/utils/dates.dart';
import 'remote/supabase_auth.dart';
import 'store/local_store.dart';

class AuthUser {
  const AuthUser({required this.id, required this.email, required this.createdAt, this.emailConfirmed = true});
  final String id;
  final String email;
  final DateTime createdAt;
  final bool emailConfirmed;
}

enum AuthErrorCode {
  invalidEmail,
  weakPassword,
  emailExists,
  invalidCredentials,
  network,

  /// Sign-up succeeded but the email must be confirmed before signing in.
  confirmEmail,
  emailNotConfirmed,
  rateLimited,
}

class AuthException implements Exception {
  const AuthException(this.code);
  final AuthErrorCode code;
  @override
  String toString() => 'AuthException($code)';
}

class AuthState {
  const AuthState({this.user, this.restored = false});
  final AuthUser? user;

  /// True once the persisted session has been checked (splash screen).
  final bool restored;
  bool get signedIn => user != null;
}

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isValidEmail(String v) => _emailRe.hasMatch(v.trim());

/// Minimum 8 characters, at least one letter and one digit.
bool isStrongPassword(String v) =>
    v.length >= 8 && RegExp(r'[A-Za-z؀-ۿ]').hasMatch(v) && RegExp(r'\d').hasMatch(v);

/// What an authentication provider must do. The UI only sees
/// [AuthController]; the backend is local (device) or Supabase.
abstract interface class AuthBackend {
  /// Whether accounts live on a server (enables email recovery etc.).
  bool get remote;

  Future<AuthUser?> restore();
  Future<AuthUser> signUp(String email, String password);
  Future<AuthUser> signIn(String email, String password);
  Future<bool> verifyPassword(AuthUser user, String password);
  Future<void> changePassword(AuthUser user, String current, String next);
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();

  /// Local: deletes the account now. Remote: records a deletion request
  /// that the server processes, then signs out.
  Future<void> deleteAccount(AuthUser user);

  /// Session changes made outside the app's calls (expiry, refresh failure).
  Stream<AuthUser?> get changes;
}

class AuthController extends Notifier<AuthState> {
  late AuthBackend _backend;
  StreamSubscription<AuthUser?>? _sub;

  @override
  AuthState build() {
    _backend = ref.watch(authBackendProvider);
    _sub?.cancel();
    _sub = _backend.changes.listen((u) {
      if (!state.restored || _deleting) return;
      // Ended elsewhere (expired / revoked): reflect it so the router
      // returns to sign-in instead of failing silently.
      if (u == null && state.user != null) state = const AuthState(restored: true);
    });
    ref.onDispose(() => _sub?.cancel());
    return const AuthState();
  }

  bool get remote => _backend.remote;

  Future<void> restore() async => state = AuthState(user: await _backend.restore(), restored: true);

  Future<void> signUp(String email, String password) async {
    email = email.trim().toLowerCase();
    if (!isValidEmail(email)) throw const AuthException(AuthErrorCode.invalidEmail);
    if (!isStrongPassword(password)) throw const AuthException(AuthErrorCode.weakPassword);
    state = AuthState(user: await _backend.signUp(email, password), restored: true);
  }

  Future<void> signIn(String email, String password) async {
    email = email.trim().toLowerCase();
    if (!isValidEmail(email)) throw const AuthException(AuthErrorCode.invalidEmail);
    state = AuthState(user: await _backend.signIn(email, password), restored: true);
  }

  /// Re-authentication for sensitive operations (screen 21).
  Future<bool> verifyPassword(String password) async {
    final u = state.user;
    return u != null && await _backend.verifyPassword(u, password);
  }

  Future<void> changePassword(String current, String next) async {
    final u = state.user;
    if (u == null) throw const AuthException(AuthErrorCode.invalidCredentials);
    if (!isStrongPassword(next)) throw const AuthException(AuthErrorCode.weakPassword);
    await _backend.changePassword(u, current, next);
  }

  Future<void> sendPasswordReset(String email) async {
    email = email.trim().toLowerCase();
    if (!isValidEmail(email)) throw const AuthException(AuthErrorCode.invalidEmail);
    await _backend.sendPasswordReset(email);
  }

  Future<void> signOut() async {
    await _backend.signOut();
    state = const AuthState(restored: true);
  }

  bool _deleting = false;

  /// Deletes (local) or requests deletion of (remote) the account. Throws
  /// before anything is cleared if the request fails. [clearLocal] runs
  /// while the user is still signed in, so it can remove their cache.
  Future<void> deleteAccount({Future<void> Function()? clearLocal}) async {
    final u = state.user;
    if (u == null) return;
    _deleting = true;
    try {
      await _backend.deleteAccount(u);
      await clearLocal?.call();
    } finally {
      _deleting = false;
    }
    state = const AuthState(restored: true);
  }
}

final authBackendProvider = Provider<AuthBackend>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? LocalAuthBackend(ref.read(localStoreProvider)) : SupabaseAuthBackend(client);
});

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Device-only accounts with salted, iterated SHA-256 password hashes.
class LocalAuthBackend implements AuthBackend {
  LocalAuthBackend(this._store);

  static const _accountsKey = 'hayati.accounts';
  static const _sessionKey = 'hayati.session';

  final LocalStore _store;

  @override
  bool get remote => false;

  @override
  Stream<AuthUser?> get changes => const Stream.empty();

  Map<String, Object?> get _accounts => _store.readJson(_accountsKey) ?? {};

  AuthUser _user(String email, Map<String, Object?> a) =>
      AuthUser(id: a['id'] as String, email: email, createdAt: decodeInstant(a['createdAt'])!);

  @override
  Future<AuthUser?> restore() async {
    final id = _store.readString(_sessionKey);
    if (id == null) return null;
    for (final e in _accounts.entries) {
      final a = (e.value as Map).cast<String, Object?>();
      if (a['id'] == id) return _user(e.key, a);
    }
    return null;
  }

  @override
  Future<AuthUser> signUp(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final accounts = _accounts;
    if (accounts.containsKey(email)) throw const AuthException(AuthErrorCode.emailExists);
    final salt = _salt();
    final a = <String, Object?>{
      'id': const Uuid().v4(),
      'salt': salt,
      'hash': _hash(salt, password),
      'createdAt': encodeInstant(DateTime.now()),
    };
    accounts[email] = a;
    await _store.writeJson(_accountsKey, accounts);
    await _store.writeString(_sessionKey, a['id'] as String);
    return _user(email, a);
  }

  @override
  Future<AuthUser> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final raw = _accounts[email];
    if (raw == null) throw const AuthException(AuthErrorCode.invalidCredentials);
    final a = (raw as Map).cast<String, Object?>();
    if (_hash(a['salt'] as String, password) != a['hash']) {
      throw const AuthException(AuthErrorCode.invalidCredentials);
    }
    await _store.writeString(_sessionKey, a['id'] as String);
    return _user(email, a);
  }

  @override
  Future<bool> verifyPassword(AuthUser user, String password) async {
    final a = (_accounts[user.email] as Map?)?.cast<String, Object?>();
    return a != null && _hash(a['salt'] as String, password) == a['hash'];
  }

  @override
  Future<void> changePassword(AuthUser user, String current, String next) async {
    if (!await verifyPassword(user, current)) throw const AuthException(AuthErrorCode.invalidCredentials);
    final accounts = _accounts;
    final salt = _salt();
    final a = (accounts[user.email] as Map).cast<String, Object?>();
    accounts[user.email] = {...a, 'salt': salt, 'hash': _hash(salt, next)};
    await _store.writeJson(_accountsKey, accounts);
  }

  /// No email service on the device; the UI explains this.
  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() => _store.remove(_sessionKey);

  @override
  Future<void> deleteAccount(AuthUser user) async {
    final accounts = _accounts..remove(user.email);
    await _store.writeJson(_accountsKey, accounts);
    await signOut();
  }

  static String _salt() {
    final r = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  static String _hash(String salt, String password) {
    List<int> bytes = utf8.encode('$salt:$password');
    for (var i = 0; i < 5000; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return base64Url.encode(bytes);
  }
}
