import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

String mapSupabaseError(String code, [String? fallbackMessage]) {
  switch (code) {
    case 'invalid_credentials':
      return 'Email or password is incorrect.';
    case 'email_not_confirmed':
      return 'Email is not confirmed. Disable Confirm email in Supabase for this demo or confirm the account first.';
    case 'user_already_exists':
      return 'This email is already registered.';
    case 'weak_password':
      return 'Password is too weak.';
    case 'email_address_invalid':
    case 'validation_failed':
      return 'Please enter a valid email address.';
    default:
      return fallbackMessage?.trim().isNotEmpty == true
          ? fallbackMessage!.trim()
          : 'Something went wrong. Please try again.';
  }
}

class AuthService {
  SupabaseClient? get _client => SupabaseService.client;

  User? get currentUser => _client?.auth.currentUser;

  Stream<User?> get authStateChanges async* {
    final client = _client;
    if (client == null) {
      yield null;
      return;
    }

    yield client.auth.currentUser;
    yield* client.auth.onAuthStateChange.map((data) => data.session?.user);
  }

  Future<AuthResult> signIn(String email, String password) async {
    final client = _client;
    if (client == null) {
      return AuthResult.failure(
        SupabaseService.missingConfigMessage ?? 'Supabase is not configured.',
      );
    }

    try {
      await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return AuthResult.success();
    } on AuthException catch (e) {
      debugPrint('Supabase signIn error: ${e.code} | ${e.message}');
      return AuthResult.failure(mapSupabaseError(e.code ?? '', e.message));
    } catch (e) {
      debugPrint('Unexpected signIn error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  Future<AuthResult> signUp(String email, String password) async {
    final client = _client;
    if (client == null) {
      return AuthResult.failure(
        SupabaseService.missingConfigMessage ?? 'Supabase is not configured.',
      );
    }

    try {
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'display_name': email.trim().split('@').first,
        },
      );

      if (response.session == null) {
        return AuthResult.failure(
          'Account created but no session was returned. Disable Confirm email in Supabase for this demo or confirm the account before signing in.',
        );
      }

      return AuthResult.success();
    } on AuthException catch (e) {
      debugPrint('Supabase signUp error: ${e.code} | ${e.message}');
      return AuthResult.failure(mapSupabaseError(e.code ?? '', e.message));
    } catch (e) {
      debugPrint('Unexpected signUp error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  Future<void> signOut() async {
    final client = _client;
    if (client == null) return;
    await client.auth.signOut();
  }
}

/// Simple result wrapper for auth operations
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;

  AuthResult._({required this.isSuccess, this.errorMessage});

  factory AuthResult.success() => AuthResult._(isSuccess: true);
  factory AuthResult.failure(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);
}
