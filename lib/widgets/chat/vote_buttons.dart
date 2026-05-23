import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class VoteButtons extends StatelessWidget {
  final bool hasVoted;
  final bool? myVote;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;

  const VoteButtons({
    super.key,
    required this.hasVoted,
    this.myVote,
    required this.onConfirm,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    if (hasVoted) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: myVote == true
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            myVote == true ? 'You voted YES ✓' : 'You voted NO ✗',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: myVote == true ? AppColors.success : AppColors.error,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.check_circle),
            label: const Text('Confirm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDecline,
            icon: const Icon(Icons.cancel, color: AppColors.error),
            label: const Text('Decline', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}