import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friend_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/chat_provider.dart';
import '../../navigation/app_router.dart';
import '../../widgets/common/app_avatar.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 3));
  final List<String> _selectedFriendIds = [];
  bool _selectAllFriends = false;
  bool _sendToChat = true;

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final friendProvider = context.watch<FriendProvider>();
    final tripProvider = context.watch<TripProvider>();
    final friends = friendProvider.friends;
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    // final userId = user.uid;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Create Trip'),
        actions: [
          TextButton(
            onPressed: tripProvider.isLoading ? null : () => _createTrip(context),
            child: tripProvider.isLoading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Trip Title',
                hintText: 'e.g., Summer Vacation 2026',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination',
                hintText: 'e.g., Paris, France',
                prefixIcon: Icon(Icons.place),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _DatePickerCard(
                    label: 'Start Date',
                    date: _startDate,
                    onTap: () => _pickDate(context, isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerCard(
                    label: 'End Date',
                    date: _endDate,
                    onTap: () => _pickDate(context, isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Any special plans or requirements...',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 24),

            SwitchListTile(
              title: const Text('Send trip plan to chat for voting'),
              subtitle: const Text('Members can vote before trip is created'),
              value: _sendToChat,
              onChanged: (value) => setState(() => _sendToChat = value),
              activeThumbColor: AppColors.primary,
            ),
            const Divider(),

            Text('Select Friends', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),

            if (friends.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add friends first to plan trips together!',
                        style: TextStyle(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              CheckboxListTile(
                title: const Text('Select All Friends'),
                value: _selectAllFriends,
                onChanged: (value) {
                  setState(() {
                    _selectAllFriends = value ?? false;
                    if (_selectAllFriends) {
                      _selectedFriendIds.clear();
                      _selectedFriendIds.addAll(friends.map((f) => f.uid));
                    } else {
                      _selectedFriendIds.clear();
                    }
                  });
                },
              ),
              const Divider(),
              ...friends.map((friend) => CheckboxListTile(
                secondary: AppAvatar(
                  imageUrl: friend.photoURL,
                  initials: friend.initials,
                  size: 40,
                ),
                title: Text(friend.name),
                subtitle: Text(friend.email, style: AppTextStyles.caption),
                value: _selectedFriendIds.contains(friend.uid),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedFriendIds.add(friend.uid);
                    } else {
                      _selectedFriendIds.remove(friend.uid);
                      _selectAllFriends = false;
                    }
                  });
                },
              )),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _createTrip(BuildContext context) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter trip title')),
      );
      return;
    }
    if (_destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter destination')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final tripProvider = context.read<TripProvider>();
    final chatProvider = context.read<ChatProvider>();
    final user = authProvider.user;

    if (user == null) return;

    final userId = user.uid;
    final memberIds = [userId, ..._selectedFriendIds];

    if (_sendToChat && _selectedFriendIds.isNotEmpty) {
      final chatId = 'proposal_${DateTime.now().millisecondsSinceEpoch}';
      
      await chatProvider.sendTripPlanProposal(
        chatId: chatId,
        senderId: userId,
        senderName: user.name,
        senderInitials: user.initials,
        destination: _destinationController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        memberIds: memberIds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip proposal sent to chat for voting!')),
        );
        Navigator.pushReplacementNamed(context, AppRouter.chatList);
      }
    } else {
      final trip = TripModel(
        id: '',
        title: _titleController.text.trim(),
        destination: _destinationController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        memberIds: memberIds,
        createdBy: userId,
        status: 'planning',
        createdAt: DateTime.now(),
        memberConfirmations: {userId: true},
      );

      try {
        await tripProvider.createTrip(trip);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip created successfully!')),
          );
          Navigator.pushReplacementNamed(context, AppRouter.main);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

class _DatePickerCard extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerCard({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d, yyyy').format(date),
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}