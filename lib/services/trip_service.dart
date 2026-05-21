import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';
import '../models/activity_model.dart';

class TripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TripModel>> getUserTrips(String userId) {
    return _firestore
        .collection('trips')
        .where('memberIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TripModel.fromMap(doc.data()))
            .toList());
  }

  Future<TripModel?> getTrip(String tripId) async {
    final doc = await _firestore.collection('trips').doc(tripId).get();
    if (!doc.exists) return null;
    return TripModel.fromMap(doc.data()!);
  }

  Stream<TripModel?> getTripStream(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .snapshots()
        .map((doc) => doc.exists ? TripModel.fromMap(doc.data()!) : null);
  }

  Future<String> createTrip(TripModel trip) async {
    final docRef = _firestore.collection('trips').doc();
    final tripWithId = trip.copyWith(id: docRef.id);
    await docRef.set(tripWithId.toMap());
    return docRef.id;
  }

  Future<void> updateTrip(TripModel trip) async {
    await _firestore.collection('trips').doc(trip.id).update(trip.toMap());
  }

  Future<void> deleteTrip(String tripId) async {
    await _firestore.collection('trips').doc(tripId).delete();
  }

  Future<void> suggestActivity(String tripId, ActivityModel activity) async {
    await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('activities')
        .doc(activity.id)
        .set(activity.toMap());
  }

  Future<void> voteActivity(
    String tripId,
    String activityId,
    String userId,
    bool isUpVote,
    int totalMembers,
  ) async {
    final docRef = _firestore
        .collection('trips')
        .doc(tripId)
        .collection('activities')
        .doc(activityId);

    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    List<String> upVotes = List<String>.from(data['upVotes'] ?? []);
    List<String> downVotes = List<String>.from(data['downVotes'] ?? []);

    upVotes.remove(userId);
    downVotes.remove(userId);

    if (isUpVote) {
      upVotes.add(userId);
    } else {
      downVotes.add(userId);
    }

    await docRef.update({
      'upVotes': upVotes,
      'downVotes': downVotes,
      'isConfirmed': upVotes.length >= (totalMembers / 2).ceil(),
    });
  }

  Future<void> deleteActivity(String tripId, String activityId) async {
    await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('activities')
        .doc(activityId)
        .delete();
  }

  Stream<List<ActivityModel>> getActivities(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('activities')
        .orderBy('dayIndex')
        .orderBy('time')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> confirmTrip(String tripId, String userId) async {
    final docRef = _firestore.collection('trips').doc(tripId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    Map<String, bool> confirmations = 
        Map<String, bool>.from(data['memberConfirmations'] ?? {});
    confirmations[userId] = true;

    final memberIds = List<String>.from(data['memberIds'] ?? []);
    final allConfirmed = confirmations.entries
        .where((e) => memberIds.contains(e.key))
        .length >= memberIds.length;

    await docRef.update({
      'memberConfirmations': confirmations,
      'isConfirmed': allConfirmed,
      'status': allConfirmed ? 'upcoming' : 'planning',
    });
  }
}