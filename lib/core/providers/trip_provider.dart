import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../models/activity_model.dart';
import '../services/trip_service.dart';

class TripProvider extends ChangeNotifier {
  final TripService _tripService = TripService();
  
  List<TripModel> _trips = [];
  List<TripModel> _upcomingTrips = [];
  List<TripModel> _pastTrips = [];
  List<TripModel> _historyTrips = [];
  TripModel? _selectedTrip;
  bool _isLoading = false;
  String? _error;

  List<TripModel> get trips => _trips;
  List<TripModel> get upcomingTrips => _upcomingTrips;
  List<TripModel> get pastTrips => _pastTrips;
  List<TripModel> get historyTrips => _historyTrips;
  TripModel? get selectedTrip => _selectedTrip;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadUserTrips(String userId) {
    _tripService.getUserTrips(userId).listen((trips) {
      _trips = trips;
      notifyListeners();
    });
  }

  void loadUpcomingTrips(String userId) {
    _tripService.getUpcomingTrips(userId).listen((trips) {
      _upcomingTrips = trips;
      notifyListeners();
    });
  }

  void loadPastTrips(String userId) {
    _tripService.getPastTrips(userId).listen((trips) {
      _pastTrips = trips;
      notifyListeners();
    });
  }

  void loadHistoryTrips(String userId) {
    _tripService.getHistoryTrips(userId).listen((trips) {
      _historyTrips = trips;
      notifyListeners();
    });
  }

  Future<TripModel?> loadTripById(String tripId) async {
    try {
      final trip = await _tripService.getTripById(tripId);
      return trip;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

Future<TripModel?> createTrip(TripModel trip) async {
    _isLoading = true;
    notifyListeners();

    try {
      final createdTrip = await _tripService.createTrip(trip);
      _isLoading = false;
      notifyListeners();
      return createdTrip;  // RETURN the created trip
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> updateTrip(TripModel trip) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _tripService.updateTrip(trip);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTrip(String tripId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _tripService.deleteTrip(tripId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMemberToTrip(String tripId, String userId) async {
    try {
      await _tripService.addMemberToTrip(tripId, userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addActivity(String tripId, ActivityModel activity) async {
    try {
      await _tripService.addActivity(tripId, activity);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateActivity(String tripId, ActivityModel activity) async {
    try {
      await _tripService.updateActivity(tripId, activity);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteActivity(String tripId, String activityId) async {
    try {
      await _tripService.deleteActivity(tripId, activityId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> moveToHistory(String tripId) async {
    try {
      await _tripService.moveToHistory(tripId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<TripModel?> reuseTrip(TripModel originalTrip, DateTime newStartDate, DateTime newEndDate, String? newNotes) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newTrip = await _tripService.reuseTrip(originalTrip, newStartDate, newEndDate, newNotes);
      _isLoading = false;
      notifyListeners();
      return newTrip;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void selectTrip(TripModel trip) {
    _selectedTrip = trip;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}