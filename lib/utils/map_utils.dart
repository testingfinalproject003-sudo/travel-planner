import 'package:latlong2/latlong.dart';
import '../models/activity_model.dart';
import 'package:flutter_map/flutter_map.dart';
class MapUtils {
  static LatLngBounds getBoundsForPoints(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(const LatLng(0, 0), const LatLng(0, 0));
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

    final padding = 0.01;
    return LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    );
  }

  static LatLng getCenterPoint(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);

    double sumLat = 0;
    double sumLng = 0;
    for (final point in points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }

  static String getDirectionsUrl(LatLng destination, {LatLng? origin}) {
    if (origin != null) {
      return 'https://www.google.com/maps/dir/${origin.latitude},${origin.longitude}/${destination.latitude},${destination.longitude}';
    }
    return 'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}';
  }

  static String estimateWalkingTime(double distanceKm) {
    const speedKmh = 5.0;
    final minutes = (distanceKm / speedKmh * 60).round();
    if (minutes < 1) return 'Less than 1 min walk';
    if (minutes < 60) return '$minutes min walk';
    final hrs = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hrs}h ${mins}m walk';
  }

  static String estimateDrivingTime(double distanceKm) {
    const speedKmh = 30.0;
    final minutes = (distanceKm / speedKmh * 60).round();
    if (minutes < 1) return 'Less than 1 min drive';
    if (minutes < 60) return '$minutes min drive';
    final hrs = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hrs}h ${mins}m drive';
  }

  static double zoomForDistance(double distanceKm) {
    if (distanceKm < 1) return 16;
    if (distanceKm < 5) return 14;
    if (distanceKm < 20) return 12;
    if (distanceKm < 100) return 10;
    return 8;
  }

  static List<LatLng> getActivityLocations(List<ActivityModel> activities) {
    return activities
        .where((a) => a.locationLat != null && a.locationLng != null)
        .map((a) => LatLng(a.locationLat!, a.locationLng!))
        .toList();
  }
}