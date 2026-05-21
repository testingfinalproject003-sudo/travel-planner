import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../models/place_model.dart';
// import '../../providers/auth_provider.dart';
import '../../services/foursquare_service.dart';
import '../../services/location_service.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/trip/trip_plan_bottom_sheet.dart';
// import '../../navigation/app_router.dart';
import 'package:latlong2/latlong.dart';
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final FoursquareService _foursquareService = FoursquareService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  List<PlaceModel> _places = [];
  bool _isLoading = false;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _loadNearbyPlaces();
    } catch (e) {
      // Use default location
      _loadNearbyPlaces();
    }
  }

  Future<void> _loadNearbyPlaces() async {
    setState(() => _isLoading = true);
    try {
      final places = await _foursquareService.getNearbyPlaces(
        lat: _currentLocation?.latitude,
        lng: _currentLocation?.longitude,
      );
      setState(() => _places = places);
    } catch (e) {
      // Error handled in service
    }
    setState(() => _isLoading = false);
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      _loadNearbyPlaces();
      return;
    }
    setState(() => _isLoading = true);
    try {
      final places = await _foursquareService.getNearbyPlaces(
        lat: _currentLocation?.latitude,
        lng: _currentLocation?.longitude,
        query: query,
      );
      setState(() => _places = places);
    } catch (e) {
      // Error handled in service
    }
    setState(() => _isLoading = false);
  }

  void _onPlaceLongPress(PlaceModel place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TripPlanBottomSheet(
        source: TripPlanSource.explore,
        prefillDestination: place.name,
      ),
    );
  }

  void _onPlaceTap(PlaceModel place) {
    // Show place details dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(place.name, style: AppTextStyles.heading2),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (place.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    place.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 150,
                      color: AppColors.primaryMuted,
                      child: const Icon(Icons.image_not_supported, color: AppColors.textMuted),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.category, 'Category', place.category ?? 'Place'),
              if (place.rating != null)
                _buildDetailRow(Icons.star, 'Rating', '${place.rating!.toStringAsFixed(1)}/5'),
              if (place.distance != null)
                _buildDetailRow(Icons.social_distance, 'Distance', _locationService.formatDistance(place.distance!)),
              if (place.address != null && place.address!.isNotEmpty)
                _buildDetailRow(Icons.location_on, 'Address', place.address!),
              if (place.description != null && place.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('About', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 4),
                Text(place.description!, style: AppTextStyles.bodySmall),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _onPlaceLongPress(place);
            },
            icon: const Icon(Icons.add_location_alt, size: 18),
            label: const Text('Plan Trip Here'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(value, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Explore Places'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearbyPlaces,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                controller: _searchController,
                hintText: 'Search places nearby...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _loadNearbyPlaces();
                        },
                      )
                    : null,
                onSubmitted: _search,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: AppLoader())
                  : _places.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: AppColors.textMuted.withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              Text(
                                'No places found',
                                style: AppTextStyles.heading3.copyWith(color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try searching for a different location',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _places.length,
                          itemBuilder: (context, index) {
                            final place = _places[index];
                            return _PlaceCard(
                              place: place,
                              onTap: () => _onPlaceTap(place),
                              onLongPress: () => _onPlaceLongPress(place),
                              distance: place.distance,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final double? distance;

  const _PlaceCard({
    required this.place,
    required this.onTap,
    required this.onLongPress,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final locationService = LocationService();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (place.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusLg),
                  topRight: Radius.circular(AppDimensions.radiusLg),
                ),
                child: Image.network(
                  place.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 160,
                    color: AppColors.primaryMuted,
                    child: const Icon(Icons.image_not_supported, color: AppColors.textMuted, size: 40),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: AppTextStyles.heading3.copyWith(fontSize: 16),
                        ),
                      ),
                      if (place.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.gold, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              place.rating!.toStringAsFixed(1),
                              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (place.category != null)
                    Chip(
                      label: Text(place.category!),
                      backgroundColor: AppColors.primaryMuted,
                      labelStyle: const TextStyle(color: AppColors.primary, fontSize: 11),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  const SizedBox(height: 8),
                  if (place.description != null && place.description!.isNotEmpty)
                    Text(
                      place.description!,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (distance != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.social_distance, size: 14, color: AppColors.textMuted.withValues(alpha: 0.6)),
                        const SizedBox(width: 4),
                        Text(
                          locationService.formatDistance(distance!),
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Text(
                          'Long press to plan trip',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.primary.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}