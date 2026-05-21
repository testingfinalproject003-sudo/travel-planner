import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_model.dart';
import '../utils/constants.dart';

class ExploreService {
  static const String _geoDbHost = Constants.geoDbHost;

  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.length < 2) return [];

    try {
      final response = await http.get(
        Uri.parse(
          'https://$_geoDbHost/v1/geo/cities?namePrefix=$query&limit=10&offset=0',
        ),
        headers: {
          'X-RapidAPI-Host': _geoDbHost,
        },
      );

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final cities = data['data'] as List? ?? [];

      return cities.map((c) => {
        'name': c['city'] ?? '',
        'country': c['country'] ?? '',
        'lat': c['latitude']?.toDouble() ?? 0.0,
        'lng': c['longitude']?.toDouble() ?? 0.0,
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PlaceModel>> searchPlaces(String query, {double? lat, double? lng, String? city}) async {
    return [
      PlaceModel(
        id: '1',
        name: '$query Landmark',
        description: 'A popular destination',
        category: 'visit',
        rating: 4.5,
      ),
      PlaceModel(
        id: '2',
        name: '$query Restaurant',
        description: 'Great food and atmosphere',
        category: 'food',
        rating: 4.2,
      ),
    ];
  }

  Future<List<PlaceModel>> getPopularPlaces({double? lat, double? lng}) async {
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
      PlaceModel(
        id: 'p6',
        name: 'Lahore Fort',
        description: 'UNESCO World Heritage Site, magnificent Mughal fortress',
        category: 'visit',
        rating: 4.7,
        lat: 31.5880,
        lng: 74.3158,
      ),
      PlaceModel(
        id: 'p7',
        name: 'Naran Valley',
        description: 'Picturesque valley in Kaghan with lakes and mountain views',
        category: 'nature',
        rating: 4.6,
        lat: 34.9070,
        lng: 73.6500,
      ),
      PlaceModel(
        id: 'p8',
        name: 'Taxila Museum',
        description: 'Ancient Gandhara civilization artifacts and Buddhist relics',
        category: 'museum',
        rating: 4.5,
        lat: 33.7445,
        lng: 72.7861,
      ),
      PlaceModel(
        id: 'p9',
        name: 'Skardu',
        description: 'Gateway to K2, beautiful lakes and desert mountains',
        category: 'nature',
        rating: 4.8,
        lat: 35.2971,
        lng: 75.4710,
      ),
      PlaceModel(
        id: 'p10',
        name: 'Wazir Khan Mosque',
        description: '17th century mosque famous for intricate tile work',
        category: 'visit',
        rating: 4.6,
        lat: 31.5831,
        lng: 74.3230,
      ),
    ];
  }
}