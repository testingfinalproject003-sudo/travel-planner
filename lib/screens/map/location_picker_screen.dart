import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../providers/map_provider.dart';
import '../../services/location_service.dart';
import '../../services/explore_service.dart';
import '../../widgets/map/location_marker.dart';
import '../../utils/constants.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _pickedLocation;
  String _pickedName = '';
  final List<Map<String, dynamic>> _searchSuggestions = [];
  bool _isSearching = false;
  final LatLng _defaultCenter = const LatLng(33.6844, 73.0479);
  final LocationService _locationService = LocationService();
  final ExploreService _exploreService = ExploreService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MapProvider>().initCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onMapTap(TapPosition tapPosition, LatLng latLng) async {
    setState(() => _pickedLocation = latLng);
    final address = await _locationService.getAddressFromCoords(
      latLng.latitude,
      latLng.longitude,
    );
    if (!mounted) return;
    setState(() => _pickedName = address);
    context.read<MapProvider>().selectLocation(latLng, address);
  }

  Future<void> _searchLocation(String query) async {
    if (query.length < 2) {
      if (mounted) {
        setState(() {
          _searchSuggestions.clear();
          _isSearching = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _isSearching = true);
    final results = await _exploreService.searchCities(query);
    if (!mounted) return;
    setState(() {
      _searchSuggestions.clear();
      _searchSuggestions.addAll(results);
      _isSearching = false;
    });
  }

  void _selectSuggestion(Map<String, dynamic> suggestion) {
    final lat = suggestion['lat'] as double;
    final lng = suggestion['lng'] as double;
    final name = '${suggestion['name']}, ${suggestion['country']}';
    final latLng = LatLng(lat, lng);

    setState(() {
      _pickedLocation = latLng;
      _pickedName = name;
      _searchSuggestions.clear();
      _searchController.text = name;
    });

    _mapController.move(latLng, 12);
    context.read<MapProvider>().selectLocation(latLng, name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick location'),
        actions: [
          TextButton(
            onPressed: _pickedLocation != null
                ? () {
                    Navigator.pop(context, {
                      'name': _pickedName,
                      'lat': _pickedLocation!.latitude,
                      'lng': _pickedLocation!.longitude,
                    });
                  }
                : null,
            child: Text(
              'Confirm',
              style: TextStyle(
                color: _pickedLocation != null ? AppColors.white : AppColors.white.withValues(alpha:0.5),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 12,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: Constants.osmTileUrl,
                userAgentPackageName: Constants.osmUserAgent,
              ),
              Consumer<MapProvider>(
                builder: (context, provider, _) {
                  if (provider.currentLocation == null) return const SizedBox.shrink();
                  return MarkerLayer(
                    markers: [
                      Marker(
                        point: provider.currentLocation!,
                        width: 28,
                        height: 28,
                        child: const Icon(Icons.my_location, color: AppColors.primary, size: 28),
                      ),
                    ],
                  );
                },
              ),
              if (_pickedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickedLocation!,
                      width: 40,
                      height: 50,
                      child: LocationMarker(
                        name: _pickedName,
                        isSelected: true,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search city...',
                      hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha:0.6)),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                      suffixIcon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_searchController.text == value) {
                          _searchLocation(value);
                        }
                      });
                    },
                  ),
                ),
                if (_searchSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchSuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _searchSuggestions[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_city, color: AppColors.textMuted, size: 20),
                          title: Text(suggestion['name']),
                          subtitle: Text(suggestion['country']),
                          onTap: () => _selectSuggestion(suggestion),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (_pickedLocation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_pin, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _pickedName,
                                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${_pickedLocation!.latitude.toStringAsFixed(4)}, ${_pickedLocation!.longitude.toStringAsFixed(4)}',
                                  style: AppTextStyles.captionSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Consumer<MapProvider>(
                        builder: (context, provider, _) {
                          if (provider.currentLocation == null) return const SizedBox.shrink();
                          final distance = provider.getDistanceFromCurrent(_pickedLocation!);
                          if (distance < 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Distance from you: ${provider.formatDistanceFromCurrent(_pickedLocation!)}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, {
                              'name': _pickedName,
                              'lat': _pickedLocation!.latitude,
                              'lng': _pickedLocation!.longitude,
                            });
                          },
                          child: const Text('Confirm this location'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: _pickedLocation != null ? 200 : 32,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () {
                final current = context.read<MapProvider>().currentLocation;
                if (current != null) {
                  _mapController.move(current, 14);
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}