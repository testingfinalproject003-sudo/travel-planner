import 'package:flutter/material.dart';
import '../models/user_model.dart';
// import '../models/friend_model.dart';
import '../services/friend_service.dart';

class FriendProvider extends ChangeNotifier {
  final FriendService _friendService = FriendService();
  
  List<UserModel> _friends = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get friends => _friends;
  List<Map<String, dynamic>> get pendingRequests => _pendingRequests;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadFriends(String userId) {
    _friendService.getFriends(userId).listen((friends) {
      _friends = friends;
      notifyListeners();
    });
  }

  void loadPendingRequests(String userId) {
    _friendService.getPendingRequests(userId).listen((requests) {
      _pendingRequests = requests;
      notifyListeners();
    });
  }

  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _friendService.sendFriendRequest(fromUserId, toUserId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _friendService.acceptFriendRequest(requestId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _friendService.rejectFriendRequest(requestId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFriend(String userId, String friendId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _friendService.removeFriend(userId, friendId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchUsers(String query, String currentUserId) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _friendService.searchUsers(query, currentUserId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> areFriends(String userId1, String userId2) async {
    return await _friendService.areFriends(userId1, userId2);
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
