import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestModel {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String fromUserEmail;
  final String toUserId;
  final String? toUserEmail;
  final String status;
  final DateTime createdAt;

  FriendRequestModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserEmail,
    required this.toUserId,
    this.toUserEmail,
    this.status = 'pending',
    required this.createdAt,
  });

  factory FriendRequestModel.fromMap(Map<String, dynamic> map, String docId) {
    return FriendRequestModel(
      id: docId,
      fromUserId: map['fromUserId'] ?? '',
      fromUserName: map['fromUserName'] ?? '',
      fromUserEmail: map['fromUserEmail'] ?? '',
      toUserId: map['toUserId'] ?? '',
      toUserEmail: map['toUserEmail'],
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserEmail': fromUserEmail,
      'toUserId': toUserId,
      'toUserEmail': toUserEmail,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}