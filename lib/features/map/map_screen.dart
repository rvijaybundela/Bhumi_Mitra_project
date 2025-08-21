import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/geo/geo_loader.dart';
import '../../data/models/survey_feature.dart';
import '../search/search_screen.dart';
import '../survey/survey_sheet.dart';

const kBrown = Color(0xFF8B4513);

/// Phase 1-6 Implementation: Complete Survey Map with Google Maps Integration
/// Following the exact hierarchy: Load  Render  Interact  Search  Report  Optimize
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Phase 1: Map + Data state
  GoogleMapController? _mapController;
  List<SurveyFeature> _features = [];
  Set<Polygon> _polygons = {};
  bool _isLoading = true;
  String? _error;
  
  // Phase 2: Select, Focus, Details state
  SurveyFeature? _selectedFeature;
  Position? _currentPosition;
  
  // Phase 6: Performance/Polish state
  MapType _currentMapType = MapType.normal;
  bool _myLocationEnabled = true;
  LatLngBounds? _currentViewport;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // Phase 1: Load data and render map
  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Phase 1.1: Load GeoJSON data
      final villageFeatures = await GeoLoader.loadVillageFeatures();
      final surveyFeatures = villageFeatures
          .map((vf) => SurveyFeature.fromVillageFeature(vf))
          .toList();
      
      if (mounted) {
        setState(() {
          _features = surveyFeatures;
          _isLoading = false;
        });
        
        // Phase 1.3: Build polygons for map rendering
        _buildPolygons();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Phase 1.3: Draw polygons on Google Maps
  void _buildPolygons() {
    final polygons = <Polygon>{};
    
    for (int i = 0; i < _features.length; i++) {
      final feature = _features[i];
      
      // Phase 6: Performance - only render if in viewport (if available)
      if (_currentViewport != null && !_isFeatureInViewport(feature)) {
        continue;
      }
      
      for (int ringIndex = 0; ringIndex < feature.rings.length; ringIndex++) {
        final ring = feature.rings[ringIndex];
        if (ring.length < 3) continue; // Skip invalid polygons
        
        final polygonId = PolygonId('${feature.id}_$ringIndex');
        final isSelected = _selectedFeature?.id == feature.id;
        
        // Convert to Google Maps LatLng
        final googleMapPoints = ring.map((point) => 
            LatLng(point.latitude, point.longitude)).toList();
        
        final polygon = Polygon(
          polygonId: polygonId,
          points: googleMapPoints,
          strokeColor: isSelected ? Colors.red : kBrown,
          strokeWidth: isSelected ? 3 : 2,
          fillColor: isSelected 
              ? Colors.red.withOpacity(0.3)
              : kBrown.withOpacity(0.1),
          consumeTapEvents: true,
          onTap: () => _onPolygonTapped(feature),
        );
        
        polygons.add(polygon);
      }
    }
    
    setState(() {
      _polygons = polygons;
    });
  }

  // Phase 6: Performance optimization - viewport filtering
  bool _isFeatureInViewport(SurveyFeature feature) {
    if (_currentViewport == null || feature.rings.isEmpty) return true;
    
    // Convert to Google Maps LatLng for bounds calculation
    final googleMapPoints = feature.rings.first.map((point) => 
        LatLng(point.latitude, point.longitude)).toList();
    final bounds = _calculateBounds(googleMapPoints);
    
    return _currentViewport!.contains(bounds.southwest) || 
           _currentViewport!.contains(bounds.northeast);
  }

  // Phase 2: Tap-to-select functionality
  void _onPolygonTapped(SurveyFeature feature) {
    setState(() {
      _selectedFeature = feature;
    });
    
    // Phase 2: Restyle polygon and fit camera
    _buildPolygons();
    _fitCameraToFeature(feature);
    
    // Phase 2: Show survey details sheet
    _showSurveyDetailsSheet(feature);
  }

  // Phase 2: Fit camera to selected feature bounds
  void _fitCameraToFeature(SurveyFeature feature) {
    if (feature.rings.isEmpty || _mapController == null) return;
    
    // Convert to Google Maps LatLng
    final googleMapPoints = feature.rings.first.map((point) => 
        LatLng(point.latitude, point.longitude)).toList();
    final bounds = _calculateBounds(googleMapPoints);
    
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    
    for (final point in points) {
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

  // Phase 2: "Locate Me"  "Which survey am I in?"
  Future<void> _locateMe() async {
    try {
      // Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied');
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });

      final userLatLng = LatLng(position.latitude, position.longitude);

      // Move camera to user location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLatLng, 16),
      );

      // Phase 2: Point-in-polygon check
      final containingFeature = _findContainingFeature(userLatLng);
      if (containingFeature != null) {
        _onPolygonTapped(containingFeature);
        _showSnackBar('You are in: ${containingFeature.name}');
      } else {
        _showSnackBar('No survey found at your location');
      }
    } catch (e) {
      _showSnackBar('Error getting location: $e');
    }
  }

  // Phase 2: Fast point-in-polygon with bounding box optimization
  SurveyFeature? _findContainingFeature(LatLng point) {
    // Check each feature
    for (final feature in _features) {
      for (final ring in feature.rings) {
        // Convert internal LatLng to Google Maps LatLng for comparison
        final googleMapRing = ring.map((p) => LatLng(p.latitude, p.longitude)).toList();
        if (_isPointInPolygonSimple(point, googleMapRing)) {
          return feature;
        }
      }
    }
    return null;
  }

  // Simple point-in-polygon check for Google Maps LatLng
  bool _isPointInPolygonSimple(LatLng point, List<LatLng> polygon) {
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
      
      if ((yi > y) != (yj > y) && 
          x < (xj - xi) * (y - yi) / (yj - yi) + xi) {
        intersections++;
      }
    }
    
    return intersections % 2 == 1;
  }

  // Phase 3: Search without duplication (single entry point)
  void _openSearch() async {
    final result = await Navigator.push<SurveyFeature>(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(features: _features),
      ),
    );
    
    // Phase 3: Return found feature  select + focus + show sheet
    if (result != null) {
      _onPolygonTapped(result);
    }
  }

  // Phase 2: Show survey details sheet
  void _showSurveyDetailsSheet(SurveyFeature feature) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SurveySheet(
        feature: feature,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  // Phase 6: Performance - update viewport on camera idle
  void _onCameraIdle() {
    _mapController?.getVisibleRegion().then((bounds) {
      setState(() {
        _currentViewport = bounds;
      });
      _buildPolygons(); // Re-render with viewport optimization
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Map'),
        backgroundColor: kBrown,
        foregroundColor: Colors.white,
        actions: [
          // Phase 6: Map type toggle
          PopupMenuButton<MapType>(
            icon: const Icon(Icons.layers),
            onSelected: (MapType type) {
              setState(() {
                _currentMapType = type;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: MapType.normal,
                child: Text('Normal'),
              ),
              const PopupMenuItem(
                value: MapType.satellite,
                child: Text('Satellite'),
              ),
              const PopupMenuItem(
                value: MapType.hybrid,
                child: Text('Hybrid'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kBrown),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeMap,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(19.1234, 73.1234), // Default location
                    zoom: 12,
                  ),
                  mapType: _currentMapType,
                  myLocationEnabled: _myLocationEnabled,
                  myLocationButtonEnabled: false, // Use custom button
                  polygons: _polygons,
                  onCameraIdle: _onCameraIdle, // Phase 6: Performance optimization
                  onTap: (LatLng latLng) {
                    // Deselect when tapping empty area
                    setState(() {
                      _selectedFeature = null;
                    });
                    _buildPolygons();
                  },
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Phase 3: Search button (single entry point)
          FloatingActionButton(
            heroTag: "search",
            onPressed: _openSearch,
            backgroundColor: kBrown,
            child: const Icon(Icons.search, color: Colors.white),
          ),
          const SizedBox(height: 12),
          // Phase 2: Locate Me button
          FloatingActionButton(
            heroTag: "locate",
            onPressed: _locateMe,
            backgroundColor: kBrown,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
