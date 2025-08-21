import 'dart:async';

// Mock location service for web compatibility
class LocationService {
  
  static StreamController<LocationData>? _positionController;
  static LocationData? _lastKnownPosition;

  static Future<bool> requestPermission() async {
    // For web, we'll simulate permission grant
    return true;
  }

  static Future<bool> isLocationServiceEnabled() async {
    // For web, we'll simulate service enabled
    return true;
  }

  static Future<LocationData?> getCurrentPosition() async {
    try {
      // For web/demo, return a mock location in Panvel area
      final mockLocation = LocationData(
        latitude: 19.0144,
        longitude: 73.1198,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );
      
      _lastKnownPosition = mockLocation;
      return mockLocation;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static Stream<LocationData> getLocationStream() {
    _positionController ??= StreamController<LocationData>.broadcast();
    
    // Simulate location updates
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_positionController?.isClosed ?? true) {
        timer.cancel();
        return;
      }
      
      // Simulate small movement around Panvel
      final baseLatitude = 19.0144;
      final baseLongitude = 73.1198;
      final variance = 0.001; // Small movement
      
      final random = DateTime.now().millisecondsSinceEpoch % 1000 / 1000.0;
      final lat = baseLatitude + (random - 0.5) * variance;
      final lng = baseLongitude + (random - 0.5) * variance;
      
      final location = LocationData(
        latitude: lat,
        longitude: lng,
        accuracy: 5.0 + random * 10,
        timestamp: DateTime.now(),
      );
      
      _lastKnownPosition = location;
      _positionController?.add(location);
    });
    
    return _positionController!.stream;
  }

  static LocationData? get lastKnownPosition => _lastKnownPosition;

  static void dispose() {
    _positionController?.close();
    _positionController = null;
  }

  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simplified distance calculation using Haversine formula
    const double earthRadius = 6371000; // Earth radius in meters
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        (dLat / 2).abs() * (dLat / 2).abs() +
        (lat1 * 3.141592653589793 / 180).abs() * (lat2 * 3.141592653589793 / 180).abs() *
        (dLon / 2).abs() * (dLon / 2).abs();
    
    final double c = 2 * (a.abs() + (1 - a).abs()).abs();
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * 3.141592653589793 / 180;
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  @override
  String toString() => 'LocationData(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
}
