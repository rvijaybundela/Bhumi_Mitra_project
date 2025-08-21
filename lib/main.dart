import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/bhumi_mitra_screen.dart';
import 'screens/survey_info_screen.dart';
import 'features/map/map_screen.dart';

void main() {
  runApp(const BhumiMitraApp());
}

class BhumiMitraApp extends StatelessWidget {
  const BhumiMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'भूमि मित्र - Bhumi Mitra',
      theme: ThemeData(
        fontFamily: 'NotoSansDevanagari',
        primarySwatch: _createMaterialColor(const Color(0xFF8B4513)),
        primaryColor: const Color(0xFF8B4513),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8B4513),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B4513),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF8B4513), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
        ),
      ),
      home: const LandingScreen(),
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/landing': (_) => const LandingScreen(),
        '/language_selection': (_) => const LanguageSelectionScreen(),
        '/signup': (_) => const SignupScreen(),
        '/bhumi_mitra': (_) => const BhumiMitraScreen(),
        '/survey_info': (_) => const SurveyInfoScreen(),
        '/village_map': (context) => const MapScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }

  static MaterialColor _createMaterialColor(Color color) {
    final strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    final swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;
    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
