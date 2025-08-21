import 'package:flutter/material.dart';
import '../../data/models/admin_levels.dart';
import '../../data/models/survey_feature.dart';
import '../../models/village_feature.dart';

const kBrown = Color(0xFF8B4513);

class HierarchicalSearchScreen extends StatefulWidget {
  final Function(SurveyFeature) onFeatureSelected;

  const HierarchicalSearchScreen({
    super.key,
    required this.onFeatureSelected,
  });

  @override
  State<HierarchicalSearchScreen> createState() => _HierarchicalSearchScreenState();
}

class _HierarchicalSearchScreenState extends State<HierarchicalSearchScreen> {
  District? _selectedDistrict;
  Taluk? _selectedTaluk;
  Hobli? _selectedHobli;
  Village? _selectedVillage;
  
  final TextEditingController _surveyNumberController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;
  
  // Demo data - in real app, this would come from API
  final List<District> _districts = [
    District(
      id: 'PANVEL',
      name: 'Panvel',
      nameKn: 'ಪಾನ್ವೆಲ್',
      taluks: [
        Taluk(
          id: 'PANVEL_TALUK',
          name: 'Panvel Taluk',
          nameKn: 'ಪಾನ್ವೆಲ್ ತಾಲೂಕು',
          districtId: 'PANVEL',
          hoblis: [
            Hobli(
              id: 'PANVEL_HOBLI',
              name: 'Panvel Hobli',
              nameKn: 'ಪಾನ್ವೆಲ್ ಹೊಬ್ಲಿ',
              talukId: 'PANVEL_TALUK',
              villages: [
                Village(
                  id: 'PANVEL_VILLAGE_1',
                  name: 'Panvel Village 1',
                  nameKn: 'ಪಾನ್ವೆಲ್ ಗ್ರಾಮ ೧',
                  hobliId: 'PANVEL_HOBLI',
                  pincode: '410206',
                  surveyNumbers: ['101', '102', '103', '104', '105'],
                ),
                Village(
                  id: 'PANVEL_VILLAGE_2',
                  name: 'Panvel Village 2',
                  nameKn: 'ಪಾನ್ವೆಲ್ ಗ್ರಾಮ ೨',
                  hobliId: 'PANVEL_HOBLI',
                  pincode: '410206',
                  surveyNumbers: ['201', '202', '203', '204', '205'],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _surveyNumberController.dispose();
    super.dispose();
  }

  Future<void> _searchSurvey() async {
    if (_selectedVillage == null || _surveyNumberController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please select village and enter survey number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo, create a mock survey feature
      // In real app, this would be an API call
      final mockSurveyFeature = SurveyFeature(
        id: 'SURVEY_${_selectedVillage!.id}_${_surveyNumberController.text}',
        properties: {
          'survey_no': _surveyNumberController.text,
          'village_name': _selectedVillage!.name,
          'district_name': _selectedDistrict!.name,
          'taluk_name': _selectedTaluk!.name,
          'hobli_name': _selectedHobli!.name,
        },
        rings: [
          [
            const LatLng(19.0144, 73.1198),
            const LatLng(19.0154, 73.1198),
            const LatLng(19.0154, 73.1208),
            const LatLng(19.0144, 73.1208),
          ]
        ],
        districtId: _selectedDistrict!.id,
        districtName: _selectedDistrict!.name,
        talukId: _selectedTaluk!.id,
        talukName: _selectedTaluk!.name,
        hobliId: _selectedHobli!.id,
        hobliName: _selectedHobli!.name,
        villageId: _selectedVillage!.id,
        villageName: _selectedVillage!.name,
        ownerName: 'Sample Owner',
        khataNumber: 'KH${DateTime.now().millisecondsSinceEpoch % 10000}',
        areaInAcres: 2.5,
        landClassification: 'Agricultural',
        irrigationType: 'Rainfed',
      );

      if (mounted) {
        widget.onFeatureSelected(mockSurveyFeature);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Search failed: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Survey'),
        backgroundColor: kBrown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Steps Indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kBrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBrown.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hierarchical Search',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Follow the steps: District → Taluk → Hobli → Village → Survey Number'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // District Dropdown
            _buildDropdown<District>(
              label: 'District',
              value: _selectedDistrict,
              items: _districts,
              onChanged: (district) {
                setState(() {
                  _selectedDistrict = district;
                  _selectedTaluk = null;
                  _selectedHobli = null;
                  _selectedVillage = null;
                });
              },
              getDisplayName: (district) => district.name,
              enabled: true,
            ),
            
            const SizedBox(height: 16),
            
            // Taluk Dropdown
            _buildDropdown<Taluk>(
              label: 'Taluk',
              value: _selectedTaluk,
              items: _selectedDistrict?.taluks ?? [],
              onChanged: (taluk) {
                setState(() {
                  _selectedTaluk = taluk;
                  _selectedHobli = null;
                  _selectedVillage = null;
                });
              },
              getDisplayName: (taluk) => taluk.name,
              enabled: _selectedDistrict != null,
            ),
            
            const SizedBox(height: 16),
            
            // Hobli Dropdown
            _buildDropdown<Hobli>(
              label: 'Hobli',
              value: _selectedHobli,
              items: _selectedTaluk?.hoblis ?? [],
              onChanged: (hobli) {
                setState(() {
                  _selectedHobli = hobli;
                  _selectedVillage = null;
                });
              },
              getDisplayName: (hobli) => hobli.name,
              enabled: _selectedTaluk != null,
            ),
            
            const SizedBox(height: 16),
            
            // Village Dropdown
            _buildDropdown<Village>(
              label: 'Village',
              value: _selectedVillage,
              items: _selectedHobli?.villages ?? [],
              onChanged: (village) {
                setState(() {
                  _selectedVillage = village;
                });
              },
              getDisplayName: (village) => village.name,
              enabled: _selectedHobli != null,
            ),
            
            const SizedBox(height: 16),
            
            // Survey Number Input
            TextField(
              controller: _surveyNumberController,
              enabled: _selectedVillage != null,
              decoration: InputDecoration(
                labelText: 'Survey Number',
                hintText: 'Enter survey number (e.g., 101, 102)',
                prefixIcon: const Icon(Icons.pin_drop, color: kBrown),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kBrown, width: 2),
                ),
                helperText: _selectedVillage != null 
                    ? 'Available: ${_selectedVillage!.surveyNumbers.join(", ")}' 
                    : null,
              ),
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 24),
            
            // Error Display
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            
            const Spacer(),
            
            // Search Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _searchSurvey,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.search),
              label: Text(_isLoading ? 'Searching...' : 'Search Survey'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) getDisplayName,
    required bool enabled,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kBrown, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(getDisplayName(item)),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      hint: Text('Select $label'),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: kBrown),
            SizedBox(width: 8),
            Text('How to Search'),
          ],
        ),
        content: const Text(
          '1. Select District first\n'
          '2. Choose Taluk from the filtered list\n'
          '3. Pick Hobli within the selected Taluk\n'
          '4. Select Village within the Hobli\n'
          '5. Enter the Survey Number\n'
          '6. Press Search to find the survey\n\n'
          'The search will locate the exact survey plot and show it on the map.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
