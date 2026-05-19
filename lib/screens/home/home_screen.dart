import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friend_provider.dart';
import '../../providers/trip_provider.dart';
import '../../navigation/app_router.dart';
import '../../utils/constants.dart';
import '../../models/user_model.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/trip/trip_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Consumer3<AuthProvider, FriendProvider, TripProvider>(
          builder: (context, authProvider, friendProvider, tripProvider, _) {
            final user = authProvider.user;
            final activeTrips = tripProvider.activeTrips;
            final upcomingTrips = tripProvider.upcomingTrips;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(user)),
                SliverToBoxAdapter(child: _buildFriendsRow(friendProvider)),
                if (activeTrips.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Active trips', style: AppTextStyles.sectionTitle),
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
                if (upcomingTrips.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Upcoming', style: AppTextStyles.sectionTitle),
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
                if (activeTrips.isEmpty && upcomingTrips.isEmpty)
                  const SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.card_travel,
                      title: 'No trips yet',
                      subtitle: 'Create your first trip with friends!',
                    ),
                  ),
                SliverToBoxAdapter(child: _buildQuickActions(context)),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<FriendProvider>(
        builder: (context, friendProvider, _) {
          if (!friendProvider.canCreateTrip) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, AppRouter.createTrip),
            icon: const Icon(Icons.add),
            label: const Text('New Trip'),
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
                        color: AppColors.white.withValues(alpha:0.7),
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
                  backgroundColor: AppColors.white.withValues(alpha:0.2),
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
                color: AppColors.white.withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.white.withValues(alpha:0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.white.withValues(alpha:0.7), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Explore destinations...',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha:0.7),
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
          border: Border.all(color: AppColors.warning.withValues(alpha:0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Add $needed more friend${needed > 1 ? 's' : ''} to start planning trips",
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
        icon: Icons.explore,
        label: 'Explore\nPlaces',
        color: AppColors.primary,
        onTap: () => Navigator.pushNamed(context, AppRouter.explore),
      ),
      _QuickAction(
        icon: Icons.chat_bubble_outline,
        label: 'Group\nChat',
        color: AppColors.success,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.map_outlined,
        label: 'View\nMap',
        color: AppColors.gold,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.wb_sunny_outlined,
        label: 'Check\nWeather',
        color: const Color(0xFF8B5CF6),
        onTap: () {},
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
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: action.color.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Icon(action.icon, color: action.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                action.label,
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
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