import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../utils/constants.dart';

class MapScreen extends StatefulWidget {
  final String destination;
  final double destinationLat;
  final double destinationLng;
  final String? tripId;

  const MapScreen({
    super.key,
    required this.destination,
    required this.destinationLat,
    required this.destinationLng,
    this.tripId,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  
  LatLng? _currentPosition;
  double? _distance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      final currentLatLng = LatLng(position.latitude, position.longitude);
      final destLatLng = LatLng(widget.destinationLat, widget.destinationLng);
      
      final distance = _locationService.calculateDistance(currentLatLng, destLatLng);
      
      setState(() {
        _currentPosition = currentLatLng;
        _distance = distance;
        _isLoading = false;
      });
      
      // Fit bounds to show both points
      _fitBounds(currentLatLng, destLatLng);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: $e')),
        );
      }
    }
  }

  void _fitBounds(LatLng from, LatLng to) {
    // Simple center and zoom calculation
    final center = LatLng(
      (from.latitude + to.latitude) / 2,
      (from.longitude + to.longitude) / 2,
    );
    
    final distance = _locationService.calculateDistance(from, to);
    double zoom = Constants.defaultZoom;
    
    if (distance > 1000){ zoom = 4;
    }else if (distance > 500) {zoom = 5;
    }else if (distance > 200) {zoom = 6;
    }else if (distance > 100) {zoom = 7;
     } else if (distance > 50) {zoom = 8;
     }else if (distance > 20) {zoom = 9;
     }else if (distance > 10) {zoom = 10;
     }else {zoom = 11;}
    
    _mapController.move(center, zoom);
  }

  @override
  Widget build(BuildContext context) {
    final destinationLatLng = LatLng(widget.destinationLat, widget.destinationLng);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.destination),
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.textMain,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: destinationLatLng,
              initialZoom: Constants.defaultZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: Constants.osmTileUrl,
                userAgentPackageName: Constants.osmUserAgent,
              ),
              MarkerLayer(
                markers: [
                  // Destination Marker
                  Marker(
                    point: destinationLatLng,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  // Current Location Marker
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.person_pin,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
              // Distance Line
              if (_currentPosition != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_currentPosition!, destinationLatLng],
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ],
                ),
            ],
          ),
          
          // Distance Card
          if (_distance != null)
            Positioned(
              top: AppDimensions.lg,
              left: AppDimensions.lg,
              right: AppDimensions.lg,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          ),
                          child: const Icon(Icons.social_distance, color: AppColors.primary),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Distance to ${widget.destination}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                _locationService.formatDistance(_distance!),
                                style: AppTextStyles.heading2.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Row(
                      children: [
                        Expanded(
                          child: _buildLocationChip(
                            'Your Location',
                            '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        const Icon(Icons.arrow_forward, color: AppColors.textMuted),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: _buildLocationChip(
                            'Destination',
                            widget.destination,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          // Loading
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha:0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _initializeLocation,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.my_location, color: AppColors.white),
      ),
    );
  }

  Widget _buildLocationChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.captionSmall.copyWith(color: color)),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMain,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}