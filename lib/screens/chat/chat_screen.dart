import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input_bar.dart';
import '../../widgets/trip/trip_plan_bottom_sheet.dart';
import '../../navigation/app_router.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String? subtitle;
  final bool isTripChat;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatName,
    this.subtitle,
    this.isTripChat = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final LocationService _locationService = LocationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view chat')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        title: Row(
          children: [
            Icon(
              widget.isTripChat ? Icons.flight : Icons.person,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  _buildOnlineStatus(),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.white),
            onSelected: (value) => _handleMenuAction(value, authProvider, chatProvider),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'plan_trip', child: Text('Plan Trip')),
              const PopupMenuItem(value: 'location', child: Text('Share Location')),
              const PopupMenuItem(value: 'map', child: Text('Open Map')),
              const PopupMenuItem(value: 'add_friend', child: Text('Add Friend to Chat')),
              if (widget.isTripChat)
                const PopupMenuItem(value: 'confirm', child: Text('Confirm Plan')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatProvider.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48, color: AppColors.textMuted.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'No messages yet',
                          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start the conversation!',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == userId;
                    final showDateSeparator = index == 0 ||
                        !_isSameDay(messages[index - 1].timestamp, message.timestamp);

                    return Column(
                      children: [
                        if (showDateSeparator)
                          _DateSeparator(date: message.timestamp),
                        MessageBubble(
                          message: message,
                          isMe: isMe,
                          currentUserId: userId,
                          chatId: widget.chatId,
                          isTripChat: widget.isTripChat,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          ChatInputBar(
            onSend: (text) {
              if (authProvider.user == null) return;
              chatProvider.sendMessage(
                chatId: widget.chatId,
                text: text,
                senderId: authProvider.user!.uid,
                senderName: authProvider.user!.name,
                senderInitials: authProvider.user!.initials,
              );
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
            },
            isLoading: chatProvider.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineStatus() {
    if (widget.isTripChat) {
      return StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('chats').doc(widget.chatId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
          
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final members = List<String>.from(data?['members'] ?? []);
          
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .where(FieldPath.documentId, whereIn: members)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) return const SizedBox.shrink();
              
              int onlineCount = 0;
              for (var doc in userSnapshot.data!.docs) {
                final userData = doc.data() as Map<String, dynamic>?;
                final lastSeen = userData?['lastSeen'] as Timestamp?;
                if (lastSeen != null) {
                  final lastSeenDate = lastSeen.toDate();
                  final now = DateTime.now();
                  if (now.difference(lastSeenDate).inMinutes < 5) {
                    onlineCount++;
                  }
                }
              }
              
              return Text(
                '$onlineCount/${members.length} online',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.white.withValues(alpha: 0.6),
                ),
              );
            },
          );
        },
      );
    }
    
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('chats').doc(widget.chatId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
        
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final members = List<String>.from(data?['members'] ?? []);
        final currentUserId = context.read<AuthProvider>().user?.uid;
        final otherUserId = members.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );
        
        if (otherUserId.isEmpty) return const SizedBox.shrink();
        
        return StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('users').doc(otherUserId).snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const SizedBox.shrink();
            }
            
            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
            final lastSeen = userData?['lastSeen'] as Timestamp?;
            final isOnline = userData?['isOnline'] as bool? ?? false;
            
            if (isOnline) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              );
            }
            
            if (lastSeen != null) {
              final lastSeenDate = lastSeen.toDate();
              final now = DateTime.now();
              final diff = now.difference(lastSeenDate);
              String status;
              if (diff.inMinutes < 1) {
                status = 'Just now';
              } else if (diff.inMinutes < 60) {
                status = '${diff.inMinutes}m ago';
              } else if (diff.inHours < 24) {
                status = '${diff.inHours}h ago';
              } else {
                status = DateFormat('MMM d').format(lastSeenDate);
              }
              return Text(
                'Last seen $status',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.white.withValues(alpha: 0.5),
                ),
              );
            }
            
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  void _handleMenuAction(String value, AuthProvider auth, ChatProvider chat) async {
    final user = auth.user;
    if (user == null) return;

    switch (value) {
      case 'plan_trip':
        _showTripPlanSheet(chat, user);
        break;
      case 'location':
        _shareLocation(chat, user);
        break;
      case 'map':
        _openMap();
        break;
      case 'add_friend':
        _showAddFriendDialog(context, auth, chat);
        break;
      case 'confirm':
        _sendPlanConfirm(chat, user);
        break;
    }
  }

  // ✅ NEW: Add friend to chat dialog
  void _showAddFriendDialog(BuildContext context, AuthProvider auth, ChatProvider chat) async {
    final currentUserId = auth.user?.uid;
    if (currentUserId == null) return;

    // Get current chat members
    final chatDoc = await _firestore.collection('chats').doc(widget.chatId).get();
    if (!chatDoc.exists) return;
    
    final chatData = chatDoc.data()!;
    final currentMembers = List<String>.from(chatData['members'] ?? []);

    // Get user's friends
    final friendsSnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .where('status', isEqualTo: 'accepted')
        .get();

    if (friendsSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No friends to add')),
      );
      return;
    }

    final friends = friendsSnapshot.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'name': data['name'] ?? 'Unknown',
      };
    }).where((f) => !currentMembers.contains(f['id'])).toList();

    if (friends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All friends are already in this chat')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Friend to Chat'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text((friend['name'] as String).substring(0, 1)),
                ),
                title: Text(friend['name'] as String),
                onTap: () async {
                  Navigator.pop(context);
                  // Add friend to chat
                  await _firestore.collection('chats').doc(widget.chatId).update({
                    'members': FieldValue.arrayUnion([friend['id']]),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${friend['name']} added to chat')),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTripPlanSheet(ChatProvider chat, dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TripPlanBottomSheet(
        source: TripPlanSource.chat,
        chatId: widget.chatId,
        preselectedMemberIds: widget.isTripChat ? null : [user.uid],
      ),
    );
  }

  Future<void> _shareLocation(ChatProvider chat, dynamic user) async {
    try {
      final position = await _locationService.getCurrentPosition();
      final address = await _locationService.getAddressFromCoords(
        position.latitude, position.longitude);
      if (!mounted) return;
      await chat.sendLocationMessage(
        chatId: widget.chatId,
        senderId: user.uid,
        senderName: user.name,
        senderInitials: user.initials,
        locationName: address,
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location error: $e')));
    }
  }

  void _openMap() async {
    String destination = widget.chatName.replaceAll('Trip to ', '');
    final coords = await _locationService.getCoordsFromAddress(destination);
    if (!mounted) return;

    Navigator.pushNamed(
      context,
      AppRouter.map,
      arguments: {
        'destination': destination,
        'lat': coords?.latitude ?? 33.6844,
        'lng': coords?.longitude ?? 73.0479,
      },
    );
  }

  void _sendPlanConfirm(ChatProvider chat, dynamic user) {
    if (!widget.isTripChat) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan confirmation only available in trip chats')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Final Plan'),
        content: const Text('Send confirmation request to all members?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel')
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              chat.sendPlanConfirm(
                chatId: widget.chatId,
                tripId: widget.chatId,
                senderId: user.uid,
                senderName: user.name,
                senderInitials: user.initials,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Confirmation request sent!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _formatDate(date),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.border)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    }
    return DateFormat('MMM d, yyyy').format(date);
  }
}