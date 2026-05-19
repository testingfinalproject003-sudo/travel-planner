import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../models/activity_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../utils/date_utils.dart';

class ActivityItem extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback onDelete;

  const ActivityItem({
    super.key,
    required this.activity,
    required this.onDelete,
  });

  Color _getTypeColor(String type) {
    switch (type) {
      case 'visit': return AppColors.primary;
      case 'food': return AppColors.gold;
      case 'transport': return AppColors.success;
      case 'other':
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    final typeColor = _getTypeColor(activity.type);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => onDelete(),
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: typeColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.name, style: AppTextStyles.heading3),
                      if (activity.notes.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(activity.notes, style: AppTextStyles.small, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ]
                    ],
                  ),
                ),
                Text(
                  AppDateUtils.formatTime(activity.time),
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}