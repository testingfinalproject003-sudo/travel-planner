import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MessageModel>> getMessages(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> sendMessage(String tripId, MessageModel message) async {
    try {
      await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('messages')
          .add(message.toMap());
    } catch (e) {
      throw Exception('Message transmit execution processing failure: $e');
    }
  }
}