import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _chatsRef => _firestore.collection('chats');
  CollectionReference get _messagesRef => _firestore.collection('messages');

  // Get user chats with limit to prevent too many tiles
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _chatsRef
        .where('memberIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .limit(50) // LIMIT to prevent too many tiles
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        }).toList());
  }

  // Get chat messages with pagination support
  Stream<List<MessageModel>> getChatMessages(String chatId, {int limit = 50}) {
    return _messagesRef
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .limit(limit) // LIMIT messages to prevent too many tiles
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
  }

  // Load more messages (pagination)
  Future<List<MessageModel>> loadMoreMessages(String chatId, DateTime before, {int limit = 50}) async {
    final snapshot = await _messagesRef
        .where('chatId', isEqualTo: chatId)
        .where('timestamp', isLessThan: Timestamp.fromDate(before))
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList();
  }

  Future<void> sendMessage(MessageModel message) async {
    final docRef = _messagesRef.doc();
    final messageWithId = message.copyWith(id: docRef.id);
    await docRef.set(messageWithId.toFirestore());

    // Update chat last message
    await _chatsRef.doc(message.chatId).update({
      'lastMessage': message.content,
      'lastMessageTime': Timestamp.fromDate(message.timestamp),
      'lastMessageSender': message.senderName,
    });
  }

  Future<String> createChat({
    required String name,
    required List<String> memberIds,
    String? tripId,
    String type = 'group',
    String? imageUrl,
  }) async {
    final docRef = _chatsRef.doc();
    await docRef.set({
      'name': name,
      'memberIds': memberIds,
      'tripId': tripId,
      'type': type,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'imageUrl': imageUrl,
      'lastMessage': null,
      'lastMessageTime': null,
      'lastMessageSender': null,
    });
    return docRef.id;
  }

  Future<void> markMessageAsRead(String messageId) async {
    await _messagesRef.doc(messageId).update({'isRead': true});
  }

  Future<void> addMemberToChat(String chatId, String userId) async {
    await _chatsRef.doc(chatId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> sendTripProposal({
    required String chatId,
    required String senderId,
    required String senderName,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> memberIds,
    String? notes,
  }) async {
    final proposalId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final message = MessageModel(
      id: '',
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      content: 'Trip Proposal: $destination',
      type: 'trip_proposal',
      timestamp: DateTime.now(),
      metadata: {
        'proposalId': proposalId,
        'destination': destination,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'notes': notes,
        'votes': <String, bool>{},
        'totalMembers': memberIds.length,
        'status': 'pending',
      },
    );

    await sendMessage(message);
  }

  Future<void> voteOnProposal(String messageId, String userId, bool vote) async {
    await _messagesRef.doc(messageId).update({
      'metadata.votes.$userId': vote,
    });
  }

  Future<Map<String, dynamic>?> getChatData(String chatId) async {
    final doc = await _chatsRef.doc(chatId).get();
    if (doc.exists) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }
    return null;
  }

  Future<void> updateChatName(String chatId, String name) async {
    await _chatsRef.doc(chatId).update({'name': name});
  }
}