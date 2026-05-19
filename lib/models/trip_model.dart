import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String title;
  final String destination;
  final double? destinationLat;
  final double? destinationLng;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;
  final List<String> memberIds;
  final String createdBy;
  final String status;
  final DateTime createdAt;

  TripModel({
    required this.id,
    required this.title,
    required this.destination,
    this.destinationLat,
    this.destinationLng,
    required this.startDate,
    required this.endDate,
    this.notes,
    this.memberIds = const [],
    required this.createdBy,
    this.status = 'upcoming',
    required this.createdAt,
  });

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      destination: map['destination'] ?? '',
      destinationLat: map['destinationLat']?.toDouble(),
      destinationLng: map['destinationLng']?.toDouble(),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'],
      memberIds: List<String>.from(map['memberIds'] ?? []),
      createdBy: map['createdBy'] ?? '',
      status: map['status'] ?? 'upcoming',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'notes': notes,
      'memberIds': memberIds,
      'createdBy': createdBy,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  int get durationDays {
    return endDate.difference(startDate).inDays;
  }

  List<DateTime> get tripDays {
    final days = <DateTime>[];
    for (int i = 0; i < durationDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming {
    return DateTime.now().isBefore(startDate);
  }

  bool get isPast {
    return DateTime.now().isAfter(endDate);
  }

  TripModel copyWith({
    String? id,
    String? title,
    String? destination,
    double? destinationLat,
    double? destinationLng,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    List<String>? memberIds,
    String? createdBy,
    String? status,
    DateTime? createdAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      memberIds: memberIds ?? this.memberIds,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}