import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send message to any chat (trip or private)
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required String senderName,
    required String senderInitials,
    String collectionPath = 'chats',
  }) async {
    final docRef = _firestore
        .collection(collectionPath)
        .doc(chatId)
        .collection('messages')
        .doc();

    final message = MessageModel(
      id: docRef.id,
      text: text,
      senderId: senderId,
      senderName: senderName,
      senderInitials: senderInitials,
      timestamp: DateTime.now(),
    );

    await docRef.set(message.toMap());

    await _firestore.collection(collectionPath).doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  /// Send system message
  Future<void> sendSystemMessage({
    required String chatId,
    required String text,
    String collectionPath = 'chats',
  }) async {
    final docRef = _firestore
        .collection(collectionPath)
        .doc(chatId)
        .collection('messages')
        .doc();

    final message = MessageModel(
      id: docRef.id,
      text: text,
      senderId: 'system',
      senderName: 'System',
      senderInitials: 'SYS',
      timestamp: DateTime.now(),
      isSystem: true,
      type: 'system',
    );

    await docRef.set(message.toMap());

    await _firestore.collection(collectionPath).doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  /// Get messages from any chat
  Stream<List<MessageModel>> getMessages(String chatId, {String collectionPath = 'chats'}) {
    return _firestore
        .collection(collectionPath)
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .limit(100)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => MessageModel.fromMap(d.data(), d.id)).toList());
  }

  /// Create private chat (called on friend accept)
  Future<void> createPrivateChat({
    required String userId1,
    required String userId2,
    required String userName1,
    required String userName2,
  }) async {
    final chatId = _generateChatId(userId1, userId2);

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (chatDoc.exists) return;

    await _firestore.collection('chats').doc(chatId).set({
      'type': 'private',
      'members': [userId1, userId2],
      'memberNames': {
        userId1: userName1,
        userId2: userName2,
      },
      'name': userName2,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': null,
      'lastMessageTime': null,
    });

    await sendSystemMessage(
      chatId: chatId,
      text: 'You are now friends! Start chatting',
    );
  }

  /// Create trip group chat
  Future<void> createTripGroupChat({
    required String tripId,
    required String destination,
    required List<String> memberIds,
  }) async {
    final chatDoc = await _firestore.collection('chats').doc(tripId).get();
    if (chatDoc.exists) return;

    await _firestore.collection('chats').doc(tripId).set({
      'type': 'trip',
      'tripId': tripId,
      'members': memberIds,
      'name': 'Trip to $destination',
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': null,
      'lastMessageTime': null,
    });

    await sendSystemMessage(
      chatId: tripId,
      text: 'Trip to $destination created! Start planning',
    );
  }

  /// Get user's chats (both private and trip)
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('members', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) {
          final data = d.data();
          data['id'] = d.id;
          return data;
        }).toList());
  }

  String _generateChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return 'private_${ids[0]}_${ids[1]}';
  }
}