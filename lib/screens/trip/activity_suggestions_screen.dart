import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../models/activity_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';

class ActivitySuggestionsScreen extends StatefulWidget {
  final String tripId;
  final int dayIndex;

  const ActivitySuggestionsScreen({
    super.key,
    required this.tripId,
    required this.dayIndex,
  });

  @override
  State<ActivitySuggestionsScreen> createState() => _ActivitySuggestionsScreenState();
}

class _ActivitySuggestionsScreenState extends State<ActivitySuggestionsScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedType = 'visit';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _suggestActivity() async {
    final authProvider = context.read<AuthProvider>();
    final tripProvider = context.read<TripProvider>();

    if (authProvider.user == null) return;
    if (_nameController.text.trim().isEmpty) return;

    final now = DateTime.now();
    final activityTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final activity = ActivityModel(
      id: '',
      name: _nameController.text.trim(),
      time: activityTime,
      type: _selectedType,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      dayIndex: widget.dayIndex,
      locationName: _locationController.text.isNotEmpty ? _locationController.text : null,
      suggestedBy: authProvider.user!.name,
      isConfirmed: false,
    );

    await tripProvider.suggestActivity(widget.tripId, activity);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('Suggest Activity')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInput(
                controller: _nameController,
                labelText: 'Activity name',
                hintText: 'e.g., Visit Eiffel Tower',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              Text('Type', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Constants.activityTypes.map((type) {
                  final isSelected = _selectedType == type;
                  return ChoiceChip(
                    label: Text(type.capitalize()),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = type);
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
                onTap: _pickTime,
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
                        _selectedTime.format(context),
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
                controller: _locationController,
                labelText: 'Location (optional)',
                hintText: 'e.g., Champs de Mars, Paris',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: _notesController,
                labelText: 'Notes (optional)',
                hintText: 'Any additional details...',
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Suggest Activity',
                onPressed: _suggestActivity,
              ),
            ],
          ),
        ),
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