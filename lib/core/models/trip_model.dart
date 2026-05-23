import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_model.dart';
class TripModel {
  final String id;
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;
  final String createdBy;
  final List<String> memberIds;
  final List<ActivityModel> activities;
  final String? chatId;
  final bool isCompleted;
  final bool isFromHistory;
  final DateTime createdAt;
  final String? imageUrl;
  final double? budget;

  TripModel({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.notes,
    required this.createdBy,
    this.memberIds = const [],
    this.activities = const [],
    this.chatId,
    this.isCompleted = false,
    this.isFromHistory = false,
    required this.createdAt,
    this.imageUrl,
    this.budget,
  });

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TripModel(
      id: doc.id,
      name: data['name'] ?? '',
      destination: data['destination'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
      createdBy: data['createdBy'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      activities: (data['activities'] as List<dynamic>?)
          ?.map((e) => ActivityModel.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      chatId: data['chatId'],
      isCompleted: data['isCompleted'] ?? false,
      isFromHistory: data['isFromHistory'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'],
      budget: data['budget']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'destination': destination,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'notes': notes,
      'createdBy': createdBy,
      'memberIds': memberIds,
      'activities': activities.map((e) => e.toMap()).toList(),
      'chatId': chatId,
      'isCompleted': isCompleted,
      'isFromHistory': isFromHistory,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'budget': budget,
    };
  }

  TripModel copyWith({
    String? id,
    String? name,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? createdBy,
    List<String>? memberIds,
    List<ActivityModel>? activities,
    String? chatId,
    bool? isCompleted,
    bool? isFromHistory,
    DateTime? createdAt,
    String? imageUrl,
    double? budget,
  }) {
    return TripModel(
      id: id ?? this.id,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      memberIds: memberIds ?? this.memberIds,
      activities: activities ?? this.activities,
      chatId: chatId ?? this.chatId,
      isCompleted: isCompleted ?? this.isCompleted,
      isFromHistory: isFromHistory ?? this.isFromHistory,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      budget: budget ?? this.budget,
    );
  }
}