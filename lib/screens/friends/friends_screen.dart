import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/providers/friend_provider.dart';
import '../../core/services/notification_service.dart';
import '../../widgets/friends/friend_card.dart';
import '../../widgets/friends/friend_request_card.dart';
import '../../widgets/friends/user_search_result.dart';
import '../../widgets/common/empty_state.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final friendProvider = context.read<FriendProvider>();
      final user = authProvider.user;
      if (user != null) {
        friendProvider.loadFriends(user.uid);
        friendProvider.loadPendingRequests(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final friendProvider = context.watch<FriendProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.cardBackground,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users by name...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          friendProvider.clearSearch();
                        },
                      ),
                    ),
                    onChanged: (value) {
                      friendProvider.searchUsers(value, user.uid);
                    },
                  ),
                  if (friendProvider.searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: friendProvider.searchResults.length,
                        itemBuilder: (context, index) {
                          final result = friendProvider.searchResults[index];
                          return UserSearchResult(
                            user: result,
                            onAddFriend: () async {
                              await friendProvider.sendFriendRequest(user.uid, result.uid);
                              NotificationService.showToast('Friend request sent!');
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

          if (friendProvider.pendingRequests.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withValues(alpha:0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Friend Requests (${friendProvider.pendingRequests.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...friendProvider.pendingRequests.map((request) {
                    final friendRequest = request['request'] as dynamic;
                    final requestUser = request['user'] as UserModel;
                    return FriendRequestCard(
                      user: requestUser,
                      onAccept: () async {
                        await friendProvider.acceptFriendRequest(friendRequest.id);
                        NotificationService.showToast('Friend request accepted! Chat created.');
                      },
                      onReject: () async {
                        await friendProvider.rejectFriendRequest(friendRequest.id);
                        NotificationService.showToast('Friend request rejected');
                      },
                    );
                  }),
                ],
              ),
            ),

          Expanded(
            child: friendProvider.friends.isEmpty
                ? EmptyState(
                    icon: Icons.people_outline,
                    title: 'No Friends Yet',
                    subtitle: 'Add friends to plan trips together!',
                    onAction: () => setState(() => _showSearch = true),
                    actionLabel: 'Add Friends',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: friendProvider.friends.length,
                    itemBuilder: (context, index) {
                      return FriendCard(
                        friend: friendProvider.friends[index],
                        onChat: () => _startPrivateChat(context, friendProvider.friends[index], user.uid),
                        onMore: () => _showFriendOptions(context, friendProvider.friends[index], user.uid),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _startPrivateChat(BuildContext context, UserModel friend, String currentUserId) async {
    final chatProvider = context.read<ChatProvider>();
    final chatId = await chatProvider.getOrCreatePrivateChat(currentUserId, friend.uid, friend.name);
    
    if (context.mounted && chatId != null) {
      context.push('/chat-detail', extra: {
        'chatId': chatId,
        'chatName': friend.name,
      });
    }
  }

  void _showFriendOptions(BuildContext context, UserModel friend, String currentUserId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.chat, color: AppColors.primary),
                title: const Text('Chat'),
                onTap: () {
                  Navigator.pop(context);
                  _startPrivateChat(context, friend, currentUserId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: AppColors.primary),
                title: const Text('View Profile'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Remove Friend', style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(context);
                  final friendProvider = context.read<FriendProvider>();
                  await friendProvider.removeFriend(currentUserId, friend.uid);
                  NotificationService.showToast('Friend removed');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}