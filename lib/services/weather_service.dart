import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);
  @override
  String toString() => message;
}

class WeatherService {
  Future<Map<String, dynamic>> getWeather(String city) async {
    final cleanCity = city.split(',')[0].trim();
    final url = Uri.parse('${Constants.openWeatherBaseUrl}/weather?q=${Uri.encodeComponent(cleanCity)}&appid=${Constants.openWeatherApiKey}&units=metric');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temp': (data['main']['temp'] as num).toDouble(),
          'feelsLike': (data['main']['feels_like'] as num).toDouble(),
          'condition': data['weather'][0]['main'] ?? 'Clear',
          'humidity': (data['main']['humidity'] as num).toInt(),
          'windSpeed': (data['wind']['speed'] as num).toDouble(),
          'icon': data['weather'][0]['icon'] ?? '01d',
        };
      } else {
        throw WeatherException('Weather metrics fetching criteria failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw WeatherException('Location data context matching failure on weather parameters: $e');
    }
  }
}