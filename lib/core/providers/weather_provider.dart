import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  
  WeatherModel? _currentWeather;
  List<WeatherForecastModel> _forecast = [];
  bool _isLoading = false;
  String? _error;

  WeatherModel? get currentWeather => _currentWeather;
  List<WeatherForecastModel> get forecast => _forecast;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getCurrentWeather(String city) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentWeather = await _weatherService.getCurrentWeather(city);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getForecast(String city) async {
    _isLoading = true;
    notifyListeners();

    try {
      _forecast = await _weatherService.getForecast(city);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getWeatherForDate(String city, DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentWeather = await _weatherService.getWeatherForDate(city, date);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}