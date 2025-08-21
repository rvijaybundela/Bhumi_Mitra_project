import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  static const Color brown = Color(0xFF8B4513);
  String selected = 'भाषा निवडा'; // default

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;
    
    // Responsive sizing
    final bool isWeb = w > 600;
    final double imageSize = isWeb ? 140 : (w * 0.35).clamp(120, 160);
    final double horizontalPadding = isWeb ? w * 0.2 : 20;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: brown,
        elevation: 0,
        centerTitle: true,
        title: const Text('Bhumi Mitra',
            style: TextStyle(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // TOP HALF: white with emblem
              SizedBox(
                height: h * 0.50,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 20),
                    // Responsive image sizing
                    Image.asset(
                      'assets/images/emblem_india.png',
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported,
                          size: imageSize,
                          color: Colors.grey,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Responsive container
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8DAD0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'Select Language',
                        style: TextStyle(
                          color: brown,
                          fontSize: isWeb ? 18 : 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              // BOTTOM HALF: bg_map + language area placed at its top
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image with error handling
                    Image.asset(
                      'assets/images/bg_map.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: brown.withOpacity(0.1),
                          child: const Center(
                            child: Icon(Icons.map, size: 100, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                    Container(color: Colors.white.withOpacity(0.12)),

                    // Language controls anchored at top of the bottom half
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWeb ? 400 : double.infinity,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 12),

                              // Responsive dropdown capsule
                              Container(
                                height: isWeb ? 50 : 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.black26, width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selected,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    style: TextStyle(
                                      fontSize: isWeb ? 16 : 14,
                                      color: Colors.black87,
                                    ),
                                    items: const [
                                      'भाषा निवडा',
                                      'English',
                                      'हिंदी',
                                      'मराठी',
                                    ].map((v) => DropdownMenuItem(
                                      value: v,
                                      child: Text(v),
                                    )).toList(),
                                    onChanged: (v) => setState(() => selected = v!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Proceed button at bottom with responsive sizing
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 24),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWeb ? 400 : double.infinity,
                          ),
                          child: SizedBox(
                            height: isWeb ? 60 : 56,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Validation: Don't allow navigation if default language is selected
                                if (selected == 'भाषा निवडा') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('कृपया भाषा निवडा / Please select a language'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pushNamed(context, '/signup');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brown,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: TextStyle(
                                    fontSize: isWeb ? 20 : 18, 
                                    fontWeight: FontWeight.w700),
                              ),
                              child: const Text('Proceed'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
