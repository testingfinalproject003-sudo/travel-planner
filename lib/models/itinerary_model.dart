class ItineraryModel {
  final List<DayPlan> days;
  final String notes;
  final DateTime createdAt;

  ItineraryModel({
    required this.days,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'days': days.map((d) => d.toMap()).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ItineraryModel.fromMap(Map<String, dynamic> map) {
    return ItineraryModel(
      days: (map['days'] as List<dynamic>?)
          ?.map((d) => DayPlan.fromMap(d as Map<String, dynamic>))
          .toList() ?? [],
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class DayPlan {
  final int dayNumber;
  final DateTime date;
  final List<Activity> activities;
  final String? notes;

  DayPlan({
    required this.dayNumber,
    required this.date,
    this.activities = const [],
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'date': date.toIso8601String(),
      'activities': activities.map((a) => a.toMap()).toList(),
      'notes': notes,
    };
  }

  factory DayPlan.fromMap(Map<String, dynamic> map) {
    return DayPlan(
      dayNumber: map['dayNumber'] ?? 1,
      date: DateTime.parse(map['date']),
      activities: (map['activities'] as List<dynamic>?)
          ?.map((a) => Activity.fromMap(a as Map<String, dynamic>))
          .toList() ?? [],
      notes: map['notes'],
    );
  }
}

class Activity {
  final String id;
  final String title;
  final String type; // 'sightseeing', 'food', 'transport', 'accommodation', 'other'
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final double? lat;
  final double? lng;
  final String? notes;
  final double? cost;
  final bool isBooked;

  Activity({
    required this.id,
    required this.title,
    this.type = 'other',
    required this.startTime,
    this.endTime,
    this.location,
    this.lat,
    this.lng,
    this.notes,
    this.cost,
    this.isBooked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'location': location,
      'lat': lat,
      'lng': lng,
      'notes': notes,
      'cost': cost,
      'isBooked': isBooked,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? 'other',
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      location: map['location'],
      lat: map['lat']?.toDouble(),
      lng: map['lng']?.toDouble(),
      notes: map['notes'],
      cost: map['cost']?.toDouble(),
      isBooked: map['isBooked'] ?? false,
    );
  }
}