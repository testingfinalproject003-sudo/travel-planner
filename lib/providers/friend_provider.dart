import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend_request_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';

class FriendProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();

  List<UserModel> _friends = [];
  List<FriendRequestModel> _incomingRequests = [];
  List<FriendRequestModel> _sentRequests = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  List<UserModel> get friends => _friends;
  List<FriendRequestModel> get incomingRequests => _incomingRequests;
  List<FriendRequestModel> get sentRequests => _sentRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Can create trip (min 1 friend needed)
  bool get canCreateTrip => _friends.length > 1;

  int get friendCount => _friends.length;
  int get pendingRequestCount => _incomingRequests.length;

  FriendProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _currentUserId = user.uid;
        _listenToFriends();
        _listenToRequests();
      } else {
        _currentUserId = null;
        _friends = [];
        _incomingRequests = [];
        _sentRequests = [];
        notifyListeners();
      }
    });
  }

  void init(String userId) {
    _currentUserId = userId;
    _listenToFriends();
    _listenToRequests();
  }

  void clear() {
    _friends = [];
    _incomingRequests = [];
    _sentRequests = [];
    _currentUserId = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void _listenToFriends() {
    final userId = _currentUserId ?? _auth.currentUser?.uid;
    if (userId == null) return;

    _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .listen((snapshot) async {
      final friendIds = snapshot.docs.map((d) => d.id).toList();
      
      if (friendIds.isEmpty) {
        _friends = [];
        notifyListeners();
        return;
      }

      // Fetch friend user data
      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();

      _friends = usersSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    });
  }

  void _listenToRequests() {
    final userId = _currentUserId ?? _auth.currentUser?.uid;
    if (userId == null) return;

    _firestore
        .collection('friend_requests')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      _incomingRequests = snapshot.docs.map((doc) {
        return FriendRequestModel.fromMap(doc.data(), doc.id);
      }).toList();
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
    });

    // Sent requests
    _firestore
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      _sentRequests = snapshot.docs
          .map((doc) => FriendRequestModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    });
  }

  Future<UserModel?> searchUserByEmail(String email) async {
    _setLoading(true);
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _setLoading(false);
        return null;
      }

      final user = UserModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      _setLoading(false);
      return user;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  Future<void> sendFriendRequest(String toUserId) async {
    final fromUserId = _auth.currentUser?.uid;
    if (fromUserId == null) return;

    _setLoading(true);
    try {
      // Check if already friends
      final existingFriend = await _firestore
          .collection('users')
          .doc(fromUserId)
          .collection('friends')
          .doc(toUserId)
          .get();

      if (existingFriend.exists) {
        throw Exception('Already friends');
      }

      // Check if request already sent
      final existingRequest = await _firestore
          .collection('friend_requests')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw Exception('Friend request already sent');
      }

      final fromUserDoc = await _firestore.collection('users').doc(fromUserId).get();
      final fromUser = UserModel.fromMap(fromUserDoc.data()!, fromUserDoc.id);

      await _firestore.collection('friend_requests').add({
        'fromUserId': fromUserId,
        'fromUserName': fromUser.name,
        'fromUserEmail': fromUser.email,
        'toUserId': toUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  /// Accept friend request + auto-create private chat
  Future<void> acceptFriendRequest(FriendRequestModel request) async {
    _setLoading(true);
    try {
      final currentUserId = _auth.currentUser!.uid;

      // Get current user data
      final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
      final currentUser = UserModel.fromMap(currentUserDoc.data()!, currentUserDoc.id);

      // Get sender user data
      final senderDoc = await _firestore.collection('users').doc(request.fromUserId).get();
      final sender = UserModel.fromMap(senderDoc.data()!, senderDoc.id);

      final batch = _firestore.batch();

      // Add sender to current user's friends subcollection
      batch.set(
        _firestore.collection('users').doc(currentUserId).collection('friends').doc(request.fromUserId),
        {
          'name': sender.name,
          'email': sender.email,
          'photoURL': sender.photoURL ?? '',
          'since': FieldValue.serverTimestamp(),
        },
      );

      // Add current user to sender's friends subcollection
      batch.set(
        _firestore.collection('users').doc(request.fromUserId).collection('friends').doc(currentUserId),
        {
          'name': currentUser.name,
          'email': currentUser.email,
          'photoURL': currentUser.photoURL ?? '',
          'since': FieldValue.serverTimestamp(),
        },
      );

      // Update request status
      batch.update(
        _firestore.collection('friend_requests').doc(request.id),
        {'status': 'accepted'},
      );

      await batch.commit();

      // Create private chat between both users
      await _chatService.createPrivateChat(
        userId1: currentUserId,
        userId2: request.fromUserId,
        userName1: currentUser.name,
        userName2: sender.name,
      );

      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> declineFriendRequest(String requestId) async {
    _setLoading(true);
    try {
      await _firestore
          .collection('friend_requests')
          .doc(requestId)
          .update({'status': 'declined'});
      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}