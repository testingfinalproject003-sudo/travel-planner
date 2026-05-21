import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_request_model.dart';
import '../models/user_model.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> searchUserByEmail(String email, String currentUserId) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    final user = UserModel.fromMap(doc.data(), doc.id);
    if (user.uid == currentUserId) {
      throw 'You cannot add yourself as a friend';
    }
    return user;
  }

  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    final areAlreadyFriends = await areFriends(fromUserId, toUserId);
    if (areAlreadyFriends) {
      throw 'You are already friends';
    }

    final existing = await _firestore
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: fromUserId)
        .where('toUserId', isEqualTo: toUserId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw 'Friend request already sent';
    }

    final fromUser = await _firestore.collection('users').doc(fromUserId).get();
    final toUser = await _firestore.collection('users').doc(toUserId).get();

    final request = FriendRequestModel(
      id: _firestore.collection('friend_requests').doc().id,
      fromUserId: fromUserId,
      fromUserName: fromUser.data()?['name'] ?? '',
      fromUserEmail: fromUser.data()?['email'] ?? '',
      toUserId: toUserId,
      toUserEmail: toUser.data()?['email'] ?? '',
      createdAt: DateTime.now(),
    );

    await _firestore.collection('friend_requests').doc(request.id).set(request.toMap());
  }

  /// ✅ FIXED: Use subcollection (matching FriendProvider pattern)
  Future<void> acceptFriendRequest(String requestId, String fromId, String toId) async {
    final batch = _firestore.batch();

    // Get both users' data
    final fromUserDoc = await _firestore.collection('users').doc(fromId).get();
    final toUserDoc = await _firestore.collection('users').doc(toId).get();

    final fromUser = fromUserDoc.data() ?? {};
    final toUser = toUserDoc.data() ?? {};

    // Add to friends subcollection (matching FriendProvider._listenToFriends)
    batch.set(
      _firestore.collection('users').doc(toId).collection('friends').doc(fromId),
      {
        'name': fromUser['name'] ?? '',
        'email': fromUser['email'] ?? '',
        'photoURL': fromUser['photoURL'] ?? '',
        'since': FieldValue.serverTimestamp(),
      },
    );

    batch.set(
      _firestore.collection('users').doc(fromId).collection('friends').doc(toId),
      {
        'name': toUser['name'] ?? '',
        'email': toUser['email'] ?? '',
        'photoURL': toUser['photoURL'] ?? '',
        'since': FieldValue.serverTimestamp(),
      },
    );

    // Update request status
    batch.update(
      _firestore.collection('friend_requests').doc(requestId),
      {'status': 'accepted'},
    );

    await batch.commit();
  }

  Future<void> declineFriendRequest(String requestId) async {
    await _firestore.collection('friend_requests').doc(requestId).update({
      'status': 'declined',
    });
  }

  Stream<List<FriendRequestModel>> getIncomingRequests(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) {
          return FriendRequestModel.fromMap(d.data(), d.id);
        }).toList());
  }

  Stream<List<FriendRequestModel>> getSentRequests(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) {
          return FriendRequestModel.fromMap(d.data(), d.id);
        }).toList());
  }

  /// ✅ FIXED: Use subcollection instead of array
  Stream<List<UserModel>> getFriends(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .asyncMap((snapshot) async {
      final friendIds = snapshot.docs.map((d) => d.id).toList();
      if (friendIds.isEmpty) return <UserModel>[];

      // Fetch full user data for each friend
      final friends = <UserModel>[];
      for (final friendId in friendIds) {
        final doc = await _firestore.collection('users').doc(friendId).get();
        if (doc.exists) {
          friends.add(UserModel.fromMap(doc.data()!, doc.id));
        }
      }
      return friends;
    });
  }

  /// ✅ FIXED: Check subcollection instead of array
  Future<bool> areFriends(String uid1, String uid2) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid1)
        .collection('friends')
        .doc(uid2)
        .get();
    return doc.exists;
  }
}