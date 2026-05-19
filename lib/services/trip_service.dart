import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';
import '../models/activity_model.dart';

class TripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tripsRef => _firestore.collection('trips');

  /// Create trip and return the generated ID
  Future<String> createTrip(TripModel trip) async {
    try {
      final docRef = _tripsRef.doc();
      final tripWithId = trip.copyWith(id: docRef.id);
      await docRef.set(tripWithId.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create trip: $e');
    }
  }

  /// Update existing trip
  Future<void> updateTrip(TripModel trip) async {
    try {
      await _tripsRef.doc(trip.id).update(trip.toMap());
    } catch (e) {
      throw Exception('Failed to update trip: $e');
    }
  }

  /// Delete trip
  Future<void> deleteTrip(String tripId) async {
    try {
      await _tripsRef.doc(tripId).delete();
    } catch (e) {
      throw Exception('Failed to delete trip: $e');
    }
  }

  /// Get all trips where user is a member
  Stream<List<TripModel>> getUserTrips(String userId) {
    return _tripsRef
        .where('memberIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TripModel.fromMap(doc.data()))
            .toList());
  }

  /// Suggest a new activity for a trip
  Future<void> suggestActivity(String tripId, ActivityModel activity) async {
    try {
      final docRef = _tripsRef
          .doc(tripId)
          .collection('activities')
          .doc();
      
      final activityWithId = activity.copyWith(id: docRef.id);
      await docRef.set(activityWithId.toMap());
    } catch (e) {
      throw Exception('Failed to suggest activity: $e');
    }
  }

  /// Vote on an activity
  Future<void> voteActivity(
    String tripId,
    String activityId,
    String userId,
    bool isUpVote,
    int totalMembers,
  ) async {
    try {
      final docRef = _tripsRef.doc(tripId).collection('activities').doc(activityId);
      final doc = await docRef.get();
      
      if (!doc.exists) return;
      
      final data = doc.data()!;
      final upVotes = List<String>.from(data['upVotes'] ?? []);
      final downVotes = List<String>.from(data['downVotes'] ?? []);
      
      upVotes.remove(userId);
      downVotes.remove(userId);
      
      if (isUpVote) {
        upVotes.add(userId);
      } else {
        downVotes.add(userId);
      }
      
      final isConfirmed = upVotes.length > (totalMembers / 2);
      
      await docRef.update({
        'upVotes': upVotes,
        'downVotes': downVotes,
        'isConfirmed': isConfirmed,
      });
    } catch (e) {
      throw Exception('Failed to vote on activity: $e');
    }
  }

  /// Get activities for a trip
  Stream<List<ActivityModel>> getActivities(String tripId) {
    return _tripsRef
        .doc(tripId)
        .collection('activities')
        .orderBy('dayIndex')
        .orderBy('time')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityModel.fromMap(doc.data()))
            .toList());
  }

  /// Add activity to itinerary
  Future<void> addActivity(String tripId, String dayId, ActivityModel activity) async {
    try {
      final docRef = _tripsRef.doc(tripId).collection('itinerary').doc(dayId);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          'day': int.tryParse(dayId) ?? 1,
          'date': dayId,
          'activities': [activity.toMap()]
        });
      } else {
        await docRef.update({
          'activities': FieldValue.arrayUnion([activity.toMap()])
        });
      }
    } catch (e) {
      throw Exception('Failed to add activity: $e');
    }
  }

  /// Delete activity from itinerary
  Future<void> deleteActivity(String tripId, String dayId, String activityId) async {
    try {
      final docRef = _tripsRef.doc(tripId).collection('itinerary').doc(dayId);
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        final List activitiesList = doc.data()!['activities'] ?? [];
        final updatedActivities = activitiesList
            .where((item) => item['id'] != activityId)
            .toList();

        await docRef.update({'activities': updatedActivities});
      }
    } catch (e) {
      throw Exception('Failed to delete activity: $e');
    }
  }

  /// Update trip status
  Future<void> updateTripStatus(String tripId, String status) async {
    try {
      await _tripsRef.doc(tripId).update({'status': status});
    } catch (e) {
      throw Exception('Failed to update trip status: $e');
    }
  }

  /// Duplicate trip as new upcoming trip
  Future<void> duplicateTrip(TripModel trip, String newTripId) async {
    try {
      final clonedTrip = trip.copyWith(
        id: newTripId,
        status: 'upcoming',
        createdAt: DateTime.now(),
      );
      await createTrip(clonedTrip);

      final itinerarySnapshot = await _tripsRef.doc(trip.id).collection('itinerary').get();
      for (var doc in itinerarySnapshot.docs) {
        await _tripsRef.doc(newTripId).collection('itinerary').doc(doc.id).set(doc.data());
      }
    } catch (e) {
      throw Exception('Failed to duplicate trip: $e');
    }
  }
}