class AppConstants {
  // App Information
  static const String appName = 'Bhumi Mitra';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.bhumimitra.com';
  static const String apiVersion = 'v1';
  static const Duration requestTimeout = Duration(seconds: 30);

  // Local Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'selected_language';
  static const String themeKey = 'app_theme';
  static const String surveysKey = 'saved_surveys';

  // GPS and Location
  static const double defaultLatitude = 23.0225;
  static const double defaultLongitude = 72.5714;
  static const double locationAccuracyThreshold = 10.0; // meters
  static const Duration locationUpdateInterval = Duration(seconds: 5);

  // Measurement Defaults
  static const double minAreaThreshold = 1.0; // square meters
  static const double minDistanceThreshold = 0.1; // meters
  static const int maxCoordinatePoints = 1000;
  static const double earthRadius = 6371000; // meters

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 2.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;

  // File and Image
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
  static const double maxImageQuality = 0.8;

  // Routes
  static const String splashRoute = '/';
  static const String languageSelectionRoute = '/language_selection';
  static const String signupRoute = '/signup';
  static const String loginRoute = '/login';
  static const String bhumiMitraRoute = '/bhumi_mitra';
  static const String surveyInfoRoute = '/survey_info';
  static const String measurementRoute = '/measurement';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';

  // Error Messages
  static const String networkErrorMessage = 'Network connection failed. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error occurred. Please try again later.';
  static const String gpsErrorMessage = 'GPS is not available. Please enable location services.';
  static const String permissionErrorMessage = 'Required permissions are not granted.';
  static const String invalidDataErrorMessage = 'Invalid data provided. Please check your input.';

  // Success Messages
  static const String surveyCreatedMessage = 'Survey created successfully!';
  static const String measurementSavedMessage = 'Measurement saved successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  static const String dataExportedMessage = 'Data exported successfully!';

  // Measurement Units
  static const Map<String, String> areaUnits = {
    'sqm': 'Square Meters',
    'sqft': 'Square Feet',
    'acre': 'Acres',
    'hectare': 'Hectares',
  };

  static const Map<String, String> distanceUnits = {
    'm': 'Meters',
    'ft': 'Feet',
    'km': 'Kilometers',
    'mi': 'Miles',
  };

  // Conversion Factors (to meters/square meters)
  static const Map<String, double> distanceConversions = {
    'm': 1.0,
    'ft': 0.3048,
    'km': 1000.0,
    'mi': 1609.34,
  };

  static const Map<String, double> areaConversions = {
    'sqm': 1.0,
    'sqft': 0.092903,
    'acre': 4046.86,
    'hectare': 10000.0,
  };
}
