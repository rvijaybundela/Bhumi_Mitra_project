import 'package:flutter/material.dart';
import '../ui/shared.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const kBrown = Color(0xFF8B4513);
    final size = MediaQuery.of(context).size;
    final w = size.width;

    // Breakpoints
    final bool isWeb = w > 600;
    final bool isTablet = w > 768;

    // Responsive padding to prevent overflow
    final double horizontalPadding =
        isTablet ? w * 0.15 : (isWeb ? w * 0.12 : 12);

    // Adjusted font sizes to prevent pixel overflow
    final double titleFontSize = isWeb ? 22 : (isTablet ? 20 : 18);
    final double mainTitleFontSize = isWeb ? 52 : (isTablet ? 48 : 44);
    final double hindiFontSize = isWeb ? 48 : (isTablet ? 44 : 40);
    final double subtitleFontSize = isWeb ? 22 : (isTablet ? 20 : 18);

    // Compact emblem sizing to save space
    final double emblemTarget = isWeb ? 160 : (isTablet ? 140 : 120);
    final double emblemMin = isWeb ? 100 : 80;

    return SplitScaffold(
      // TOP: No scroll. Uses flexible emblem and scale-down subtitle so both always visible.
      topChild: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: isWeb ? 12 : 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title card
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 16 : 12,
                vertical: isWeb ? 10 : 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBrown, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Text(
                'Survey Settlement and\nLand Records',
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w700,
                  color: kBrown,
                  height: 1.15,
                ),
              ),
            ),

            SizedBox(height: isWeb ? 12 : 8),

            // Emblem and subtitle block that adapts instead of overflowing
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emblem: can shrink between emblemMin and emblemTarget to prevent pushing text out
                LayoutBuilder(
                  builder: (context, c) {
                    final maxPossible = c.maxWidth.clamp(emblemMin, emblemTarget);
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxPossible,
                        minWidth: emblemMin,
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.asset(
                            'assets/images/emblem_india.png',
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.account_balance,
                              size: emblemMin,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: isWeb ? 4 : 3),

                // Government of Maharashtra text - ensure visibility
                Container(
                  constraints: BoxConstraints(
                    maxWidth: w - (horizontalPadding * 2),
                  ),
                  child: Text(
                    'Government of Maharashtra',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // MID: Fixed layout without scroll
      midFloat: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place, color: kBrown, size: isWeb ? 28 : 24),
          SizedBox(height: isWeb ? 6 : 4),
          Text(
            'Bhumi Mitra',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: mainTitleFontSize,
              fontWeight: FontWeight.w800,
              color: kBrown,
              height: 1.2,
            ),
          ),
          SizedBox(height: isWeb ? 4 : 2),
          Text(
            'भूमि मित्र',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: hindiFontSize,
              fontWeight: FontWeight.w800,
              color: kBrown,
              height: 1.0,
            ),
          ),
        ],
      ),

      // BOTTOM: full-width button unchanged
      bottomChild: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            text: 'Proceed',
            onPressed: () => Navigator.pushNamed(context, '/language_selection'),
          ),
        ),
      ),
    );
  }
}
