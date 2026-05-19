import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        _user = await _authService.getCurrentUser();
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  /// 🔥 Clear state (called on logout before signOut)
  void clear() {
    _user = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signUp(String name, String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _authService.signUp(name, email, password);
      _setLoading(false);
      return _user != null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _authService.signIn(email, password);
      _setLoading(false);
      return _user != null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> updateProfile({String? name, String? photoURL}) async {
    if (_user == null) return;
    try {
      await _authService.updateUserProfile(_user!.uid, name: name, photoURL: photoURL);
      _user = _user!.copyWith(name: name, photoURL: photoURL);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}