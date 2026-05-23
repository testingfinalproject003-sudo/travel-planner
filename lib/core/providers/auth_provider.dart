import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SharedPreferences _prefs;
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  AuthProvider({required SharedPreferences prefs}) : _prefs = prefs {
    _checkLoginStatus();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  void _checkLoginStatus() {
    final currentUser = _authService.currentUser;
    _isLoggedIn = currentUser != null;
    if (_isLoggedIn) {
      _loadUserData();
    }
    notifyListeners();
  }

  Future<bool> checkLoginStatus() async {
    // Try cached first for instant UI, then verify with Firebase
    final cachedUid = _prefs.getString('user_uid');
    if (cachedUid != null) {
      _isLoggedIn = true;
      notifyListeners();
    }
    
    final currentUser = _authService.currentUser;
    _isLoggedIn = currentUser != null;
    if (_isLoggedIn) {
      await _prefs.setString('user_uid', currentUser!.uid);
      await _loadUserData();
    } else {
      await _prefs.remove('user_uid');
    }
    notifyListeners();
    return _isLoggedIn;
  }
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );
      _isLoggedIn = true;
      if (_user != null) {
        await _prefs.setString('user_uid', _user!.uid);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(
        email: email,
        password: password,
      );
      _isLoggedIn = true;
      if (_user != null) {
        await _prefs.setString('user_uid', _user!.uid);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();
    await _prefs.remove('user_uid');
    _user = null;
    _isLoggedIn = false;
    _isLoading = false;
    notifyListeners();
  }
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    if (_user == null) return;
    
    await _authService.updateUserProfile(
      uid: _user!.uid,
      name: name,
      photoUrl: photoUrl,
    );
    
    _user = _user!.copyWith(
      name: name,
      photoUrl: photoUrl,
    );
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
   Future<void> _loadUserData() async {
    _user = await _authService.getCurrentUserData();
    notifyListeners();
  }

}
