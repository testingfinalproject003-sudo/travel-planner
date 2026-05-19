import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  StreamSubscription<List<MessageModel>>? _chatSubscription;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  void loadMessages(String tripId) {
    _isLoading = true;
    _chatSubscription?.cancel();
    _chatSubscription = _chatService.getMessages(tripId).listen((msgList) {
      _messages = msgList;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String tripId, String text, String senderId, String senderName) async {
    if (text.trim().isEmpty) return;

    final message = MessageModel(
      id: '',
      text: text.trim(),
      senderId: senderId,
      senderName: senderName,
      type: 'text',
      timestamp: DateTime.now(),
    );
    await _chatService.sendMessage(tripId, message);
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }
}