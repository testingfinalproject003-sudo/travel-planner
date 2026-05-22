class Constants {
  // API Keys — replace with real keys
  static const String openWeatherApiKey = '';
  static const String geoDbHost = '';
  
  // Foursquare Places API
  static const String foursquareApiKey = ''; // Replace with real key
  static const String foursquareBaseUrl = 'https://api.foursquare.com/v3';
  
  // OpenRouter AI API
  static const String openRouterApiKey = ''; // Replace with real key
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String openRouterModel = 'openai/gpt-4o-mini'; // Uses free tier models

  // App rules
  static const int minFriendsToCreateTrip = 1;
  static const int votesNeededToConfirm = 2;
  static const int maxMessageHistory = 100;
  static const int locationPhotosCount = 12;

  // Map
  static const String osmTileUrl =
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmUserAgent = 'com.travelplanner.app';
  static const double defaultZoom = 13.0;
  static const double defaultLat = 33.6844; // Rawalpindi
  static const double defaultLng = 73.0479;

  // Activity types
  static const List<String> activityTypes =
    ['visit', 'food', 'museum', 'nature', 'transport', 'other'];

  // Trip statuses
  static const List<String> tripStatuses =
    ['upcoming', 'active', 'past'];

  // Date rules
  static const int maxTripDurationDays = 365;
  static const int maxFutureDaysAllowed = 730;

  // Network
  static const Duration requestTimeout = Duration(seconds: 10);
  static const int maxRetries = 3;
  
  // Foursquare
  static const int foursquareSearchRadius = 5000; // meters
  static const int foursquareSearchLimit = 20;
}