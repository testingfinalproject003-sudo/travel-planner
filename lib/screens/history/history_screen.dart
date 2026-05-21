import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../models/trip_model.dart';
import '../../providers/trip_provider.dart';
import '../../navigation/app_router.dart';
// import '../../widgets/trip/trip_card.dart';
import '../../widgets/trip/trip_plan_bottom_sheet.dart';
import '../../widgets/common/empty_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Trip History'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<TripProvider>(
          builder: (context, tripProvider, _) {
            final pastTrips = tripProvider.pastTrips;

            if (pastTrips.isEmpty) {
              return const EmptyState(
                icon: Icons.history,
                title: 'No past trips',
                subtitle: 'Your completed trips will appear here',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pastTrips.length,
              itemBuilder: (context, index) {
                final trip = pastTrips[index];
                return _HistoryTripCard(
                  trip: trip,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRouter.tripDetail,
                    arguments: trip,
                  ),
                  onReuse: () => _reuseTrip(context, trip),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _reuseTrip(BuildContext context, TripModel trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TripPlanBottomSheet(
        source: TripPlanSource.home,
        prefillDestination: trip.destination,
        preselectedMemberIds: trip.memberIds,
      ),
    );
  }
}

class _HistoryTripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;
  final VoidCallback onReuse;

  const _HistoryTripCard({
    required this.trip,
    required this.onTap,
    required this.onReuse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            ),
            title: Text(
              trip.title,
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  trip.destination,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('MMM d, yyyy').format(trip.startDate)} - ${DateFormat('MMM d, yyyy').format(trip.endDate)}',
                  style: AppTextStyles.captionSmall,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            onTap: onTap,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Icon(Icons.people, size: 14, color: AppColors.textMuted.withValues(alpha: 0.6)),
                const SizedBox(width: 4),
                Text(
                  '${trip.memberIds.length} members',
                  style: AppTextStyles.captionSmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onReuse,
                  icon: const Icon(Icons.replay, size: 16),
                  label: const Text('Reuse'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}