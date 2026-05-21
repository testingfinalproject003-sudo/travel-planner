import 'package:flutter/material.dart';
// import '../../theme/app_colors.dart';
import '../../models/trip_model.dart';

class ItineraryScreen extends StatelessWidget {
  final TripModel trip;

  const ItineraryScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${trip.title} - Itinerary')),
      body: const Center(
        child: Text('Full Itinerary View'),
      ),
    );
  }
}