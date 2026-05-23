import 'package:flutter/material.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class TripHistoryItem {
  final String id;
  final String destination;
  final String originalDates;
  final String notes;

  const TripHistoryItem({
    required this.id,
    required this.destination,
    required this.originalDates,
    required this.notes,
  });
}

class TripHistoryScreen extends StatefulWidget {
  // Converted to modern super parameter
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  // Simulating our persistent database list state structure
  final List<TripHistoryItem> _historyTrips = [
    const TripHistoryItem(id: "h1", destination: "Bali, Indonesia", originalDates: "10 Jan 2025 - 18 Jan 2025", notes: "Graduation getaway celebration"),
    const TripHistoryItem(id: "h2", destination: "Tokyo, Japan", originalDates: "04 Apr 2025 - 12 Apr 2025", notes: "Cherry blossom sightseeing project"),
  ];

  void _showReusePlanModal(BuildContext context, TripHistoryItem originalPlan) {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Reuse: ${originalPlan.destination}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff2d2d2d)),
                  ),
                  const CircleAvatar(
                    backgroundColor: Color(0xfff5f5f5),
                    child: Icon(Icons.history, color: Color(0xffd99379)),
                  )
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "This creates a completely separate card instance. The historical record remains untouched.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),
              CustomTextField(
                controller: dateController,
                labelText: "New Dates Configuration",
                hintText: "e.g., 15 Jul 2026 - 22 Jul 2026",
                prefixIcon: Icons.calendar_month,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: notesController,
                labelText: "Updated Trip Notes",
                hintText: "Update your baggage or stay descriptions",
                prefixIcon: Icons.edit_note,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Generate New Trip Instance",
                  onPressed: () {
                    if (dateController.text.isNotEmpty) {
                      // Logic would run backend append here: 
                      // tripService.createNew(originalPlan.destination, dateController.text, notesController.text)
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("New trip created successfully from template!"),
                          backgroundColor: Color(0xffd99379),
                        ),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Travel Log History", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff2d2d2d),
        elevation: 0,
      ),
      body: _historyTrips.isEmpty
          ? const Center(child: Text("No completed logs located yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _historyTrips.length,
              itemBuilder: (context, index) {
                final item = _historyTrips[index];
                return GestureDetector(
                  onLongPress: () => _showReusePlanModal(context, item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xfffafafa),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xffe0e0e0).withValues(alpha: 0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xffd99379).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.archive_outlined, color: Color(0xffd99379)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.destination,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff2d2d2d)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.originalDates,
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                if (item.notes.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    item.notes,
                                    // Fixed property here: fontStyle instead of italic
                                    style: const TextStyle(fontSize: 13, color: Color(0xff757575), fontStyle: FontStyle.italic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ]
                              ],
                            ),
                          ),
                          const Tooltip(
                            message: "Long press to reuse plan templates",
                            child: Icon(Icons.touch_app, color: Colors.grey, size: 18),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}