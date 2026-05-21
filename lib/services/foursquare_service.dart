import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_model.dart';
import '../utils/constants.dart';
import 'location_service.dart';
import 'package:latlong2/latlong.dart';  // ✅ FIXED: Correct import

class FoursquareService {
  static const String _baseUrl = Constants.foursquareBaseUrl;
  static const String _apiKey = Constants.foursquareApiKey;
  final LocationService _locationService = LocationService();

  Future<List<PlaceModel>> getNearbyPlaces({
    double? lat,
    double? lng,
    String? query,
    int radius = Constants.foursquareSearchRadius,
    int limit = Constants.foursquareSearchLimit,
  }) async {
    try {
      // Get current location if not provided
      if (lat == null || lng == null) {
        try {
          final position = await _locationService.getCurrentPosition();
          lat = position.latitude;
          lng = position.longitude;
        } catch (e) {
          // Use default location
          lat = Constants.defaultLat;
          lng = Constants.defaultLng;
        }
      }

      final uri = Uri.parse('$_baseUrl/places/search').replace(queryParameters: {
        'll': '$lat,$lng',
        'radius': radius.toString(),
        'limit': limit.toString(),
        'sort': 'POPULARITY',
        if (query != null && query.isNotEmpty) 'query': query,
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': _apiKey,
          'Accept': 'application/json',
        },
      ).timeout(Constants.requestTimeout);

      if (response.statusCode != 200) {
        throw Exception('Foursquare API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? [];

      return results.map((json) => _parsePlace(json, lat!, lng!)).toList();
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockPlaces();
    }
  }

  Future<PlaceModel?> getPlaceDetails(String fsqId) async {
    try {
      final uri = Uri.parse('$_baseUrl/places/$fsqId');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': _apiKey,
          'Accept': 'application/json',
        },
      ).timeout(Constants.requestTimeout);

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      return _parsePlaceDetail(data);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getPlacePhoto(String fsqId) async {
    try {
      final uri = Uri.parse('$_baseUrl/places/$fsqId/photos').replace(queryParameters: {
        'limit': '1',
        'sort': 'popular',
      });
      final response = await http.get(
        uri,
        headers: {
          'Authorization': _apiKey,
          'Accept': 'application/json',
        },
      ).timeout(Constants.requestTimeout);

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final photos = data as List? ?? [];
      if (photos.isEmpty) return null;

      final photo = photos.first;
      final prefix = photo['prefix'] ?? '';
      final suffix = photo['suffix'] ?? '';
      return '${prefix}original$suffix';
    } catch (e) {
      return null;
    }
  }

  PlaceModel _parsePlace(Map<String, dynamic> json, double userLat, double userLng) {
    final location = json['location'] ?? {};
    final geocodes = json['geocodes']?['main'] ?? {};
    final categories = json['categories'] as List? ?? [];
    final category = categories.isNotEmpty ? categories.first['name'] : 'Place';
    final icon = categories.isNotEmpty ? categories.first['icon'] : null;

    final placeLat = geocodes['latitude']?.toDouble() ?? userLat;
    final placeLng = geocodes['longitude']?.toDouble() ?? userLng;

    // ✅ FIXED: Use LatLng directly (not latlong2.LatLng)
    final distance = _locationService.calculateDistance(
      LatLng(userLat, userLng),
      LatLng(placeLat, placeLng),
    );

    // Build photo URL from category icon
    String? imageUrl;
    if (icon != null) {
      final prefix = icon['prefix'] ?? '';
      final suffix = icon['suffix'] ?? '';
      imageUrl = '${prefix}64$suffix';
    }

    return PlaceModel(
      id: json['fsq_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown Place',
      description: json['description'] ?? location['formatted_address'] ?? '',
      imageUrl: imageUrl,
      lat: placeLat,
      lng: placeLng,
      category: category,
      rating: (json['rating']?.toDouble() ?? 0.0) / 2, // Foursquare rating is 0-10, convert to 0-5
      address: location['formatted_address'] ?? location['address'] ?? '',
      distance: distance,
    );
  }

  PlaceModel _parsePlaceDetail(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    final categories = json['categories'] as List? ?? [];
    final category = categories.isNotEmpty ? categories.first['name'] : 'Place';

    return PlaceModel(
      id: json['fsq_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown Place',
      description: json['description'] ?? location['formatted_address'] ?? '',
      lat: json['geocodes']?['main']?['latitude']?.toDouble(),
      lng: json['geocodes']?['main']?['longitude']?.toDouble(),
      category: category,
      rating: (json['rating']?.toDouble() ?? 0.0) / 2,
      address: location['formatted_address'] ?? location['address'] ?? '',
    );
  }

  List<PlaceModel> _getMockPlaces() {
    return [
      PlaceModel(
        id: 'p1',
        name: 'Badshahi Mosque',
        description: 'Mughal-era imperial mosque in Lahore, one of the largest in the world',
        category: 'visit',
        rating: 4.9,
        lat: 31.5882,
        lng: 74.3104,
      ),
      PlaceModel(
        id: 'p2',
        name: 'Faisal Mosque',
        description: 'Iconic modern mosque in Islamabad, designed by Turkish architect',
        category: 'visit',
        rating: 4.8,
        lat: 33.7294,
        lng: 73.0372,
      ),
      PlaceModel(
        id: 'p3',
        name: 'Hunza Valley',
        description: 'Breathtaking mountain valley in Gilgit-Baltistan with snow-capped peaks',
        category: 'nature',
        rating: 4.9,
        lat: 36.3167,
        lng: 74.6500,
      ),
      PlaceModel(
        id: 'p4',
        name: 'Mohenjo-daro',
        description: 'Ancient Indus Valley Civilization archaeological site',
        category: 'museum',
        rating: 4.7,
        lat: 27.3294,
        lng: 68.1389,
      ),
      PlaceModel(
        id: 'p5',
        name: 'Deosai National Park',
        description: 'Second highest plateau in the world, known as Land of Giants',
        category: 'nature',
        rating: 4.8,
        lat: 34.9606,
        lng: 75.4150,
      ),
    ];
  }
}