import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String senderInitials;
  final DateTime timestamp;
  final bool isSystem;
  final String type;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.senderInitials,
    required this.timestamp,
    this.isSystem = false,
    this.type = 'text',
  });

  /// ✅ 2 arguments: data + docId
  factory MessageModel.fromMap(Map<String, dynamic> data, String docId) {
    return MessageModel(
      id: docId,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderInitials: data['senderInitials'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isSystem: data['isSystem'] ?? false,
      type: data['type'] ?? 'text',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'senderInitials': senderInitials,
      'timestamp': Timestamp.fromDate(timestamp),
      'isSystem': isSystem,
      'type': type,
    };
  }

  bool get isMe => false;
}