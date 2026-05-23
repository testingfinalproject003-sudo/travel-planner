import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class DistanceBadge extends StatelessWidget {
  final double? distance; // in km

  const DistanceBadge({
    super.key,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    if (distance == null) return const SizedBox.shrink();

    String text;
    if (distance! < 1) {
      text = '${(distance! * 1000).toStringAsFixed(0)} m';
    } else {
      text = '${distance!.toStringAsFixed(1)} km';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}