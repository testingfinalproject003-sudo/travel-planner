class PlaceModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final double? lat;
  final double? lng;
  final String? category;
  final double? rating;
  final String? address;
  final double? distance;

  PlaceModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.lat,
    this.lng,
    this.category,
    this.rating,
    this.address,
    this.distance,
  });

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      lat: map['lat']?.toDouble(),
      lng: map['lng']?.toDouble(),
      category: map['category'],
      rating: map['rating']?.toDouble(),
      address: map['address'],
      distance: map['distance']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'lat': lat,
      'lng': lng,
      'category': category,
      'rating': rating,
      'address': address,
      'distance': distance,
    };
  }
}