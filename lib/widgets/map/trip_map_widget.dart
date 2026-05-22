import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../models/activity_model.dart';
// import '../../utils/map_utils.dart';
// import 'location_marker.dart';

class TripMapWidget extends StatelessWidget {
  final List<ActivityModel> activities;
  final double height;
  final VoidCallback? onExpand;

  const TripMapWidget({
    super.key,
    required this.activities,
    this.height = 200,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    // ActivityModel mein lat/lng nahi hain, sirf locationName hai
    // Map pe locations dikhana possible nahi bina coordinates ke
    // final hasLocations = false; 

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(Constants.defaultLat, Constants.defaultLng),
              initialZoom: 12,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: Constants.osmTileUrl,
                userAgentPackageName: Constants.osmUserAgent,
              ),
            ],
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha:0.9),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, color: AppColors.textMuted.withValues(alpha:0.6), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'No map locations available',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onExpand,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha:0.95),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.08),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_full, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Full map',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Constants {
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmUserAgent = 'com.travelplanner.app';
  static const double defaultLat = 33.6844;
  static const double defaultLng = 73.0479;
}