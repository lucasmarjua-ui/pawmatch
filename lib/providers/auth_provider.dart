import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn({required String email, required String password}) {
    return _run(() => _authService.signIn(email: email, password: password));
  }

  Future<bool> signUp({required String email, required String password}) {
    return _run(() => _authService.signUp(email: email, password: password));
  }

  Future<bool> _run(Future<AppUser> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await action();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  /// Se llama al terminar CreateProfileScreen — a partir de aquí AuthGate
  /// deja pasar a MainShell en vez de volver a pedir el perfil.
  void markProfileComplete() {
    if (_user == null) return;
    _user = _user!.copyWith(hasCompletedProfile: true);
    notifyListeners();
  }
}
