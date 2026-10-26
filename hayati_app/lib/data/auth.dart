import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/dates.dart';
import 'store/local_store.dart';

class AuthUser {
  const AuthUser({required this.id, required this.email, required this.createdAt});
  final String id;
  final String email;
  final DateTime createdAt;
}

enum AuthErrorCode { invalidEmail, weakPassword, emailExists, invalidCredentials, network }

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

/// Local-mode authentication.
///
/// Accounts live on this device only; passwords are salted and hashed.
/// In production this class is replaced by Supabase Auth — the UI depends
/// only on [AuthController]'s public API.
class AuthController extends Notifier<AuthState> {
  static const _accountsKey = 'hayati.accounts';
  static const _sessionKey = 'hayati.session';

  LocalStore get _store => ref.read(localStoreProvider);

  @override
  AuthState build() => const AuthState();

  Map<String, Object?> get _accounts => _store.readJson(_accountsKey) ?? {};

  Future<void> restore() async {
    final id = _store.readString(_sessionKey);
    AuthUser? user;
    if (id != null) {
      for (final e in _accounts.entries) {
        final a = (e.value as Map).cast<String, Object?>();
        if (a['id'] == id) {
          user = AuthUser(id: id, email: e.key, createdAt: decodeInstant(a['createdAt'])!);
        }
      }
    }
    state = AuthState(user: user, restored: true);
  }

  Future<void> signUp(String email, String password) async {
    email = email.trim().toLowerCase();
    if (!isValidEmail(email)) throw const AuthException(AuthErrorCode.invalidEmail);
    if (!isStrongPassword(password)) throw const AuthException(AuthErrorCode.weakPassword);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final accounts = _accounts;
    if (accounts.containsKey(email)) throw const AuthException(AuthErrorCode.emailExists);
    final salt = _salt();
    final id = const Uuid().v4();
    final now = DateTime.now();
    accounts[email] = {
      'id': id,
      'salt': salt,
      'hash': _hash(salt, password),
      'createdAt': encodeInstant(now),
    };
    await _store.writeJson(_accountsKey, accounts);
    await _store.writeString(_sessionKey, id);
    state = AuthState(user: AuthUser(id: id, email: email, createdAt: now), restored: true);
  }

  Future<void> signIn(String email, String password) async {
    email = email.trim().toLowerCase();
    if (!isValidEmail(email)) throw const AuthException(AuthErrorCode.invalidEmail);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final raw = _accounts[email];
    if (raw == null) throw const AuthException(AuthErrorCode.invalidCredentials);
    final a = (raw as Map).cast<String, Object?>();
    if (_hash(a['salt'] as String, password) != a['hash']) {
      throw const AuthException(AuthErrorCode.invalidCredentials);
    }
    await _store.writeString(_sessionKey, a['id'] as String);
    state = AuthState(
      user: AuthUser(id: a['id'] as String, email: email, createdAt: decodeInstant(a['createdAt'])!),
      restored: true,
    );
  }

  /// Re-authentication for sensitive operations (screen 21).
  bool verifyPassword(String password) {
    final u = state.user;
    if (u == null) return false;
    final a = (_accounts[u.email] as Map?)?.cast<String, Object?>();
    return a != null && _hash(a['salt'] as String, password) == a['hash'];
  }

  Future<void> changePassword(String current, String next) async {
    final u = state.user;
    if (u == null || !verifyPassword(current)) {
      throw const AuthException(AuthErrorCode.invalidCredentials);
    }
    if (!isStrongPassword(next)) throw const AuthException(AuthErrorCode.weakPassword);
    final accounts = _accounts;
    final salt = _salt();
    final a = (accounts[u.email] as Map).cast<String, Object?>();
    accounts[u.email] = {...a, 'salt': salt, 'hash': _hash(salt, next)};
    await _store.writeJson(_accountsKey, accounts);
  }

  Future<void> signOut() async {
    await _store.remove(_sessionKey);
    state = const AuthState(restored: true);
  }

  /// Removes the account record. User data is wiped by the caller first.
  Future<void> deleteAccount() async {
    final u = state.user;
    if (u == null) return;
    final accounts = _accounts..remove(u.email);
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

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
