import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/trip_model.dart';
import '../../models/activity_model.dart';
import '../../providers/trip_provider.dart';
import '../../utils/date_utils.dart';
import '../../widgets/trip/activity_item.dart';
import '../../widgets/common/app_loader.dart';
import '../../theme/app_colors.dart';

class ItineraryScreen extends StatefulWidget {
  final TripModel trip;

  const ItineraryScreen({super.key, required this.trip});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final _actController = TextEditingController();
  String _selectedType = 'visit';
  TimeOfDay _selectedTime = TimeOfDay.now();

  void _showAddDialog(String dayId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Activity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _actController, decoration: const InputDecoration(hintText: 'Activity Name')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: const [
                DropdownMenuItem(value: 'visit', child: Text('Visit')),
                DropdownMenuItem(value: 'food', child: Text('Food')),
                DropdownMenuItem(value: 'transport', child: Text('Transport')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => _selectedType = v ?? 'visit'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final t = await showTimePicker(context: context, initialTime: _selectedTime);
                if (t != null) _selectedTime = t;
              },
              child: const Text('Pick Time'),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (_actController.text.isEmpty) return;
              final timeStr = '${_selectedTime.hour}:${_selectedTime.minute}';
              Provider.of<TripProvider>(context, listen: false).addActivity(
                widget.trip.id,
                dayId,
                _actController.text,
                timeStr,
                _selectedType,
                '',
              );
              _actController.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext buildContext) {
    final days = AppDateUtils.getDaysInRange(widget.trip.startDate, widget.trip.endDate);

    return Scaffold(
      body: ListView.builder(
        itemCount: days.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final dayId = '${index + 1}';
          final formattedDayDate = AppDateUtils.formatDate(days[index]);

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('trips')
                .doc(widget.trip.id)
                .collection('itinerary')
                .doc(dayId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();

              List<ActivityModel> activities = [];
              if (snapshot.data!.exists && snapshot.data!.data() != null) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final List actsList = data['activities'] ?? [];
                activities = actsList.map((a) => ActivityModel.fromMap(a)).toList();
                activities.sort((a, b) => a.time.compareTo(b.time));
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text('Day ${index + 1} - $formattedDayDate', style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                    onPressed: () => _showAddDialog(dayId),
                  ),
                  children: [
                    if (activities.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No activities added yet.'),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activities.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (ctx, idx) => ActivityItem(
                          activity: activities[idx],
                          onDelete: () => Provider.of<TripProvider>(context, listen: false).deleteActivity(widget.trip.id, dayId, activities[idx].id),
                        ),
                      )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}