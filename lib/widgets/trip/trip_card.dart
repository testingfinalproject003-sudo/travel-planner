import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../models/trip_model.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;
  final bool isPlanning;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
    this.isPlanning = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isPlanning ? AppColors.warning.withValues(alpha:0.5) : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isPlanning 
                    ? AppColors.warning.withValues(alpha:0.1)
                    : AppColors.primary.withValues(alpha:0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusLg),
                  topRight: Radius.circular(AppDimensions.radiusLg),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isPlanning ? Icons.pending_actions : Icons.flight_takeoff,
                    color: isPlanning ? AppColors.warning : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trip.title,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isPlanning ? AppColors.warning : AppColors.primary,
                      ),
                    ),
                  ),
                  if (isPlanning)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: const Text(
                        'PLANNING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.place, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          trip.destination,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}',
                        style: AppTextStyles.caption,
                      ),
                      const Spacer(),
                      Icon(Icons.people, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${trip.memberIds.length}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  // ✅ FIXED: Safe division with null/empty checks
                  if (isPlanning && trip.memberIds.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: trip.memberConfirmations.isEmpty 
                          ? 0 
                          : trip.memberConfirmations.length / trip.memberIds.length,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${trip.memberConfirmations.length}/${trip.memberIds.length} confirmed',
                      style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}