import 'package:flutter/material.dart';
import '../data/models/survey_feature.dart';
import '../models/village_feature.dart';

const kBrown = Color(0xFF8B4513);
const kBeige = Color(0xFFE8DAD0);

class SurveyInfoScreen extends StatefulWidget {
  const SurveyInfoScreen({Key? key}) : super(key: key);

  @override
  State<SurveyInfoScreen> createState() => _SurveyInfoScreenState();
}

class _SurveyInfoScreenState extends State<SurveyInfoScreen> with WidgetsBindingObserver {
  bool _showSurveyList = false;
  List<String> _allSurveyNumbers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAllSurveyNumbers();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reset survey list when app comes back to foreground
      if (mounted) {
        setState(() {
          _showSurveyList = false;
        });
      }
    }
  }

  // Add this method to handle route changes
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset survey list when returning to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _showSurveyList = false;
        });
      }
    });
  }

  void _loadAllSurveyNumbers() {
    // Mock survey numbers from API
    _allSurveyNumbers = [
      '101', '102', '103', '104', '105',
      '201', '202', '203', '204', '205',
      '301', '302', '303', '304', '305',
      '401', '402', '403', '404', '405',
    ];
  }

  void _onSurveyButtonPressed() {
    setState(() {
      _showSurveyList = !_showSurveyList;
    });
  }

  // Add method to reset survey list state
  void _resetSurveyListState() {
    if (mounted) {
      setState(() {
        _showSurveyList = false;
        _isLoading = false;
      });
    }
  }

  void _onSurveyNumberSelected(String surveyNumber) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call to get survey location
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock survey feature for selected survey number
      final mockSurveyFeature = SurveyFeature(
        id: 'SURVEY_$surveyNumber',
        properties: {
          'survey_no': surveyNumber,
          'village_name': 'Panvel Village ${surveyNumber.startsWith('1') ? '1' : '2'}',
          'district_name': 'Panvel District',
          'taluk_name': 'Panvel Taluk',
          'hobli_name': 'Panvel Hobli',
        },
        rings: [
          [
            const LatLng(19.0144, 73.1198),
            const LatLng(19.0154, 73.1208),
            const LatLng(19.0134, 73.1218),
            const LatLng(19.0124, 73.1188),
            const LatLng(19.0144, 73.1198),
          ],
        ],
        districtId: 'PANVEL',
        districtName: 'Panvel District',
        talukId: 'PANVEL_TALUK',
        talukName: 'Panvel Taluk',
        hobliId: 'PANVEL_HOBLI',
        hobliName: 'Panvel Hobli',
        villageId: 'PANVEL_VILLAGE_1',
        villageName: 'Panvel Village ${surveyNumber.startsWith('1') ? '1' : '2'}',
        ownerName: 'Owner Name',
        khataNumber: 'KH$surveyNumber',
        landClassification: 'Agricultural',
        irrigationType: 'Rain Fed',
      );

      // Hide the survey list before navigation
      setState(() {
        _showSurveyList = false;
        _isLoading = false;
      });

      // Navigate to map with selected survey location
      if (mounted) {
        await Navigator.pushNamed(
          context, 
          '/village_map',
          arguments: {
            'surveyFeature': mockSurveyFeature,
            'surveyNumber': surveyNumber,
          },
        );
        
        // When returning from map, ensure survey list stays hidden
        _resetSurveyListState();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading survey location: $e')),
        );
      }
    } finally {
      // Always reset to clean state
      _resetSurveyListState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    
    // Responsive sizing
    final bool isWeb = w > 600;
    final bool isTablet = w > 768;
    final double horizontalPadding = isTablet ? w * 0.25 : (isWeb ? w * 0.2 : 20);
    final double cardMaxWidth = isWeb ? 600 : 560;
    
    return PopScope(
      canPop: !_showSurveyList, // Allow pop only if survey list is hidden
      onPopInvokedWithResult: (didPop, result) {
        // If survey list is showing and we haven't popped yet, hide it
        if (_showSurveyList && !didPop) {
          setState(() {
            _showSurveyList = false;
          });
        }
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kBrown,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Bhumi Mitra',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: isWeb ? 22 : 20,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Map background across the whole page
              Image.asset(
                'assets/images/bg_map.png', 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: kBrown.withOpacity(0.1),
                    child: const Center(
                      child: Icon(Icons.map, size: 100, color: Colors.grey),
                    ),
                  );
                },
              ),
              // Very light overlay to keep text readable but keep map visible
              Container(color: Colors.white.withOpacity(0.08)),

              SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - MediaQuery.of(context).padding.top,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isWeb ? 20 : 10),
                      child: Column(
                        children: [
                          SizedBox(height: isWeb ? 20 : 10),
                          // Clickable "Survey No." button
                          GestureDetector(
                            onTap: _isLoading ? null : _onSurveyButtonPressed,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isWeb ? 24 : 16, 
                                vertical: isWeb ? 12 : 8
                              ),
                              decoration: BoxDecoration(
                                color: _isLoading ? kBeige.withOpacity(0.5) : kBeige,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isLoading)
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(kBrown),
                                      ),
                                    )
                                  else
                                    Icon(
                                      _showSurveyList ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: kBrown,
                                      size: isWeb ? 20 : 18,
                                    ),
                                  SizedBox(width: 8),
                                  Text(
                                    _showSurveyList ? 'Hide Survey Numbers' : 'Show All Survey Numbers',
                                    style: TextStyle(
                                      color: kBrown,
                                      fontWeight: FontWeight.w700,
                                      fontSize: isWeb ? 20 : (isTablet ? 18 : 16),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: isWeb ? 20 : 15),

                          // Survey numbers list (shown when button is pressed)
                          if (_showSurveyList)
                            Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: cardMaxWidth),
                                child: Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: isWeb ? 20 : 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(isWeb ? 20 : 16),
                                        child: Text(
                                          'Available Survey Numbers',
                                          style: TextStyle(
                                            fontSize: isWeb ? 18 : 16,
                                            fontWeight: FontWeight.bold,
                                            color: kBrown,
                                          ),
                                        ),
                                      ),
                                      Divider(height: 1, color: Colors.grey[300]),
                                      Container(
                                        constraints: BoxConstraints(
                                          maxHeight: isWeb ? 300 : 250,
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _allSurveyNumbers.length,
                                          itemBuilder: (context, index) {
                                            final surveyNumber = _allSurveyNumbers[index];
                                            return ListTile(
                                              leading: Icon(
                                                Icons.location_on,
                                                color: kBrown,
                                                size: isWeb ? 22 : 20,
                                              ),
                                              title: Text(
                                                'Survey No. $surveyNumber',
                                                style: TextStyle(
                                                  fontSize: isWeb ? 16 : 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: kBrown,
                                                ),
                                              ),
                                              subtitle: Text(
                                                'Panvel Village ${surveyNumber.startsWith('1') ? '1' : '2'}',
                                                style: TextStyle(
                                                  fontSize: isWeb ? 14 : 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              trailing: Icon(
                                                Icons.arrow_forward_ios,
                                                color: kBrown,
                                                size: 16,
                                              ),
                                              onTap: () => _onSurveyNumberSelected(surveyNumber),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // Original info card (hidden when survey list is shown)
                          if (!_showSurveyList)
                            Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: cardMaxWidth),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(isWeb ? 24 : 18),
                                  decoration: BoxDecoration(
                                    color: kBrown,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _InfoLine(label: 'Survey Number -', isWeb: isWeb),
                                      _InfoLine(label: 'Village Name -', isWeb: isWeb),
                                      _InfoLine(label: 'Hobli Name -', isWeb: isWeb),
                                      _InfoLine(label: 'Taluk Name -', isWeb: isWeb),
                                      _InfoLine(label: 'District Name -', isWeb: isWeb),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          SizedBox(height: isWeb ? 40 : 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      ), // Close PopScope
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final bool isWeb;
  const _InfoLine({required this.label, this.isWeb = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isWeb ? 8 : 6),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: isWeb ? 16 : 14,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}
