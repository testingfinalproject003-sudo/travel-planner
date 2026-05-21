import 'package:flutter/material.dart';
import '../../models/trip_model.dart';
import '../../theme/app_colors.dart';
import '../../navigation/app_router.dart';
import '../trip/itinerary_screen.dart';
import '../../widgets/trip/weather_card.dart';
import '../chat/chat_screen.dart';

class TripDetailScreen extends StatelessWidget {
  final TripModel trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(trip.title),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
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
            _WeatherTab(destination: trip.destination),
            ChatScreen(
              chatId: trip.id,
              chatName: trip.destination,
              isTripChat: true,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(
            context,
            AppRouter.tripMap,
            arguments: trip,
          ),
          icon: const Icon(Icons.map),
          label: const Text('View Map'),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }
}

class _WeatherTab extends StatelessWidget {
  final String destination;

  const _WeatherTab({required this.destination});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeatherCard(city: destination, compact: false),
          const SizedBox(height: 24),
          Text(
            '7-Day Forecast',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 12),
          _ForecastList(city: destination),
        ],
      ),
    );
  }
}

class _ForecastList extends StatelessWidget {
  final String city;

  const _ForecastList({required this.city});

  @override
  Widget build(BuildContext context) {
    // Forecast will be loaded by WeatherService inside WeatherCard
    // This is a placeholder for extended forecast display
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Text(
          'Extended forecast loading...',
          style: TextStyle(color: AppColors.textMuted),
        ),
      ),
    );
  }
}