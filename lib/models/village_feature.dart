// import 'package:google_maps_flutter/google_maps_flutter.dart';

class LatLng {
  final double latitude;
  final double longitude;
  
  const LatLng(this.latitude, this.longitude);
  
  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

class VillageFeature {
  final String id;
  final Map<String, dynamic> properties; // name, survey_no, etc.
  final List<List<LatLng>> rings; // MultiPolygon flattened: list of rings; first is outer, others holes
  
  VillageFeature({
    required this.id,
    required this.properties,
    required this.rings,
  });

  String get name => (properties['name'] ?? properties['NAME'] ?? properties['VIL_NAME'] ?? '').toString();
  String get surveyNo => (properties['survey_no'] ?? properties['SURVEY_NO'] ?? properties['PIN'] ?? '').toString();
  
  // Display name with fallback
  String get displayName {
    final n = name;
    return n.isEmpty ? 'Village' : n;
  }
  
  // Survey number with fallback
  String get surveyNumber {
    final sn = surveyNo;
    return sn.isEmpty || sn == 'null' ? '-' : sn;
  }
}
