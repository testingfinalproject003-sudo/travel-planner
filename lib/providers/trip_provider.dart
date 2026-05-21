import 'dart:async';
import 'package:flutter/material.dart';
import '../services/trip_service.dart';
import '../services/chat_service.dart';
import '../models/trip_model.dart';
import '../models/activity_model.dart';

class TripProvider extends ChangeNotifier {
  final TripService _tripService = TripService();
  final ChatService _chatService = ChatService();
  
  List<TripModel> _trips = [];
  List<TripModel> get activeTrips => _trips.where((t) => t.isActive && t.isConfirmed).toList();
  List<TripModel> get upcomingTrips => _trips.where((t) => t.isUpcoming && t.isConfirmed).toList();
  List<TripModel> get planningTrips => _trips.where((t) => t.status == 'planning').toList();
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

  void clear() {
    _tripsSubscription?.cancel();
    _tripsSubscription = null;
    _trips = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<TripModel?> getTrip(String tripId) async {
    try {
      return await _tripService.getTrip(tripId);
    } catch (e) {
      return null;
    }
  }

  Stream<TripModel?> getTripStream(String tripId) {
    return _tripService.getTripStream(tripId);
  }

  Future<String?> createTrip(TripModel trip) async {
    _setLoading(true);
    try {
      final tripId = await _tripService.createTrip(trip);
      
      await _chatService.createTripGroupChat(
        tripId: tripId,
        destination: trip.destination,
        memberIds: trip.memberIds,
        tripTitle: trip.title,
      );
      
      // Send notification to each member's private chat
      for (final memberId in trip.memberIds) {
        if (memberId != trip.createdBy) {
          final chatId = _generatePrivateChatId(trip.createdBy, memberId);
          await _chatService.sendSystemMessage(
            chatId: chatId,
            text: '📢 New Trip: "${trip.title}" to ${trip.destination}!\n'
                  '📅 ${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}\n'
                  '👉 Open trip chat to vote and plan!',
            metadata: {
              'type': 'trip_notification',
              'tripId': tripId,
            },
          );
        }
      }
      
      _error = null;
      _setLoading(false);
      return tripId;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  /// Create trip from approved proposal (called from ChatProvider)
  Future<String?> createTripFromProposal({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> memberIds,
    required String createdBy,
  }) async {
    _setLoading(true);
    try {
      final trip = TripModel(
        id: '',
        title: 'Trip to $destination',
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        memberIds: memberIds,
        createdBy: createdBy,
        status: 'upcoming',
        createdAt: DateTime.now(),
        memberConfirmations: {for (var id in memberIds) id: true},
        isConfirmed: true,
      );

      final tripId = await _tripService.createTrip(trip);
      
      await _chatService.createTripGroupChat(
        tripId: tripId,
        destination: destination,
        memberIds: memberIds,
        tripTitle: trip.title,
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

  Future<void> confirmTrip(String tripId, String userId) async {
    _setLoading(true);
    try {
      await _tripService.confirmTrip(tripId, userId);
      
      final trip = await _tripService.getTrip(tripId);
      if (trip != null && trip.isConfirmed) {
        await _chatService.sendSystemMessage(
          chatId: tripId,
          text: '🎉 Trip "${trip.title}" is FULLY CONFIRMED!\n'
                '📍 ${trip.destination} | 📅 ${_formatDate(trip.startDate)}\n'
                'All members voted yes. Check home screen for details!',
          metadata: {
            'type': 'plan_confirm',
            'tripId': tripId,
          },
        );
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
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
    String tripId, String activityId, String userId, bool isUpVote, int totalMembers,
  ) async {
    try {
      await _tripService.voteActivity(tripId, activityId, userId, isUpVote, totalMembers);
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

  String _generatePrivateChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return 'private_${ids[0]}_${ids[1]}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _tripsSubscription?.cancel();
    super.dispose();
  }
}