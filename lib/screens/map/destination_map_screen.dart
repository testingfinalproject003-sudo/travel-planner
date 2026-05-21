import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';  // ✅ ADDED
import '../../services/location_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../utils/constants.dart';

class DestinationMapScreen extends StatefulWidget {
  final String destination;
  final double destinationLat;
  final double destinationLng;
  final String? startAddress;

  const DestinationMapScreen({
    super.key,
    required this.destination,
    required this.destinationLat,
    required this.destinationLng,
    this.startAddress,
  });

  @override
  State<DestinationMapScreen> createState() => _DestinationMapScreenState();
}

class _DestinationMapScreenState extends State<DestinationMapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  LatLng? _startPosition;
  String? _startAddress;
  double? _distance;
  bool _isLoading = true;
  String? _error;
  LatLng? _searchedLocation;
  String? _searchedName;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      bool hasPermission = await _locationService.checkPermission();
      if (!hasPermission) {
        setState(() {
          _error = 'Location permission denied. Please enable in settings.';
          _isLoading = false;
        });
        return;
      }

      final position = await _locationService.getCurrentPosition();
      final current = LatLng(position.latitude, position.longitude);
      final dest = LatLng(widget.destinationLat, widget.destinationLng);

      String startAddr = widget.startAddress ?? 
          await _locationService.getAddressFromCoords(position.latitude, position.longitude);

      final dist = _locationService.calculateDistance(current, dest);

      if (mounted) {
        setState(() {
          _startPosition = current;
          _startAddress = startAddr;
          _distance = dist;
          _isLoading = false;
        });
      }

      _fitBounds(current, dest);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _fitBounds(LatLng from, LatLng to) {
    final center = LatLng(
      (from.latitude + to.latitude) / 2,
      (from.longitude + to.longitude) / 2,
    );
    final dist = _locationService.calculateDistance(from, to);
    double zoom;
    if (dist < 1) {zoom = 14;
    }else if (dist < 5) {zoom = 12;
    }else if (dist < 20) {zoom = 10;
    }else if (dist < 100) {zoom = 8;
    }else{zoom = 6;}

    _mapController.move(center, zoom);
  }

  void _openDirections() async {
    if (_startPosition == null) return;
    final url = 'https://www.google.com/maps/dir/?api=1&origin=${_startPosition!.latitude},${_startPosition!.longitude}&destination=${widget.destinationLat},${widget.destinationLng}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() => _isSearching = true);
    
    try {
      final coords = await _locationService.getCoordsFromAddress(query.trim());
      if (coords != null && mounted) {
        setState(() {
          _searchedLocation = coords;
          _searchedName = query.trim();
          _isSearching = false;
        });
        _mapController.move(coords, 14);
      } else if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not found')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final destLatLng = LatLng(widget.destinationLat, widget.destinationLng);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.destination, style: const TextStyle(fontSize: 16)),
            if (_distance != null)
              Text(
                '${_locationService.formatDistance(_distance!)} away',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initialize,
            tooltip: 'Refresh location',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: destLatLng,
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: Constants.osmTileUrl,
                userAgentPackageName: Constants.osmUserAgent,
              ),
              PolylineLayer(
                polylines: [
                  if (_startPosition != null)
                    Polyline(
                      points: [_startPosition!, destLatLng],
                      color: AppColors.primary,
                      strokeWidth: 4,
                      borderStrokeWidth: 1,
                      borderColor: Colors.white,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: destLatLng,
                    width: 50,
                    height: 55,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'DEST',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.location_on, color: Colors.red, size: 36),
                      ],
                    ),
                  ),
                  if (_startPosition != null)
                    Marker(
                      point: _startPosition!,
                      width: 45,
                      height: 50,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'YOU',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.person_pin, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                  if (_searchedLocation != null)
                    Marker(
                      point: _searchedLocation!,
                      width: 45,
                      height: 50,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SEARCH',
                              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Icon(Icons.location_on, color: AppColors.gold, size: 32),
                        ],
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search location...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onSubmitted: _searchLocation,
                    ),
                  ),
                  if (_isSearching)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchedLocation = null;
                          _searchedName = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),

          if (_distance != null)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: _DistanceCard(
                distance: _distance!,
                destination: widget.destination,
                startAddress: _startAddress ?? 'Your Location',
                onDirections: _openDirections,
              ),
            ),

          if (_searchedLocation != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.gold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _searchedName ?? 'Selected Location',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, {
                            'name': _searchedName,
                            'lat': _searchedLocation!.latitude,
                            'lng': _searchedLocation!.longitude,
                          });
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Use This Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    SizedBox(height: 16),
                    Text(
                      'Getting your location...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          if (_error != null)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_off, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Location Error',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _initialize,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          await _locationService.openAppSettings();
                        },
                        child: const Text('Open Settings'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _startPosition != null
          ? FloatingActionButton.extended(
              onPressed: () => _mapController.move(_startPosition!, 15),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.my_location, color: Colors.white),
              label: const Text('My Location', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _DistanceCard extends StatelessWidget {
  final double distance;
  final String destination;
  final String startAddress;
  final VoidCallback onDirections;

  const _DistanceCard({
    required this.distance,
    required this.destination,
    required this.startAddress,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final locationService = LocationService();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.social_distance, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationService.formatDistance(distance),
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primary,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'Total Distance',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          Row(
            children: [
              Expanded(
                child: _LocationPoint(
                  label: 'FROM',
                  address: startAddress,
                  color: AppColors.primary,
                  icon: Icons.trip_origin,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Icon(Icons.arrow_forward, color: AppColors.primary, size: 20),
                    Text(
                      locationService.formatDistance(distance),
                      style: AppTextStyles.captionSmall.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _LocationPoint(
                  label: 'TO',
                  address: destination,
                  color: Colors.red,
                  icon: Icons.location_on,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onDirections,
              icon: const Icon(Icons.directions),
              label: const Text('Get Directions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPoint extends StatelessWidget {
  final String label;
  final String address;
  final Color color;
  final IconData icon;

  const _LocationPoint({
    required this.label,
    required this.address,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                address,
                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}