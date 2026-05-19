import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/trip_model.dart';
import '../models/activity_model.dart';
import '../services/trip_service.dart';

class TripProvider extends ChangeNotifier {
  final TripService _tripService = TripService();
  List<TripModel> _trips = [];
  bool _isLoading = false;
  StreamSubscription<List<TripModel>>? _tripsSubscription;

  List<TripModel> get trips => _trips;
  bool get isLoading => _isLoading;

  List<TripModel> get activeTrips => _trips.where((t) => t.status == 'active').toList();
  List<TripModel> get upcomingTrips => _trips.where((t) => t.status == 'upcoming').toList();
  List<TripModel> get pastTrips => _trips.where((t) => t.status == 'past').toList();

  void loadUserTrips(String userId) {
    _isLoading = true;
    _tripsSubscription?.cancel();
    _tripsSubscription = _tripService.getUserTrips(userId).listen((tripsList) {
      _trips = tripsList;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createTrip({
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required String notes,
    required String userId,
  }) async {
    final id = const Uuid().v4();
    final newTrip = TripModel(
      id: id,
      title: title,
      destination: destination,
      notes: notes,
      createdBy: userId,
      status: 'upcoming',
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
      memberIds: [userId],
    );
    await _tripService.createTrip(newTrip);
  }

  Future<void> addActivity(String tripId, String dayId, String name, String time, String type, String notes) async {
    final activity = ActivityModel(
      id: const Uuid().v4(),
      name: name,
      time: time,
      type: type,
      notes: notes,
    );
    await _tripService.addActivity(tripId, dayId, activity);
  }

  Future<void> deleteActivity(String tripId, String dayId, String activityId) async {
    await _tripService.deleteActivity(tripId, dayId, activityId);
  }

  Future<void> updateTripStatus(String tripId, String status) async {
    await _tripService.updateTripStatus(tripId, status);
  }

  Future<void> duplicateTrip(TripModel trip) async {
    final newId = const Uuid().v4();
    await _tripService.duplicateTrip(trip, newId);
  }

  @override
  void dispose() {
    _tripsSubscription?.cancel();
    super.dispose();
  }
}