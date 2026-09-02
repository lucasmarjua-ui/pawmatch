import 'package:flutter_test/flutter_test.dart';
import 'package:pawmatch/providers/auth_provider.dart';
import 'package:pawmatch/services/auth_service.dart';

void main() {
  group('AuthProvider', () {
    test('signIn with valid credentials signs the user in', () async {
      final provider = AuthProvider(MockAuthService());

      final result = await provider.signIn(email: 'lucas@pawmatch.app', password: 'password123');

      expect(result, isTrue);
      expect(provider.isSignedIn, isTrue);
      expect(provider.user?.email, 'lucas@pawmatch.app');
      expect(provider.errorMessage, isNull);
    });

    test('signIn with empty credentials surfaces an error and stays signed out', () async {
      final provider = AuthProvider(MockAuthService());

      final result = await provider.signIn(email: '', password: '');

      expect(result, isFalse);
      expect(provider.isSignedIn, isFalse);
      expect(provider.errorMessage, isNotNull);
    });

    test('signOut clears the current user', () async {
      final provider = AuthProvider(MockAuthService());
      await provider.signIn(email: 'lucas@pawmatch.app', password: 'password123');

      await provider.signOut();

      expect(provider.isSignedIn, isFalse);
      expect(provider.user, isNull);
    });

    test('signIn starts with a completed profile', () async {
      final provider = AuthProvider(MockAuthService());

      await provider.signIn(email: 'lucas@pawmatch.app', password: 'password123');

      expect(provider.user?.hasCompletedProfile, isTrue);
    });

    test('signUp starts with an incomplete profile', () async {
      final provider = AuthProvider(MockAuthService());

      await provider.signUp(email: 'lucas@pawmatch.app', password: 'password123');

      expect(provider.user?.hasCompletedProfile, isFalse);
    });

    test('markProfileComplete flips hasCompletedProfile to true', () async {
      final provider = AuthProvider(MockAuthService());
      await provider.signUp(email: 'lucas@pawmatch.app', password: 'password123');
      expect(provider.user?.hasCompletedProfile, isFalse);

      provider.markProfileComplete();

      expect(provider.user?.hasCompletedProfile, isTrue);
    });

    test('markProfileComplete is a no-op when signed out', () {
      final provider = AuthProvider(MockAuthService());

      expect(() => provider.markProfileComplete(), returnsNormally);
      expect(provider.user, isNull);
    });
  });
}
