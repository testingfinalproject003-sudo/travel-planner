import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';
import '../services/trip_service.dart';
import '../models/message_model.dart';
import '../models/trip_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final TripService _tripService = TripService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _chatService.getMessages(chatId);
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required String senderName,
    required String senderInitials,
    String type = 'text', 
    Map<String, dynamic>? metadata,  
  }) async {
    try {
      await _chatService.sendMessage(
        chatId: chatId,
        text: text,
        senderId: senderId,
        senderName: senderName,
        senderInitials: senderInitials,
        type: type,  
        metadata: metadata,  
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendLocationMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderInitials,
    required String locationName,
    required double lat,
    required double lng,
  }) async {
    try {
      await _chatService.sendLocationMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderInitials: senderInitials,
        locationName: locationName,
        lat: lat,
        lng: lng,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ✅ FIXED: Send trip plan proposal - sender must also vote
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
    _setLoading(true);
    try {
      // ✅ Ensure sender is in members list
      final allMembers = <String>{senderId, ...memberIds}.toList();
      
      await _chatService.sendTripPlanProposal(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderInitials: senderInitials,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        memberIds: allMembers,
        weatherData: weatherData,
      );
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // ✅ FIXED: Vote on trip proposal - ALL members must vote, not just creator
  Future<void> voteOnProposal({
  required String chatId,
  required String messageId,
  required String userId,
  required String userName,
  required String userInitials,
  required bool vote,
}) async {
  _setLoading(true);
  try {
    final messageDoc = await _firestore
        .collection('chats').doc(chatId).collection('messages').doc(messageId)
        .get();

    if (!messageDoc.exists) {
      throw Exception('Proposal not found');
    }

    final data = messageDoc.data()!;
    final metadata = Map<String, dynamic>.from(data['metadata'] ?? {});
    
    final votes = Map<String, bool>.from(metadata['votes'] ?? {});
    final memberIds = List<String>.from(metadata['memberIds'] ?? []);
    final totalMembers = memberIds.length;
    
    // ✅ Add user's vote
    votes[userId] = vote;
    
    final yesVotes = votes.entries.where((e) => e.value).length;
    final noVotes = votes.entries.where((e) => !e.value).length;
    
    // ✅ FIXED: ALL members must vote YES for approval
    final isApproved = yesVotes >= totalMembers;
    
    await _chatService.updateMessage(
      chatId: chatId,
      messageId: messageId,
      data: {
        'metadata.votes': votes,
        'metadata.yesVotes': yesVotes,
        'metadata.noVotes': noVotes,
        'metadata.status': isApproved ? 'approved' : 'voting',
        'text': _buildProposalText(
          destination: metadata['destination'] ?? '',
          startDate: DateTime.parse(metadata['startDate'] ?? DateTime.now().toIso8601String()),
          endDate: DateTime.parse(metadata['endDate'] ?? DateTime.now().toIso8601String()),
          memberIds: memberIds,
          yesVotes: yesVotes,
          noVotes: noVotes,
          totalMembers: totalMembers,
          isApproved: isApproved,
          weather: metadata['weather'],
        ),
      },
    );

    await _chatService.sendVoteUpdate(
      chatId: chatId,
      messageId: messageId,
      senderId: userId,
      senderName: userName,
      senderInitials: userInitials,
      votes: votes,
      totalMembers: totalMembers,
      isApproved: isApproved,
    );

    // ✅ If approved, create trip
    if (isApproved) {
      await _createTripFromApprovedProposal(
        chatId: chatId,
        messageId: messageId,
        metadata: metadata,
        memberIds: memberIds,
      );
    }

    _error = null;
  } catch (e) {
    _error = e.toString();
  }
  _setLoading(false);
}
  // ✅ FIXED: Create trip from approved proposal - proper member handling
  Future<void> _createTripFromApprovedProposal({
    required String chatId,
    required String messageId,
    required Map<String, dynamic> metadata,
    required List<String> memberIds,
  }) async {
    try {
      final destination = metadata['destination'] ?? '';
      final startDate = DateTime.parse(metadata['startDate'] ?? DateTime.now().toIso8601String());
      final endDate = DateTime.parse(metadata['endDate'] ?? DateTime.now().toIso8601String());
      
      // ✅ Create trip with ALL members confirmed
      final trip = TripModel(
        id: '',
        title: 'Trip to \$destination',
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        memberIds: memberIds,
        createdBy: memberIds.first,
        status: 'upcoming',
        createdAt: DateTime.now(),
        memberConfirmations: {for (var id in memberIds) id: true},
        isConfirmed: true,
      );

      final tripId = await _tripService.createTrip(trip);
      
      // ✅ Create group chat for the trip
      await _chatService.createTripGroupChat(
        tripId: tripId,
        destination: destination,
        memberIds: memberIds,
        tripTitle: trip.title,
      );

      // ✅ Send notification
      await _chatService.sendTripCreatedNotification(
        chatId: chatId,
        tripId: tripId,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendPlanConfirm({
    required String chatId,
    required String tripId,
    required String senderId,
    required String senderName,
    required String senderInitials,
  }) async {
    try {
      await _chatService.sendPlanConfirm(
        chatId: chatId,
        tripId: tripId,
        senderId: senderId,
        senderName: senderName,
        senderInitials: senderInitials,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _chatService.getUserChats(userId);
  }

  String _buildProposalText({
  required String destination,
  required DateTime startDate,
  required DateTime endDate,
  required List<String> memberIds,
  required int yesVotes,
  required int noVotes,
  required int totalMembers,
  required bool isApproved,
  Map<String, dynamic>? weather,
}) {
  String text = '🗳️ TRIP PLAN PROPOSAL\n\n';
  text += '📍 Destination: $destination\n';
  text += '📅 Dates: ${_formatDate(startDate)} - ${_formatDate(endDate)}\n';
  text += '👥 Members: $totalMembers\n';
  
  if (weather != null) {
    final temp = weather['temp']?.toString() ?? 'N/A';
    final description = weather['description']?.toString() ?? 'N/A';
    text += '\n🌤️ Weather: $temp°C, $description\n';
  }
  
  text += '\n✅ Yes: $yesVotes | ❌ No: $noVotes\n';
  text += '📝 Progress: $yesVotes/$totalMembers\n\n';
  
  if (isApproved) {
    text += '🎉 APPROVED! Trip is being created...';
  } else {
    text += '⏳ Tap CONFIRM to vote YES\n';
    text += '❌ Tap REJECT to vote NO';
  }
  
  return text;
}

  String _formatDate(DateTime date) {
    return '\${date.day}/\${date.month}/\${date.year}';
  }
}