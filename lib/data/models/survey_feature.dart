import '../../models/village_feature.dart';

class SurveyFeature extends VillageFeature {
  final String districtId;
  final String districtName;
  final String talukId;
  final String talukName;
  final String hobliId;
  final String hobliName;
  final String villageId;
  final String villageName;
  final String ownerName;
  final String khataNumber;
  final double? areaInAcres;
  final double? areaInSqMeters;
  final String landClassification;
  final String irrigationType;
  final DateTime? lastUpdated;

  SurveyFeature({
    required super.id,
    required super.properties,
    required super.rings,
    required this.districtId,
    required this.districtName,
    required this.talukId,
    required this.talukName,
    required this.hobliId,
    required this.hobliName,
    required this.villageId,
    required this.villageName,
    required this.ownerName,
    required this.khataNumber,
    this.areaInAcres,
    this.areaInSqMeters,
    required this.landClassification,
    required this.irrigationType,
    this.lastUpdated,
  });

  factory SurveyFeature.fromVillageFeature(
    VillageFeature feature, {
    String? districtId,
    String? districtName,
    String? talukId,
    String? talukName,
    String? hobliId,
    String? hobliName,
    String? villageId,
    String? villageName,
  }) {
    final props = feature.properties;
    
    return SurveyFeature(
      id: feature.id,
      properties: props,
      rings: feature.rings,
      districtId: districtId ?? props['district_id']?.toString() ?? 'PANVEL_DIST',
      districtName: districtName ?? props['district_name']?.toString() ?? 'Panvel District',
      talukId: talukId ?? props['taluk_id']?.toString() ?? 'PANVEL_TALUK',
      talukName: talukName ?? props['taluk_name']?.toString() ?? 'Panvel Taluk',
      hobliId: hobliId ?? props['hobli_id']?.toString() ?? 'PANVEL_HOBLI',
      hobliName: hobliName ?? props['hobli_name']?.toString() ?? 'Panvel Hobli',
      villageId: villageId ?? props['village_id']?.toString() ?? props['VIL_CODE']?.toString() ?? feature.id,
      villageName: villageName ?? props['village_name']?.toString() ?? feature.name,
      ownerName: props['owner_name']?.toString() ?? props['OWNER']?.toString() ?? 'Unknown Owner',
      khataNumber: props['khata_number']?.toString() ?? props['KHATA']?.toString() ?? props['PIN']?.toString() ?? '-',
      areaInAcres: _parseDouble(props['area_acres']) ?? _parseDouble(props['AREA_AC']),
      areaInSqMeters: _parseDouble(props['area_sqm']) ?? _parseDouble(props['AREA_SQM']),
      landClassification: props['land_class']?.toString() ?? props['CLASS']?.toString() ?? 'Agricultural',
      irrigationType: props['irrigation']?.toString() ?? props['IRRIGATION']?.toString() ?? 'Rainfed',
      lastUpdated: _parseDate(props['last_updated']) ?? _parseDate(props['UPDATED']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String get fullAddress => '$villageName, $hobliName, $talukName, $districtName';
  
  String get areaDisplay {
    if (areaInAcres != null) {
      return '${areaInAcres!.toStringAsFixed(2)} acres';
    } else if (areaInSqMeters != null) {
      return '${areaInSqMeters!.toStringAsFixed(0)} sq.m';
    }
    return 'Area not available';
  }

  LatLng get centroid {
    if (rings.isEmpty || rings.first.isEmpty) {
      return const LatLng(0, 0);
    }
    
    final points = rings.first;
    double lat = 0, lng = 0;
    for (final point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }
}
