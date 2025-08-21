import '../../../models/village_feature.dart';
import '../../models/survey_feature.dart';

class BoundingBox {
  final double minLat;
  final double minLng;
  final double maxLat;
  final double maxLng;

  const BoundingBox({
    required this.minLat,
    required this.minLng,
    required this.maxLat,
    required this.maxLng,
  });

  bool contains(double lat, double lng) {
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }

  bool intersects(BoundingBox other) {
    return !(other.maxLat < minLat || 
             other.minLat > maxLat || 
             other.maxLng < minLng || 
             other.minLng > maxLng);
  }

  static BoundingBox fromPoints(List<LatLng> points) {
    if (points.isEmpty) {
      return const BoundingBox(minLat: 0, minLng: 0, maxLat: 0, maxLng: 0);
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return BoundingBox(
      minLat: minLat,
      minLng: minLng,
      maxLat: maxLat,
      maxLng: maxLng,
    );
  }
}

class IndexedFeature {
  final SurveyFeature feature;
  final BoundingBox bbox;

  IndexedFeature({
    required this.feature,
    required this.bbox,
  });
}

class SpatialIndex {
  final List<IndexedFeature> _features = [];
  
  void addFeatures(List<SurveyFeature> features) {
    _features.clear();
    for (final feature in features) {
      if (feature.rings.isNotEmpty) {
        final bbox = BoundingBox.fromPoints(feature.rings.first);
        _features.add(IndexedFeature(feature: feature, bbox: bbox));
      }
    }
  }

  List<SurveyFeature> queryPoint(double lat, double lng) {
    final candidates = <SurveyFeature>[];
    
    for (final indexed in _features) {
      if (indexed.bbox.contains(lat, lng)) {
        // Perform detailed point-in-polygon test
        if (_pointInPolygon(lat, lng, indexed.feature.rings.first)) {
          candidates.add(indexed.feature);
        }
      }
    }
    
    return candidates;
  }

  List<SurveyFeature> queryBounds(BoundingBox bounds) {
    final candidates = <SurveyFeature>[];
    
    for (final indexed in _features) {
      if (indexed.bbox.intersects(bounds)) {
        candidates.add(indexed.feature);
      }
    }
    
    return candidates;
  }

  List<SurveyFeature> findNearby(double lat, double lng, double radiusMeters) {
    // Create a bounding box around the point
    const double metersPerDegree = 111320; // Approximate at equator
    final double deltaLat = radiusMeters / metersPerDegree;
    final double deltaLng = radiusMeters / (metersPerDegree * (lat * 3.141592653589793 / 180).abs());
    
    final bounds = BoundingBox(
      minLat: lat - deltaLat,
      maxLat: lat + deltaLat,
      minLng: lng - deltaLng,
      maxLng: lng + deltaLng,
    );
    
    return queryBounds(bounds);
  }

  // Ray casting algorithm for point-in-polygon test
  bool _pointInPolygon(double lat, double lng, List<LatLng> polygon) {
    if (polygon.length < 3) return false;
    
    bool inside = false;
    int j = polygon.length - 1;
    
    for (int i = 0; i < polygon.length; i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;
      
      if (((yi > lat) != (yj > lat)) &&
          (lng < (xj - xi) * (lat - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
      j = i;
    }
    
    return inside;
  }

  int get featureCount => _features.length;

  void clear() {
    _features.clear();
  }
}
