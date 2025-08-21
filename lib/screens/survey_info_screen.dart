import 'package:flutter/material.dart';

const kBrown = Color(0xFF8B4513);
const kBeige = Color(0xFFE8DAD0);

class SurveyInfoScreen extends StatelessWidget {
  const SurveyInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    
    // Responsive sizing
    final bool isWeb = w > 600;
    final bool isTablet = w > 768;
    final double horizontalPadding = isTablet ? w * 0.25 : (isWeb ? w * 0.2 : 20);
    final double cardMaxWidth = isWeb ? 600 : 560;
    
    return Scaffold(
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
                          // Beige ribbon "Survey No."
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWeb ? 24 : 16, 
                              vertical: isWeb ? 12 : 8
                            ),
                            decoration: BoxDecoration(
                              color: kBeige,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Survey No.',
                              style: TextStyle(
                                color: kBrown,
                                fontWeight: FontWeight.w700,
                                fontSize: isWeb ? 20 : (isTablet ? 18 : 16),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),

                          SizedBox(height: isWeb ? 30 : 22),

                          // Centered info card with constrained width
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
