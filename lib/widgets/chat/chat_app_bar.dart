import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String chatName;
  final String? tripId;
  final int messageCount;
  final List<String> memberIds;

  const ChatAppBar({
    super.key,
    required this.chatName,
    this.tripId,
    required this.messageCount,
    required this.memberIds,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(chatName),
          Text(
            '${memberIds.length} members • $messageCount messages',
            style: TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ),
      actions: [
        if (tripId != null)
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              context.push('/trip-detail', extra: tripId!);
            },
          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'members') {
              _showMembersDialog(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'members',
              child: Row(
                children: [
                  Icon(Icons.people, size: 20),
                  SizedBox(width: 12),
                  Text('Members'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showMembersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat Members'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: memberIds.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    memberIds[index].substring(0, 1).toUpperCase(),
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                title: Text('Member ${index + 1}'),
                subtitle: Text(memberIds[index]),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}