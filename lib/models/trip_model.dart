import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String title;
  final String destination;
  final String notes;
  final String createdBy;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final List<String> memberIds;

  TripModel({
    required this.id,
    required this.title,
    required this.destination,
    required this.notes,
    required this.createdBy,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.memberIds,
  });

  bool get isActive => status == 'active';
  bool get isPast => status == 'past';
  int get durationDays => endDate.difference(startDate).inDays + 1;

  factory TripModel.fromMap(Map<String, dynamic> map, String id) {
    return TripModel(
      id: id,
      title: map['title'] ?? '',
      destination: map['destination'] ?? '',
      notes: map['notes'] ?? '',
      createdBy: map['createdBy'] ?? '',
      status: map['status'] ?? 'upcoming',
      startDate: map['startDate'] is Timestamp
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: map['endDate'] is Timestamp
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      memberIds: List<String>.from(map['memberIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'destination': destination,
      'notes': notes,
      'createdBy': createdBy,
      'status': status,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'memberIds': memberIds,
    };
  }

  TripModel copyWith({
    String? id,
    String? title,
    String? destination,
    String? notes,
    String? createdBy,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    List<String>? memberIds,
  }) {
    return TripModel(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      memberIds: memberIds ?? this.memberIds,
    );
  }
}