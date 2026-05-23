import 'package:cloud_firestore/cloud_firestore.dart';
class ChatModel {
  final String id;
  final String name;
  final String? tripId;
  final List<String> memberIds;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSender;
  final String type; // 'private', 'group', 'trip'
  final DateTime createdAt;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  ChatModel({
    required this.id,
    required this.name,
    this.tripId,
    required this.memberIds,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSender,
    this.type = 'group',
    required this.createdAt,
    this.imageUrl,
    this.metadata,
  });

  factory ChatModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return ChatModel(
      id: docId,
      name: data['name'] ?? '',
      tripId: data['tripId'],
      memberIds: List<String>.from(data['memberIds'] ?? []),
      lastMessage: data['lastMessage'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      lastMessageSender: data['lastMessageSender'],
      type: data['type'] ?? 'group',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'tripId': tripId,
      'memberIds': memberIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'lastMessageSender': lastMessageSender,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }
}