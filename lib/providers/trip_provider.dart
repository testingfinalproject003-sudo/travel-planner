import 'package:flutter/material.dart';
import 'dart:async';
import '../services/trip_service.dart';
import '../services/chat_service.dart';
import '../models/trip_model.dart';
import '../models/activity_model.dart';

class TripProvider extends ChangeNotifier {
  final TripService _tripService = TripService();
  final ChatService _chatService = ChatService();
  
  List<TripModel> _trips = [];
  List<TripModel> get activeTrips => _trips.where((t) => t.isActive).toList();
  List<TripModel> get upcomingTrips => _trips.where((t) => t.isUpcoming).toList();
  List<TripModel> get pastTrips => _trips.where((t) => t.isPast).toList();
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<TripModel>>? _tripsSubscription;

  List<TripModel> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void init(String userId) {
    _loadTrips(userId);
  }

  void _loadTrips(String userId) {
    _tripsSubscription?.cancel();
    _tripsSubscription = _tripService.getUserTrips(userId).listen((trips) {
      _trips = trips;
      notifyListeners();
    });
  }

  /// Clear all state (called on logout)
  void clear() {
    _tripsSubscription?.cancel();
    _tripsSubscription = null;
    _trips = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> createTrip(TripModel trip) async {
    _setLoading(true);
    try {
      final tripId = await _tripService.createTrip(trip);
      
      await _chatService.createTripGroupChat(
        tripId: tripId,
        destination: trip.destination,
        memberIds: trip.memberIds,
      );
      
      _error = null;
      _setLoading(false);
      return tripId;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  Future<void> updateTrip(TripModel trip) async {
    _setLoading(true);
    try {
      await _tripService.updateTrip(trip);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> deleteTrip(String tripId) async {
    _setLoading(true);
    try {
      await _tripService.deleteTrip(tripId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> suggestActivity(String tripId, ActivityModel activity) async {
    _setLoading(true);
    try {
      await _tripService.suggestActivity(tripId, activity);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> voteActivity(
    String tripId,
    String activityId,
    String userId,
    bool isUpVote,
    int totalMembers,
  ) async {
    try {
      await _tripService.voteActivity(
        tripId,
        activityId,
        userId,
        isUpVote,
        totalMembers,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Stream<List<ActivityModel>> getActivities(String tripId) {
    return _tripService.getActivities(tripId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _tripsSubscription?.cancel();
    super.dispose();
  }
}