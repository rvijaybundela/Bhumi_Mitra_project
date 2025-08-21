# Village Survey Data API Documentation

## Overview
The Village Survey Data API uses GeoJSON format to provide detailed village boundary and survey information for the Panvel Taluka area in Raigad District, Maharashtra.

## Data Format: GeoJSON

### Base Structure
```json
{
  "type": "FeatureCollection",
  "name": "sample village data", 
  "crs": {
    "type": "name",
    "properties": {
      "name": "urn:ogc:def:crs:EPSG::32643"
    }
  },
  "features": [...]
}
```

### Feature Structure
Each village is represented as a Feature with:

```json
{
  "type": "Feature",
  "properties": {
    "CCODE": "Census Code",
    "PIN": "Plot ID Number", 
    "DTNCODE": "District Code",
    "THNCODE": "Tehsil Code",
    "VINCODE": "Village Code",
    "VIL_NAME": "Village Name",
    "DTName": "District Name",
    "THName": "Tehsil Name",
    "LGD_CODE": "Local Govt Code",
    "EF_CODE": "Extended Feature Code"
  },
  "geometry": {
    "type": "MultiPolygon",
    "coordinates": [
      [
        [
          [x, y, z],
          [x, y, z],
          ...
        ]
      ]
    ]
  }
}
```

## Current Dataset: Panvel Villages

### Coverage
- **District**: Raigad (DTNCODE: 491)
- **Taluka**: Panvel (THNCODE: 4173) 
- **Villages**: 401 features
- **Area**: Panvel Taluka boundaries

### Sample Villages
1. **Bonshet** (VINCODE: 553406)
2. **Kharghar** (VINCODE: 553407)
3. **Kalamboli** (VINCODE: 553408)
4. **Panvel** (Main town)
5. **Khandeshwar**
6. **Taloja**

### Coordinate System
- **Source**: UTM Zone 43N (EPSG:32643)
- **Converted to**: WGS84 (Latitude/Longitude)
- **Units**: Decimal degrees
- **Transformation**: Done via proj4dart library

## Field Definitions

| Field | Description | Example |
|-------|-------------|---------|
| CCODE | Census Code | "240002000202829100" |
| PIN | Plot/Survey Number | "21", "22", "23/1" |
| DTNCODE | District Code | "491" (Raigad) |
| THNCODE | Tehsil/Taluka Code | "4173" (Panvel) |
| VINCODE | Village Code | "553406" |
| VIL_NAME | Village Name | "Bonshet" |
| DTName | District Name | "Raigad" |
| THName | Tehsil Name | "Panvel" |
| LGD_CODE | Local Government Directory Code | "553406" |
| EF_CODE | Extended Feature Code | "272400020282950000" |

## Data Processing

### Loading Process
1. **File**: `assets/data/panvel_villages.geojson`
2. **Parser**: `GeoLoader.loadVillageFeatures()`
3. **Transformation**: UTM → WGS84 coordinates
4. **Output**: List of `VillageFeature` objects

### VillageFeature Model
```dart
class VillageFeature {
  final String id;
  final Map<String, dynamic> properties;
  final List<List<LatLng>> rings;
  
  String get name => properties['VIL_NAME'] ?? '';
  String get surveyNo => properties['PIN'] ?? '';
}
```

## Usage in Flutter App

### 1. Data Loading
```dart
final features = await GeoLoader.loadVillageFeatures();
print('Loaded ${features.length} village features');
```

### 2. Village Information Access
```dart
for (final village in features) {
  print('Village: ${village.name}');
  print('Survey No: ${village.surveyNo}');
  print('District: ${village.properties['DTName']}');
  print('Coordinates: ${village.rings.length} polygon rings');
}
```

### 3. Map Integration
- **Google Maps**: Polygons and markers for each village
- **Search**: Filter by village name or survey number
- **Selection**: Click to view village details

## API Statistics

### Current Data (Panvel GeoJSON)
- **Total Features**: 401 villages
- **File Size**: ~2.8MB
- **Average Polygons per Village**: 1-5 rings
- **Coordinate Points**: ~50,000+ points total
- **Coverage**: Complete Panvel Taluka

### Performance
- **Load Time**: ~1-2 seconds
- **Memory Usage**: ~15-20MB for full dataset
- **Rendering**: Real-time on Google Maps
- **Search**: Instant filtering

## Sample API Response

```json
{
  "village_count": 401,
  "villages": [
    {
      "id": "bonshet_553406",
      "name": "Bonshet", 
      "survey_no": "21",
      "district": "Raigad",
      "taluka": "Panvel",
      "coordinates": [
        [
          [18.9894, 73.1197],
          [18.9895, 73.1198],
          [18.9896, 73.1199]
        ]
      ]
    }
  ]
}
```

## Integration Notes

### Google Maps Setup Required
1. Get Google Cloud Platform API key
2. Enable Maps JavaScript API
3. Add key to `web/index.html`
4. Update API restrictions

### File Locations
- **Main Data**: `assets/data/panvel_villages.geojson`
- **Sample**: `assets/data/sample_village_api.json`
- **Loader**: `lib/data/geo/geo_loader.dart`
- **Model**: `lib/models/village_feature.dart`

---

*This documentation covers the current village survey data API implementation in the Bhumi Mitra Flutter application.*
