import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../navigation/app_router.dart';
import '../../widgets/common/app_avatar.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Navigator.pushNamed(context, AppRouter.addFriend),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatProvider.getUserChats(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64, color: AppColors.textMuted.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add friends to start chatting',
                    style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final isPrivate = chat['type'] == 'private';
              final members = List<String>.from(chat['members'] ?? []);
              final otherUserId = members.firstWhere(
                (id) => id != userId,
                orElse: () => '',
              );

              // Get chat name - for private chats, show friend's name
              String chatName = chat['name'] ?? 'Unknown';
              if (isPrivate && chat['memberNames'] != null) {
                final memberNames = Map<String, dynamic>.from(chat['memberNames']);
                chatName = memberNames[otherUserId] ?? chatName;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  leading: AppAvatar(
                    initials: isPrivate && otherUserId.isNotEmpty 
                        ? chatName.isNotEmpty ? chatName[0].toUpperCase() : '?' 
                        : 'T',
                    size: AppDimensions.avatarMd,
                  ),
                  title: Text(
                    chatName,
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    chat['lastMessage'] ?? 'No messages yet',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: chat['lastMessageTime'] != null
                      ? Text(
                          _formatTime(chat['lastMessageTime']),
                          style: AppTextStyles.caption,
                        )
                      : null,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.chat,
                      arguments: {
                        'chatId': chat['id'],
                        'chatName': chatName,
                        'isTripChat': !isPrivate,
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return '';
    }

    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}';
  }
}