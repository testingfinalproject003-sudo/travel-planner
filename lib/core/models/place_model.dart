class PlaceModel {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final int? reviewCount;
  final String? photoUrl;
  final String? category;
  final String? phone;
  final String? website;
  final double? distance;
  final List<String>? photos;
  final String? famousFor;

  PlaceModel({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.rating,
    this.reviewCount,
    this.photoUrl,
    this.category,
    this.phone,
    this.website,
    this.distance,
    this.photos,
    this.famousFor,
  });

  factory PlaceModel.fromFoursquare(Map<String, dynamic> data) {
    final location = data['location'] ?? {};
    final categories = data['categories'] ?? [];
    final photos = data['photos'] ?? [];
    
    return PlaceModel(
      id: data['fsq_id'] ?? data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      address: location['formatted_address'] ?? location['address'],
      latitude: data['geocodes']?['main']?['latitude']?.toDouble() ??
                location['lat']?.toDouble(),
      longitude: data['geocodes']?['main']?['longitude']?.toDouble() ??
                 location['lng']?.toDouble(),
      rating: data['rating']?.toDouble(),
      reviewCount: data['stats']?['total_ratings'],
      photoUrl: photos.isNotEmpty ? photos[0] : null,
      category: categories.isNotEmpty ? categories[0]['name'] : null,
      phone: data['tel'],
      website: data['website'],
      distance: data['distance']?.toDouble(),
      photos: photos.isNotEmpty ? List<String>.from(photos) : null,
      famousFor: data['famous_for'],
    );
  }

  factory PlaceModel.fromGoogle(Map<String, dynamic> data) {
    final photos = data['photos'] ?? [];
    final photoReference = photos.isNotEmpty ? photos[0]['photo_reference'] : null;
    
    return PlaceModel(
      id: data['place_id'] ?? '',
      name: data['name'] ?? '',
      description: data['editorial_summary']?['overview'],
      address: data['formatted_address'] ?? data['vicinity'],
      latitude: data['geometry']?['location']?['lat']?.toDouble(),
      longitude: data['geometry']?['location']?['lng']?.toDouble(),
      rating: data['rating']?.toDouble(),
      reviewCount: data['user_ratings_total'],
      photoUrl: photoReference != null 
          ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=YOUR_API_KEY'
          : null,
      category: data['types']?.isNotEmpty == true ? data['types'][0] : null,
      phone: data['formatted_phone_number'],
      website: data['website'],
      distance: null,
      photos: null,
      famousFor: data['famous_for'],
    );
  }
}