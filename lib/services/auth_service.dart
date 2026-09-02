import '../models/app_user.dart';

/// Excepción con mensaje legible pensado para mostrarse tal cual en la UI.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Contrato de autenticación. Hoy lo implementa MockAuthService en memoria;
/// cuando conectemos Firebase Auth de verdad, una FirebaseAuthService
/// implementa este mismo contrato y AuthProvider no cambia.
abstract class AuthService {
  AppUser? get currentUser;
  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> signUp({required String email, required String password});
  Future<void> signOut();
}

class MockAuthService implements AuthService {
  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      throw const AuthException('Enter your email and password.');
    }
    _currentUser = AppUser(id: 'mock-user', email: trimmedEmail, location: 'Manchester');
    return _currentUser!;
  }

  @override
  Future<AppUser> signUp({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      throw const AuthException('Enter your email.');
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }
    _currentUser = AppUser(id: 'mock-user', email: trimmedEmail, location: 'Manchester', hasCompletedProfile: false);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }
}
