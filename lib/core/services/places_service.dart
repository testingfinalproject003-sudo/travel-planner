import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_model.dart';
import '../constants/api_keys.dart';

class PlacesService {
  // Foursquare API v3
  static const String foursquareBaseUrl = 'https://api.foursquare.com/v3/places';
  
  // Google Places API (fallback)
  static const String googleBaseUrl = 'https://maps.googleapis.com/maps/api/place';

  Future<List<PlaceModel>> searchPlaces({
    required String query,
    double? lat,
    double? lon,
    int limit = 20,
  }) async {
    try {
      // Try Foursquare first
      return await _searchFoursquare(query: query, lat: lat, lon: lon, limit: limit);
    } catch (e) {
      // Fallback to Google Places if Foursquare fails
      if (ApiKeys.googlePlaces != 'YOUR_GOOGLE_PLACES_API_KEY') {
        return await _searchGooglePlaces(query: query, lat: lat, lon: lon);
      }
      rethrow;
    }
  }

  Future<List<PlaceModel>> _searchFoursquare({
    required String query,
    double? lat,
    double? lon,
    int limit = 20,
  }) async {
    String url = '$foursquareBaseUrl/search?query=$query&limit=$limit';
    if (lat != null && lon != null) {
      url += '&ll=$lat,$lon';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': ApiKeys.foursquareClientId,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      return results.map((e) => PlaceModel.fromFoursquare(e)).toList();
    } else {
      throw Exception('Foursquare API error: ${response.statusCode}');
    }
  }

  Future<List<PlaceModel>> _searchGooglePlaces({
    required String query,
    double? lat,
    double? lon,
  }) async {
    String url = '$googleBaseUrl/textsearch/json?query=$query&key=${ApiKeys.googlePlaces}';
    if (lat != null && lon != null) {
      url += '&location=$lat,$lon&radius=50000';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      return results.map((e) => PlaceModel.fromGoogle(e)).toList();
    } else {
      throw Exception('Google Places API error: ${response.statusCode}');
    }
  }

  Future<List<PlaceModel>> getNearbyPlaces({
    required double lat,
    required double lon,
    String? category,
    int radius = 5000,
    int limit = 20,
  }) async {
    String url = '$foursquareBaseUrl/search?ll=$lat,$lon&radius=$radius&limit=$limit';
    if (category != null) {
      url += '&categories=$category';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': ApiKeys.foursquareClientId,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      return results.map((e) => PlaceModel.fromFoursquare(e)).toList();
    } else {
      throw Exception('Failed to get nearby places: ${response.statusCode}');
    }
  }

  Future<PlaceModel?> getPlaceDetails(String placeId) async {
    final url = '$foursquareBaseUrl/$placeId';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': ApiKeys.foursquareClientId,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PlaceModel.fromFoursquare(data);
    }
    return null;
  }

  Future<List<PlaceModel>> getPopularDestinations() async {
    // Return popular destinations with descriptions
    final popularPlaces = [
      {
        'fsq_id': 'paris',
        'name': 'Paris, France',
        'description': 'The City of Light, famous for the Eiffel Tower, Louvre Museum, and romantic ambiance.',
        'famous_for': 'Eiffel Tower, Louvre, Notre-Dame, Fashion, Cuisine',
        'geocodes': {'main': {'latitude': 48.8566, 'longitude': 2.3522}},
        'photos': ['https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400'],
      },
      {
        'fsq_id': 'tokyo',
        'name': 'Tokyo, Japan',
        'description': 'A vibrant metropolis blending ancient traditions with cutting-edge technology.',
        'famous_for': 'Shibuya Crossing, Temples, Anime, Sushi, Technology',
        'geocodes': {'main': {'latitude': 35.6762, 'longitude': 139.6503}},
        'photos': ['https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400'],
      },
      {
        'fsq_id': 'dubai',
        'name': 'Dubai, UAE',
        'description': 'A futuristic city known for luxury shopping, ultramodern architecture, and vibrant nightlife.',
        'famous_for': 'Burj Khalifa, Palm Jumeirah, Luxury Shopping, Desert Safari',
        'geocodes': {'main': {'latitude': 25.2048, 'longitude': 55.2708}},
        'photos': ['https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400'],
      },
      {
        'fsq_id': 'bali',
        'name': 'Bali, Indonesia',
        'description': 'A tropical paradise with stunning beaches, lush rice terraces, and spiritual temples.',
        'famous_for': 'Ubud, Tanah Lot, Rice Terraces, Surfing, Yoga',
        'geocodes': {'main': {'latitude': -8.4095, 'longitude': 115.1889}},
        'photos': ['https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400'],
      },
      {
        'fsq_id': 'newyork',
        'name': 'New York City, USA',
        'description': 'The city that never sleeps, featuring iconic landmarks and diverse culture.',
        'famous_for': 'Times Square, Central Park, Statue of Liberty, Broadway',
        'geocodes': {'main': {'latitude': 40.7128, 'longitude': -74.0060}},
        'photos': ['https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=400'],
      },
      {
        'fsq_id': 'rome',
        'name': 'Rome, Italy',
        'description': 'The Eternal City with ancient ruins, Renaissance art, and world-class cuisine.',
        'famous_for': 'Colosseum, Vatican, Trevi Fountain, Pasta, Gelato',
        'geocodes': {'main': {'latitude': 41.9028, 'longitude': 12.4964}},
        'photos': ['https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=400'],
      },
    ];

    return popularPlaces.map((e) => PlaceModel.fromFoursquare(e)).toList();
  }
}