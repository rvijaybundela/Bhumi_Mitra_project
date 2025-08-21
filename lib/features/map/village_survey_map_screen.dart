import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/geo/geo_loader.dart';
import '../../data/models/survey_feature.dart';

const kBrown = Color(0xFF8B4513);

class VillageSurveyMapScreen extends StatefulWidget {
  const VillageSurveyMapScreen({super.key});

  @override
  State<VillageSurveyMapScreen> createState() => _VillageSurveyMapScreenState();
}

class _VillageSurveyMapScreenState extends State<VillageSurveyMapScreen> {
  GoogleMapController? _mapController;
  List<SurveyFeature> _features = [];
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _error;
  SurveyFeature? _selectedFeature;
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _loadVillageSurveyData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      final targetSurvey = args['surveyFeature'] as SurveyFeature?;
      if (targetSurvey != null && _features.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _highlightSurvey(targetSurvey);
        });
      }
    }
  }

  void _changeMapType(MapType mapType) {
    setState(() {
      _currentMapType = mapType;
    });
  }

  void _showMapTypeMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.layers, color: kBrown),
                  const SizedBox(width: 12),
                  const Text(
                    'Map Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            _buildMapTypeOption(
              'Normal',
              'Default map view',
              Icons.map,
              MapType.normal,
            ),
            _buildMapTypeOption(
              'Satellite',
              'Satellite imagery',
              Icons.satellite,
              MapType.satellite,
            ),
            _buildMapTypeOption(
              'Hybrid',
              'Satellite with labels',
              Icons.terrain,
              MapType.hybrid,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTypeOption(String title, String subtitle, IconData icon, MapType mapType) {
    final isSelected = _currentMapType == mapType;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? kBrown : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? kBrown : Colors.black,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected 
        ? const Icon(Icons.check, color: kBrown)
        : null,
      onTap: () {
        _changeMapType(mapType);
        Navigator.pop(context);
      },
    );
  }

  void _highlightSurvey(SurveyFeature targetFeature) {
    final matchingFeature = _features.firstWhere(
      (feature) => feature.id == targetFeature.id,
      orElse: () => targetFeature,
    );
    
    setState(() {
      _selectedFeature = matchingFeature;
    });
    
    _buildPolygonsAndMarkers();
    _focusOnSurvey(matchingFeature);
  }

  void _focusOnSurvey(SurveyFeature feature) {
    if (_mapController != null && feature.rings.isNotEmpty && feature.rings.first.isNotEmpty) {
      final centroid = feature.centroid;
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(centroid.latitude, centroid.longitude), 
          16,
        ),
      );
    }
  }

  Future<void> _loadVillageSurveyData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final villageFeatures = await GeoLoader.loadVillageFeatures();
      final surveyFeatures = villageFeatures
          .map((vf) => SurveyFeature.fromVillageFeature(vf))
          .toList();
      
      if (mounted) {
        setState(() {
          _features = surveyFeatures;
          _isLoading = false;
        });
        _buildPolygonsAndMarkers();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load village survey data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _buildPolygonsAndMarkers() {
    final polygons = <Polygon>{};
    final markers = <Marker>{};
    
    for (int i = 0; i < _features.length; i++) {
      final feature = _features[i];
      
      if (feature.rings.isNotEmpty && feature.rings.first.isNotEmpty) {
        final isSelected = _selectedFeature?.id == feature.id;
        final surveyNumber = feature.surveyNumber.isNotEmpty 
            ? feature.surveyNumber 
            : '${i + 1}';
        
        // Create polygon for survey boundaries
        final polygon = Polygon(
          polygonId: PolygonId('survey_${feature.id}'),
          points: feature.rings.first.map((point) => 
            LatLng(point.latitude, point.longitude)).toList(),
          strokeColor: isSelected ? Colors.blue : Colors.red,
          strokeWidth: isSelected ? 3 : 2,
          fillColor: isSelected 
              ? Colors.blue.withOpacity(0.3) 
              : Colors.red.withOpacity(0.1),
          onTap: () => _onSurveyTapped(feature),
        );
        polygons.add(polygon);
        
        // Create marker for survey center
        final centroid = feature.centroid;
        final marker = Marker(
          markerId: MarkerId('marker_${feature.id}'),
          position: LatLng(centroid.latitude, centroid.longitude),
          infoWindow: InfoWindow(
            title: 'Survey $surveyNumber',
            snippet: feature.name.isNotEmpty ? feature.name : feature.villageName,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed,
          ),
          onTap: () => _onSurveyTapped(feature),
        );
        markers.add(marker);
      }
    }
    
    setState(() {
      _polygons = polygons;
      _markers = markers;
    });
  }

  void _onSurveyTapped(SurveyFeature feature) {
    setState(() {
      _selectedFeature = feature;
    });
    
    _buildPolygonsAndMarkers();
    _focusOnSurvey(feature);
    
    // Show survey info
    _showSurveyInfo(feature);
  }

  void _showSurveyInfo(SurveyFeature feature) {
    final surveyNumber = feature.surveyNumber.isNotEmpty 
        ? feature.surveyNumber 
        : 'N/A';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    surveyNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Survey No. $surveyNumber',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Name: ${feature.name.isNotEmpty ? feature.name : 'N/A'}'),
            Text('Village: ${feature.villageName}'),
            Text('Owner: ${feature.ownerName}'),
            Text('Area: ${feature.areaDisplay}'),
            Text('Land Classification: ${feature.landClassification}'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Village Survey Map'),
        backgroundColor: kBrown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            tooltip: 'Map Type',
            onPressed: _showMapTypeMenu,
          ),
          if (_selectedFeature != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear Selection',
              onPressed: () {
                setState(() {
                  _selectedFeature = null;
                });
                _buildPolygonsAndMarkers();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: kBrown),
                  SizedBox(height: 16),
                  Text('Loading village survey data...'),
                ],
              ),
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
                        onPressed: _loadVillageSurveyData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Map info header
                    Container(
                      color: Colors.green[50],
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Icon(Icons.map_outlined, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Village Survey Map with Boundaries (${_features.length} surveys)${_selectedFeature != null ? ' - Selected Survey Highlighted' : ''}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Google Map
                    Expanded(
                      child: GoogleMap(
                        mapType: _currentMapType,
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(19.0176, 73.0961), // Panvel coordinates
                          zoom: 13,
                        ),
                        polygons: _polygons,
                        markers: _markers,
                        zoomControlsEnabled: true,
                        mapToolbarEnabled: true,
                        myLocationButtonEnabled: false,
                        onTap: (LatLng position) {
                          // Clear selection when tapping empty area
                          setState(() {
                            _selectedFeature = null;
                          });
                          _buildPolygonsAndMarkers();
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
