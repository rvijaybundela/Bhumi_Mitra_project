import 'package:google_maps_flutter/google_maps_flutter.dart';

class PointInPolygonService {
  /// Check if a point is inside a polygon using ray-casting algorithm
  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;
    
    int intersections = 0;
    final x = point.longitude;
    final y = point.latitude;
    
    for (int i = 0; i < polygon.length; i++) {
      final j = (i + 1) % polygon.length;
      
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;
      
      // Check if point is on boundary
      if (_isPointOnEdge(point, polygon[i], polygon[j])) {
        return true;
      }
      
      // Ray casting algorithm
      if ((yi > y) != (yj > y) && 
          x < (xj - xi) * (y - yi) / (yj - yi) + xi) {
        intersections++;
      }
    }
    
    return intersections % 2 == 1;
  }
  
  /// Check if point lies on the edge between two points
  static bool _isPointOnEdge(LatLng point, LatLng p1, LatLng p2) {
    const double tolerance = 1e-10;
    
    final crossProduct = (point.latitude - p1.latitude) * (p2.longitude - p1.longitude) - 
                        (point.longitude - p1.longitude) * (p2.latitude - p1.latitude);
    
    if (crossProduct.abs() > tolerance) return false;
    
    final dotProduct = (point.longitude - p1.longitude) * (p2.longitude - p1.longitude) + 
                      (point.latitude - p1.latitude) * (p2.latitude - p1.latitude);
    
    final squaredLength = (p2.longitude - p1.longitude) * (p2.longitude - p1.longitude) + 
                         (p2.latitude - p1.latitude) * (p2.latitude - p1.latitude);
    
    return dotProduct >= 0 && dotProduct <= squaredLength;
  }
  
  /// Calculate bounding box for a polygon
  static LatLngBounds getBoundingBox(List<LatLng> polygon) {
    if (polygon.isEmpty) {
      throw ArgumentError('Polygon cannot be empty');
    }
    
    double minLat = polygon.first.latitude;
    double maxLat = polygon.first.latitude;
    double minLng = polygon.first.longitude;
    double maxLng = polygon.first.longitude;
    
    for (final point in polygon) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }
    
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
  
  /// Fast filter by bounding box before expensive point-in-polygon check
  static List<T> filterByBoundingBox<T>(
    LatLng point,
    List<T> features,
    LatLngBounds Function(T) getBounds,
  ) {
    return features.where((feature) {
      final bounds = getBounds(feature);
      return point.latitude >= bounds.southwest.latitude &&
             point.latitude <= bounds.northeast.latitude &&
             point.longitude >= bounds.southwest.longitude &&
             point.longitude <= bounds.northeast.longitude;
    }).toList();
  }
}
