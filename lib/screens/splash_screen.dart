import 'package:flutter/material.dart';
import 'language_selection_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    
    // Responsive sizing
    final bool isWeb = w > 600;
    final bool isTablet = w > 768;
    final double horizontalPadding = isTablet ? w * 0.25 : (isWeb ? w * 0.15 : 20);
    final double iconSize = isWeb ? 100 : (w * 0.2).clamp(60, 90);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green.shade50, Colors.white],
              ),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isWeb ? 30 : 20),
                        margin: EdgeInsets.symmetric(horizontal: isWeb ? 0 : 10),
                        decoration: BoxDecoration(
                          color: Colors.brown.shade100,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'Survey Settlement and\nLand Records',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isWeb ? 20 : (isTablet ? 18 : 16),
                            fontWeight: FontWeight.w500,
                            color: Colors.brown.shade800,
                          ),
                        ),
                      ),
                      SizedBox(height: isWeb ? 40 : 30),
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance,
                          size: iconSize * 0.5,
                          color: Colors.brown.shade600,
                        ),
                      ),
                      SizedBox(height: isWeb ? 30 : 20),
                      Text(
                        'भूमि मित्र',
                        style: TextStyle(
                          fontSize: isWeb ? 32 : (isTablet ? 28 : 24),
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade700,
                        ),
                      ),
                      SizedBox(height: isWeb ? 15 : 10),
                      Text(
                        'Government of Maharashtra',
                        style: TextStyle(
                          fontSize: isWeb ? 18 : (isTablet ? 16 : 14),
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: isWeb ? 50 : 40),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isWeb ? 400 : double.infinity,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: isWeb ? 60 : 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LanguageSelectionScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown.shade600,
                              padding: EdgeInsets.symmetric(vertical: isWeb ? 18 : 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Proceed',
                              style: TextStyle(
                                fontSize: isWeb ? 20 : (isTablet ? 18 : 16),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
