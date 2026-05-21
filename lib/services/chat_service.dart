import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required String senderName,
    required String senderInitials,
    String type = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    final docRef = _firestore.collection('chats').doc(chatId).collection('messages').doc();
    final message = MessageModel(
      id: docRef.id,
      text: text,
      senderId: senderId,
      senderName: senderName,
      senderInitials: senderInitials,
      timestamp: DateTime.now(),
      isSystem: type == 'system',
      type: type,
      metadata: metadata,
    );
    await docRef.set(message.toMap());
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendSystemMessage({
    required String chatId,
    required String text,
    Map<String, dynamic>? metadata,
  }) async {
    await sendMessage(
      chatId: chatId,
      text: text,
      senderId: 'system',
      senderName: 'System',
      senderInitials: 'SYS',
      type: 'system',
      metadata: metadata,
    );
  }

  Future<void> sendWeatherMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderInitials,
    required String city,
    required Map<String, dynamic> weatherData,
    DateTime? tripDate,
  }) async {
    final temp = weatherData['temp']?.toString() ?? 'N/A';
    final description = weatherData['description']?.toString() ?? '';
    final windSpeed = weatherData['windSpeed']?.toString() ?? 'N/A';
    final humidity = weatherData['humidity']?.toString() ?? 'N/A';
    
    String text = '🌤️ Weather for $city\n';
    text += 'Current: $temp°C, $description\n';
    text += '💨 Wind: $windSpeed m/s | 💧 Humidity: $humidity%\n';
    if (tripDate != null) {
      text += '\n📅 Trip Date: ${_formatDate(tripDate)}';
      final forecastTemp = weatherData['forecastTemp'];
      final forecastDesc = weatherData['forecastDesc']?.toString() ?? '';
      if (forecastTemp != null) {
        text += '\n🌡️ Expected: $forecastTemp°C, $forecastDesc';
      }
    }
    await sendMessage(
      chatId: chatId,
      text: text,
      senderId: senderId,
      senderName: senderName,
      senderInitials: senderInitials,
      type: 'weather',
      metadata: {
        ...weatherData,
        'city': city,
        'tripDate': tripDate?.toIso8601String(),
      },
    );
  }

  Future<void> sendLocationMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderInitials,
    required String locationName,
    required double lat,
    required double lng,
    String? address,
  }) async {
    String text = '📍 Location Shared\n📌 $locationName\n';
    if (address != null && address.isNotEmpty) text += '🏠 $address\n';
    text += '🌐 $lat, $lng';
    await sendMessage(
      chatId: chatId,
      text: text,
      senderId: senderId,
      senderName: senderName,
      senderInitials: senderInitials,
      type: 'location',
      metadata: {'lat': lat, 'lng': lng, 'locationName': locationName, 'address': address},
    );
  }

  Future<void> sendDestinationMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderInitials,
    required String destination,
    required Map<String, dynamic> weatherData,
    double? lat,
    double? lng,
    DateTime? proposedDate,
  }) async {
    final temp = weatherData['temp']?.toString() ?? 'N/A';
    final description = weatherData['description']?.toString() ?? '';
    final windSpeed = weatherData['windSpeed']?.toString() ?? 'N/A';
    final humidity = weatherData['humidity']?.toString() ?? 'N/A';
    
    String text = '🎯 Destination: $destination\n';
    text += '🌤️ Current Weather: $temp°C, $description\n';
    text += '💨 Wind: $windSpeed m/s | 💧 Humidity: $humidity%\n';
    if (proposedDate != null) {
      text += '\n📅 Proposed Date: ${_formatDate(proposedDate)}';
      final forecastTemp = weatherData['forecastTemp'];
      final forecastDesc = weatherData['forecastDesc']?.toString() ?? '';
      if (forecastTemp != null) {
        text += '\n🌡️ Expected Weather: $forecastTemp°C, $forecastDesc';
      }
    }
    if (lat != null && lng != null) text += '\n\n🗺️ Coordinates: $lat, $lng';
    await sendMessage(
      chatId: chatId,
      text: text,
      senderId: senderId,
      senderName: senderName,
      senderInitials: senderInitials,
      type: 'destination',
      metadata: {
        'type': 'destination_search',
        'destination': destination,
        'weather': weatherData,
        'lat': lat,
        'lng': lng,
        'proposedDate': proposedDate?.toIso8601String(),
      },
    );
  }

  Future<void> sendTripPlanProposal({
  required String chatId,
  required String senderId,
  required String senderName,
  required String senderInitials,
  required String destination,
  required DateTime startDate,
  required DateTime endDate,
  required List<String> memberIds,
  Map<String, dynamic>? weatherData,
}) async {
  // ✅ Auto-add creator's YES vote
  final initialVotes = <String, bool>{senderId: true};
  
  String text = '🗳️ TRIP PLAN PROPOSAL\n\n📍 Destination: $destination\n';
  text += '📅 Dates: ${_formatDate(startDate)} - ${_formatDate(endDate)}\n';
  text += '👥 Members: ${memberIds.length}\n';
  if (weatherData != null) {
    final temp = weatherData['temp']?.toString() ?? 'N/A';
    final description = weatherData['description']?.toString() ?? '';
    text += '\n🌤️ Weather Forecast:\n$temp°C, $description\n';
  }
  
  // ✅ Show current vote count (1 = creator)
  final yesCount = initialVotes.values.where((v) => v).length;
  final remaining = memberIds.length - yesCount;
  text += '\n✅ Tap CONFIRM to vote YES\n❌ Tap REJECT to vote NO\n\n📝 Votes: $yesCount/${memberIds.length} • $remaining needed';

  await sendMessage(
    chatId: chatId,
    text: text,
    senderId: senderId,
    senderName: senderName,
    senderInitials: senderInitials,
    type: 'trip_proposal',
    metadata: {
      'type': 'trip_proposal',
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'memberIds': memberIds,
      'votes': initialVotes,  // ✅ Creator already voted YES
      'weather': weatherData,
      'status': 'voting',
    },
  );
}

  Future<void> sendVoteUpdate({
    required String chatId,
    required String messageId,
    required String senderId,
    required String senderName,
    required String senderInitials,
    required Map<String, bool> votes,
    required int totalMembers,
    required bool isApproved,
  }) async {
    final yesCount = votes.entries.where((e) => e.value).length;
    final noCount = votes.entries.where((e) => !e.value).length;
    String text = '🗳️ VOTE UPDATE\n\n✅ Yes: $yesCount | ❌ No: $noCount\n';
    text += 'Total: $yesCount/$totalMembers\n\n';
    text += isApproved ? '🎉 TRIP APPROVED! Creating trip now...' : '⏳ Waiting for more votes...';
    await sendMessage(
      chatId: chatId,
      text: text,
      senderId: senderId,
      senderName: senderName,
      senderInitials: senderInitials,
      type: 'vote_update',
      metadata: {
        'type': 'vote_update',
        'votes': votes,
        'totalMembers': totalMembers,
        'isApproved': isApproved,
        'parentMessageId': messageId,
      },
    );
  }

  Future<void> sendSuggestion({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderInitials,
    required String text,
    required String suggestionType,
  }) async {
    await sendMessage(
      chatId: chatId,
      text: text,
      senderId: senderId,
      senderName: senderName,
      senderInitials: senderInitials,
      type: 'suggestion',
      metadata: {'suggestionType': suggestionType},
    );
  }

  Future<void> sendPlanConfirm({
    required String chatId,
    required String tripId,
    required String senderId,
    required String senderName,
    required String senderInitials,
  }) async {
    await sendMessage(
      chatId: chatId,
      text: '📋 Final Plan Confirmation Required',
      senderId: senderId,
      senderName: senderName,
      senderInitials: senderInitials,
      type: 'plan_confirm',
      metadata: {'tripId': tripId, 'status': 'pending'},
    );
  }

  Future<void> sendTripCreatedNotification({
    required String chatId,
    required String tripId,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await sendSystemMessage(
      chatId: chatId,
      text: '🎉 TRIP CREATED!\n\n📍 $destination\n📅 ${_formatDate(startDate)} - ${_formatDate(endDate)}\n\n✅ All members confirmed! Check your trips screen.',
      metadata: {'type': 'trip_created', 'tripId': tripId, 'destination': destination},
    );
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats').doc(chatId).collection('messages')
        .orderBy('timestamp', descending: false).limit(200)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => MessageModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updateMessage({
    required String chatId,
    required String messageId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update(data);
  }

  Future<void> createPrivateChat({
    required String userId1,
    required String userId2,
    required String userName1,
    required String userName2,
  }) async {
    final chatId = _generateChatId(userId1, userId2);
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (chatDoc.exists) return;
    await _firestore.collection('chats').doc(chatId).set({
      'type': 'private',
      'members': [userId1, userId2],
      'memberNames': {userId1: userName1, userId2: userName2},
      'name': userName2,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': null,
      'lastMessageTime': null,
    });
    await sendSystemMessage(
      chatId: chatId,
      text: 'You are now friends! Start chatting and plan trips together.',
    );
  }

  Future<void> createTripGroupChat({
    required String tripId,
    required String destination,
    required List<String> memberIds,
    String? tripTitle,
  }) async {
    final chatDoc = await _firestore.collection('chats').doc(tripId).get();
    if (chatDoc.exists) return;
    await _firestore.collection('chats').doc(tripId).set({
      'type': 'trip',
      'tripId': tripId,
      'members': memberIds,
      'name': tripTitle ?? 'Trip to $destination',
      'destination': destination,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': null,
      'lastMessageTime': null,
    });
    await sendSystemMessage(
      chatId: tripId,
      text: 'Trip group created! Start planning your adventure to $destination.',
    );
  }

  // ✅ FIXED: Get user's chats - handle null lastMessageTime, sort client-side
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return data;
          }).toList();
          // ✅ Sort client-side to avoid Firestore composite index requirement
          docs.sort((a, b) {
            final aTime = a['lastMessageTime'];
            final bTime = b['lastMessageTime'];
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1; // null goes to bottom
            if (bTime == null) return -1;
            return (bTime as Timestamp).compareTo(aTime as Timestamp);
          });
          return docs;
        });
  }

  String _generateChatId(String uid1, String uid2) {
    final sortedIds = [uid1, uid2]..sort();
    return 'private_${sortedIds[0]}_${sortedIds[1]}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}