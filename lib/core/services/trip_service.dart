import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';
import '../models/activity_model.dart';

class TripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _tripsRef => _firestore.collection('trips');

  Stream<List<TripModel>> getUserTrips(String userId) {
    return _tripsRef
        .where('memberIds', arrayContains: userId)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList());
  }

  Stream<List<TripModel>> getUpcomingTrips(String userId) {
    final now = DateTime.now();
    return _tripsRef
        .where('memberIds', arrayContains: userId)
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('isCompleted', isEqualTo: false)
        .orderBy('endDate', descending: false)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList());
  }

  Stream<List<TripModel>> getPastTrips(String userId) {
    final now = DateTime.now();
    return _tripsRef
        .where('memberIds', arrayContains: userId)
        .where('endDate', isLessThan: Timestamp.fromDate(now))
        .orderBy('endDate', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList());
  }

  Stream<List<TripModel>> getHistoryTrips(String userId) {
    return _tripsRef
        .where('memberIds', arrayContains: userId)
        .where('isFromHistory', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList());
  }

   Future<TripModel> createTrip(TripModel trip) async {
    final docRef = _firestore.collection('trips').doc();
    final tripWithId = trip.copyWith(id: docRef.id);
    await docRef.set(tripWithId.toFirestore());
    return tripWithId;
  }

  Future<void> updateTrip(TripModel trip) async {
    await _tripsRef.doc(trip.id).update(trip.toFirestore());
  }

  Future<void> deleteTrip(String tripId) async {
    await _tripsRef.doc(tripId).delete();
  }

  Future<void> addMemberToTrip(String tripId, String userId) async {
    await _tripsRef.doc(tripId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeMemberFromTrip(String tripId, String userId) async {
    await _tripsRef.doc(tripId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> addActivity(String tripId, ActivityModel activity) async {
    await _tripsRef.doc(tripId).update({
      'activities': FieldValue.arrayUnion([activity.toMap()]),
    });
  }

  Future<void> updateActivity(String tripId, ActivityModel updatedActivity) async {
    final doc = await _tripsRef.doc(tripId).get();
    final trip = TripModel.fromFirestore(doc);
    
    final updatedActivities = trip.activities.map((a) => 
        a.id == updatedActivity.id ? updatedActivity : a).toList();
    
    await _tripsRef.doc(tripId).update({
      'activities': updatedActivities.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> deleteActivity(String tripId, String activityId) async {
    final doc = await _tripsRef.doc(tripId).get();
    final trip = TripModel.fromFirestore(doc);
    
    final updatedActivities = trip.activities.where((a) => a.id != activityId).toList();
    
    await _tripsRef.doc(tripId).update({
      'activities': updatedActivities.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> markTripAsCompleted(String tripId) async {
    await _tripsRef.doc(tripId).update({
      'isCompleted': true,
      'isFromHistory': true,
    });
  }

  Future<void> moveToHistory(String tripId) async {
    await _tripsRef.doc(tripId).update({
      'isFromHistory': true,
      'isCompleted': true,
    });
  }

  Future<TripModel> reuseTrip(TripModel originalTrip, DateTime newStartDate, DateTime newEndDate, String? newNotes) async {
    final docRef = _tripsRef.doc();
    final newTrip = TripModel(
      id: docRef.id,
      name: originalTrip.name,
      destination: originalTrip.destination,
      startDate: newStartDate,
      endDate: newEndDate,
      notes: newNotes ?? originalTrip.notes,
      createdBy: originalTrip.createdBy,
      memberIds: originalTrip.memberIds,
      activities: originalTrip.activities.map((a) => a.copyWith(
        id: '${a.id}_reused_${DateTime.now().millisecondsSinceEpoch}',
        date: newStartDate.add(a.date.difference(originalTrip.startDate)),
      )).toList(),
      chatId: null,
      isCompleted: false,
      isFromHistory: false,
      createdAt: DateTime.now(),
      imageUrl: originalTrip.imageUrl,
      budget: originalTrip.budget,
    );
    
    await docRef.set(newTrip.toFirestore());
    return newTrip;
  }

  Future<TripModel?> getTripById(String tripId) async {
    final doc = await _tripsRef.doc(tripId).get();
    if (doc.exists) {
      return TripModel.fromFirestore(doc);
    }
    return null;
  }
}