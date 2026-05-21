import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friend_provider.dart';
import '../../navigation/app_router.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/empty_state.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('Friends'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Friends'),
              Tab(text: 'Requests'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => Navigator.pushNamed(context, AppRouter.addFriend),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _FriendsList(),
            _FriendRequests(),
          ],
        ),
      ),
    );
  }
}

class _FriendsList extends StatelessWidget {
  const _FriendsList();

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.friends.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.friends.isEmpty) {
          return EmptyState(
            icon: Icons.people_outline,
            title: 'No friends yet',
            subtitle: 'Add friends to plan trips together',
            action: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.addFriend),
              child: const Text('Add Friend'),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.friends.length,
          itemBuilder: (context, index) {
            final friend = provider.friends[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                leading: AppAvatar(
                  imageUrl: friend.photoURL,
                  initials: friend.initials,
                  size: AppDimensions.avatarMd,
                ),
                title: Text(friend.name, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text(friend.email, style: AppTextStyles.caption),
                trailing: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                  onPressed: () => _openChat(context, friend),
                ),
                onTap: () => _openChat(context, friend),
              ),
            );
          },
        );
      },
    );
  }

  void _openChat(BuildContext context, dynamic friend) {
    final currentUserId = context.read<AuthProvider>().user?.uid ?? '';
    if (currentUserId.isEmpty) return;

    // ✅ FIXED: Use SAME ID generation as ChatService._generateChatId()
    final ids = [currentUserId, friend.uid]..sort();
    final chatId = 'private_${ids[0]}_${ids[1]}';

    Navigator.pushNamed(
      context,
      AppRouter.chat,
      arguments: {
        'chatId': chatId,
        'chatName': friend.name,
        'isTripChat': false,
      },
    );
  }
}

class _FriendRequests extends StatelessWidget {
  const _FriendRequests();

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.incomingRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.incomingRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('Error: ${provider.error}', style: AppTextStyles.body),
                TextButton(
                  onPressed: () => provider.clearError(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.incomingRequests.isEmpty) {
          return const EmptyState(
            icon: Icons.mail_outline,
            title: 'No requests',
            subtitle: 'Friend requests will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.incomingRequests.length,
          itemBuilder: (context, index) {
            final request = provider.incomingRequests[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppAvatar(
                        initials: request.fromUserName.isNotEmpty
                            ? request.fromUserName[0].toUpperCase()
                            : '?',
                        size: AppDimensions.avatarMd,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.fromUserName,
                              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(request.fromUserEmail, style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await provider.acceptFriendRequest(request);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Friend request accepted! Chat created.')),
                              );
                            }
                          },
                          child: const Text('Accept'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.declineFriendRequest(request.id),
                          child: const Text('Decline'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}