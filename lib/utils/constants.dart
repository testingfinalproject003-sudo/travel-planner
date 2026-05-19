class Constants {
  // API Keys — replace with real keys
  static const String openWeatherApiKey = '';
  // static const String unsplashAccessKey = 'YOUR_UNSPLASH_ACCESS_KEY';
  // static const String pixabayApiKey     = 'YOUR_PIXABAY_KEY';
  // // static const String foursquareApiKey  = 'YOUR_FOURSQUARE_KEY';
  // static const String geoDbApiKey       = 'YOUR_GEODB_KEY';
  static const String geoDbHost         = 'wft-geo-db.p.rapidapi.com';

  // App rules
  static const int minFriendsToCreateTrip = 1;
  static const int votesNeededToConfirm   = 2;
  static const int maxMessageHistory      = 100;
  static const int locationPhotosCount    = 12;

  // Map
  static const String osmTileUrl =
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmUserAgent = 'com.travelplanner.app';
  static const double defaultZoom  = 13.0;
  static const double defaultLat   = 33.6844; // Rawalpindi
  static const double defaultLng   = 73.0479;

  // Activity types
  static const List<String> activityTypes =
    ['visit', 'food', 'museum', 'nature', 'transport', 'other'];

  // Trip statuses
  static const List<String> tripStatuses =
    ['upcoming', 'active', 'past'];

  // Date rules
  static const int maxTripDurationDays  = 365;
  static const int maxFutureDaysAllowed = 730;

  // Network
  static const Duration requestTimeout = Duration(seconds: 10);
  static const int maxRetries = 3;
}