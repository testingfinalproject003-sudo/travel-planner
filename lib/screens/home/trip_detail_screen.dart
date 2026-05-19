import 'package:flutter/material.dart';
import '../../models/trip_model.dart';
import '../../theme/app_colors.dart';
import '../trip/itinerary_screen.dart';
import '../../widgets/trip/weather_card.dart';
import '../chat/chat_screen.dart';

class TripDetailScreen extends StatelessWidget {
  final TripModel trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext buildContext) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(trip.title),
          bottom: const TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.primaryMuted,
            indicatorColor: AppColors.gold,
            tabs: [
              Tab(icon: Icon(Icons.map_rounded), text: 'Itinerary'),
              Tab(icon: Icon(Icons.wb_sunny_rounded), text: 'Weather'),
              Tab(icon: Icon(Icons.chat_bubble_rounded), text: 'Chat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ItineraryScreen(trip: trip),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  WeatherCard(destination: trip.destination),
                ],
              ),
            ),
            ChatScreen(tripId: trip.id),
          ],
        ),
      ),
    );
  }
}