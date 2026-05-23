import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';

class FriendCard extends StatelessWidget {
  final UserModel friend;
  final VoidCallback? onChat;
  final VoidCallback? onMore;

  const FriendCard({
    super.key,
    required this.friend,
    this.onChat,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundImage: friend.photoUrl != null ? NetworkImage(friend.photoUrl!) : null,
          child: friend.photoUrl == null
              ? const Icon(Icons.person, color: AppColors.primary)
              : null,
        ),
        title: Text(
          friend.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          friend.email,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onChat != null)
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                onPressed: onChat,
              ),
            if (onMore != null)
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: onMore,
              ),
          ],
        ),
      ),
    );
  }
}