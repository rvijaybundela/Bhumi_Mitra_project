import 'package:flutter/material.dart';
import '../../data/models/survey_feature.dart';

const kBrown = Color(0xFF8B4513);

/// Phase 3: Search without duplication (single entry point)
/// District → Taluk → Hobli → Village + Survey No
/// Returns selectedFeature → map_screen selects + focuses + opens sheet
class SearchScreen extends StatefulWidget {
  final List<SurveyFeature> features;
  
  const SearchScreen({
    super.key,
    required this.features,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? _selectedDistrict;
  String? _selectedTaluk;
  String? _selectedHobli;
  String? _selectedVillage;
  String _surveyNumber = '';
  
  final TextEditingController _surveyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  List<String> _districts = [];
  List<String> _taluks = [];
  List<String> _hoblis = [];
  List<String> _villages = [];
  List<SurveyFeature> _searchResults = [];
  
  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  @override
  void dispose() {
    _surveyController.dispose();
    super.dispose();
  }

  // Phase 3: Extract unique districts from features
  void _loadDistricts() {
    final districtNames = widget.features
        .map((f) => f.districtName)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
        ..sort();
    
    setState(() {
      _districts = districtNames;
    });
  }

  // Phase 3: Cascading dropdown - load taluks based on district
  void _loadTaluks(String district) {
    final talukNames = widget.features
        .where((f) => f.districtName == district)
        .map((f) => f.talukName)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
        ..sort();
    
    setState(() {
      _taluks = talukNames;
      _selectedTaluk = null;
      _selectedHobli = null;
      _selectedVillage = null;
      _hoblis.clear();
      _villages.clear();
      _searchResults.clear();
    });
  }

  // Phase 3: Cascading dropdown - load hoblis based on taluk
  void _loadHoblis(String taluk) {
    final hobliNames = widget.features
        .where((f) => 
            f.districtName == _selectedDistrict &&
            f.talukName == taluk)
        .map((f) => f.hobliName)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
        ..sort();
    
    setState(() {
      _hoblis = hobliNames;
      _selectedHobli = null;
      _selectedVillage = null;
      _villages.clear();
      _searchResults.clear();
    });
  }

  // Phase 3: Cascading dropdown - load villages based on hobli
  void _loadVillages(String hobli) {
    final villageNames = widget.features
        .where((f) => 
            f.districtName == _selectedDistrict &&
            f.talukName == _selectedTaluk &&
            f.hobliName == hobli)
        .map((f) => f.villageName)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
        ..sort();
    
    setState(() {
      _villages = villageNames;
      _selectedVillage = null;
      _searchResults.clear();
    });
  }

  // Phase 3: Search functionality (local filtering)
  void _performSearch() {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    
    // Phase 3: If using assets - filter the in-memory features
    List<SurveyFeature> results = widget.features;
    
    // Filter by district
    if (_selectedDistrict != null) {
      results = results.where((f) => f.districtName == _selectedDistrict!).toList();
    }
    
    // Filter by taluk
    if (_selectedTaluk != null) {
      results = results.where((f) => f.talukName == _selectedTaluk!).toList();
    }
    
    // Filter by hobli
    if (_selectedHobli != null) {
      results = results.where((f) => f.hobliName == _selectedHobli!).toList();
    }
    
    // Filter by village
    if (_selectedVillage != null) {
      results = results.where((f) => f.villageName == _selectedVillage!).toList();
    }
    
    // Filter by survey number
    if (_surveyNumber.isNotEmpty) {
      results = results.where((f) => 
          f.surveyNumber.toLowerCase().contains(_surveyNumber.toLowerCase())).toList();
    }
    
    setState(() {
      _searchResults = results;
    });
  }

  void _clearSearch() {
    setState(() {
      _selectedDistrict = null;
      _selectedTaluk = null;
      _selectedHobli = null;
      _selectedVillage = null;
      _surveyNumber = '';
      _surveyController.clear();
      _taluks.clear();
      _hoblis.clear();
      _villages.clear();
      _searchResults.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Survey'),
        backgroundColor: kBrown,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _clearSearch,
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Search Form
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Phase 3: District → Taluk → Hobli → Village cascading dropdowns
                    
                    // District Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      decoration: const InputDecoration(
                        labelText: 'District',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city, color: kBrown),
                      ),
                      items: _districts.map((district) => DropdownMenuItem(
                        value: district,
                        child: Text(district),
                      )).toList(),
                      onChanged: (district) {
                        setState(() {
                          _selectedDistrict = district;
                        });
                        if (district != null) {
                          _loadTaluks(district);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Taluk Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedTaluk,
                      decoration: const InputDecoration(
                        labelText: 'Taluk',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.domain, color: kBrown),
                      ),
                      items: _taluks.map((taluk) => DropdownMenuItem(
                        value: taluk,
                        child: Text(taluk),
                      )).toList(),
                      onChanged: _selectedDistrict == null ? null : (taluk) {
                        setState(() {
                          _selectedTaluk = taluk;
                        });
                        if (taluk != null) {
                          _loadHoblis(taluk);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Hobli Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedHobli,
                      decoration: const InputDecoration(
                        labelText: 'Hobli',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.place, color: kBrown),
                      ),
                      items: _hoblis.map((hobli) => DropdownMenuItem(
                        value: hobli,
                        child: Text(hobli),
                      )).toList(),
                      onChanged: _selectedTaluk == null ? null : (hobli) {
                        setState(() {
                          _selectedHobli = hobli;
                        });
                        if (hobli != null) {
                          _loadVillages(hobli);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Village Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedVillage,
                      decoration: const InputDecoration(
                        labelText: 'Village',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home, color: kBrown),
                      ),
                      items: _villages.map((village) => DropdownMenuItem(
                        value: village,
                        child: Text(village),
                      )).toList(),
                      onChanged: _selectedHobli == null ? null : (village) {
                        setState(() {
                          _selectedVillage = village;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Phase 3: Survey Number TextField
                    TextFormField(
                      controller: _surveyController,
                      decoration: const InputDecoration(
                        labelText: 'Survey Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers, color: kBrown),
                        hintText: 'Enter survey number',
                      ),
                      onSaved: (value) {
                        _surveyNumber = value ?? '';
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Search Button
                    ElevatedButton.icon(
                      onPressed: _performSearch,
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text('Search', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrown,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Phase 3: Search Results
            if (_searchResults.isNotEmpty)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kBrown.withOpacity(0.1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, color: kBrown),
                            const SizedBox(width: 8),
                            Text(
                              'Search Results (${_searchResults.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kBrown,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final feature = _searchResults[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: kBrown,
                                  child: Text(
                                    feature.surveyNumber.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  feature.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Survey No: ${feature.surveyNumber}'),
                                    Text('Owner: ${feature.ownerName}'),
                                    Text('Area: ${feature.areaDisplay}'),
                                    Text('${feature.villageName}, ${feature.hobliName}'),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward, color: kBrown),
                                onTap: () {
                                  // Phase 3: Return found feature → map_screen selects + focuses + opens sheet
                                  Navigator.pop(context, feature);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
