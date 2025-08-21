import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '../models/survey_feature.dart';
import '../services/geo_data_service.dart';
import '../../core/services/point_in_polygon.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  Position? _lastKnownPosition;
  SurveyFeature? _currentSurvey;

  /// Get current location with permission handling
  Future<LocationResult> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.error('Location services are disabled');
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.error('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.error('Location permission permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      _lastKnownPosition = position;
      return LocationResult.success(position);
    } catch (e) {
      return LocationResult.error('Failed to get location: $e');
    }
  }

  /// Find survey at current location
  Future<SurveyLocationResult> findSurveyAtCurrentLocation() async {
    final locationResult = await getCurrentLocation();
    if (!locationResult.isSuccess) {
      return SurveyLocationResult.error(locationResult.errorMessage!);
    }

    return findSurveyAtPosition(locationResult.position!);
  }

  /// Find survey at specific position
  Future<SurveyLocationResult> findSurveyAtPosition(Position position) async {
    try {
      final features = await GeoDataService.instance.loadSurveyFeatures();
      final userLatLng = gmaps.LatLng(position.latitude, position.longitude);
      
      for (final feature in features) {
        if (feature.rings.isNotEmpty) {
          // Convert to Google Maps LatLng for point-in-polygon check
          final googleMapsRings = feature.rings.first.map((point) => 
            gmaps.LatLng(point.latitude, point.longitude)).toList();
          
          final isInside = PointInPolygonService.isPointInPolygon(
            userLatLng, 
            googleMapsRings,
          );
          
          if (isInside) {
            _currentSurvey = feature;
            return SurveyLocationResult.found(feature, position);
          }
        }
      }
      
      _currentSurvey = null;
      return SurveyLocationResult.notFound(position);
    } catch (e) {
      return SurveyLocationResult.error('Failed to check survey location: $e');
    }
  }

  /// Find nearby surveys within buffer radius (in meters)
  Future<List<SurveyFeature>> findNearbySurveys(Position position, double radiusMeters) async {
    try {
      final features = await GeoDataService.instance.loadSurveyFeatures();
      final userLatLng = gmaps.LatLng(position.latitude, position.longitude);
      final nearbySurveys = <SurveyFeature>[];

      for (final feature in features) {
        final featureCentroid = gmaps.LatLng(
          feature.centroid.latitude, 
          feature.centroid.longitude
        );
        
        final distance = _calculateDistance(userLatLng, featureCentroid);
        if (distance <= radiusMeters) {
          nearbySurveys.add(feature);
        }
      }

      // Sort by distance
      nearbySurveys.sort((a, b) {
        final distanceA = _calculateDistance(userLatLng, gmaps.LatLng(
          a.centroid.latitude, a.centroid.longitude));
        final distanceB = _calculateDistance(userLatLng, gmaps.LatLng(
          b.centroid.latitude, b.centroid.longitude));
        return distanceA.compareTo(distanceB);
      });

      return nearbySurveys;
    } catch (e) {
      return [];
    }
  }

  /// Calculate distance between two points in meters
  double _calculateDistance(gmaps.LatLng point1, gmaps.LatLng point2) {
    const double earthRadius = 6371000; // meters
    final lat1Rad = point1.latitude * (math.pi / 180);
    final lat2Rad = point2.latitude * (math.pi / 180);
    final deltaLatRad = (point2.latitude - point1.latitude) * (math.pi / 180);
    final deltaLngRad = (point2.longitude - point1.longitude) * (math.pi / 180);

    final a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  /// Get last known position
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Get current survey (if user is within one)
  SurveyFeature? get currentSurvey => _currentSurvey;

  /// Clear cached data
  void clearCache() {
    _lastKnownPosition = null;
    _currentSurvey = null;
  }
}

// Result classes
class LocationResult {
  final bool isSuccess;
  final Position? position;
  final String? errorMessage;

  LocationResult._(this.isSuccess, this.position, this.errorMessage);

  factory LocationResult.success(Position position) =>
      LocationResult._(true, position, null);

  factory LocationResult.error(String message) =>
      LocationResult._(false, null, message);
}

class SurveyLocationResult {
  final SurveyLocationStatus status;
  final SurveyFeature? survey;
  final Position? position;
  final String? errorMessage;

  SurveyLocationResult._(this.status, this.survey, this.position, this.errorMessage);

  factory SurveyLocationResult.found(SurveyFeature survey, Position position) =>
      SurveyLocationResult._(SurveyLocationStatus.found, survey, position, null);

  factory SurveyLocationResult.notFound(Position position) =>
      SurveyLocationResult._(SurveyLocationStatus.notFound, null, position, null);

  factory SurveyLocationResult.error(String message) =>
      SurveyLocationResult._(SurveyLocationStatus.error, null, null, message);

  bool get isFound => status == SurveyLocationStatus.found;
  bool get isNotFound => status == SurveyLocationStatus.notFound;
  bool get isError => status == SurveyLocationStatus.error;

  String get statusMessage {
    switch (status) {
      case SurveyLocationStatus.found:
        return '✅ You are within ${survey!.name.isNotEmpty ? survey!.name : "Survey ${survey!.surveyNumber}"}';
      case SurveyLocationStatus.notFound:
        return '❌ You are not within any registered survey area';
      case SurveyLocationStatus.error:
        return '⚠️ $errorMessage';
    }
  }
}

enum SurveyLocationStatus {
  found,
  notFound,
  error,
}
