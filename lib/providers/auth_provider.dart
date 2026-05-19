import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _authSubscription;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authSubscription = _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        try {
          _user = await _authService.getUserData(firebaseUser.uid);
        } catch (e) {
          _error = e.toString();
        }
      } else {
        _user = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.login(email, password);
      final fbUser = _authService.currentFirebaseUser;
      if (fbUser != null) {
        _user = await _authService.getUserData(fbUser.uid);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.signup(name, email, password);
      final fbUser = _authService.currentFirebaseUser;
      if (fbUser != null) {
        _user = await _authService.getUserData(fbUser.uid);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authService.logout();
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}