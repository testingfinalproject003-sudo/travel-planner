import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/chat_provider.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final user = authProvider.user;

    if (user != null) {
      chatProvider.loadUserChats(user.uid);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: chatProvider.chats.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatProvider.chats.length,
              itemBuilder: (context, index) {
                final chat = chatProvider.chats[index];
                return _buildChatTile(context, chat);
              },
            ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    final chatProvider = context.read<ChatProvider>();
    final allChats = chatProvider.chats;
    List<Map<String, dynamic>> searchResults = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Search Chats'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or message...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              setDialogState(() => searchResults = []);
                            },
                          )
                        : null,
                  ),
                  onChanged: (query) {
                    if (query.isEmpty) {
                      setDialogState(() => searchResults = []);
                      return;
                    }
                    final results = allChats.where((chat) {
                      final name = (chat['name'] ?? '').toString().toLowerCase();
                      final lastMessage = (chat['lastMessage'] ?? '').toString().toLowerCase();
                      final searchLower = query.toLowerCase();
                      return name.contains(searchLower) || lastMessage.contains(searchLower);
                    }).toList();
                    setDialogState(() => searchResults = results);
                  },
                ),
                const SizedBox(height: 16),
                if (searchResults.isNotEmpty)
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final chat = searchResults[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              (chat['name'] ?? '?')[0].toUpperCase(),
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                          title: Text(chat['name'] ?? 'Unknown'),
                          subtitle: Text(
                            chat['lastMessage'] ?? 'No messages',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/chat-detail', extra: {
                              'chatId': chat['id'],
                              'chatName': chat['name'],
                              'tripId': chat['tripId'],
                            });
                          },
                        );
                      },
                    ),
                  )
                else if (searchController.text.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No results found'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, Map<String, dynamic> chat) {
    final lastMessage = chat['lastMessage'] as String?;
    final lastMessageTime = chat['lastMessageTime'] != null
        ? (chat['lastMessageTime'] as dynamic).toDate() as DateTime
        : null;
    final chatName = chat['name'] as String? ?? 'Unknown';
    final chatType = chat['type'] as String? ?? 'group';
    final memberCount = (chat['memberIds'] as List<dynamic>?)?.length ?? 0;

    String timeText = '';
    if (lastMessageTime != null) {
      final now = DateTime.now();
      final diff = now.difference(lastMessageTime);
      if (diff.inDays > 0) {
        timeText = DateFormat('MMM dd').format(lastMessageTime);
      } else if (diff.inHours > 0) {
        timeText = '${diff.inHours}h ago';
      } else {
        timeText = '${diff.inMinutes}m ago';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  chatType == 'trip' ? Icons.flight : Icons.chat_bubble,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            if (memberCount > 1)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$memberCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          chatName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          lastMessage ?? 'No messages yet',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (timeText.isNotEmpty)
              Text(
                timeText,
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        onTap: () {
          context.push('/chat-detail', extra: {
            'chatId': chat['id'] as String,
            'chatName': chatName,
            'tripId': chat['tripId'] as String?,
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'No Messages Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a trip or add friends to chat!',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}