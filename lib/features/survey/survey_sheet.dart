import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/models/survey_feature.dart';
import 'report_service.dart';

const kBrown = Color(0xFF8B4513);

/// Phase 2: Survey details bottom sheet with key properties
/// Phase 4: "Download Sketch" integration with report service
class SurveySheet extends StatelessWidget {
  final SurveyFeature feature;
  final VoidCallback? onClose;

  const SurveySheet({
    super.key,
    required this.feature,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Phase 2: Header with key properties
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kBrown.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: kBrown, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phase 2: Village name
                      Text(
                        feature.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kBrown,
                        ),
                      ),
                      // Phase 2: Survey number
                      Text(
                        'Survey No: ${feature.surveyNumber}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Phase 2: Area
                      Text(
                        'Area: ${feature.areaDisplay}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: kBrown),
                  ),
              ],
            ),
          ),
          
          // Phase 2: Survey details content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  _buildSection(
                    title: 'Survey Information',
                    icon: Icons.description,
                    children: [
                      _buildInfoRow('Survey Number', feature.surveyNumber),
                      _buildInfoRow('Owner Name', feature.ownerName),
                      _buildInfoRow('Khata Number', feature.khataNumber),
                      _buildInfoRow('Area', feature.areaDisplay),
                      _buildInfoRow('Land Classification', feature.landClassification),
                      _buildInfoRow('Irrigation Type', feature.irrigationType),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Location Details Section
                  _buildSection(
                    title: 'Location Details',
                    icon: Icons.location_city,
                    children: [
                      _buildInfoRow('District', feature.districtName),
                      _buildInfoRow('Taluk', feature.talukName),
                      _buildInfoRow('Hobli', feature.hobliName),
                      _buildInfoRow('Village', feature.villageName),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Coordinates Section
                  _buildSection(
                    title: 'Coordinates',
                    icon: Icons.gps_fixed,
                    children: [
                      _buildInfoRow(
                        'Centroid',
                        '${feature.centroid.latitude.toStringAsFixed(6)}, ${feature.centroid.longitude.toStringAsFixed(6)}',
                      ),
                      _buildInfoRow(
                        'Total Points',
                        '${feature.rings.fold<int>(0, (sum, ring) => sum + ring.length)} coordinate points',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Technical Details Section
                  if (feature.lastUpdated != null || feature.areaInSqMeters != null)
                    _buildSection(
                      title: 'Technical Details',
                      icon: Icons.info,
                      children: [
                        if (feature.lastUpdated != null)
                          _buildInfoRow(
                            'Last Updated',
                            '${feature.lastUpdated!.day}/${feature.lastUpdated!.month}/${feature.lastUpdated!.year}',
                          ),
                        _buildInfoRow('Feature ID', feature.id),
                        if (feature.areaInSqMeters != null)
                          _buildInfoRow(
                            'Area (sq.m)',
                            feature.areaInSqMeters!.toStringAsFixed(2),
                          ),
                        if (feature.areaInAcres != null)
                          _buildInfoRow(
                            'Area (acres)',
                            feature.areaInAcres!.toStringAsFixed(4),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          
          // Phase 4: Action buttons including "Download Sketch"
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // View on Map button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Map will already be focused on this feature
                        },
                        icon: const Icon(Icons.map, color: kBrown),
                        label: const Text(
                          'View on Map',
                          style: TextStyle(color: kBrown),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kBrown),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Phase 4: Download Sketch button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadSketch(context),
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: const Text(
                          'Download Sketch',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrown,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Additional actions row
                Row(
                  children: [
                    // Share coordinates
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _shareCoordinates(context),
                        icon: const Icon(Icons.share, color: kBrown),
                        label: const Text(
                          'Share Coordinates',
                          style: TextStyle(color: kBrown),
                        ),
                      ),
                    ),
                    // View full details
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _showFullDetails(context),
                        icon: const Icon(Icons.info_outline, color: kBrown),
                        label: const Text(
                          'Full Details',
                          style: TextStyle(color: kBrown),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Phase 4: Download survey sketch using report service
  Future<void> _downloadSketch(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Generating survey sketch...'),
            ],
          ),
        ),
      );

      // Phase 4: Call report service to generate and share
      await ReportService.generateAndSharePngReport(
        feature: feature,
        mapSnapshot: Uint8List(0), // In real implementation, pass map snapshot
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Survey sketch generated successfully!'),
            backgroundColor: kBrown,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating sketch: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareCoordinates(BuildContext context) {
    final coordinates = 'Survey ${feature.surveyNumber} Location:\n'
        'Latitude: ${feature.centroid.latitude.toStringAsFixed(6)}\n'
        'Longitude: ${feature.centroid.longitude.toStringAsFixed(6)}\n'
        'Village: ${feature.name}\n'
        'Owner: ${feature.ownerName}';
    
    // In real implementation, use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coordinates copied: $coordinates'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showFullDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Full Survey Details - ${feature.surveyNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Complete Address: ${feature.fullAddress}'),
              const SizedBox(height: 8),
              Text('All Properties:'),
              ...feature.properties.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: kBrown, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kBrown,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
