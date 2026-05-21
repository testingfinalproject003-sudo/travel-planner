import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import 'package:flutter/material.dart';

class ActivityModel {
  final String id;
  final String name;
  final DateTime time;
  final String type;
  final String? notes;
  final int dayIndex;
  final String? locationName;
  final double? locationLat;
  final double? locationLng;
  final List<String> photoUrls;
  final String suggestedBy;
  final List<String> upVotes;
  final List<String> downVotes;
  final bool isConfirmed;

  ActivityModel({
    required this.id,
    required this.name,
    required this.time,
    required this.type,
    this.notes,
    required this.dayIndex,
    this.locationName,
    this.locationLat,
    this.locationLng,
    this.photoUrls = const [],
    required this.suggestedBy,
    this.upVotes = const [],
    this.downVotes = const [],
    this.isConfirmed = false,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      time: (map['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: map['type'] ?? 'other',
      notes: map['notes'],
      dayIndex: map['dayIndex'] ?? 0,
      locationName: map['locationName'],
      locationLat: map['locationLat']?.toDouble(),
      locationLng: map['locationLng']?.toDouble(),
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      suggestedBy: map['suggestedBy'] ?? '',
      upVotes: List<String>.from(map['upVotes'] ?? []),
      downVotes: List<String>.from(map['downVotes'] ?? []),
      isConfirmed: map['isConfirmed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'time': Timestamp.fromDate(time),
      'type': type,
      'notes': notes,
      'dayIndex': dayIndex,
      'locationName': locationName,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'photoUrls': photoUrls,
      'suggestedBy': suggestedBy,
      'upVotes': upVotes,
      'downVotes': downVotes,
      'isConfirmed': isConfirmed,
    };
  }

  ActivityModel copyWith({
    String? id, String? name, DateTime? time, String? type,
    String? notes, int? dayIndex, String? locationName,
    double? locationLat, double? locationLng, List<String>? photoUrls,
    String? suggestedBy, List<String>? upVotes, List<String>? downVotes,
    bool? isConfirmed,
  }) {
    return ActivityModel(
      id: id ?? this.id, name: name ?? this.name,
      time: time ?? this.time, type: type ?? this.type,
      notes: notes ?? this.notes, dayIndex: dayIndex ?? this.dayIndex,
      locationName: locationName ?? this.locationName,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      photoUrls: photoUrls ?? this.photoUrls,
      suggestedBy: suggestedBy ?? this.suggestedBy,
      upVotes: upVotes ?? this.upVotes,
      downVotes: downVotes ?? this.downVotes,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  Color get typeColor {
    switch (type) {
      case 'visit': return AppColors.primary;
      case 'food': return AppColors.gold;
      case 'museum': return const Color(0xFF8B5CF6);
      case 'nature': return AppColors.success;
      case 'transport': return AppColors.textMuted;
      default: return AppColors.primaryLight;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'visit': return Icons.place;
      case 'food': return Icons.restaurant;
      case 'museum': return Icons.museum;
      case 'nature': return Icons.park;
      case 'transport': return Icons.directions_car;
      default: return Icons.star;
    }
  }

  int get upVoteCount => upVotes.length;
  int get downVoteCount => downVotes.length;
  int get totalVotes => upVotes.length + downVotes.length;
  double get upVotePercent => totalVotes > 0 ? upVotes.length / totalVotes : 0;
}