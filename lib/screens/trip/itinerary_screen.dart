import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../models/trip_model.dart';
import '../../models/activity_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/trip/activity_item.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
// import '../../navigation/app_router.dart';

class ItineraryScreen extends StatefulWidget {
  final TripModel trip;

  const ItineraryScreen({super.key, required this.trip});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  int _selectedDay = 0;

  @override
  Widget build(BuildContext context) {
    final days = widget.trip.durationInDays;
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // Day selector
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: days,
              itemBuilder: (context, index) {
                final dayDate = widget.trip.startDate.add(Duration(days: index));
                final isSelected = index == _selectedDay;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = index),
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Day ${index + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.white : AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEE').format(dayDate),
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected 
                                ? AppColors.white.withValues(alpha: 0.8) 
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Activities for selected day
          Expanded(
            child: StreamBuilder<List<ActivityModel>>(
              stream: context.read<TripProvider>().getActivities(widget.trip.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allActivities = snapshot.data ?? [];
                final dayActivities = allActivities
                    .where((a) => a.dayIndex == _selectedDay)
                    .toList();

                if (dayActivities.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dayActivities.length,
                  itemBuilder: (context, index) {
                    final activity = dayActivities[index];
                    return ActivityItem(
                      activity: activity,
                      showVotes: true,
                      onUpVote: () => _voteActivity(activity, true),
                      onDownVote: () => _voteActivity(activity, false),
                      onTap: () => _showActivityOptions(activity),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddActivitySheet(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('Add Activity', style: TextStyle(color: AppColors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No activities yet',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Text(
            'Plan your Day ${_selectedDay + 1} activities',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddActivitySheet(),
            icon: const Icon(Icons.add),
            label: const Text('Add First Activity'),
          ),
        ],
      ),
    );
  }

  void _voteActivity(ActivityModel activity, bool isUpVote) {
    final authProvider = context.read<AuthProvider>();
    final tripProvider = context.read<TripProvider>();
    
    if (authProvider.user == null) return;
    
    tripProvider.voteActivity(
      widget.trip.id,
      activity.id,
      authProvider.user!.uid,
      isUpVote,
      widget.trip.memberIds.length,
    );
  }

  void _showActivityOptions(ActivityModel activity) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit Activity'),
              onTap: () {
                Navigator.pop(context);
                _showEditActivitySheet(activity);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.danger),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(activity);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(ActivityModel activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity?'),
        content: Text('Remove "${activity.name}" from the itinerary?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TripProvider>().deleteActivity(
                widget.trip.id,
                activity.id,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activity deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddActivitySheet() {
    _showActivityFormSheet(isEditing: false);
  }

  void _showEditActivitySheet(ActivityModel activity) {
    _showActivityFormSheet(isEditing: true, activity: activity);
  }

  void _showActivityFormSheet({required bool isEditing, ActivityModel? activity}) {
    final nameController = TextEditingController(text: isEditing ? activity?.name : '');
    final notesController = TextEditingController(text: isEditing ? activity?.notes : '');
    final locationController = TextEditingController(text: isEditing ? activity?.locationName : '');
    String selectedType = isEditing ? activity?.type ?? 'visit' : 'visit';
    TimeOfDay selectedTime = isEditing 
        ? TimeOfDay(hour: activity!.time.hour, minute: activity.time.minute)
        : const TimeOfDay(hour: 10, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  isEditing ? 'Edit Activity' : 'Add Activity',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 4),
                Text(
                  'Day ${_selectedDay + 1} • ${DateFormat('MMM d, yyyy').format(
                    widget.trip.startDate.add(Duration(days: _selectedDay)),
                  )}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                
                AppInput(
                  controller: nameController,
                  labelText: 'Activity Name',
                  hintText: 'e.g., Visit Eiffel Tower',
                ),
                const SizedBox(height: 16),
                
                Text('Type', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['visit', 'food', 'museum', 'nature', 'transport', 'other'].map((type) {
                    final isSelected = selectedType == type;
                    return ChoiceChip(
                      label: Text(type.capitalize()),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() => selectedType = type);
                        }
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.textMain,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setModalState(() => selectedTime = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.textMuted),
                        const SizedBox(width: 12),
                        Text(
                          selectedTime.format(context),
                          style: AppTextStyles.body,
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                AppInput(
                  controller: locationController,
                  labelText: 'Location (Optional)',
                  hintText: 'e.g., Champs de Mars, Paris',
                ),
                const SizedBox(height: 16),
                
                AppInput(
                  controller: notesController,
                  labelText: 'Notes (Optional)',
                  hintText: 'Any additional details...',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                
                AppButton(
                  text: isEditing ? 'Update Activity' : 'Add Activity',
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter activity name')),
                      );
                      return;
                    }

                    final authProvider = context.read<AuthProvider>();
                    if (authProvider.user == null) return;

                    // final now = DateTime.now();
                    final activityTime = DateTime(
                      widget.trip.startDate.year,
                      widget.trip.startDate.month,
                      widget.trip.startDate.day + _selectedDay,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    final newActivity = ActivityModel(
                      id: isEditing ? activity!.id : '',
                      name: nameController.text.trim(),
                      time: activityTime,
                      type: selectedType,
                      notes: notesController.text.isNotEmpty ? notesController.text : null,
                      dayIndex: _selectedDay,
                      locationName: locationController.text.isNotEmpty ? locationController.text : null,
                      suggestedBy: authProvider.user!.name,
                      isConfirmed: isEditing ? activity!.isConfirmed : false,
                    );

                    if (isEditing) {
                      // For edit, we need to update - but TripService only has suggestActivity
                      // which creates new. We'll delete old and create new for now.
                      context.read<TripProvider>().deleteActivity(widget.trip.id, activity!.id);
                    }
                    
                    context.read<TripProvider>().suggestActivity(
                      widget.trip.id,
                      newActivity,
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing ? 'Activity updated' : 'Activity added'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}