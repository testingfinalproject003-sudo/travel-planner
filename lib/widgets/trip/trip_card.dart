import 'package:flutter/material.dart';
import '../../models/trip_model.dart';
import '../common/app_card.dart';
import '../common/app_badge.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../utils/date_utils.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext buildContext) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: const Icon(Icons.flight_takeoff_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(trip.title, style: AppTextStyles.heading3, overflow: TextOverflow.ellipsis),
                    ),
                    AppBadge(label: trip.status, variant: trip.status),
                  ],
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(trip.destination, style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: AppDimensions.xs),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${AppDateUtils.formatShortDate(trip.startDate)} - ${AppDateUtils.formatShortDate(trip.endDate)}',
                      style: AppTextStyles.small,
                    ),
                    const SizedBox(width: AppDimensions.md),
                    const Icon(Icons.people_alt_rounded, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${trip.memberIds.length} members', style: AppTextStyles.small),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}