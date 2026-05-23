import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../services/places_service.dart';
import '../services/location_service.dart';

class ExploreProvider extends ChangeNotifier {
  final PlacesService _placesService = PlacesService();
  final LocationService _locationService = LocationService();
  
  List<PlaceModel> _places = [];
  List<PlaceModel> _popularDestinations = [];
  List<PlaceModel> _nearbyPlaces = [];
  PlaceModel? _selectedPlace;
  bool _isLoading = false;
  String? _error;

  List<PlaceModel> get places => _places;
  List<PlaceModel> get popularDestinations => _popularDestinations;
  List<PlaceModel> get nearbyPlaces => _nearbyPlaces;
  PlaceModel? get selectedPlace => _selectedPlace;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> searchPlaces(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      _places = await _placesService.searchPlaces(
        query: query,
        lat: position?.latitude,
        lon: position?.longitude,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPopularDestinations() async {
    _isLoading = true;
    notifyListeners();

    try {
      _popularDestinations = await _placesService.getPopularDestinations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNearbyPlaces() async {
    _isLoading = true;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        _nearbyPlaces = await _placesService.getNearbyPlaces(
          lat: position.latitude,
          lon: position.longitude,
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _places = [];
    notifyListeners();
  }

  void selectPlace(PlaceModel place) {
    _selectedPlace = place;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}