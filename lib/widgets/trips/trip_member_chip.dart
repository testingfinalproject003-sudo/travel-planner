import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TripMemberChip extends StatelessWidget {
  final String memberId;
  final String? memberName;
  final VoidCallback? onRemove;
  final bool isCreator;

  const TripMemberChip({
    super.key,
    required this.memberId,
    this.memberName,
    this.onRemove,
    this.isCreator = false,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
        child: Text(
          (memberName ?? memberId).substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      label: Text(
        memberName ?? 'Member',
        style: const TextStyle(fontSize: 13),
      ),
      backgroundColor: AppColors.cardBackground,
      deleteIcon: onRemove != null ? const Icon(Icons.close, size: 16) : null,
      onDeleted: onRemove,
      side: isCreator
          ? BorderSide(color: AppColors.primary.withValues(alpha: 0.5))
          : null,
    );
  }
}