import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
// import '../services/photo_service.dart';
import '../models/location_photo_model.dart';

class MapProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  // final PhotoService _photoService = PhotoService();

  LatLng? _currentLocation;
  LatLng? _selectedLocation;
  String? _selectedLocationName;
  List<LocationPhotoModel> _locationPhotos = [];
  bool _isLoadingPhotos = false;
  bool _isLoadingLocation = false;
  String? _error;
  final MapController _mapController = MapController();
  double _currentZoom = 13.0;

  LatLng? get currentLocation => _currentLocation;
  LatLng? get selectedLocation => _selectedLocation;
  String? get selectedLocationName => _selectedLocationName;
  List<LocationPhotoModel> get locationPhotos => _locationPhotos;
  bool get isLoadingPhotos => _isLoadingPhotos;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get error => _error;
  MapController get mapController => _mapController;
  double get currentZoom => _currentZoom;

  Future<void> initCurrentLocation() async {
    _isLoadingLocation = true;
    notifyListeners();
    try {
      final position = await _locationService.getCurrentPosition();
      _currentLocation = LatLng(position.latitude, position.longitude);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoadingLocation = false;
    notifyListeners();
  }

  Future<void> selectLocation(LatLng latLng, String name) async {
    _selectedLocation = latLng;
    _selectedLocationName = name;
    notifyListeners();
    await loadLocationPhotos(name);
  }

  Future<void> loadLocationPhotos(String locationName) async {
    _isLoadingPhotos = true;
    notifyListeners();
    try {
      // _locationPhotos = await _photoService.getLocationPhotos(locationName);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _locationPhotos = [];
    }
    _isLoadingPhotos = false;
    notifyListeners();
  }

  Future<void> searchAndGoTo(String address) async {
    final coords = await _locationService.getCoordsFromAddress(address);
    if (coords != null) {
      _selectedLocation = coords;
      _mapController.move(coords, 14);
      notifyListeners();
    }
  }

  void animateToLocation(LatLng target, {double zoom = 14}) {
    _mapController.move(target, zoom);
    _currentZoom = zoom;
  }

  double getDistanceFromCurrent(LatLng target) {
    if (_currentLocation == null) return -1;
    return _locationService.calculateDistance(_currentLocation!, target);
  }

  String formatDistanceFromCurrent(LatLng target) {
    final distance = getDistanceFromCurrent(target);
    if (distance < 0) return '';
    return _locationService.formatDistance(distance);
  }

  void clearPhotos() {
    _locationPhotos = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}