import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/message_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/services/notification_service.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/vote_buttons.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String? tripId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatName,
    this.tripId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showProposalForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.loadChatMessages(widget.chatId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final user = authProvider.user;

    if (user == null) return;

    _messageController.clear();

    await chatProvider.sendMessage(
      chatId: widget.chatId,
      senderId: user.uid,
      senderName: user.name,
      content: text,
      senderPhotoUrl: user.photoUrl,
    );

    _scrollToBottom();
  }

  Future<void> _sendTripProposal() async {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final user = authProvider.user;

    if (user == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const TripProposalDialog(),
    );

    if (result != null) {
      final memberIds = (result['memberIds'] as List<dynamic>?)?.cast<String>() ?? [user.uid];
      
      await chatProvider.sendTripProposal(
        chatId: widget.chatId,
        senderId: user.uid,
        senderName: user.name,
        destination: result['destination'] as String,
        startDate: result['startDate'] as DateTime,
        endDate: result['endDate'] as DateTime,
        memberIds: memberIds,
        notes: result['notes'] as String?,
      );

      NotificationService.showToast('Trip proposal sent!');
      _scrollToBottom();
    }
  }

  Future<void> _voteOnProposal(String messageId, bool vote) async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null) return;

    final chatProvider = context.read<ChatProvider>();
    await chatProvider.voteOnProposal(messageId, user.uid, vote);

    NotificationService.showToast(vote ? 'You voted YES!' : 'You voted NO');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final user = authProvider.user;
    final messages = chatProvider.messages;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chatName),
            Text(
              '${messages.length} messages',
              style: TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
          ],
        ),
        actions: [
          if (widget.tripId != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                context.push('/trip-detail', extra: widget.tripId!);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == user.uid;
                      
                      if (message.type == 'trip_proposal') {
                        return _buildProposalBubble(message, user.uid);
                      }
                      
                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  ),
          ),

          if (_showProposalForm)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trip_origin, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Create Trip Plan',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _showProposalForm = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _sendTripProposal,
                    icon: const Icon(Icons.add_location),
                    label: const Text('New Trip Proposal'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                    onPressed: () {
                      setState(() => _showProposalForm = !_showProposalForm);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalBubble(MessageModel message, String currentUserId) {
    final metadata = message.metadata ?? {};
    final votes = (metadata['votes'] as Map<String, dynamic>?) ?? {};
    final status = metadata['status'] ?? 'pending';
    final hasVoted = votes.containsKey(currentUserId);
    final myVote = hasVoted ? votes[currentUserId] as bool? : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha:0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha:0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.trip_origin, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trip Proposal',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      Text(
                        'by ${message.senderName}',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: status == 'confirmed'
                        ? AppColors.success.withValues(alpha:0.1)
                        : AppColors.warning.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status == 'confirmed' ? 'Confirmed' : 'Voting',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: status == 'confirmed' ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProposalDetail(message),
            const SizedBox(height: 16),
            VoteButtons(
              hasVoted: hasVoted,
              myVote: myVote,
              onConfirm: () => _voteOnProposal(message.id, true),
              onDecline: () => _voteOnProposal(message.id, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProposalDetail(MessageModel message) {
    final metadata = message.metadata ?? {};
    final destination = metadata['destination'] ?? 'Unknown';
    final startDate = metadata['startDate'] != null
        ? DateTime.parse(metadata['startDate'] as String)
        : DateTime.now();
    final endDate = metadata['endDate'] != null
        ? DateTime.parse(metadata['endDate'] as String)
        : DateTime.now();
    final notes = metadata['notes'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(Icons.location_on, 'Destination', destination),
        const SizedBox(height: 8),
        _buildDetailRow(
          Icons.calendar_today,
          'Dates',
          '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd').format(endDate)}',
        ),
        if (notes != null && notes.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildDetailRow(Icons.notes, 'Notes', notes),
        ],
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// Trip Proposal Dialog
class TripProposalDialog extends StatefulWidget {
  const TripProposalDialog({super.key});

  @override
  State<TripProposalDialog> createState() => _TripProposalDialogState();
}

class _TripProposalDialogState extends State<TripProposalDialog> {
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 3));

  @override
  void dispose() {
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Trip Proposal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Start Date'),
              subtitle: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
              onTap: () => _selectDate(true),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('End Date'),
              subtitle: Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
              onTap: () => _selectDate(false),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_destinationController.text.isEmpty) return;
            Navigator.pop(context, {
              'destination': _destinationController.text,
              'startDate': _startDate,
              'endDate': _endDate,
              'notes': _notesController.text.isEmpty ? null : _notesController.text,
              'memberIds': [],
            });
          },
          child: const Text('Send Proposal'),
        ),
      ],
    );
  }
}