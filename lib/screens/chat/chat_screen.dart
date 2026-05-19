import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input_bar.dart';
import '../../widgets/common/app_loader.dart';

class ChatScreen extends StatefulWidget {
  final String tripId;

  const ChatScreen({super.key, required this.tripId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ChatProvider>(context, listen: false).loadMessages(widget.tripId);
  }

  @override
  Widget build(BuildContext buildContext) {
    final chatProvider = Provider.of<ChatProvider>(buildContext);
    final user = Provider.of<AuthProvider>(buildContext).user;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: chatProvider.isLoading
                ? const AppLoader(label: 'Syncing discussion thread...')
                : chatProvider.messages.isEmpty
                ? const Center(child: Text('No messages yet. Say hello! 👋'))
                : ListView.builder(
              reverse: true,
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final msg = chatProvider.messages[index];
                return MessageBubble(
                  message: msg,
                  isMe: msg.senderId == user?.uid,
                );
              },
            ),
          ),
          ChatInputBar(
            onSend: (text) {
              if (user != null) {
                chatProvider.sendMessage(widget.tripId, text, user.uid, user.name);
              }
            },
          )
        ],
      ),
    );
  }
}