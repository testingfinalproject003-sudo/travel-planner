import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../models/trip_model.dart';
import '../../models/activity_model.dart';
import '../../providers/trip_provider.dart';
import '../../services/location_service.dart';
import '../../utils/map_utils.dart';
import '../../utils/constants.dart';
import '../../widgets/map/location_marker.dart';

class TripMapScreen extends StatefulWidget {
  final TripModel trip;

  const TripMapScreen({super.key, required this.trip});

  @override
  State<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  final MapController _mapController = MapController();
  List<ActivityModel> _activities = [];
  ActivityModel? _selectedActivity;
  LatLng? _currentLocation;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (mounted) {
        setState(() => _currentLocation = LatLng(position.latitude, position.longitude));
      }
    } catch (e) {
      // Location not available
    }

    if (!mounted) return;
    context.read<TripProvider>().getActivities(widget.trip.id).listen((activities) {
      if (mounted) {
        setState(() => _activities = activities.where((a) => a.locationLat != null).toList());
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationActivities = _activities.where((a) => a.locationLat != null).toList();
    final locations = MapUtils.getActivityLocations(locationActivities);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.trip.title, style: const TextStyle(fontSize: 16)),
            const Text('Map view', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: locations.isNotEmpty
                  ? MapUtils.getCenterPoint(locations)
                  : const LatLng(Constants.defaultLat, Constants.defaultLng),
              initialZoom: locations.isNotEmpty ? 12 : 10,
            ),
            children: [
              TileLayer(
                urlTemplate: Constants.osmTileUrl,
                userAgentPackageName: Constants.osmUserAgent,
              ),
              if (locations.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: locations,
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: locationActivities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;
                  return Marker(
                    point: LatLng(activity.locationLat!, activity.locationLng!),
                    width: 44,
                    height: 55,
                    child: LocationMarker(
                      name: activity.name,
                      color: activity.typeColor,
                      number: index + 1,
                      isSelected: _selectedActivity?.id == activity.id,
                      onTap: () => setState(() => _selectedActivity = activity),
                    ),
                  );
                }).toList(),
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 16,
                      height: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_selectedActivity != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _ActivityBottomSheet(
                activity: _selectedActivity!,
                currentLocation: _currentLocation,
                onClose: () => setState(() => _selectedActivity = null),
              ),
            ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha:0.1), blurRadius: 4),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    ),
                  ),
                  const Divider(height: 1),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    ),
                  ),
                  const Divider(height: 1),
                  IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: () {
                      if (_currentLocation != null) {
                        _mapController.move(_currentLocation!, 14);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: locationActivities.isNotEmpty
          ? Container(
              height: 60,
              color: AppColors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                itemCount: locationActivities.length,
                itemBuilder: (context, index) {
                  final activity = locationActivities[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: CircleAvatar(
                        backgroundColor: activity.typeColor,
                        radius: 10,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: AppColors.white, fontSize: 10),
                        ),
                      ),
                      label: Text(
                        activity.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () {
                        _mapController.move(
                          LatLng(activity.locationLat!, activity.locationLng!),
                          15,
                        );
                        setState(() => _selectedActivity = activity);
                      },
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }
}

class _ActivityBottomSheet extends StatelessWidget {
  final ActivityModel activity;
  final LatLng? currentLocation;
  final VoidCallback onClose;

  const _ActivityBottomSheet({
    required this.activity,
    this.currentLocation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    double? distance;
    if (currentLocation != null && activity.locationLat != null && activity.locationLng != null) {
      distance = LocationService().calculateDistance(
        currentLocation!,
        LatLng(activity.locationLat!, activity.locationLng!),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    activity.name,
                    style: AppTextStyles.heading3.copyWith(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: activity.typeColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    activity.type,
                    style: TextStyle(color: activity.typeColor, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                if (distance != null) ...[
                  Icon(Icons.directions_walk, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    MapUtils.estimateWalkingTime(distance),
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (activity.locationLat != null && activity.locationLng != null) {
                    final url = MapUtils.getDirectionsUrl(
                      LatLng(activity.locationLat!, activity.locationLng!),
                      origin: currentLocation,
                    );
                    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('Get directions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}