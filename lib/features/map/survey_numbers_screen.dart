import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/geo/geo_loader.dart';
import '../../data/models/survey_feature.dart';

const kBrown = Color(0xFF8B4513);

class SurveyNumbersScreen extends StatefulWidget {
  const SurveyNumbersScreen({super.key});

  @override
  State<SurveyNumbersScreen> createState() => _SurveyNumbersScreenState();
}

class _SurveyNumbersScreenState extends State<SurveyNumbersScreen> {
  List<SurveyFeature> _features = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSurveyNumbers();
  }

  Future<void> _loadSurveyNumbers() async {
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
          _error = 'Failed to load survey data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // Download survey data as PDF
  Future<void> _downloadSurveyPDF(SurveyFeature feature, String surveyNumber) async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Survey Report - $surveyNumber'),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Survey Number: $surveyNumber', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                if (feature.name.isNotEmpty) pw.Text('Name: ${feature.name}'),
                if (feature.ownerName.isNotEmpty) pw.Text('Owner: ${feature.ownerName}'),
                pw.Text('Area: ${feature.areaDisplay}'),
                if (feature.khataNumber.isNotEmpty) pw.Text('Khata Number: ${feature.khataNumber}'),
                if (feature.landClassification.isNotEmpty) pw.Text('Land Classification: ${feature.landClassification}'),
                if (feature.irrigationType.isNotEmpty) pw.Text('Irrigation Type: ${feature.irrigationType}'),
                pw.Text('Village: ${feature.villageName}'),
                pw.Text('District: ${feature.districtName}'),
                pw.SizedBox(height: 20),
                pw.Text('Generated on: ${DateTime.now().toString().split('.')[0]}'),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Survey_$surveyNumber.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: ${e.toString()}')),
        );
      }
    }
  }

  // Share survey data
  Future<void> _shareSurveyData(SurveyFeature feature, String surveyNumber) async {
    try {
      final data = StringBuffer();
      data.writeln('Survey Report - $surveyNumber');
      data.writeln('=====================================');
      data.writeln('Survey Number: $surveyNumber');
      if (feature.name.isNotEmpty) data.writeln('Name: ${feature.name}');
      if (feature.ownerName.isNotEmpty) data.writeln('Owner: ${feature.ownerName}');
      data.writeln('Area: ${feature.areaDisplay}');
      if (feature.khataNumber.isNotEmpty) data.writeln('Khata Number: ${feature.khataNumber}');
      if (feature.landClassification.isNotEmpty) data.writeln('Land Classification: ${feature.landClassification}');
      if (feature.irrigationType.isNotEmpty) data.writeln('Irrigation Type: ${feature.irrigationType}');
      data.writeln('Village: ${feature.villageName}');
      data.writeln('District: ${feature.districtName}');
      data.writeln('\nGenerated on: ${DateTime.now().toString().split('.')[0]}');
      
      await Share.share(
        data.toString(),
        subject: 'Survey Report - $surveyNumber',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing data: ${e.toString()}')),
        );
      }
    }
  }

  // View survey on map
  void _viewOnMap(SurveyFeature feature) {
    Navigator.pushNamed(
      context,
      '/village_survey_map',
      arguments: {
        'surveyFeature': feature,
        'surveyNumber': feature.surveyNumber,
      },
    );
  }

  void _showFullDetails(SurveyFeature feature, String surveyNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kBrown,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      surveyNumber,
                      style: TextStyle(
                        color: kBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Survey No. $surveyNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Survey Number', surveyNumber),
                    _buildDetailRow('Name', feature.name.isNotEmpty ? feature.name : 'N/A'),
                    _buildDetailRow('Village', feature.villageName.isNotEmpty ? feature.villageName : 'N/A'),
                    _buildDetailRow('Owner Name', feature.ownerName.isNotEmpty ? feature.ownerName : 'N/A'),
                    _buildDetailRow('Area', feature.areaDisplay),
                    _buildDetailRow('Land Classification', feature.landClassification.isNotEmpty ? feature.landClassification : 'N/A'),
                    _buildDetailRow('Irrigation Type', feature.irrigationType.isNotEmpty ? feature.irrigationType : 'N/A'),
                    _buildDetailRow('Khata Number', feature.khataNumber.isNotEmpty ? feature.khataNumber : 'N/A'),
                    _buildDetailRow('ID', feature.id),
                    if (feature.rings.isNotEmpty)
                      _buildDetailRow('Coordinates', '${feature.rings.first.length} boundary points'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Numbers'),
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
                  Text('Loading survey numbers...'),
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
                        onPressed: _loadSurveyNumbers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header info
                    Container(
                      color: Colors.blue[50],
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.format_list_numbered, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'All Survey Numbers (${_features.length} records) - Tap for full details',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Survey numbers list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _features.length,
                        itemBuilder: (context, index) {
                          final feature = _features[index];
                          final surveyNumber = feature.surveyNumber.isNotEmpty 
                              ? feature.surveyNumber 
                              : '${index + 1}';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 2,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: kBrown,
                                    child: Text(
                                      surveyNumber,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'Survey No. $surveyNumber',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (feature.name.isNotEmpty)
                                        Text('Name: ${feature.name}'),
                                      if (feature.ownerName.isNotEmpty)
                                        Text('Owner: ${feature.ownerName}'),
                                      Text('Area: ${feature.areaDisplay}'),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: kBrown),
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'details':
                                          _showFullDetails(feature, surveyNumber);
                                          break;
                                        case 'download':
                                          _downloadSurveyPDF(feature, surveyNumber);
                                          break;
                                        case 'share':
                                          _shareSurveyData(feature, surveyNumber);
                                          break;
                                        case 'map':
                                          _viewOnMap(feature);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'details',
                                        child: Row(
                                          children: [
                                            Icon(Icons.info, color: kBrown),
                                            SizedBox(width: 8),
                                            Text('View Details'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'download',
                                        child: Row(
                                          children: [
                                            Icon(Icons.download, color: kBrown),
                                            SizedBox(width: 8),
                                            Text('Download PDF'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'share',
                                        child: Row(
                                          children: [
                                            Icon(Icons.share, color: kBrown),
                                            SizedBox(width: 8),
                                            Text('Share Data'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'map',
                                        child: Row(
                                          children: [
                                            Icon(Icons.map, color: kBrown),
                                            SizedBox(width: 8),
                                            Text('View on Map'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _showFullDetails(feature, surveyNumber),
                                ),
                                // Action buttons row
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _downloadSurveyPDF(feature, surveyNumber),
                                        icon: const Icon(Icons.download, size: 16),
                                        label: const Text('Download'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kBrown,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          minimumSize: const Size(80, 32),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => _shareSurveyData(feature, surveyNumber),
                                        icon: const Icon(Icons.share, size: 16),
                                        label: const Text('Share'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kBrown,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          minimumSize: const Size(80, 32),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => _viewOnMap(feature),
                                        icon: const Icon(Icons.map, size: 16),
                                        label: const Text('View on Map'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kBrown,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          minimumSize: const Size(80, 32),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
