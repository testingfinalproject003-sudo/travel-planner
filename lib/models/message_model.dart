import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String type;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      type: map['type'] ?? 'text',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}