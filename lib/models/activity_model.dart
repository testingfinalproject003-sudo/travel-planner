class ActivityModel {
  final String id;
  final String name;
  final String time;
  final String type;
  final String notes;

  ActivityModel({
    required this.id,
    required this.name,
    required this.time,
    required this.type,
    required this.notes,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      time: map['time'] ?? '',
      type: map['type'] ?? 'visit',
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'type': type,
      'notes': notes,
    };
  }
}