import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/trip_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/trip_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/services/notification_service.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 3));
  bool _createGroupChat = true;

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
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

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final tripProvider = context.read<TripProvider>();
    final chatProvider = context.read<ChatProvider>();
    final user = authProvider.user;

    if (user == null) return;

    final trip = TripModel(
      id: '',
      name: _nameController.text.trim(),
      destination: _destinationController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      notes: _notesController.text.isEmpty ? null : _notesController.text.trim(),
      createdBy: user.uid,
      memberIds: [user.uid],
      createdAt: DateTime.now(),
    );

    try {
      final createdTrip = await tripProvider.createTrip(trip);

      // Create group chat for the trip
      if (_createGroupChat && createdTrip != null) {
        final chatId = await chatProvider.createTripChat(
          tripName: createdTrip.name,
          memberIds: createdTrip.memberIds,
          tripId: createdTrip.id,
        );

        // Update trip with chat ID
        await tripProvider.updateTrip(createdTrip.copyWith(chatId: chatId));

        // Send welcome message
        await chatProvider.sendMessage(
          chatId: chatId,
          senderId: 'system',
          senderName: 'Genz Go',
          content: 'Welcome to ${createdTrip.name}! Start planning your trip here.',
          type: 'notification',
        );
      }

      NotificationService.showToast('Trip created successfully!');
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      NotificationService.showToast('Failed to create trip: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Your Adventure',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in the details to create your trip',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Trip Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Trip Name',
                    hintText: 'e.g., Summer Vacation 2026',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a trip name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Destination
                TextFormField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    hintText: 'e.g., Paris, France',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a destination';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Date Selection
                Row(
                  children: [
                    Expanded(
                      child: _buildDateCard(
                        'Start Date',
                        dateFormat.format(_startDate),
                        Icons.calendar_today,
                        () => _selectDate(true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateCard(
                        'End Date',
                        dateFormat.format(_endDate),
                        Icons.calendar_today,
                        () => _selectDate(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Any special plans or reminders...',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Create Group Chat Toggle
                SwitchListTile(
                  title: const Text('Create Group Chat'),
                  subtitle: const Text('Automatically create a chat for trip members'),
                  value: _createGroupChat,
                  onChanged: (value) => setState(() => _createGroupChat = value),
                  activeThumbColor: AppColors.primary,
                ),

                const SizedBox(height: 32),

                // Create Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _createTrip,
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Create Trip'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(String label, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}