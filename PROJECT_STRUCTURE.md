# Bhumi Mitra - Land Survey and Measurement App

A Flutter application for land surveying and measurement using GPS coordinates.

## Project Structure

```
lib/
├── main.dart                          # App entry point with routing
├── models/                           # Data models
│   ├── user_model.dart              # User data model
│   ├── survey_model.dart            # Survey data model
│   └── measurement_model.dart       # Measurement data model
├── screens/                          # UI screens
│   ├── splash_screen.dart           # App splash screen
│   ├── language_selection_screen.dart # Language selection
│   ├── signup_screen.dart           # User registration
│   ├── bhumi_mitra_screen.dart      # Main dashboard
│   ├── survey_info_screen.dart      # Survey creation form
│   └── measurement_screen.dart      # Measurement tools
├── widgets/                         # Reusable UI components
│   ├── custom_button.dart           # Custom button widget
│   ├── custom_text_field.dart       # Custom text input field
│   ├── info_card.dart               # Information card widget
│   └── measurement_option_tile.dart  # Measurement option selector
├── utils/                           # Utility classes
│   ├── constants.dart               # App constants
│   ├── colors.dart                  # Color scheme
│   ├── text_styles.dart             # Text styling
│   └── navigation_helper.dart       # Navigation utilities
└── services/                        # Business logic services
    ├── auth_service.dart            # Authentication service
    ├── survey_service.dart          # Survey management
    └── location_service.dart        # GPS and location services
```

## Features

### Implemented
- ✅ Complete project structure
- ✅ User authentication (signup flow)
- ✅ Language selection
- ✅ Survey creation and management
- ✅ GPS-based measurements (area, distance, perimeter)
- ✅ Custom UI components
- ✅ Navigation system
- ✅ Data models for users, surveys, and measurements
- ✅ Service layer for business logic

### Measurement Types
- **Area Measurement**: Calculate land area using GPS coordinates
- **Distance Measurement**: Measure distances between points
- **Perimeter Measurement**: Calculate perimeter of land plots

### Services
- **AuthService**: Handle user registration, login, and profile management
- **SurveyService**: Manage survey creation, updates, and data storage
- **LocationService**: GPS tracking, coordinate calculations, and measurement algorithms

## Getting Started

1. Ensure you have Flutter installed
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

## Dependencies

The app uses standard Flutter packages:
- `flutter/material.dart` for UI components
- Custom services for GPS and measurement calculations

## Configuration

Update `pubspec.yaml` with additional dependencies as needed:
- GPS/Location services (when implementing real GPS functionality)
- Local storage (SQLite, SharedPreferences)
- HTTP client for API communication
- Image handling packages

## Development Notes

- All GPS calculations are currently simulated with mock data
- Authentication is implemented with local state management
- Data persistence will require additional packages (SQLite, etc.)
- Real GPS integration will need location permissions setup

## Future Enhancements

- [ ] Real GPS integration
- [ ] Offline data storage
- [ ] Export functionality (PDF, Excel)
- [ ] Map visualization
- [ ] Multi-language support
- [ ] Cloud synchronization
- [ ] Advanced measurement tools
- [ ] Report generation

## Color Scheme

The app uses a green-based color scheme appropriate for agricultural/land applications:
- Primary: Green (#2E7D32)
- Secondary: Light Green (#8BC34A)
- Accent: Material Green (#4CAF50)

## File Organization

Each folder has a specific purpose:
- `models/`: Data structures and business entities
- `screens/`: Full-screen UI pages
- `widgets/`: Reusable UI components
- `utils/`: Helper classes and constants
- `services/`: Business logic and external integrations
