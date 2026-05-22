// lib/models/friend_request_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestModel {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String fromUserEmail;
  final String toUserId;
  final String toUserEmail;
  final String status;
  final DateTime? createdAt;

  FriendRequestModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserEmail,
    required this.toUserId,
    required this.toUserEmail,
    this.status = 'pending',
    this.createdAt,
  });

  /// ✅ 2 arguments: data + docId
  factory FriendRequestModel.fromMap(Map<String, dynamic> data, String docId) {
    return FriendRequestModel(
      id: docId,
      fromUserId: data['fromUserId'] ?? '',
      fromUserName: data['fromUserName'] ?? 'Unknown',
      fromUserEmail: data['fromUserEmail'] ?? '',
      toUserId: data['toUserId'] ?? '',
      toUserEmail: data['toUserEmail'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
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
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}