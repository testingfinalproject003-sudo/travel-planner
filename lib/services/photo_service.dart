// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/location_photo_model.dart';
// import '../utils/constants.dart';

// class PhotoService {
//   static const String _unsplashKey = Constants.unsplashAccessKey;
//   static const String _pixabayKey = Constants.pixabayApiKey;

//   Future<List<LocationPhotoModel>> getLocationPhotos(
//     String locationName, {
//     int count = 10,
//   }) async {
//     // Try Unsplash first
//     final unsplashPhotos = await _fetchUnsplash(locationName, count);
//     if (unsplashPhotos.isNotEmpty) return unsplashPhotos;

//     // Fallback to Pixabay
//     final pixabayPhotos = await _fetchPixabay(locationName, count);
//     if (pixabayPhotos.isNotEmpty) return pixabayPhotos;

//     // Last fallback: placeholder
//     return _getPlaceholders(locationName, count);
//   }

//   Future<List<LocationPhotoModel>> getActivityPhotos(
//     String activityName,
//     String city, {
//     int count = 10,
//   }) async {
//     return getLocationPhotos('$activityName $city', count: count);
//   }

//   Future<List<LocationPhotoModel>> _fetchUnsplash(String query, int count) async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//           'https://api.unsplash.com/search/photos?query=$query&per_page=$count&orientation=landscape',
//         ),
//         headers: {'Authorization': 'Client-ID $_unsplashKey'},
//       );

//       if (response.statusCode != 200) return [];

//       final data = jsonDecode(response.body);
//       final results = data['results'] as List? ?? [];

//       return results.map((json) => _parseUnsplashPhoto(json)).toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   Future<List<LocationPhotoModel>> _fetchPixabay(String query, int count) async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//           'https://pixabay.com/api/?key=$_pixabayKey&q=$query&image_type=photo&orientation=horizontal&per_page=$count&safesearch=true',
//         ),
//       );

//       if (response.statusCode != 200) return [];

//       final data = jsonDecode(response.body);
//       final hits = data['hits'] as List? ?? [];

//       return hits.map((json) => _parsePixabayPhoto(json)).toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   LocationPhotoModel _parseUnsplashPhoto(Map<String, dynamic> json) {
//     return LocationPhotoModel(
//       id: json['id']?.toString() ?? '',
//       url: json['urls']?['regular'] ?? '',
//       thumbUrl: json['urls']?['thumb'] ?? '',
//       fullUrl: json['urls']?['full'] ?? '',
//       description: json['description'] ?? json['alt_description'] ?? '',
//       photographerName: json['user']?['name'] ?? 'Unknown',
//       photographerUrl: json['user']?['links']?['html'] ?? '',
//       width: json['width'] ?? 0,
//       height: json['height'] ?? 0,
//       source: 'unsplash',
//     );
//   }

//   LocationPhotoModel _parsePixabayPhoto(Map<String, dynamic> json) {
//     return LocationPhotoModel(
//       id: json['id']?.toString() ?? '',
//       url: json['webformatURL'] ?? '',
//       thumbUrl: json['previewURL'] ?? '',
//       fullUrl: json['largeImageURL'] ?? '',
//       description: json['tags'] ?? '',
//       photographerName: json['user'] ?? 'Unknown',
//       photographerUrl: '',
//       width: json['imageWidth'] ?? 0,
//       height: json['imageHeight'] ?? 0,
//       source: 'pixabay',
//     );
//   }

//   List<LocationPhotoModel> _getPlaceholders(String seed, int count) {
//     return List.generate(count, (i) => LocationPhotoModel(
//       id: 'placeholder_$i',
//       url: 'https://picsum.photos/seed/${seed}_$i/800/600',
//       thumbUrl: 'https://picsum.photos/seed/${seed}_$i/200/150',
//       fullUrl: 'https://picsum.photos/seed/${seed}_$i/1600/1200',
//       description: '$seed photo',
//       photographerName: 'Picsum',
//       photographerUrl: '',
//       width: 800,
//       height: 600,
//       source: 'placeholder',
//     ));
//   }
// }