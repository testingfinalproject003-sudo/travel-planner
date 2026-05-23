import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/trip_model.dart';
import '../services/chat_service.dart';
import '../services/trip_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final TripService _tripService = TripService();
  
  List<Map<String, dynamic>> _chats = [];
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;
  String? _currentChatId;

  List<Map<String, dynamic>> get chats => _chats;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentChatId => _currentChatId;

  void loadUserChats(String userId) {
    _chatService.getUserChats(userId).listen((chats) {
      _chats = chats;
      notifyListeners();
    });
  }

  void loadChatMessages(String chatId) {
    _currentChatId = chatId;
    _chatService.getChatMessages(chatId).listen((messages) {
      _messages = messages;
      notifyListeners();
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    String? senderPhotoUrl,
    String type = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final message = MessageModel(
        id: '',
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        content: content,
        type: type,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

      await _chatService.sendMessage(message);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<String> createTripChat({
    required String tripName,
    required List<String> memberIds,
    required String tripId,
    String? imageUrl,
  }) async {
    try {
      final chatId = await _chatService.createChat(
        name: tripName,
        memberIds: memberIds,
        tripId: tripId,
        type: 'trip',
        imageUrl: imageUrl,
      );
      return chatId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendTripProposal({
    required String chatId,
    required String senderId,
    required String senderName,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> memberIds,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _chatService.sendTripProposal(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        memberIds: memberIds,
        notes: notes,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getOrCreatePrivateChat(String userId1, String userId2, String friendName) async {
    try {
      final existingChat = _chats.firstWhere(
        (chat) {
          final memberIds = List<String>.from(chat['memberIds'] ?? []);
          final type = chat['type'] as String? ?? '';
          return type == 'private' &&
              memberIds.contains(userId1) &&
              memberIds.contains(userId2) &&
              memberIds.length == 2;
        },
        orElse: () => <String, dynamic>{},
      );

      if (existingChat.isNotEmpty && existingChat['id'] != null) {
        return existingChat['id'] as String;
      }

      final chatId = await _chatService.createChat(
        name: friendName,
        memberIds: [userId1, userId2],
        type: 'private',
      );
      return chatId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  Future<void> voteOnProposal(String messageId, String userId, bool vote) async {
    try {
      await _chatService.voteOnProposal(messageId, userId, vote);
      
      // Check if all members voted yes - auto create trip
      final message = _messages.firstWhere((m) => m.id == messageId);
      final votes = (message.metadata?['votes'] as Map<String, dynamic>?) ?? {};
      final totalMembers = message.metadata?['totalMembers'] ?? 0;
      
      final yesVotes = votes.values.where((v) => v == true).length;
      
      if (yesVotes == totalMembers && totalMembers > 0) {
        final destination = message.metadata?['destination'] ?? '';
        final startDateStr = message.metadata?['startDate'] ?? '';
        final endDateStr = message.metadata?['endDate'] ?? '';
        
        if (destination.isNotEmpty && startDateStr.isNotEmpty && endDateStr.isNotEmpty) {
          final startDate = DateTime.parse(startDateStr);
          final endDate = DateTime.parse(endDateStr);
          
          // Auto-create trip when all vote yes
          final trip = TripModel(
            id: '',
            name: 'Trip to $destination',
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            notes: message.metadata?['notes'] as String?,
            createdBy: message.senderId,
            memberIds: votes.keys.toList(),
            createdAt: DateTime.now(),
          );
          
          await _tripService.createTrip(trip);
          
          // Send confirmation message
          await sendMessage(
            chatId: message.chatId,
            senderId: 'system',
            senderName: 'Genz Go',
            content: 'Trip to $destination created! All members confirmed.',
            type: 'notification',
          );
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addMemberToChat(String chatId, String userId) async {
    try {
      await _chatService.addMemberToChat(chatId, userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}