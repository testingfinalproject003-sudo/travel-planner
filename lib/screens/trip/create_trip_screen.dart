import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_button.dart';
import '../../utils/validators.dart';
import '../../utils/date_utils.dart';
import '../../theme/app_dimensions.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  bool _loading = false;

  void _pickDates() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027, 1, 1),
    );
    if (picked != null) {
      setState(() {
        _start = picked.start;
        _end = picked.end;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _start == null || _end == null) return;
    setState(() => _loading = true);

    final userId = Provider.of<AuthProvider>(context, listen: false).user!.uid;
    await Provider.of<TripProvider>(context, listen: false).createTrip(
      title: _titleController.text,
      destination: _destController.text,
      startDate: _start!,
      endDate: _end!,
      notes: _notesController.text,
      userId: userId,
    );

    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Plan')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                AppInput(
                  label: 'Trip Title',
                  hint: 'Summer Vacation',
                  controller: _titleController,
                  prefixIcon: Icons.title_rounded,
                  validator: (v) => Validators.validateRequired(v, 'Title'),
                ),
                const SizedBox(height: AppDimensions.lg),
                AppInput(
                  label: 'Destination',
                  hint: 'Murree, Pakistan',
                  controller: _destController,
                  prefixIcon: Icons.location_on_rounded,
                  validator: (v) => Validators.validateRequired(v, 'Destination'),
                ),
                const SizedBox(height: AppDimensions.xl),
                AppButton(
                  label: _start == null ? 'Select Dates' : '${AppDateUtils.formatShortDate(_start!)} - ${AppDateUtils.formatShortDate(_end!)}',
                  variant: ButtonVariant.outline,
                  isFullWidth: true,
                  onPressed: _pickDates,
                ),
                const SizedBox(height: AppDimensions.lg),
                AppInput(
                  label: 'Notes',
                  hint: 'Optional notes...',
                  controller: _notesController,
                  prefixIcon: Icons.notes_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: AppDimensions.xl),
                AppButton(
                  label: 'Create Trip',
                  isLoading: _loading,
                  isFullWidth: true,
                  onPressed: _submit,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}