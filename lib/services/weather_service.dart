import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'package:flutter/material.dart';

class WeatherService {
  static const String _apiKey = Constants.openWeatherApiKey;
  static const String _base = 'https://api.openweathermap.org/data/2.5';

  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    final response = await http.get(
      Uri.parse('$_base/weather?q=$city&units=metric&appid=$_apiKey'),
    );

    if (response.statusCode != 200) {
      throw 'Failed to fetch weather';
    }

    final data = jsonDecode(response.body);
    return {
      'temp': data['main']['temp']?.toDouble() ?? 0.0,
      'feelsLike': data['main']['feels_like']?.toDouble() ?? 0.0,
      'condition': data['weather'][0]['main'] ?? 'Unknown',
      'description': data['weather'][0]['description'] ?? '',
      'humidity': data['main']['humidity'] ?? 0,
      'windSpeed': data['wind']['speed']?.toDouble() ?? 0.0,
      'icon': data['weather'][0]['icon'] ?? '01d',
      'cityName': data['name'] ?? city,
    };
  }

  Future<List<Map<String, dynamic>>> getForecast(String city, {int days = 7}) async {
    final response = await http.get(
      Uri.parse('$_base/forecast?q=$city&units=metric&cnt=${days * 8}&appid=$_apiKey'),
    );

    if (response.statusCode != 200) {
      throw 'Failed to fetch forecast';
    }

    final data = jsonDecode(response.body);
    final list = data['list'] as List;

    // Group by date
    final Map<String, List<dynamic>> grouped = {};
    for (final item in list) {
      final date = item['dt_txt'].toString().split(' ')[0];
      grouped.putIfAbsent(date, () => []).add(item);
    }

    return grouped.entries.map((entry) {
      final items = entry.value;
      final temps = items.map((i) => i['main']['temp'].toDouble()).toList();
      final minTemp = temps.reduce((a, b) => a < b ? a : b);
      final maxTemp = temps.reduce((a, b) => a > b ? a : b);
      final midday = items[items.length ~/ 2];

      return {
        'date': entry.key,
        'minTemp': minTemp,
        'maxTemp': maxTemp,
        'condition': midday['weather'][0]['main'] ?? 'Unknown',
        'icon': midday['weather'][0]['icon'] ?? '01d',
        'description': midday['weather'][0]['description'] ?? '',
      };
    }).toList();
  }

  bool isGoodWeather(String condition) {
    return condition == 'Clear' ||
        (condition == 'Clouds');
  }

  IconData getWeatherIcon(String condition) {
    switch (condition) {
      case 'Clear':
        return Icons.wb_sunny;
      case 'Clouds':
        return Icons.cloud;
      case 'Rain':
      case 'Drizzle':
        return Icons.water_drop;
      case 'Thunderstorm':
        return Icons.thunderstorm;
      case 'Snow':
        return Icons.ac_unit;
      case 'Mist':
      case 'Fog':
        return Icons.foggy;
      default:
        return Icons.wb_cloudy;
    }
  }
}