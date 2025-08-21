import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:collection/collection.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/village_feature.dart';
import 'projections.dart';

class GeoLoader {
  static Future<List<VillageFeature>> loadVillageFeatures() async {
    // Try to load Panvel data first, fallback to test data if needed
    try {
      return await _loadPanvelData();
    } catch (e) {
      print('Failed to load Panvel data: $e');
      return await _loadTestData();
    }
  }

  static Future<List<VillageFeature>> _loadPanvelData() async {
    final raw = await rootBundle.loadString('assets/data/panvel_villages.geojson');
    final data = jsonDecode(raw);

    final features = (data['features'] as List?) ?? [];
    final result = <VillageFeature>[];

    for (final f in features) {
      final props = (f['properties'] ?? {}) as Map<String, dynamic>;
      final geom = f['geometry'] as Map<String, dynamic>?;
      if (geom == null) continue;
      final type = (geom['type'] ?? '').toString();
      if (type != 'MultiPolygon' && type != 'Polygon') continue;

      final coords = geom['coordinates'];
      // Normalize to MultiPolygon => [[[ [x,y], ... ]]] structure
      final multi = type == 'Polygon' ? [coords] : coords;

      final rings = <List<LatLng>>[];

      // multi: List<Polygon>; polygon: List<Ring>; ring: List<[x,y]>
      for (final polygon in multi) {
        for (final ring in (polygon as List)) {
          final latlngRing = <LatLng>[];
          for (final pair in (ring as List)) {
            final x = (pair[0] as num).toDouble(); // easting (meters)
            final y = (pair[1] as num).toDouble(); // northing (meters)
            final geo = transformToWgs84(x, y); // -> lon/lat
            latlngRing.add(LatLng(geo.y, geo.x)); // LatLng(lat, lon)
          }
          // ensure closed ring visually (optional)
          if (latlngRing.isNotEmpty && !const ListEquality().equals([latlngRing.first.latitude, latlngRing.first.longitude], [latlngRing.last.latitude, latlngRing.last.longitude])) {
            latlngRing.add(latlngRing.first);
          }
          rings.add(latlngRing);
        }
      }

      result.add(VillageFeature(
        id: (props['LGD_CODE'] ?? props['VINCODE'] ?? props['CCODE'] ?? '${result.length + 1}').toString(),
        properties: props,
        rings: rings,
      ));
    }

    print('Loaded ${result.length} features from Panvel data');
    return result;
  }

  static Future<List<VillageFeature>> _loadTestData() async {
    final raw = await rootBundle.loadString('assets/data/village.json');
    final data = jsonDecode(raw);

    final features = (data['features'] as List?) ?? [];
    final result = <VillageFeature>[];

    for (final f in features) {
      final props = (f['properties'] ?? {}) as Map<String, dynamic>;
      final geom = f['geometry'] as Map<String, dynamic>?;
      if (geom == null) continue;
      final type = (geom['type'] ?? '').toString();
      if (type != 'MultiPolygon' && type != 'Polygon') continue;

      final coords = geom['coordinates'];
      // Normalize to MultiPolygon => [[[ [x,y], ... ]]] structure
      final multi = type == 'Polygon' ? [coords] : coords;

      final rings = <List<LatLng>>[];

      // multi: List<Polygon>; polygon: List<Ring>; ring: List<[x,y]>
      for (final polygon in multi) {
        for (final ring in (polygon as List)) {
          final latlngRing = <LatLng>[];
          for (final pair in (ring as List)) {
            final x = (pair[0] as num).toDouble(); // easting (meters)
            final y = (pair[1] as num).toDouble(); // northing (meters)
            final geo = transformToWgs84(x, y); // -> lon/lat
            latlngRing.add(LatLng(geo.y, geo.x)); // LatLng(lat, lon)
          }
          // ensure closed ring visually (optional)
          if (latlngRing.isNotEmpty && !const ListEquality().equals([latlngRing.first.latitude, latlngRing.first.longitude], [latlngRing.last.latitude, latlngRing.last.longitude])) {
            latlngRing.add(latlngRing.first);
          }
          rings.add(latlngRing);
        }
      }

      result.add(VillageFeature(
        id: (props['id'] ?? props['CCODE'] ?? props['EF_CODE'] ?? '${result.length + 1}').toString(),
        properties: props,
        rings: rings,
      ));
    }

    return result;
  }
}
