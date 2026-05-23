class WeatherModel {
  final String city;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String iconCode;
  final DateTime date;
  final List<WeatherForecastModel>? forecast;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.iconCode,
    required this.date,
    this.forecast,
  });

  factory WeatherModel.fromOpenWeather(Map<String, dynamic> data) {
    final main = data['main'] ?? {};
    final weather = (data['weather'] as List<dynamic>?) ?? [];
    final wind = data['wind'] ?? {};
    
    return WeatherModel(
      city: data['name'] ?? '',
      temperature: (main['temp'] ?? 0).toDouble(),
      feelsLike: (main['feels_like'] ?? 0).toDouble(),
      humidity: main['humidity'] ?? 0,
      windSpeed: (wind['speed'] ?? 0).toDouble(),
      description: weather.isNotEmpty ? weather[0]['description'] ?? '' : '',
      iconCode: weather.isNotEmpty ? weather[0]['icon'] ?? '01d' : '01d',
      date: DateTime.now(),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}

class WeatherForecastModel {
  final DateTime date;
  final double temperature;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String iconCode;
  final int humidity;

  WeatherForecastModel({
    required this.date,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.iconCode,
    required this.humidity,
  });

  factory WeatherForecastModel.fromMap(Map<String, dynamic> data) {
    final main = data['main'] ?? {};
    final weather = (data['weather'] as List<dynamic>?) ?? [];
    
    return WeatherForecastModel(
      date: DateTime.parse(data['dt_txt'] ?? DateTime.now().toIso8601String()),
      temperature: (main['temp'] ?? 0).toDouble(),
      minTemp: (main['temp_min'] ?? 0).toDouble(),
      maxTemp: (main['temp_max'] ?? 0).toDouble(),
      description: weather.isNotEmpty ? weather[0]['description'] ?? '' : '',
      iconCode: weather.isNotEmpty ? weather[0]['icon'] ?? '01d' : '01d',
      humidity: main['humidity'] ?? 0,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}
