class PlaceModel {
  final String id;
  final String name;
  final String category;
  final String address;
  final double rating;
  final double distance;
  final double lat;
  final double lng;

  PlaceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.rating,
    required this.distance,
    required this.lat,
    required this.lng,
  });

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    double parsedRating = 0.0;
    if (map['rating'] != null) {
      parsedRating = (map['rating'] as num).toDouble();
    }

    String cat = 'Attraction';
    if (map['categories'] != null && (map['categories'] as List).isNotEmpty) {
      cat = map['categories'][0]['name'] ?? 'Attraction';
    }

    return PlaceModel(
      id: map['fsq_id'] ?? '',
      name: map['name'] ?? '',
      category: cat,
      address: map['location']?['formatted_address'] ?? 'No Address available',
      rating: parsedRating,
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
      lat: map['geocodes']?['main']?['latitude']?.toDouble() ?? 0.0,
      lng: map['geocodes']?['main']?['longitude']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'address': address,
      'rating': rating,
      'distance': distance,
      'lat': lat,
      'lng': lng,
    };
  }
}