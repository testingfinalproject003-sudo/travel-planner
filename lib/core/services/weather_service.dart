import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../constants/api_keys.dart';

class WeatherService {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherModel> getCurrentWeather(String city) async {
    final url = Uri.parse(
      '$baseUrl/weather?q=$city&appid=${ApiKeys.openWeatherMap}&units=metric',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherModel.fromOpenWeather(data);
    } else {
      throw Exception('Failed to load weather: ${response.statusCode}');
    }
  }

  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon) async {
    final url = Uri.parse(
      '$baseUrl/weather?lat=$lat&lon=$lon&appid=${ApiKeys.openWeatherMap}&units=metric',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherModel.fromOpenWeather(data);
    } else {
      throw Exception('Failed to load weather: ${response.statusCode}');
    }
  }

  Future<List<WeatherForecastModel>> getForecast(String city) async {
    final url = Uri.parse(
      '$baseUrl/forecast?q=$city&appid=${ApiKeys.openWeatherMap}&units=metric',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = data['list'] as List<dynamic>;
      return list.map((e) => WeatherForecastModel.fromMap(e)).toList();
    } else {
      throw Exception('Failed to load forecast: ${response.statusCode}');
    }
  }

  Future<List<WeatherForecastModel>> getForecastByCoordinates(double lat, double lon) async {
    final url = Uri.parse(
      '$baseUrl/forecast?lat=$lat&lon=$lon&appid=${ApiKeys.openWeatherMap}&units=metric',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = data['list'] as List<dynamic>;
      return list.map((e) => WeatherForecastModel.fromMap(e)).toList();
    } else {
      throw Exception('Failed to load forecast: ${response.statusCode}');
    }
  }

  Future<WeatherModel> getWeatherForDate(String city, DateTime date) async {
    final forecast = await getForecast(city);
    
    // Find forecast closest to the requested date
    final targetDate = DateTime(date.year, date.month, date.day);
    WeatherForecastModel? closest;
    Duration minDiff = const Duration(days: 365);
    
    for (var f in forecast) {
      final fDate = DateTime(f.date.year, f.date.month, f.date.day);
      final diff = fDate.difference(targetDate).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = f;
      }
    }
    
    if (closest != null) {
      return WeatherModel(
        city: city,
        temperature: closest.temperature,
        feelsLike: closest.temperature,
        humidity: closest.humidity,
        windSpeed: 0,
        description: closest.description,
        iconCode: closest.iconCode,
        date: closest.date,
      );
    }
    
    return await getCurrentWeather(city);
  }
}