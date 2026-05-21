import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;
  final List<String> memberIds;
  final String createdBy;
  final String status; // planning, upcoming, active, completed, cancelled
  final DateTime createdAt;
  final Map<String, bool> memberConfirmations;
  final bool isConfirmed;
  final List<String>? markedLocations; // Added for map locations

  TripModel({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.notes,
    required this.memberIds,
    required this.createdBy,
    this.status = 'planning',
    required this.createdAt,
    this.memberConfirmations = const {},
    this.isConfirmed = false,
    this.markedLocations,
  });

  bool get isActive {
    final now = DateTime.now();
    return startDate.isBefore(now) && endDate.isAfter(now);
  }

  bool get isUpcoming {
    return startDate.isAfter(DateTime.now());
  }

  bool get isPast {
    return endDate.isBefore(DateTime.now());
  }

  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      destination: map['destination'] ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'],
      memberIds: List<String>.from(map['memberIds'] ?? []),
      createdBy: map['createdBy'] ?? '',
      status: map['status'] ?? 'planning',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      memberConfirmations: Map<String, bool>.from(map['memberConfirmations'] ?? {}),
      isConfirmed: map['isConfirmed'] ?? false,
      markedLocations: map['markedLocations'] != null 
          ? List<String>.from(map['markedLocations']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'notes': notes,
      'memberIds': memberIds,
      'createdBy': createdBy,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'memberConfirmations': memberConfirmations,
      'isConfirmed': isConfirmed,
      'markedLocations': markedLocations,
    };
  }

  TripModel copyWith({
    String? id,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    List<String>? memberIds,
    String? createdBy,
    String? status,
    DateTime? createdAt,
    Map<String, bool>? memberConfirmations,
    bool? isConfirmed,
    List<String>? markedLocations,
  }) {
    return TripModel(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      memberIds: memberIds ?? this.memberIds,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      memberConfirmations: memberConfirmations ?? this.memberConfirmations,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      markedLocations: markedLocations ?? this.markedLocations,
    );
  }
}