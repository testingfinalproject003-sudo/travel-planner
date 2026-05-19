import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';
import '../models/activity_model.dart';

class TripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tripsRef => _firestore.collection('trips');

  Future<void> createTrip(TripModel trip) async {
    try {
      await _tripsRef.doc(trip.id).set(trip.toMap());
    } catch (e) {
      throw Exception('Trip data save karne mein error aya: $e');
    }
  }

  Stream<List<TripModel>> getUserTrips(String userId) {
    return _tripsRef
        .where('memberIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TripModel.fromMap(doc.data(), doc.id))
        .toList());
  }

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
      throw Exception('Activity append karne mein issue aya: $e');
    }
  }

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
      throw Exception('Activity remove nahi ki ja saki: $e');
    }
  }

  Future<void> updateTripStatus(String tripId, String status) async {
    try {
      await _tripsRef.doc(tripId).update({'status': status});
    } catch (e) {
      throw Exception('Trip status change failed: $e');
    }
  }

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
      throw Exception('Trip structure mapping cloning issue: $e');
    }
  }
}