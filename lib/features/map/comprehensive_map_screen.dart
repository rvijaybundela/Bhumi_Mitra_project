import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/services/location_service.dart';
import '../../data/services/geo_data_service.dart';
import '../../data/models/survey_feature.dart';

const kBrown = Color(0xFF8B4513);

class ComprehensiveMapScreen extends StatefulWidget {
  const ComprehensiveMapScreen({super.key});

  @override
  State<ComprehensiveMapScreen> createState() => _ComprehensiveMapScreenState();
}

class _ComprehensiveMapScreenState extends State<ComprehensiveMapScreen> {
  GoogleMapController? _mapController;
  List<SurveyFeature> _features = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _error;
  Position? _currentPosition;
  SurveyFeature? _userLocationSurvey;
  bool _locationPermissionGranted = false;
  String _locationStatus = 'Checking location permissions...';
  List<SurveyFeature> _nearbySurveys = [];
  MapType _currentMapType = MapType.normal;

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

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load survey data using the new service
      final surveyFeatures = await GeoDataService.instance.loadSurveyFeatures();
      
      if (mounted) {
        setState(() {
          _features = surveyFeatures;
          _isLoading = false;
        });
        
        // Check location permission and get user location
        await _checkLocationAndFindSurvey();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load map data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkLocationAndFindSurvey() async {
    setState(() {
      _locationStatus = 'Getting your location...';
    });

    try {
      // Use the enhanced location service
      final result = await LocationService.instance.findSurveyAtCurrentLocation();
      
      if (result.isFound) {
        setState(() {
          _userLocationSurvey = result.survey;
          _currentPosition = result.position;
          _locationPermissionGranted = true;
          _locationStatus = result.statusMessage;
        });
        
        // Add user location marker and focus on it
        _addUserLocationMarker(result.position!);
        _focusOnUserLocation(result.position!);
        
        // Find nearby surveys
        await _findNearbySurveys(result.position!);
        
      } else if (result.isNotFound) {
        setState(() {
          _userLocationSurvey = null;
          _currentPosition = result.position;
          _locationPermissionGranted = true;
          _locationStatus = result.statusMessage;
        });
        
        // Add user location marker and focus on it
        _addUserLocationMarker(result.position!);
        _focusOnUserLocation(result.position!);
        
        // Find nearby surveys
        await _findNearbySurveys(result.position!);
        
      } else {
        setState(() {
          _locationStatus = result.statusMessage;
          _locationPermissionGranted = false;
        });
      }
    } catch (e) {
      setState(() {
        _locationStatus = 'Error getting location: ${e.toString()}';
        _locationPermissionGranted = false;
      });
    }
  }

  Future<void> _findNearbySurveys(Position position) async {
    try {
      final nearbySurveys = await LocationService.instance.findNearbySurveys(
        position, 
        1000, // 1km radius
      );
      
      setState(() {
        _nearbySurveys = nearbySurveys;
      });
    } catch (e) {
      print('Error finding nearby surveys: $e');
    }
  }

  void _addUserLocationMarker(Position position) {
    final userMarker = Marker(
      markerId: const MarkerId('user_location'),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: InfoWindow(
        title: '📍 Your Location',
        snippet: _userLocationSurvey != null 
            ? 'Within Survey ${_userLocationSurvey!.surveyNumber}'
            : 'Not in any survey area',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    
    setState(() {
      _markers = {userMarker};
    });
  }

  void _focusOnUserLocation(Position position) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        16,
      ),
    );
  }

  void _showSurveyDetails() {
    if (_userLocationSurvey == null) return;
    
    final feature = _userLocationSurvey!;
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
                const Icon(Icons.location_on, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You are in Survey No. $surveyNumber',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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

  void _showNearbySurveys() {
    if (_nearbySurveys.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.near_me, color: kBrown, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nearby Surveys (${_nearbySurveys.length})',
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
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _nearbySurveys.length,
                  itemBuilder: (context, index) {
                    final survey = _nearbySurveys[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: kBrown,
                        child: Text(
                          survey.surveyNumber.isNotEmpty ? survey.surveyNumber : '${index + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      title: Text('Survey No. ${survey.surveyNumber}'),
                      subtitle: Text('${survey.villageName} • ${survey.areaDisplay}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        _focusOnSurvey(survey);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _focusOnSurvey(SurveyFeature survey) {
    final centroid = survey.centroid;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(centroid.latitude, centroid.longitude),
        18,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprehensive Map'),
        backgroundColor: kBrown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            tooltip: 'Map Type',
            onPressed: _showMapTypeMenu,
          ),
          if (_locationPermissionGranted)
            IconButton(
              icon: const Icon(Icons.my_location),
              tooltip: 'Get My Location',
              onPressed: _checkLocationAndFindSurvey,
            ),
          if (_nearbySurveys.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.near_me),
              tooltip: 'Nearby Surveys',
              onPressed: _showNearbySurveys,
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
                  Text('Loading comprehensive map...'),
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
                        onPressed: _initializeMap,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Location status header
                    Container(
                      color: _userLocationSurvey != null 
                          ? Colors.green[50] 
                          : Colors.orange[50],
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            _userLocationSurvey != null 
                                ? Icons.location_on 
                                : Icons.location_off,
                            color: _userLocationSurvey != null 
                                ? Colors.green[700] 
                                : Colors.orange[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _locationStatus,
                              style: TextStyle(
                                color: _userLocationSurvey != null 
                                    ? Colors.green[700] 
                                    : Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (_userLocationSurvey != null)
                            IconButton(
                              icon: const Icon(Icons.info),
                              onPressed: _showSurveyDetails,
                              color: Colors.green[700],
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
                          zoom: 12,
                        ),
                        markers: _markers,
                        zoomControlsEnabled: true,
                        mapToolbarEnabled: true,
                        myLocationEnabled: _locationPermissionGranted,
                        myLocationButtonEnabled: false, // We have our custom button
                        compassEnabled: true,
                        rotateGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _locationPermissionGranted && _currentPosition != null
          ? FloatingActionButton(
              onPressed: () => _focusOnUserLocation(_currentPosition!),
              backgroundColor: kBrown,
              child: const Icon(Icons.my_location, color: Colors.white),
            )
          : null,
    );
  }
}
