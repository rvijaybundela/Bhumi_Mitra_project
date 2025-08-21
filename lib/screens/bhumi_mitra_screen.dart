import 'package:flutter/material.dart';

const kBrown = Color(0xFF8B4513);
const kSubtitle = Color(0xFF9A8F86);

class BhumiMitraScreen extends StatelessWidget {
  const BhumiMitraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    
    // Responsive sizing
    final bool isWeb = w > 600;
    final bool isTablet = w > 768;
    final bool isLargeWeb = w > 1200;
    final double horizontalPadding = isLargeWeb ? w * 0.3 : (isTablet ? w * 0.25 : (isWeb ? w * 0.15 : 20));
    final double buttonHeight = isWeb ? 60 : (isTablet ? 56 : 52);
    final double titleFontSize = isLargeWeb ? 40 : (isWeb ? 32 : (isTablet ? 28 : 24));
    final double buttonFontSize = isLargeWeb ? 16 : (isWeb ? 14 : (isTablet ? 13 : 12));

    return Scaffold(
      backgroundColor: Colors.white,

      // TOP LOOK replaced (AppBar only)
      appBar: AppBar(
        backgroundColor: kBrown,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Text(
          'Bhumi Mitra',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: isWeb ? 22 : 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {}, // settings action (keep as is)
            icon: Icon(Icons.settings, color: Colors.white, size: isWeb ? 26 : 22),
            padding: const EdgeInsets.only(right: 12),
            tooltip: 'Settings',
          ),
        ],
      ),

      // BOTTOM LOOK is untouched
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // your existing bottom map/background (leave as is)
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: h * (isWeb ? 0.35 : 0.40), // Slightly less height on web
                  width: double.infinity,
                  child: Image.asset(
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
                ),
              ),

              // Foreground content
              Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: isWeb ? 20 : 16),
                          // TOP HEADING updated to match screenshot
                          Text(
                            'Welcome to\nBhumi Mitra',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: titleFontSize,      // responsive font size
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              color: kBrown,
                            ),
                          ),

                          SizedBox(height: isWeb ? 24 : 16),

                          // Constrained container for buttons to prevent overflow
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isLargeWeb ? 500 : (isWeb ? 450 : double.infinity),
                            ),
                            child: Column(
                              children: [
                                // Survey No. button
                                SizedBox(
                                  width: double.infinity,
                                  height: buttonHeight,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pushNamed(context, '/survey_info'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kBrown,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                      padding: EdgeInsets.symmetric(horizontal: isWeb ? 30 : 20),
                                      textStyle: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    child: const Text('Survey No.'),
                                  ),
                                ),

                                SizedBox(height: isWeb ? 15 : 10),

                                // Keep your existing subtitle text below the button
                                Text(
                                  'SURVEY NO. LOOKUP',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: kSubtitle,
                                    fontSize: isWeb ? 14 : 12.5,
                                    letterSpacing: 1.3,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                SizedBox(height: isWeb ? 30 : 20),

                                // Village Map button
                                SizedBox(
                                  width: double.infinity,
                                  height: buttonHeight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/village_map');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kBrown,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                      padding: EdgeInsets.symmetric(horizontal: isWeb ? 30 : 20),
                                      textStyle: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    child: const Text('Village Survey Map'),
                                  ),
                                ),

                                SizedBox(height: isWeb ? 15 : 10),

                                Text(
                                  'POLYGON VISUALIZATION',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: kSubtitle,
                                    fontSize: isWeb ? 14 : 12.5,
                                    letterSpacing: 1.3,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                SizedBox(height: isWeb ? 20 : 10),

                                // Comprehensive Map button
                                SizedBox(
                                  width: double.infinity,
                                  height: buttonHeight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/village_map');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kBrown,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                      padding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 15),
                                      textStyle: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.public, size: isWeb ? 22 : 18),
                                          SizedBox(width: isWeb ? 8 : 6),
                                          Text(
                                            isLargeWeb ? 'Comprehensive Map' : (isWeb ? 'Map View' : 'Map'),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: isWeb ? 15 : 10),

                                Text(
                                  'GOOGLE MAPS INTEGRATION',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: kSubtitle,
                                    fontSize: isWeb ? 14 : 12.5,
                                    letterSpacing: 1.3,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
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
