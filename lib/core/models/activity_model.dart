class ActivityModel {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final String? time;
  final String? location;
  final double? latitude;
  final double? longitude;
  final double? cost;
  final String? category;
  final bool isCompleted;

  ActivityModel({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.time,
    this.location,
    this.latitude,
    this.longitude,
    this.cost,
    this.category,
    this.isCompleted = false,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      time: map['time'],
      location: map['location'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      cost: map['cost']?.toDouble(),
      category: map['category'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'cost': cost,
      'category': category,
      'isCompleted': isCompleted,
    };
  }

  ActivityModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? location,
    double? latitude,
    double? longitude,
    double? cost,
    String? category,
    bool? isCompleted,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cost: cost ?? this.cost,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}