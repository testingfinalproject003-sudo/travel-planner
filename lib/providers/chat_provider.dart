import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 🔥 Clear all state (called on logout)
  void clear() {
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// 🔥 Get messages (works for both trip and private chats)
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _chatService.getMessages(chatId);
  }

  /// 🔥 Get user's all chats
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _chatService.getUserChats(userId);
  }

  /// 🔥 Send message
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required String senderName,
    required String senderInitials,
  }) async {
    if (text.trim().isEmpty) return;
    _setLoading(true);
    try {
      await _chatService.sendMessage(
        chatId: chatId,
        text: text.trim(),
        senderId: senderId,
        senderName: senderName,
        senderInitials: senderInitials,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  /// 🔥 Create trip group chat
  Future<void> createTripChat(String tripId, String destination, List<String> memberIds) async {
    try {
      await _chatService.createTripGroupChat(
        tripId: tripId,
        destination: destination,
        memberIds: memberIds,
      );
    } catch (e) {
      _error = e.toString();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}