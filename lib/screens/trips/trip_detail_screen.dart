import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/trip_model.dart';
import '../../core/models/activity_model.dart';
import '../../core/providers/trip_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/notification_service.dart';
import '../../widgets/trips/activity_card.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    final tripProvider = context.read<TripProvider>();
    final trip = await tripProvider.loadTripById(widget.tripId);
    if (mounted && trip != null) {
      tripProvider.selectTrip(trip);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final authProvider = context.watch<AuthProvider>();
    final trip = tripProvider.selectedTrip;
    final user = authProvider.user;

    if (trip == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isCreator = trip.createdBy == user?.uid;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final daysLeft = trip.startDate.difference(DateTime.now()).inDays;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(trip.name),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                trip.destination,
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                          style: TextStyle(color: Colors.white.withValues(alpha:0.9)),
                        ),
                        if (daysLeft > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$daysLeft days until trip',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              if (isCreator)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      _editTrip(context, trip);
                    } else if (value == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Trip'),
                          content: const Text('Are you sure? This cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await tripProvider.deleteTrip(trip.id);
                        if (context.mounted) {
                          NotificationService.showToast('Trip deleted');
                          context.pop();
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Trip')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete Trip')),
                  ],
                ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          Icons.chat_bubble,
                          'Chat',
                          () {
                            if (trip.chatId != null) {
                              context.push('/chat-detail', extra: {
                                'chatId': trip.chatId!,
                                'chatName': trip.name,
                                'tripId': trip.id,
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          Icons.wb_sunny,
                          'Weather',
                          () => context.push('/weather', extra: trip.destination),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          Icons.people,
                          'Members',
                          () => _showMembers(context, trip),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (trip.notes != null) ...[
                    _buildSectionTitle('Notes'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(trip.notes!),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Itinerary'),
                      ElevatedButton.icon(
                        onPressed: () => _addActivity(context, trip),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 36)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (trip.activities.isEmpty)
                    _buildEmptyState('No activities yet', 'Add your first activity!')
                  else
                    ...trip.activities.map((activity) => ActivityCard(
                      activity: activity,
                      onEdit: () => _editActivity(context, trip, activity),
                      onDelete: () async {
                        await tripProvider.deleteActivity(trip.id, activity.id);
                        NotificationService.showToast('Activity deleted');
                      },
                    )),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Members'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...trip.memberIds.map((memberId) => Chip(
                        avatar: const CircleAvatar(child: Icon(Icons.person, size: 16)),
                        label: const Text('Member'),
                        backgroundColor: AppColors.cardBackground,
                      )),
                      if (isCreator)
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                          onPressed: () => _showAddMemberDialog(context, trip),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.event_note, size: 48, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }

  void _editTrip(BuildContext context, TripModel trip) {
    final nameController = TextEditingController(text: trip.name);
    final destinationController = TextEditingController(text: trip.destination);
    final notesController = TextEditingController(text: trip.notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Trip'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Trip Name')),
              const SizedBox(height: 12),
              TextField(controller: destinationController, decoration: const InputDecoration(labelText: 'Destination')),
              const SizedBox(height: 12),
              TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final tripProvider = context.read<TripProvider>();
              final updatedTrip = trip.copyWith(
                name: nameController.text,
                destination: destinationController.text,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );
              await tripProvider.updateTrip(updatedTrip);
              if (context.mounted) {
                Navigator.pop(context);
                NotificationService.showToast('Trip updated!');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMembers(BuildContext context, TripModel trip) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trip Members', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...trip.memberIds.map((id) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('Member $id'),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _addActivity(BuildContext context, TripModel trip) {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    DateTime selectedDate = trip.startDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Activity'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Activity Title')),
              const SizedBox(height: 16),
              TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Time (Optional)')),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: trip.startDate,
                    lastDate: trip.endDate,
                  );
                  if (picked != null) selectedDate = picked;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;
              final activity = ActivityModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                date: selectedDate,
                time: timeController.text.isEmpty ? null : timeController.text,
              );
              final tripProvider = context.read<TripProvider>();
              await tripProvider.addActivity(trip.id, activity);
              if (context.mounted) {
                Navigator.pop(context);
                NotificationService.showToast('Activity added!');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editActivity(BuildContext context, TripModel trip, ActivityModel activity) {
    final titleController = TextEditingController(text: activity.title);
    final timeController = TextEditingController(text: activity.time);
    DateTime selectedDate = activity.date;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Activity'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Activity Title')),
              const SizedBox(height: 16),
              TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Time (Optional)')),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: trip.startDate,
                    lastDate: trip.endDate,
                  );
                  if (picked != null) selectedDate = picked;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;
              final updatedActivity = activity.copyWith(
                title: titleController.text,
                date: selectedDate,
                time: timeController.text.isEmpty ? null : timeController.text,
              );
              final tripProvider = context.read<TripProvider>();
              await tripProvider.updateActivity(trip.id, updatedActivity);
              if (context.mounted) {
                Navigator.pop(context);
                NotificationService.showToast('Activity updated!');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, TripModel trip) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'User Email or ID', hintText: 'Enter member email or user ID'),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty) return;
              final tripProvider = context.read<TripProvider>();
              await tripProvider.addMemberToTrip(trip.id, emailController.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
                NotificationService.showToast('Member added!');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}