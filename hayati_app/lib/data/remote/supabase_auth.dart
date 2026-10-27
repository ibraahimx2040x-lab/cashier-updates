import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../auth.dart';
import '../models/health.dart';

/// Supabase Auth. Sessions are persisted and refreshed by the Supabase
/// client; email confirmation, password recovery and rate limits are
/// enforced by the server.
class SupabaseAuthBackend implements AuthBackend {
  SupabaseAuthBackend(this._client);

  final sb.SupabaseClient _client;

  sb.GoTrueClient get _auth => _client.auth;

  @override
  bool get remote => true;

  @override
  Stream<AuthUser?> get changes => _auth.onAuthStateChange.map((s) => s.session == null ? null : _map(s.session!.user));

  static AuthUser _map(sb.User u) => AuthUser(
        id: u.id,
        email: u.email ?? '',
        createdAt: DateTime.tryParse(u.createdAt)?.toLocal() ?? DateTime.now(),
        emailConfirmed: u.emailConfirmedAt != null,
        sex: Sex.values.where((x) => x.name == u.userMetadata?['sex']).firstOrNull,
      );

  static AuthException _err(Object e) {
    if (e is sb.AuthRetryableFetchException) return const AuthException(AuthErrorCode.network);
    if (e is sb.AuthException) {
      switch (e.code) {
        case 'invalid_credentials':
          return const AuthException(AuthErrorCode.invalidCredentials);
        case 'user_already_exists':
        case 'email_exists':
          return const AuthException(AuthErrorCode.emailExists);
        case 'weak_password':
          return const AuthException(AuthErrorCode.weakPassword);
        case 'email_not_confirmed':
          return const AuthException(AuthErrorCode.emailNotConfirmed);
        case 'email_address_invalid':
        case 'validation_failed':
          return const AuthException(AuthErrorCode.invalidEmail);
        case 'over_request_rate_limit':
        case 'over_email_send_rate_limit':
          return const AuthException(AuthErrorCode.rateLimited);
      }
      // Older servers return no code for bad credentials.
      if (e.statusCode == '400') return const AuthException(AuthErrorCode.invalidCredentials);
    }
    return const AuthException(AuthErrorCode.network);
  }

  Future<T> _guard<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _err(e);
    }
  }

  @override
  Future<AuthUser?> restore() async {
    final s = _auth.currentSession;
    if (s == null) return null;
    if (s.isExpired) {
      try {
        await _auth.refreshSession();
      } catch (_) {
        // Offline: keep the cached session so the app opens with cached
        // data; requests will refresh once the connection is back.
        // Revoked: the change stream signs the user out.
      }
    }
    final u = _auth.currentUser;
    return u == null ? null : _map(u);
  }

  @override
  Future<AuthUser> signUp(String email, String password, {Sex? sex}) => _guard(() async {
        // Stored as account metadata; the profile trigger copies it.
        final r = await _auth.signUp(email: email, password: password, data: {'sex': ?sex?.name});
        // With email confirmation enabled there is no session yet.
        if (r.session == null || r.user == null) throw const AuthException(AuthErrorCode.confirmEmail);
        return _map(r.user!);
      });

  @override
  Future<AuthUser> signIn(String email, String password) => _guard(() async {
        final r = await _auth.signInWithPassword(email: email, password: password);
        return _map(r.user!);
      });

  @override
  Future<bool> verifyPassword(AuthUser user, String password) async {
    try {
      await _auth.signInWithPassword(email: user.email, password: password);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> changePassword(AuthUser user, String current, String next) => _guard(() async {
        if (!await verifyPassword(user, current)) throw const AuthException(AuthErrorCode.invalidCredentials);
        await _auth.updateUser(sb.UserAttributes(password: next));
      });

  @override
  Future<void> sendPasswordReset(String email) => _guard(() => _auth.resetPasswordForEmail(email));

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // Signing out must work offline: the local session is cleared anyway.
    }
  }

  @override
  Future<void> deleteAccount(AuthUser user) => _guard(() async {
        try {
          await _client.from('account_deletion_requests').insert({'user_id': user.id});
        } on sb.PostgrestException catch (e) {
          if (e.code != '23505') rethrow; // already requested
        }
        await signOut();
      });
}
