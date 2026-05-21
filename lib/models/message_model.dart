import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String senderInitials;
  final DateTime timestamp;
  final bool isSystem;
  final String type; // 'text', 'system', 'weather', 'location', 'suggestion', 'plan_confirm', 'trip_proposal', 'vote_update', 'trip_created', 'destination'
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.senderInitials,
    required this.timestamp,
    this.isSystem = false,
    this.type = 'text',
    this.metadata,
  });

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
      metadata: data['metadata'],
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
      'metadata': metadata,
    };
  }

  bool get isMe => false;
  bool get isWeather => type == 'weather';
  bool get isLocation => type == 'location';
  bool get isSuggestion => type == 'suggestion';
  bool get isPlanConfirm => type == 'plan_confirm';
  bool get isTripProposal => type == 'trip_proposal';
  bool get isVoteUpdate => type == 'vote_update';
  bool get isTripCreated => type == 'trip_created';
  bool get isDestination => type == 'destination';
}