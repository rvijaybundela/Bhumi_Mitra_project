import 'package:flutter/material.dart';

const kBrown = Color(0xFF8B4513);
const kBeige = Color(0xFFE8DAD0);

class SplitScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget topChild;     // content inside the top white half
  final Widget midFloat;     // content anchored at top of bottom half (optional)
  final Widget? bottomChild; // content anchored at bottom of bottom half (e.g., button)

  const SplitScaffold({
    super.key,
    this.appBar,
    required this.topChild,
    required this.midFloat,
    this.bottomChild,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;
    
    // Responsive sizing
    final bool isWeb = w > 600;
    final bool isTablet = w > 768;
    final double horizontalPadding = isTablet ? w * 0.25 : (isWeb ? w * 0.2 : 20);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: appBar,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              SizedBox(
                height: h * (isWeb ? 0.45 : 0.48),
                width: double.infinity,
                child: Container(
                  height: h * (isWeb ? 0.45 : 0.48),
                  child: topChild,
                ),
              ),
              SizedBox(
                height: h * (isWeb ? 0.55 : 0.52),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
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
                    Container(color: Colors.white.withOpacity(0.12)),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWeb ? 600 : double.infinity,
                          ),
                          child: midFloat,
                        ),
                      ),
                    ),
                    if (bottomChild != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isWeb ? 400 : double.infinity,
                            ),
                            child: bottomChild!,
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

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const PrimaryButton({super.key, required this.text, required this.onPressed});
  
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final bool isWeb = w > 600;
    final bool isTablet = w > 768;
    
    return Container(
      height: isWeb ? 58 : (isTablet ? 56 : 54),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kBrown, kBrown.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kBrown.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: TextStyle(
            fontSize: isWeb ? 18 : (isTablet ? 17 : 16), 
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5
          ),
          elevation: 0,
        ),
        child: Text(text),
      ),
    );
  }
}

Widget beigeRibbon(String text) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(color: kBeige, borderRadius: BorderRadius.circular(6)),
  child: Text(text, style: const TextStyle(color: kBrown, fontWeight: FontWeight.w700, fontSize: 16)),
);
// TODO Implement this library.