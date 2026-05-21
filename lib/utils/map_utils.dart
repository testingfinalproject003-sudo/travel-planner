import 'package:latlong2/latlong.dart';
import '../models/activity_model.dart';
import 'package:flutter_map/flutter_map.dart';
class MapUtils {
  static List<LatLng> getActivityLocations(List<ActivityModel> activities) {
    return activities
        .where((a) => a.locationLat != null && a.locationLng != null)
        .map((a) => LatLng(a.locationLat!, a.locationLng!))
        .toList();
  }

  static LatLng getCenterPoint(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(33.6844, 73.0479);

    double lat = 0, lng = 0;
    for (final point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  static double zoomForDistance(double distanceInDegrees) {
    // Approximate zoom based on lat/lng distance
    if (distanceInDegrees <= 0.001) return 18;
    if (distanceInDegrees <= 0.01) return 16;
    if (distanceInDegrees <= 0.05) return 14;
    if (distanceInDegrees <= 0.1) return 13;
    if (distanceInDegrees <= 0.5) return 12;
    if (distanceInDegrees <= 1.0) return 11;
    if (distanceInDegrees <= 5.0) return 10;
    if (distanceInDegrees <= 10.0) return 9;
    return 8;
  }

  static LatLngBounds getBoundsForPoints(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(
        const LatLng(33.6844, 73.0479),
        const LatLng(33.6844, 73.0479),
      );
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  static String estimateWalkingTime(double distanceKm) {
    final minutes = (distanceKm / 5) * 60; // 5 km/h walking speed
    if (minutes < 60) {
      return '${minutes.round()} min walk';
    }
    return '${(minutes / 60).toStringAsFixed(1)} hr walk';
  }

  static String getDirectionsUrl(LatLng destination, {LatLng? origin}) {
    final originStr = origin != null 
        ? '${origin.latitude},${origin.longitude}' 
        : '';
    final destStr = '${destination.latitude},${destination.longitude}';

    if (originStr.isNotEmpty) {
      return 'https://www.google.com/maps/dir/?api=1&origin=$originStr&destination=$destStr';
    }
    return 'https://www.google.com/maps/search/?api=1&query=$destStr';
  }
}