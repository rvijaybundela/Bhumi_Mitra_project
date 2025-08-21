import 'package:flutter/material.dart';
import '../../data/geo/geo_loader.dart';
import '../../data/models/survey_feature.dart';
import '../survey/survey_sheet.dart';

const kBrown = Color(0xFF8B4513);

class SimpleMapScreen extends StatefulWidget {
  const SimpleMapScreen({super.key});

  @override
  State<SimpleMapScreen> createState() => _SimpleMapScreenState();
}

class _SimpleMapScreenState extends State<SimpleMapScreen> {
  List<SurveyFeature> _features = [];
  bool _isLoading = true;
  String? _error;
  SurveyFeature? _selectedFeature;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Handle navigation from survey selection
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      final targetSurvey = args['surveyFeature'] as SurveyFeature?;
      final surveyNumber = args['surveyNumber'] as String?;
      
      if (targetSurvey != null && _features.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToSurvey(targetSurvey, surveyNumber);
        });
      }
    }
  }

  void _navigateToSurvey(SurveyFeature targetFeature, String? targetNumber) {
    // Find matching survey
    final matchingFeature = _features.firstWhere(
      (feature) => feature.id == targetFeature.id ||
                  (targetNumber != null && feature.surveyNumber.contains(targetNumber)),
      orElse: () => targetFeature,
    );
    
    setState(() {
      _selectedFeature = matchingFeature;
    });
  }

  Future<void> _initializeData() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Map'),
        backgroundColor: kBrown,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: kBrown),
                  SizedBox(height: 16),
                  Text('Loading survey data...'),
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
                        onPressed: _initializeData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Info banner
                    Container(
                      color: Colors.blue[50],
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Survey Numbers List - Tap to select and view blue point',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Survey list showing only survey numbers
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _features.length,
                        itemBuilder: (context, index) {
                          final feature = _features[index];
                          final surveyNumber = feature.surveyNumber.isNotEmpty 
                              ? feature.surveyNumber 
                              : '${index + 1}';
                          final isSelected = _selectedFeature?.id == feature.id;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: isSelected ? Colors.blue[50] : null,
                            elevation: isSelected ? 4 : 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSelected ? Colors.blue : kBrown,
                                child: Text(
                                  surveyNumber,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Survey No. $surveyNumber',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.blue[800] : null,
                                ),
                              ),
                              subtitle: feature.name.isNotEmpty 
                                  ? Text(feature.name)
                                  : const Text('Survey location'),
                              trailing: Icon(
                                Icons.location_on,
                                color: isSelected ? Colors.blue : kBrown,
                                size: isSelected ? 32 : 24,
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedFeature = feature;
                                });
                                // Show survey details
                                _showSurveyDetailsSheet(feature);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
