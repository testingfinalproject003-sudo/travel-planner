class LocationPhotoModel {
  final String id;
  final String url;
  final String thumbUrl;
  final String fullUrl;
  final String description;
  final String photographerName;
  final String photographerUrl;
  final int width;
  final int height;
  final String source;

  LocationPhotoModel({
    required this.id,
    required this.url,
    required this.thumbUrl,
    required this.fullUrl,
    required this.description,
    required this.photographerName,
    required this.photographerUrl,
    required this.width,
    required this.height,
    required this.source,
  });

  factory LocationPhotoModel.fromMap(Map<String, dynamic> map) {
    return LocationPhotoModel(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
      thumbUrl: map['thumbUrl'] ?? '',
      fullUrl: map['fullUrl'] ?? '',
      description: map['description'] ?? '',
      photographerName: map['photographerName'] ?? '',
      photographerUrl: map['photographerUrl'] ?? '',
      width: map['width'] ?? 0,
      height: map['height'] ?? 0,
      source: map['source'] ?? 'placeholder',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'thumbUrl': thumbUrl,
      'fullUrl': fullUrl,
      'description': description,
      'photographerName': photographerName,
      'photographerUrl': photographerUrl,
      'width': width,
      'height': height,
      'source': source,
    };
  }

  double get aspectRatio => height > 0 ? width / height : 1.0;
  bool get isLandscape => width > height;
}