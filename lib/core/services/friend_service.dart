import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_model.dart';
import '../models/user_model.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _friendsRef => _firestore.collection('friends');
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference get _chatsRef => _firestore.collection('chats');

  // Send friend request
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    // Check if already friends or request already sent
    final existing = await _friendsRef
        .where('userId', isEqualTo: fromUserId)
        .where('friendId', isEqualTo: toUserId)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Friend request already sent or already friends');
    }

    final docRef = _friendsRef.doc();
    final friendRequest = FriendModel(
      id: docRef.id,
      userId: fromUserId,
      friendId: toUserId,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await docRef.set(friendRequest.toFirestore());

    // Add to pending requests of recipient
    await _usersRef.doc(toUserId).update({
      'pendingRequests': FieldValue.arrayUnion([fromUserId]),
    });
  }

  // Accept friend request - AUTO CREATE PRIVATE CHAT
  Future<void> acceptFriendRequest(String requestId) async {
    final doc = await _friendsRef.doc(requestId).get();
    if (!doc.exists) throw Exception('Friend request not found');

    final request = FriendModel.fromFirestore(doc);
    
    await _friendsRef.doc(requestId).update({
      'status': 'accepted',
      'acceptedAt': Timestamp.fromDate(DateTime.now()),
    });

    // Add to both users' friends list
    await _usersRef.doc(request.userId).update({
      'friends': FieldValue.arrayUnion([request.friendId]),
    });
    await _usersRef.doc(request.friendId).update({
      'friends': FieldValue.arrayUnion([request.userId]),
    });

    // Remove from pending requests
    await _usersRef.doc(request.friendId).update({
      'pendingRequests': FieldValue.arrayRemove([request.userId]),
    });

    // AUTO CREATE PRIVATE CHAT between friends
    await _createPrivateChat(request.userId, request.friendId);
  }

  // Create private chat between two users
  Future<void> _createPrivateChat(String userId1, String userId2) async {
    // Check if private chat already exists
    final existingChat = await _chatsRef
        .where('type', isEqualTo: 'private')
        .where('memberIds', arrayContains: userId1)
        .get();

    for (var doc in existingChat.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final members = List<String>.from(data['memberIds'] ?? []);
      if (members.contains(userId2) && members.length == 2) {
        return; // Chat already exists
      }
    }

    // Get user names for chat name
    final user1Doc = await _usersRef.doc(userId1).get();
    final user2Doc = await _usersRef.doc(userId2).get();
    
    final user1Name = (user1Doc.data() as Map<String, dynamic>?)?['name'] ?? 'User';
    final user2Name = (user2Doc.data() as Map<String, dynamic>?)?['name'] ?? 'User';

    // Create new private chat
    final chatRef = _chatsRef.doc();
    await chatRef.set({
      'name': '$user1Name & $user2Name',
      'memberIds': [userId1, userId2],
      'type': 'private',
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'lastMessage': 'You are now friends! Start chatting.',
      'lastMessageTime': Timestamp.fromDate(DateTime.now()),
      'lastMessageSender': 'system',
    });

    // Add welcome message
    final messageRef = _firestore.collection('messages').doc();
    await messageRef.set({
      'chatId': chatRef.id,
      'senderId': 'system',
      'senderName': 'Genz Go',
      'content': 'You are now friends! Start chatting.',
      'type': 'notification',
      'timestamp': Timestamp.fromDate(DateTime.now()),
      'isRead': false,
    });
  }

  // Reject friend request
  Future<void> rejectFriendRequest(String requestId) async {
    final doc = await _friendsRef.doc(requestId).get();
    if (!doc.exists) throw Exception('Friend request not found');

    final request = FriendModel.fromFirestore(doc);
    
    await _friendsRef.doc(requestId).delete();

    // Remove from pending requests
    await _usersRef.doc(request.friendId).update({
      'pendingRequests': FieldValue.arrayRemove([request.userId]),
    });
  }

  // Remove friend
  Future<void> removeFriend(String userId, String friendId) async {
    // Find and delete the friendship document
    final query = await _friendsRef
        .where('userId', isEqualTo: userId)
        .where('friendId', isEqualTo: friendId)
        .get();
    
    final reverseQuery = await _friendsRef
        .where('userId', isEqualTo: friendId)
        .where('friendId', isEqualTo: userId)
        .get();

    for (var doc in query.docs) {
      await _friendsRef.doc(doc.id).delete();
    }
    for (var doc in reverseQuery.docs) {
      await _friendsRef.doc(doc.id).delete();
    }

    // Remove from both users' friends list
    await _usersRef.doc(userId).update({
      'friends': FieldValue.arrayRemove([friendId]),
    });
    await _usersRef.doc(friendId).update({
      'friends': FieldValue.arrayRemove([userId]),
    });
  }

  // Get friends list
  Stream<List<UserModel>> getFriends(String userId) {
    return _usersRef.doc(userId).snapshots().asyncMap((doc) async {
      if (!doc.exists) return [];
      
      final data = doc.data() as Map<String, dynamic>;
      final friendIds = List<String>.from(data['friends'] ?? []);
      
      if (friendIds.isEmpty) return [];
      
      final friendsDocs = await _usersRef
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();
      
      return friendsDocs.docs.map((d) => UserModel.fromFirestore(d)).toList();
    });
  }

  // Get pending friend requests
  Stream<List<Map<String, dynamic>>> getPendingRequests(String userId) {
    return _friendsRef
        .where('friendId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
      final requests = <Map<String, dynamic>>[];
      
      for (var doc in snapshot.docs) {
        final request = FriendModel.fromFirestore(doc);
        final userDoc = await _usersRef.doc(request.userId).get();
        if (userDoc.exists) {
          requests.add({
            'request': request,
            'user': UserModel.fromFirestore(userDoc),
          });
        }
      }
      
      return requests;
    });
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query, String currentUserId) async {
    if (query.isEmpty) return [];
    
    final snapshot = await _usersRef
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\\uf8ff')
        .limit(20)
        .get();
    
    return snapshot.docs
        .where((doc) => doc.id != currentUserId)
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }

  // Check if users are friends
  Future<bool> areFriends(String userId1, String userId2) async {
    final doc = await _usersRef.doc(userId1).get();
    if (!doc.exists) return false;
    
    final data = doc.data() as Map<String, dynamic>;
    final friends = List<String>.from(data['friends'] ?? []);
    return friends.contains(userId2);
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }
}