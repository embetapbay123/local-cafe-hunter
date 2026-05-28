import 'package:flutter_test/flutter_test.dart';

import 'package:local_cafe_hunter/services/auth_service.dart';

void main() {
  group('mapSupabaseError', () {
    test('maps known Supabase errors to user-facing messages', () {
      expect(
        mapSupabaseError('invalid_credentials'),
        'Email or password is incorrect.',
      );
      expect(
        mapSupabaseError('email_not_confirmed'),
        'Email is not confirmed. Disable Confirm email in Supabase for this demo or confirm the account first.',
      );
      expect(
        mapSupabaseError('user_already_exists'),
        'This email is already registered.',
      );
      expect(
        mapSupabaseError('weak_password'),
        'Password is too weak.',
      );
    });

    test('falls back to the provided message or a generic error', () {
      expect(
        mapSupabaseError('unknown', 'Backend says no'),
        'Backend says no',
      );
      expect(
        mapSupabaseError('unknown', '   '),
        'Something went wrong. Please try again.',
      );
    });
  });
}
