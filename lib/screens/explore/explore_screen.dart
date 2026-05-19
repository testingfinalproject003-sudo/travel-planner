import 'package:flutter/material.dart';
import '../../services/explore_service.dart';
import '../../models/place_model.dart';
import '../../widgets/common/app_card.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ExploreService _exploreService = ExploreService();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _cities = [];
  List<PlaceModel> _places = [];
  bool _loading = false;

  void _search(String query) async {
    if (query.isEmpty) return;
    setState(() => _loading = true);
    final results = await _exploreService.searchCities(query);
    setState(() {
      _cities = results;
      _loading = false;
    });
  }

  void _fetchPlaces(double lat, double lng) async {
    setState(() => _loading = true);
    final results = await _exploreService.getNearbyPlaces(lat, lng);
    setState(() {
      _places = results;
      _cities = [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Locations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search city...',
                suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: () => _search(_searchController.text)),
              ),
              onSubmitted: _search,
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: _cities.isNotEmpty
                ? ListView.builder(
              itemCount: _cities.length,
              itemBuilder: (context, index) {
                final c = _cities[index];
                return ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text('${c['city']}, ${c['country']}'),
                  onTap: () => _fetchPlaces(c['latitude'], c['longitude']),
                );
              },
            )
                : ListView.builder(
              itemCount: _places.length,
              itemBuilder: (context, index) {
                final p = _places[index];
                return AppCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(p.name, style: AppTextStyles.heading3),
                    subtitle: Text('${p.category} • ${(p.distance / 1000).toStringAsFixed(1)} km away'),
                    trailing: const Icon(Icons.star, color: AppColors.gold),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}