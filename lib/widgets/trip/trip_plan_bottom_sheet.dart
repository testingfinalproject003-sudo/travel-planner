import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friend_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/openrouter_service.dart';
import '../../services/weather_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/app_input.dart';

enum TripPlanSource { home, chat, explore }

class TripPlanBottomSheet extends StatefulWidget {
  final TripPlanSource source;
  final String? prefillDestination;
  final String? chatId;
  final List<String>? preselectedMemberIds;

  const TripPlanBottomSheet({
    super.key,
    required this.source,
    this.prefillDestination,
    this.chatId,
    this.preselectedMemberIds,
  });

  @override
  State<TripPlanBottomSheet> createState() => _TripPlanBottomSheetState();
}

class _TripPlanBottomSheetState extends State<TripPlanBottomSheet> {
  final _destinationController = TextEditingController();
  final _titleController = TextEditingController();
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 3));
  final List<String> _selectedMemberIds = [];
  bool _isLoading = false;
  bool _isAILoading = false;
  String? _aiAdvice;
  String? _error;

  final _openRouterService = OpenRouterService();
  final _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    if (widget.prefillDestination != null) {
      _destinationController.text = widget.prefillDestination!;
      _titleController.text = 'Trip to ${widget.prefillDestination!}';
    }
    if (widget.preselectedMemberIds != null) {
      _selectedMemberIds.addAll(widget.preselectedMemberIds!);
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _getAIAdvice() async {
    if (_destinationController.text.trim().isEmpty) return;

    setState(() {
      _isAILoading = true;
      _aiAdvice = null;
    });

    final advice = await _openRouterService.getTravelAdvice(
      destination: _destinationController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
    );

    if (mounted) {
      setState(() {
        _aiAdvice = advice ?? 'Could not get AI advice. Please try again.';
        _isAILoading = false;
      });
    }
  }

  Future<bool?> _showChatSelectionDialog(List<dynamic> friends, List<String> memberIds) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Send Proposal?', style: AppTextStyles.heading2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do you want to send this as a voting proposal to a chat, or create the trip directly?',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            if (friends.isNotEmpty)
              Text(
                'Members: ${memberIds.length}',
                style: AppTextStyles.caption,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Create Directly', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Send to Chat'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showChatPicker() async {
    final chatProvider = context.read<ChatProvider>();
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;
    if (userId == null) return null;

    final chats = await chatProvider.getUserChats(userId).first;

    if (!mounted) return null;

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Select Chat', style: AppTextStyles.heading2),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: Icon(
                  chat['type'] == 'private' ? Icons.person : Icons.group,
                  color: AppColors.primary,
                ),
                title: Text(chat['name'] ?? 'Chat'),
                subtitle: Text(
                  chat['type'] == 'private' ? 'Private Chat' : 'Group Chat',
                  style: AppTextStyles.caption,
                ),
                onTap: () => Navigator.pop(context, chat['id'] as String),
              );
            },
          ),
        ),
      ),
    );

    return selected;
  }

  @override
  Widget build(BuildContext context) {
    final friendProvider = context.watch<FriendProvider>();
    final friends = friendProvider.friends;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                widget.source == TripPlanSource.chat
                    ? 'Plan Trip in Chat'
                    : 'Plan a New Trip',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 4),
              Text(
                'Set destination, dates, and invite friends',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),

              AppInput(
                controller: _destinationController,
                labelText: 'Destination',
                hintText: 'e.g., Paris, France',
                prefixIcon: const Icon(Icons.place, color: AppColors.primary),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _titleController.text = 'Trip to $value';
                  }
                },
              ),
              const SizedBox(height: 16),

              AppInput(
                controller: _titleController,
                labelText: 'Trip Title (optional)',
                hintText: 'e.g., Summer Vacation 2026',
                prefixIcon: const Icon(Icons.title, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _DatePickerTile(
                      icon: Icons.flight_takeoff,
                      label: 'Start',
                      date: _startDate,
                      onTap: () => _pickDate(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerTile(
                      icon: Icons.flight_land,
                      label: 'End',
                      date: _endDate,
                      onTap: () => _pickDate(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (widget.source != TripPlanSource.chat) ...[
                Text('Invite Friends', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 8),
                if (friends.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Add friends first to plan trips together!',
                            style: TextStyle(color: AppColors.warning, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: friends.map((friend) {
                      final isSelected = _selectedMemberIds.contains(friend.uid);
                      return FilterChip(
                        avatar: AppAvatar(
                          imageUrl: friend.photoURL,
                          initials: friend.initials,
                          size: 28,
                        ),
                        label: Text(friend.name.split(' ').first),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedMemberIds.add(friend.uid);
                            } else {
                              _selectedMemberIds.remove(friend.uid);
                            }
                          });
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 20),
              ],

              if (_aiAdvice == null) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isAILoading ? null : _getAIAdvice,
                    icon: _isAILoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome, color: AppColors.gold),
                    label: Text(
                      _isAILoading ? 'Getting AI Advice...' : 'Get AI Travel Advice',
                      style: const TextStyle(color: AppColors.gold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.gold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.gold, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'AI Travel Advice',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _aiAdvice!,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: AppColors.danger, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              AppButton(
                text: widget.source == TripPlanSource.chat
                    ? 'Send Trip Proposal'
                    : 'Plan Trip',
                onPressed: _confirm,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    final authProvider = context.read<AuthProvider>();
    final tripProvider = context.read<TripProvider>();
    final chatProvider = context.read<ChatProvider>();
    final friendProvider = context.read<FriendProvider>();
    final user = authProvider.user;

    if (user == null) {
      setState(() => _error = 'Please login first');
      return;
    }

    final destination = _destinationController.text.trim();
    if (destination.isEmpty) {
      setState(() => _error = 'Please enter a destination');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final memberIds = <String>{user.uid, ..._selectedMemberIds}.toList();
      final weather = await _weatherService.getWeather(destination);

      if (widget.source == TripPlanSource.chat && widget.chatId != null) {
        await chatProvider.sendTripPlanProposal(
          chatId: widget.chatId!,
          senderId: user.uid,
          senderName: user.name,
          senderInitials: user.initials,
          destination: destination,
          startDate: _startDate,
          endDate: _endDate,
          memberIds: memberIds,
          weatherData: weather,
        );

        if (mounted) {
          Navigator.pop(context, {'sentToChat': true, 'memberCount': memberIds.length});
        }
      } else {
        final shouldSendToChat = await _showChatSelectionDialog(
          friendProvider.friends,
          memberIds,
        );

        if (shouldSendToChat == null) {
          setState(() => _isLoading = false);
          return;
        }

        if (shouldSendToChat) {
          final selectedChatId = await _showChatPicker();
          if (selectedChatId == null) {
            setState(() => _isLoading = false);
            return;
          }

          await chatProvider.sendTripPlanProposal(
            chatId: selectedChatId,
            senderId: user.uid,
            senderName: user.name,
            senderInitials: user.initials,
            destination: destination,
            startDate: _startDate,
            endDate: _endDate,
            memberIds: memberIds,
            weatherData: weather,
          );

          if (mounted) {
            Navigator.pop(context, {'sentToChat': true, 'chatId': selectedChatId});
          }
        } else {
          final trip = TripModel(
            id: '',
            title: _titleController.text.trim().isNotEmpty
                ? _titleController.text.trim()
                : 'Trip to $destination',
            destination: destination,
            startDate: _startDate,
            endDate: _endDate,
            memberIds: memberIds,
            createdBy: user.uid,
            status: 'planning',
            createdAt: DateTime.now(),
            memberConfirmations: {user.uid: true},
          );

          await tripProvider.createTrip(trip);

          if (mounted) {
            Navigator.pop(context, {'created': true});
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
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
}

class _DatePickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.icon,
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
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, yyyy').format(date),
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}