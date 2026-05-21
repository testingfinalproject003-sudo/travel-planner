import 'package:flutter/material.dart' hide DateUtils;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../models/activity_model.dart';
import '../../utils/date_utils.dart';
import '../common/app_avatar.dart';


class ActivityItem extends StatelessWidget {
  final ActivityModel activity;
  final bool showVotes;
  final VoidCallback? onUpVote;
  final VoidCallback? onDownVote;
  final VoidCallback? onTap;
  final bool isDimmed;

  const ActivityItem({
    super.key,
    required this.activity,
    this.showVotes = true,
    this.onUpVote,
    this.onDownVote,
    this.onTap,
    this.isDimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDimmed ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: activity.isConfirmed ? AppColors.success.withValues(alpha:0.3) : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: activity.typeColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Icon(activity.typeIcon, color: activity.typeColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.name,
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateUtils.formatTime(activity.time),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  if (activity.isConfirmed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 12, color: AppColors.success),
                          SizedBox(width: 4),
                          Text(
                            'Confirmed',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (activity.locationName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: AppColors.textMuted.withValues(alpha:0.6)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        activity.locationName!,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (showVotes) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    _VoteButton(
                      icon: Icons.thumb_up,
                      count: activity.upVoteCount,
                      isActive: false,
                      onTap: onUpVote,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    _VoteButton(
                      icon: Icons.thumb_down,
                      count: activity.downVoteCount,
                      isActive: false,
                      onTap: onDownVote,
                      color: AppColors.danger,
                    ),
                    const Spacer(),
                    AppAvatar(
                      initials: activity.suggestedBy.isNotEmpty
                          ? activity.suggestedBy[0].toUpperCase()
                          : '?',
                      size: 24,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final VoidCallback? onTap;
  final Color color;

  const _VoteButton({
    required this.icon,
    required this.count,
    required this.isActive,
    this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha:0.1) : AppColors.primaryMuted,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? color : AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? color : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}