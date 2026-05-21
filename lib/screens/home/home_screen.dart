import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friend_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/chat_provider.dart';
import '../../navigation/app_router.dart';
import '../../utils/constants.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/trip/trip_card.dart';
import '../../widgets/trip/trip_plan_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<TripProvider>().init(authProvider.user!.uid);
        context.read<FriendProvider>().init(authProvider.user!.uid);
      }
    });
  }

  void _openTripPlanSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TripPlanBottomSheet(
        source: TripPlanSource.home,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Consumer4<AuthProvider, FriendProvider, TripProvider, ChatProvider>(
          builder: (context, authProvider, friendProvider, tripProvider, chatProvider, _) {
            final user = authProvider.user;
            final activeTrips = tripProvider.activeTrips;
            final upcomingTrips = tripProvider.upcomingTrips;
            final planningTrips = tripProvider.planningTrips;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(user)),
                SliverToBoxAdapter(child: _buildFriendsRow(friendProvider)),
                SliverToBoxAdapter(child: _buildQuickActions(context)),
                
                // ✅ NEW: Recent Chats Section (shows private + trip group chats)
                _buildRecentChatsSection(context, authProvider),
                
                // Planning Trips
                if (planningTrips.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Icon(Icons.pending_actions, color: AppColors.warning, size: 20),
                          const SizedBox(width: 8),
                          Text('Planning', style: AppTextStyles.sectionTitle),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => TripCard(
                          trip: planningTrips[index],
                          isPlanning: true,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.tripDetail,
                            arguments: planningTrips[index],
                          ),
                        ),
                        childCount: planningTrips.length,
                      ),
                    ),
                  ),
                ],

                // Active Trips
                if (activeTrips.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Active Trips', style: AppTextStyles.sectionTitle),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => TripCard(
                          trip: activeTrips[index],
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.tripDetail,
                            arguments: activeTrips[index],
                          ),
                        ),
                        childCount: activeTrips.length,
                      ),
                    ),
                  ),
                ],

                // Upcoming Trips
                if (upcomingTrips.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Upcoming Trips', style: AppTextStyles.sectionTitle),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => TripCard(
                          trip: upcomingTrips[index],
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.tripDetail,
                            arguments: upcomingTrips[index],
                          ),
                        ),
                        childCount: upcomingTrips.length,
                      ),
                    ),
                  ),
                ],

                if (activeTrips.isEmpty && upcomingTrips.isEmpty && planningTrips.isEmpty)
                  const SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.card_travel,
                      title: 'No trips yet',
                      subtitle: 'Plan your first trip with friends!',
                    ),
                  ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openTripPlanSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text(
          'Plan Trip',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ✅ NEW: Recent Chats Section
  Widget _buildRecentChatsSection(BuildContext context, AuthProvider authProvider) {
    final userId = authProvider.user?.uid;
    if (userId == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: context.read<ChatProvider>().getUserChats(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }

          final chats = snapshot.data!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Recent Chats', style: AppTextStyles.sectionTitle),
                  ],
                ),
              ),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final chatId = chat['id'] ?? '';
                    final chatName = chat['name'] ?? 'Chat';
                    final chatType = chat['type'] ?? 'private';
                    final lastMessage = chat['lastMessage'] ?? '';
                    final members = List<String>.from(chat['members'] ?? []);
                    
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.chat,
                        arguments: {
                          'chatId': chatId,
                          'chatName': chatName,
                          'isTripChat': chatType == 'trip',
                        },
                      ),
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  chatType == 'trip' ? Icons.flight : Icons.person,
                                  color: chatType == 'trip' ? AppColors.success : AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    chatName,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              lastMessage.isEmpty ? 'No messages yet' : lastMessage,
                              style: AppTextStyles.caption,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${members.length} members',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, ${user?.name.split(' ').first ?? 'Traveler'}",
                      style: AppTextStyles.heading2.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready for your next adventure?',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRouter.profile),
                child: AppAvatar(
                  imageUrl: user?.photoURL,
                  initials: user?.initials ?? '?',
                  size: AppDimensions.avatarLg,
                  backgroundColor: AppColors.white.withValues(alpha: 0.2),
                  textColor: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.explore),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.white.withValues(alpha: 0.7), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Explore destinations...',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsRow(FriendProvider friendProvider) {
    final count = friendProvider.friendCount;
    final needed = Constants.minFriendsToCreateTrip - count;

    if (needed > 0) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Add ${needed > 0 ? needed : 0} more friend${needed > 1 ? 's' : ''} to start planning trips",
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.addFriend),
              child: const Text('Add'),
            ),
          ],
        ),
      );
    }

    if (friendProvider.friends.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 80,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: friendProvider.friends.length,
        itemBuilder: (context, index) {
          final friend = friendProvider.friends[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                AppAvatar(
                  imageUrl: friend.photoURL,
                  initials: friend.initials,
                  size: AppDimensions.avatarLg,
                ),
                const SizedBox(height: 4),
                Text(
                  friend.name.split(' ').first,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.add_location_alt,
        label: 'Plan\nTrip',
        color: AppColors.primary,
        onTap: _openTripPlanSheet,
      ),
      _QuickAction(
        icon: Icons.explore,
        label: 'Explore\nPlaces',
        color: AppColors.success,
        onTap: () => Navigator.pushNamed(context, AppRouter.explore),
      ),
      _QuickAction(
        icon: Icons.people,
        label: 'Friends',
        color: AppColors.gold,
        onTap: () => Navigator.pushNamed(context, AppRouter.friends),
      ),
      _QuickAction(
        icon: Icons.history,
        label: 'History',
        color: const Color(0xFF8B5CF6),
        onTap: () => Navigator.pushNamed(context, AppRouter.history),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: 0.85,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: actions.map((a) => _buildActionCard(a)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(_QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, color: action.color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}