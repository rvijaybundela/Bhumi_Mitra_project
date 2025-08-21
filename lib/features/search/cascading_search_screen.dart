import 'package:flutter/material.dart';
import '../../data/models/survey_feature.dart';
import '../../data/models/admin_levels.dart';

const kBrown = Color(0xFF8B4513);

class CascadingSearchScreen extends StatefulWidget {
  final List<SurveyFeature> features;
  
  const CascadingSearchScreen({
    super.key,
    required this.features,
  });

  @override
  State<CascadingSearchScreen> createState() => _CascadingSearchScreenState();
}

class _CascadingSearchScreenState extends State<CascadingSearchScreen> {
  District? _selectedDistrict;
  Taluk? _selectedTaluk;
  Hobli? _selectedHobli;
  Village? _selectedVillage;
  String _surveyNumber = '';
  
  final TextEditingController _surveyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  List<District> _districts = [];
  List<Taluk> _taluks = [];
  List<Hobli> _hoblis = [];
  List<Village> _villages = [];
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

  void _loadDistricts() {
    // Extract unique districts from features
    final districtNames = widget.features
        .map((f) => f.properties['DTName']?.toString() ?? 'Unknown')
        .where((name) => name != 'Unknown')
        .toSet()
        .toList();
    
    setState(() {
      _districts = districtNames
          .asMap()
          .map((index, name) => MapEntry(
                index,
                District(
                  id: (index + 1).toString(),
                  name: name,
                  nameKn: name, // Could be mapped to Kannada
                  taluks: const [],
                ),
              ))
          .values
          .toList();
    });
  }

  void _loadTaluks(District district) {
    final talukNames = widget.features
        .where((f) => f.properties['DTName']?.toString() == district.name)
        .map((f) => f.properties['TalukaName']?.toString() ?? 'Unknown')
        .where((name) => name != 'Unknown')
        .toSet()
        .toList();
    
    setState(() {
      _taluks = talukNames
          .asMap()
          .map((index, name) => MapEntry(
                index,
                Taluk(
                  id: (index + 1).toString(),
                  name: name,
                  nameKn: name,
                  districtId: district.id,
                  hoblis: const [],
                ),
              ))
          .values
          .toList();
      _selectedTaluk = null;
      _selectedHobli = null;
      _selectedVillage = null;
      _hoblis.clear();
      _villages.clear();
    });
  }

  void _loadHoblis(Taluk taluk) {
    final hobliNames = widget.features
        .where((f) => 
            f.properties['DTName']?.toString() == _selectedDistrict?.name &&
            f.properties['TalukaName']?.toString() == taluk.name)
        .map((f) => f.properties['HobliName']?.toString() ?? 'Unknown')
        .where((name) => name != 'Unknown')
        .toSet()
        .toList();
    
    setState(() {
      _hoblis = hobliNames
          .asMap()
          .map((index, name) => MapEntry(
                index,
                Hobli(
                  id: (index + 1).toString(),
                  name: name,
                  nameKn: name,
                  talukId: taluk.id,
                  villages: const [],
                ),
              ))
          .values
          .toList();
      _selectedHobli = null;
      _selectedVillage = null;
      _villages.clear();
    });
  }

  void _loadVillages(Hobli hobli) {
    final villageNames = widget.features
        .where((f) => 
            f.properties['DTName']?.toString() == _selectedDistrict?.name &&
            f.properties['TalukaName']?.toString() == _selectedTaluk?.name &&
            f.properties['HobliName']?.toString() == hobli.name)
        .map((f) => f.properties['VIL_NAME']?.toString() ?? 'Unknown')
        .where((name) => name != 'Unknown')
        .toSet()
        .toList();
    
    setState(() {
      _villages = villageNames
          .asMap()
          .map((index, name) => MapEntry(
                index,
                Village(
                  id: (index + 1).toString(),
                  name: name,
                  nameKn: name,
                  hobliId: hobli.id,
                  pincode: '',
                  surveyNumbers: const [],
                ),
              ))
          .values
          .toList();
      _selectedVillage = null;
    });
  }

  void _performSearch() {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    
    List<SurveyFeature> results = widget.features;
    
    // Filter by district
    if (_selectedDistrict != null) {
      results = results.where((f) => 
          f.properties['DTName']?.toString() == _selectedDistrict!.name).toList();
    }
    
    // Filter by taluk
    if (_selectedTaluk != null) {
      results = results.where((f) => 
          f.properties['TalukaName']?.toString() == _selectedTaluk!.name).toList();
    }
    
    // Filter by hobli
    if (_selectedHobli != null) {
      results = results.where((f) => 
          f.properties['HobliName']?.toString() == _selectedHobli!.name).toList();
    }
    
    // Filter by village
    if (_selectedVillage != null) {
      results = results.where((f) => 
          f.properties['VIL_NAME']?.toString() == _selectedVillage!.name).toList();
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
        title: const Text('Advanced Search'),
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
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // District Dropdown
                    DropdownButtonFormField<District>(
                      value: _selectedDistrict,
                      decoration: const InputDecoration(
                        labelText: 'District',
                        border: OutlineInputBorder(),
                      ),
                      items: _districts.map((district) => DropdownMenuItem(
                        value: district,
                        child: Text(district.name),
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
                    DropdownButtonFormField<Taluk>(
                      value: _selectedTaluk,
                      decoration: const InputDecoration(
                        labelText: 'Taluk',
                        border: OutlineInputBorder(),
                      ),
                      items: _taluks.map((taluk) => DropdownMenuItem(
                        value: taluk,
                        child: Text(taluk.name),
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
                    DropdownButtonFormField<Hobli>(
                      value: _selectedHobli,
                      decoration: const InputDecoration(
                        labelText: 'Hobli',
                        border: OutlineInputBorder(),
                      ),
                      items: _hoblis.map((hobli) => DropdownMenuItem(
                        value: hobli,
                        child: Text(hobli.name),
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
                    DropdownButtonFormField<Village>(
                      value: _selectedVillage,
                      decoration: const InputDecoration(
                        labelText: 'Village',
                        border: OutlineInputBorder(),
                      ),
                      items: _villages.map((village) => DropdownMenuItem(
                        value: village,
                        child: Text(village.name),
                      )).toList(),
                      onChanged: _selectedHobli == null ? null : (village) {
                        setState(() {
                          _selectedVillage = village;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Survey Number TextField
                    TextFormField(
                      controller: _surveyController,
                      decoration: const InputDecoration(
                        labelText: 'Survey Number',
                        border: OutlineInputBorder(),
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
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Search Results
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
                        child: Text(
                          'Search Results (${_searchResults.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kBrown,
                          ),
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
                                title: Text(feature.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Survey No: ${feature.surveyNumber}'),
                                    Text('Owner: ${feature.ownerName}'),
                                    Text('Area: ${feature.areaDisplay}'),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () {
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
