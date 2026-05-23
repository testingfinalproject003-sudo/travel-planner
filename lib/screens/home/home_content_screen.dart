import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/trip_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/trip_provider.dart';
import '../../core/providers/weather_provider.dart';
import '../../core/services/notification_service.dart'; // ADDED

class HomeContentScreen extends StatelessWidget {
  const HomeContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final tripProvider = context.watch<TripProvider>();
    final weatherProvider = context.watch<WeatherProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Load weather for upcoming trips
    if (tripProvider.upcomingTrips.isNotEmpty) {
      final firstTrip = tripProvider.upcomingTrips.first;
      weatherProvider.getCurrentWeather(firstTrip.destination); // FIXED: getCurrentWeather
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with User Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user.name.split(' ')[0]}!',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ready for your next adventure?',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          image: user.photoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(user.photoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user.photoUrl == null
                            ? const Icon(Icons.person, color: AppColors.primary)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Upcoming Trips Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.upcomingTrips,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => context.push('/trip-history'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),

            // Upcoming Trips List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: tripProvider.upcomingTrips.isEmpty
                    ? _buildEmptyState('No upcoming trips', 'Plan your next adventure!')
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: tripProvider.upcomingTrips.length,
                        itemBuilder: (context, index) {
                          return _buildTripCard(context, tripProvider.upcomingTrips[index]);
                        },
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        Icons.map_rounded,
                        'Explore',
                        'Discover places',
                        () => context.go('/explore'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        Icons.wb_sunny_rounded,
                        'Weather',
                        'Check forecast',
                        () => context.push('/weather'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        Icons.chat_rounded,
                        'Chat',
                        'Trip discussions',
                        () => context.go('/chat'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Past Trips Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  AppStrings.pastTrips,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: tripProvider.pastTrips.isEmpty
                  ? SliverToBoxAdapter(
                      child: _buildEmptyState('No past trips', 'Your travel history will appear here'),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildPastTripTile(context, tripProvider.pastTrips[index]);
                        },
                        childCount: tripProvider.pastTrips.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripModel trip) {
    final daysLeft = trip.startDate.difference(DateTime.now()).inDays;
    final dateFormat = DateFormat('MMM dd');

    return GestureDetector(
      onTap: () => context.push('/trip-detail', extra: trip.id),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      daysLeft > 0 ? '$daysLeft days left' : 'Today!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.more_vert, color: Colors.white),
                ],
              ),
              const Spacer(),
              Text(
                trip.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      trip.destination,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPastTripTile(BuildContext context, TripModel trip) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.place, color: AppColors.primary),
        ),
        title: Text(trip.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${trip.destination} \u2022 ${dateFormat.format(trip.startDate)}'),
        trailing: IconButton(
          icon: const Icon(Icons.replay, color: AppColors.primary),
          onPressed: () => _reuseTrip(context, trip),
        ),
        onTap: () => context.push('/trip-detail', extra: trip.id),
      ),
    );
  }

  void _reuseTrip(BuildContext context, TripModel trip) async {
    DateTime? newStartDate;
    DateTime? newEndDate;
    final notesController = TextEditingController(text: trip.notes);
    final tripProvider = context.read<TripProvider>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Reuse Trip Plan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Destination: ${trip.destination}'),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('New Start Date'),
                  subtitle: Text(newStartDate != null
                      ? DateFormat('MMM dd, yyyy').format(newStartDate!)
                      : 'Select date'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setDialogState(() => newStartDate = picked);
                    }
                  },
                ),
                ListTile(
                  title: const Text('New End Date'),
                  subtitle: Text(newEndDate != null
                      ? DateFormat('MMM dd, yyyy').format(newEndDate!)
                      : 'Select date'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: newStartDate?.add(const Duration(days: 1)) ??
                          DateTime.now().add(const Duration(days: 3)),
                      firstDate: newStartDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setDialogState(() => newEndDate = picked);
                    }
                  },
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newStartDate != null && newEndDate != null) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Reuse Trip'),
            ),
          ],
        ),
      ),
    );

    if (result == true && newStartDate != null && newEndDate != null) {
      final newTrip = await tripProvider.reuseTrip(
        trip,
        newStartDate!,
        newEndDate!,
        notesController.text.isEmpty ? null : notesController.text,
      );

      if (newTrip != null) {
        NotificationService.showToast('Trip reused successfully!');
        if (context.mounted) {
          context.push('/trip-detail', extra: newTrip.id);
        }
      }
    }
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.travel_explore, size: 48, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
} 