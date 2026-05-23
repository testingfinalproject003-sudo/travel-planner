import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';

class UserSearchResult extends StatelessWidget {
  final UserModel user;
  final VoidCallback onAddFriend;
  final bool isLoading;

  const UserSearchResult({
    super.key,
    required this.user,
    required this.onAddFriend,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
        child: user.photoUrl == null
            ? const Icon(Icons.person, color: AppColors.primary)
            : null,
      ),
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        user.email,
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
      trailing: ElevatedButton.icon(
        onPressed: isLoading ? null : onAddFriend,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.person_add, size: 18),
        label: const Text('Add'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(80, 36),
        ),
      ),
    );
  }
}