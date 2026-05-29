import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/remote/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService) {
    _init();
  }

  final AuthService _authService;

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  String? get uid => FirebaseAuth.instance.currentUser?.uid;


  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Stream<User?>? _sub;

  void _init() {
    // Listen to Firebase auth state
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _isLoggedIn = user != null;
      notifyListeners();
    });
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setError(null);
    _setLoading(true);
    try {
      await _authService.login(email: email, password: password);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ FIXED: After signup, sign out so app does NOT jump to dashboard
  Future<void> signup(String email, String password) async {
    _setError(null);
    _setLoading(true);
    try {
      await _authService.signup(email: email, password: password);

      // ✅ Firebase auto-logs-in after signup — sign out to force login again
      await FirebaseAuth.instance.signOut();

      // Optional: update state immediately (listener will also do it)
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setError(null);
    _setLoading(true);
    try {
      await _authService.logout();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
