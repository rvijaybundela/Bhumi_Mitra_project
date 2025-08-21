import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '../models/survey_feature.dart';
import '../../models/village_feature.dart';

class GeoDataService {
  static GeoDataService? _instance;
  static GeoDataService get instance => _instance ??= GeoDataService._();
  GeoDataService._();

  List<SurveyFeature>? _cachedFeatures;
  Map<String, List<SurveyFeature>>? _featuresByDistrict;
  Map<String, List<SurveyFeature>>? _featuresByTaluk;
  Map<String, List<SurveyFeature>>? _featuresByVillage;

  /// Load and parse GeoJSON data from assets
  Future<List<SurveyFeature>> loadSurveyFeatures() async {
    if (_cachedFeatures != null) return _cachedFeatures!;

    try {
      // Load GeoJSON from assets
      final String geoJsonString = await rootBundle.loadString('assets/data/panvel_villages.geojson');
      final Map<String, dynamic> geoJson = json.decode(geoJsonString);
      
      final List<SurveyFeature> features = [];
      
      if (geoJson['type'] == 'FeatureCollection' && geoJson['features'] != null) {
        for (final feature in geoJson['features']) {
          try {
            final surveyFeature = _parseGeoJsonFeature(feature);
            if (surveyFeature != null) {
              features.add(surveyFeature);
            }
          } catch (e) {
            print('Error parsing feature: $e');
            continue;
          }
        }
      }

      _cachedFeatures = features;
      _buildIndexes();
      return features;
    } catch (e) {
      throw Exception('Failed to load GeoJSON data: $e');
    }
  }

  /// Parse individual GeoJSON feature to SurveyFeature
  SurveyFeature? _parseGeoJsonFeature(Map<String, dynamic> featureJson) {
    try {
      final geometry = featureJson['geometry'];
      final properties = Map<String, dynamic>.from(featureJson['properties'] ?? {});
      
      if (geometry == null || geometry['type'] == null) return null;

      final List<List<LatLng>> rings = [];
      
      // Handle different geometry types
      if (geometry['type'] == 'Polygon') {
        final coords = geometry['coordinates'] as List;
        for (final ring in coords) {
          final latLngRing = _parseCoordinateRing(ring);
          if (latLngRing.isNotEmpty) rings.add(latLngRing);
        }
      } else if (geometry['type'] == 'MultiPolygon') {
        final coords = geometry['coordinates'] as List;
        for (final polygon in coords) {
          for (final ring in polygon) {
            final latLngRing = _parseCoordinateRing(ring);
            if (latLngRing.isNotEmpty) rings.add(latLngRing);
          }
        }
      }

      if (rings.isEmpty) return null;

      // Create VillageFeature first
      final villageFeature = VillageFeature(
        id: properties['id']?.toString() ?? properties['PIN']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        properties: properties,
        rings: rings,
      );

      // Convert to SurveyFeature with enhanced data
      return SurveyFeature.fromVillageFeature(villageFeature);
    } catch (e) {
      print('Error parsing GeoJSON feature: $e');
      return null;
    }
  }

  /// Parse coordinate ring from GeoJSON format [lng, lat] to LatLng
  List<LatLng> _parseCoordinateRing(List coordinates) {
    final List<LatLng> ring = [];
    
    for (final coord in coordinates) {
      if (coord is List && coord.length >= 2) {
        final lng = (coord[0] as num).toDouble();
        final lat = (coord[1] as num).toDouble();
        
        // Ensure coordinates are in WGS84 range
        if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
          ring.add(LatLng(lat, lng));
        }
      }
    }
    
    return ring;
  }

  /// Build search indexes for faster queries
  void _buildIndexes() {
    if (_cachedFeatures == null) return;

    _featuresByDistrict = groupBy(_cachedFeatures!, (f) => f.districtId);
    _featuresByTaluk = groupBy(_cachedFeatures!, (f) => f.talukId);
    _featuresByVillage = groupBy(_cachedFeatures!, (f) => f.villageId);
  }

  /// Search features by text query
  List<SurveyFeature> searchFeatures(String query) {
    if (_cachedFeatures == null) return [];
    
    final normalizedQuery = query.toLowerCase().trim();
    if (normalizedQuery.isEmpty) return _cachedFeatures!;

    return _cachedFeatures!.where((feature) {
      return feature.villageName.toLowerCase().contains(normalizedQuery) ||
             feature.districtName.toLowerCase().contains(normalizedQuery) ||
             feature.talukName.toLowerCase().contains(normalizedQuery) ||
             feature.hobliName.toLowerCase().contains(normalizedQuery) ||
             feature.ownerName.toLowerCase().contains(normalizedQuery) ||
             feature.khataNumber.toLowerCase().contains(normalizedQuery) ||
             feature.surveyNumber.toLowerCase().contains(normalizedQuery) ||
             feature.name.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  /// Get features by district
  List<SurveyFeature> getFeaturesByDistrict(String districtId) {
    return _featuresByDistrict?[districtId] ?? [];
  }

  /// Get features by taluk
  List<SurveyFeature> getFeaturesByTaluk(String talukId) {
    return _featuresByTaluk?[talukId] ?? [];
  }

  /// Get features by village
  List<SurveyFeature> getFeaturesByVillage(String villageId) {
    return _featuresByVillage?[villageId] ?? [];
  }

  /// Get unique districts
  List<String> getDistricts() {
    return _featuresByDistrict?.keys.toList() ?? [];
  }

  /// Get unique taluks for a district
  List<String> getTaluks(String? districtId) {
    if (_cachedFeatures == null) return [];
    
    return _cachedFeatures!
        .where((f) => districtId == null || f.districtId == districtId)
        .map((f) => f.talukId)
        .toSet()
        .toList();
  }

  /// Get unique villages for a taluk
  List<String> getVillages(String? talukId) {
    if (_cachedFeatures == null) return [];
    
    return _cachedFeatures!
        .where((f) => talukId == null || f.talukId == talukId)
        .map((f) => f.villageId)
        .toSet()
        .toList();
  }

  /// Clear cache (useful for refresh)
  void clearCache() {
    _cachedFeatures = null;
    _featuresByDistrict = null;
    _featuresByTaluk = null;
    _featuresByVillage = null;
  }
}

// Extension for Google Maps LatLng
extension LatLngExtension on gmaps.LatLng {
  /// Convert to GeoJSON coordinate format [lng, lat]
  List<double> toGeoJsonCoordinate() => [longitude, latitude];
  
  /// Calculate distance to another point in meters
  double distanceTo(gmaps.LatLng other) {
    // Simple haversine distance calculation
    const double earthRadius = 6371000; // meters
    final lat1Rad = latitude * (math.pi / 180);
    final lat2Rad = other.latitude * (math.pi / 180);
    final deltaLatRad = (other.latitude - latitude) * (math.pi / 180);
    final deltaLngRad = (other.longitude - longitude) * (math.pi / 180);

    final a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }
}
