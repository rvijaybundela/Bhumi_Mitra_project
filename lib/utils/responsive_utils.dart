import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }
  
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 768;
  }
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }
  
  static double getHorizontalPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 768) return w * 0.25; // Tablet
    if (w > 600) return w * 0.2;  // Web
    return 20; // Mobile
  }
  
  static double getContentMaxWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 600) return 600;
    return double.infinity;
  }
  
  static double getButtonHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 768) return 60;
    if (w > 600) return 58;
    return 56;
  }
  
  static double getFontSize(BuildContext context, {
    required double mobile,
    required double tablet,
    required double web,
  }) {
    final w = MediaQuery.of(context).size.width;
    if (w > 768) return web;
    if (w > 600) return tablet;
    return mobile;
  }
  
  static EdgeInsets getScreenPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 768) return EdgeInsets.symmetric(horizontal: w * 0.25, vertical: 24);
    if (w > 600) return EdgeInsets.symmetric(horizontal: w * 0.2, vertical: 20);
    return const EdgeInsets.all(20);
  }
  
  static Widget makeResponsiveContainer({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? getContentMaxWidth(context),
        ),
        child: child,
      ),
    );
  }
  
  static Widget makeScrollableScreen({
    required BuildContext context,
    required Widget child,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
