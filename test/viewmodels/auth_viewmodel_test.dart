import 'package:flutter_test/flutter_test.dart';

import 'package:local_cafe_hunter/services/auth_service.dart';
import 'package:local_cafe_hunter/viewmodels/auth_viewmodel.dart';

class FakeAuthService extends AuthService {
  FakeAuthService({
    this.signInResult,
    this.signUpResult,
  });

  AuthResult? signInResult;
  AuthResult? signUpResult;
  int signOutCalls = 0;

  @override
  Future<AuthResult> signIn(String email, String password) async {
    return signInResult ?? AuthResult.success();
  }

  @override
  Future<AuthResult> signUp(String email, String password) async {
    return signUpResult ?? AuthResult.success();
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
  }
}

void main() {
  group('AuthViewModel', () {
    test('transitions to authenticated on successful sign in', () async {
      final service = FakeAuthService();
      final viewModel = AuthViewModel(authService: service);

      final result = await viewModel.signIn('demo@local.dev', 'password');

      expect(result, isTrue);
      expect(viewModel.isAuthenticated, isTrue);
      expect(viewModel.errorMessage, isNull);
    });

    test('stores error state on failed sign up and clears after reset', () async {
      final service = FakeAuthService(
        signUpResult: AuthResult.failure('No session returned'),
      );
      final viewModel = AuthViewModel(authService: service);

      final result = await viewModel.signUp('demo@local.dev', 'password');

      expect(result, isFalse);
      expect(viewModel.state, AuthState.error);
      expect(viewModel.errorMessage, 'No session returned');

      viewModel.clearError();
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.state, AuthState.unauthenticated);
    });

    test('signOut uses the injected auth service', () async {
      final service = FakeAuthService();
      final viewModel = AuthViewModel(authService: service);

      await viewModel.signOut();

      expect(service.signOutCalls, 1);
      expect(viewModel.state, AuthState.unauthenticated);
    });
  });
}
