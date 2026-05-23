import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/activity_model.dart';
import 'activity_card.dart';

class ItineraryDayCard extends StatelessWidget {
  final DateTime date;
  final List<ActivityModel> activities;
  final Function(ActivityModel)? onEditActivity;
  final Function(ActivityModel)? onDeleteActivity;

  const ItineraryDayCard({
    super.key,
    required this.date,
    required this.activities,
    this.onEditActivity,
    this.onDeleteActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE, MMM dd').format(date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${activities.length} activities',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (activities.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No activities planned',
              style: TextStyle(color: AppColors.textLight),
            ),
          )
        else
          ...activities.map((activity) => ActivityCard(
            activity: activity,
            onEdit: onEditActivity != null ? () => onEditActivity!(activity) : null,
            onDelete: onDeleteActivity != null ? () => onDeleteActivity!(activity) : null,
          )),
      ],
    );
  }
}