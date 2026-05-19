import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class AppBadge extends StatelessWidget {
  final String label;
  final String variant;

  const AppBadge({
    super.key,
    required this.label,
    required this.variant,
  });

  @override
  Widget build(BuildContext buildContext) {
    Color bg;
    Color text;

    switch (variant) {
      case 'active':
        bg = AppColors.successBg;
        text = AppColors.success;
        break;
      case 'upcoming':
        bg = AppColors.primaryMuted;
        text = AppColors.primary;
        break;
      case 'past':
      default:
        bg = const Color(0xFFECEFF1);
        text = const Color(0xFF546E7A);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: AppDimensions.xs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}