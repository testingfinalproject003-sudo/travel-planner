import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/trip/trip_card.dart';
import '../../theme/app_text_styles.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext buildContext) {
    final historyTrips = Provider.of<TripProvider>(buildContext).pastTrips;

    return Scaffold(
      appBar: AppBar(title: const Text('Past Adventures')),
      body: SafeArea(
        child: historyTrips.isEmpty
            ? Center(
          child: Text('No past trips recorded.', style: AppTextStyles.body),
        )
            : ListView.builder(
          itemCount: historyTrips.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) => TripCard(
            trip: historyTrips[index],
            onTap: () => Navigator.pushNamed(context, '/trip-detail', arguments: historyTrips[index]),
          ),
        ),
      ),
    );
  }
}