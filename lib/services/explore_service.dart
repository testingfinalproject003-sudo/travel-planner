import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/place_model.dart';

class ExploreService {
  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse('${Constants.geoDbBaseUrl}/places?namePrefix=${Uri.encodeComponent(query)}&types=CITY&limit=5');

    try {
      final response = await http.get(url, headers: {
        'X-RapidAPI-Key': Constants.geoDbApiKey,
        'X-RapidAPI-Host': 'wft-geo-db.p.rapidapi.com'
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List items = data['data'] ?? [];
        return items.map((city) => {
          'city': city['city'] ?? '',
          'country': city['country'] ?? '',
          'countryCode': city['countryCode'] ?? '',
          'latitude': city['latitude']?.toDouble() ?? 0.0,
          'longitude': city['longitude']?.toDouble() ?? 0.0
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<PlaceModel>> getNearbyPlaces(double lat, double lng) async {
    if (lat == 0.0 && lng == 0.0) return [];

    final url = Uri.parse('${Constants.foursquareBaseUrl}/places/search?ll=$lat,$lng&radius=5000&limit=15');

    try {
      final response = await http.get(url, headers: {
        'Authorization': Constants.foursquareApiKey,
        'accept': 'application/json'
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results.map((place) => PlaceModel.fromMap(place)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}