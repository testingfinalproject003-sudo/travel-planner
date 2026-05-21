import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class WeatherService {
  Future<Map<String, dynamic>?> getCurrentWeather(String city) async {
    return getWeather(city);
  }

  Future<Map<String, dynamic>?> getWeather(String city, {DateTime? date}) async {
    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=${Constants.openWeatherApiKey}&units=metric',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'temp': data['main']['temp']?.toDouble() ?? 0.0,
          'feelsLike': data['main']['feels_like']?.toDouble() ?? 0.0,
          'humidity': data['main']['humidity'] ?? 0,
          'description': data['weather'][0]['description'] ?? '',
          'condition': data['weather'][0]['main'] ?? '',
          'icon': data['weather'][0]['icon'] ?? '',
          'windSpeed': (data['wind']['speed'] ?? 0).toDouble(),
          'cityName': data['name'] ?? city,
          'date': date?.toIso8601String() ?? DateTime.now().toIso8601String(),
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getForecast(String city) async {
    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=${Constants.openWeatherApiKey}&units=metric',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['list'];
        return list.map((item) => {
          'temp': item['main']['temp']?.toDouble() ?? 0.0,
          'description': item['weather'][0]['description'] ?? '',
          'condition': item['weather'][0]['main'] ?? '',
          'icon': item['weather'][0]['icon'] ?? '',
          'date': item['dt_txt'],
          'windSpeed': (item['wind']['speed'] ?? 0).toDouble(),
          'humidity': item['main']['humidity'] ?? 0,
        }).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get weather for a specific date from forecast
  Future<Map<String, dynamic>?> getWeatherForDate(String city, DateTime date) async {
    try {
      final forecast = await getForecast(city);
      if (forecast == null || forecast.isEmpty) return null;

      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Find forecast closest to the date
      final matchingForecast = forecast.firstWhere(
        (f) => f['date'].toString().startsWith(dateStr),
        orElse: () => forecast.first,
      );

      return matchingForecast;
    } catch (e) {
      return null;
    }
  }

  IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return Icons.wb_sunny;
      case 'clouds':
      case 'cloudy':
      case 'partly cloudy':
        return Icons.wb_cloudy;
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return Icons.water_drop;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.foggy;
      default:
        return Icons.wb_sunny;
    }
  }

  String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
}