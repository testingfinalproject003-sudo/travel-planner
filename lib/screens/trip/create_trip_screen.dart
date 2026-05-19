import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../models/trip_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friend_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/map_provider.dart';
import '../../navigation/app_router.dart';
import '../../utils/date_utils.dart';
import '../../utils/constants.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/chat/location_photos_widget.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic>? _selectedLocation;
  final List<UserModel> _selectedFriends = [];
  String? _destinationError;
  String? _startDateError;
  String? _endDateError;
  bool _datesValid = false;

  @override
  void dispose() {
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.cardBg,
              onSurface: AppColors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked;
        _startDateError = null;
        if (_endDate != null && !_endDate!.isAfter(_startDate!)) {
          _endDate = null;
          _endDateError = 'Please re-select end date';
        }
      });
      _validateDates();
    }
  }

  void _pickEndDate() async {
    if (_startDate == null) {
      setState(() => _endDateError = 'Please select start date first');
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!.add(const Duration(days: 1)),
      lastDate: _startDate!.add(const Duration(days: 365)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.cardBg,
              onSurface: AppColors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _endDate = picked;
        _endDateError = null;
      });
      _validateDates();
    }
  }

  void _validateDates() {
    setState(() {
      _datesValid = _startDate != null &&
          _endDate != null &&
          _endDate!.isAfter(_startDate!) &&
          !_startDate!.isBefore(DateTime.now().subtract(const Duration(hours: 1)));
    });
  }

  void _pickLocation() async {
    final result = await Navigator.pushNamed(context, AppRouter.locationPicker);
    if (!mounted) return;
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedLocation = result;
        _destinationController.text = result['name'];
        _destinationError = null;
      });
      context.read<MapProvider>().loadLocationPhotos(result['name']);
    }
  }

  Future<void> _createTrip() async {
    final authProvider = context.read<AuthProvider>();
    final tripProvider = context.read<TripProvider>();

    if (authProvider.user == null) return;
    if (_selectedLocation == null || !_datesValid || _selectedFriends.length < Constants.minFriendsToCreateTrip) return;

    final trip = TripModel(
      id: '',
      title: _destinationController.text,
      destination: _selectedLocation!['name'],
      destinationLat: _selectedLocation!['lat'],
      destinationLng: _selectedLocation!['lng'],
      startDate: _startDate!,
      endDate: _endDate!,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      memberIds: [
        authProvider.user!.uid,
        ..._selectedFriends.map((f) => f.uid),
      ],
      createdBy: authProvider.user!.uid,
      createdAt: DateTime.now(),
    );

    final tripId = await tripProvider.createTrip(trip);
    if (!mounted) return;
    if (tripId != null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tripProvider.error ?? 'Failed to create trip')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Plan a new trip'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDragHandle(),
              const SizedBox(height: 8),
              Text('Plan a new trip', style: AppTextStyles.heading2),
              const SizedBox(height: 24),
              _buildDestinationSection(),
              const SizedBox(height: 24),
              _buildDateSection(),
              const SizedBox(height: 24),
              _buildFriendsSection(),
              const SizedBox(height: 24),
              _buildNotesSection(),
              const SizedBox(height: 32),
              _buildCreateButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildDestinationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Destination', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppInput(
                controller: _destinationController,
                hintText: 'Select destination',
                readOnly: true,
                onTap: _pickLocation,
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 20),
                suffixIcon: const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _pickLocation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(14),
                minimumSize: const Size(48, 48),
              ),
              child: const Icon(Icons.map, size: 20),
            ),
          ],
        ),
        if (_destinationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(_destinationError!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
          ),
        if (_selectedLocation != null) ...[
          const SizedBox(height: 12),
          LocationPhotosWidget(locationName: _selectedLocation!['name']),
        ],
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trip dates', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DateCard(
                label: 'Start date',
                date: _startDate,
                error: _startDateError,
                onTap: _pickStartDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateCard(
                label: 'End date',
                date: _endDate,
                error: _endDateError,
                onTap: _pickEndDate,
              ),
            ),
          ],
        ),
        if (_datesValid && _startDate != null && _endDate != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Text(
                  '\${_endDate!.difference(_startDate!).inDays} days trip',
                  style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
        if (_startDate != null && DateUtils.isSameDay(_startDate!, DateTime.now())) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                SizedBox(width: 6),
                Text(
                  'Trip starts today!',
                  style: TextStyle(color: AppColors.warning, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFriendsSection() {
    return Consumer<FriendProvider>(
      builder: (context, friendProvider, _) {
        if (friendProvider.friends.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Add friends first to plan together',
                    style: TextStyle(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invite friends (min. \${Constants.minFriendsToCreateTrip})', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            ...friendProvider.friends.map((friend) {
              final isSelected = _selectedFriends.any((f) => f.uid == friend.uid);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedFriends.add(friend);
                    } else {
                      _selectedFriends.removeWhere((f) => f.uid == friend.uid);
                    }
                  });
                },
                title: Row(
                  children: [
                    AppAvatar(
                      imageUrl: friend.photoURL,
                      initials: friend.initials,
                      size: AppDimensions.avatarSm,
                    ),
                    const SizedBox(width: 12),
                    Text(friend.name),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: AppColors.primary,
              );
            }),
            if (_selectedFriends.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedFriends.map((friend) {
                  return Chip(
                    avatar: AppAvatar(
                      imageUrl: friend.photoURL,
                      initials: friend.initials,
                      size: 24,
                    ),
                    label: Text(friend.name.split(' ').first),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedFriends.removeWhere((f) => f.uid == friend.uid);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notes (optional)', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 8),
        AppInput(
          controller: _notesController,
          hintText: 'Add any notes about the trip...',
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    final canCreate = _datesValid &&
        _selectedLocation != null &&
        _selectedFriends.length >= Constants.minFriendsToCreateTrip;

    return AppButton(
      text: 'Create trip',
      onPressed: canCreate ? _createTrip : null,
      backgroundColor: canCreate ? AppColors.primary : AppColors.textMuted.withValues(alpha:0.3),
    );
  }
}

class _DateCard extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String? error;
  final VoidCallback onTap;

  const _DateCard({
    required this.label,
    this.date,
    this.error,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: error != null ? AppColors.danger : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.textMuted.withValues(alpha:0.6)),
                const SizedBox(width: 6),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: 8),
            if (date == null)
              Text(
                'Select \$label',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              )
            else
              Row(
                children: [
                  Text(
                    DateUtils.formatDate(date!),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                ],
              ),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(error!, style: const TextStyle(color: AppColors.danger, fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }
}