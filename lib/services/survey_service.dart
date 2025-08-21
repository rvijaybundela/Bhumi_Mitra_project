import 'dart:async';
import '../models/survey_model.dart';

class SurveyService {
  static final SurveyService _instance = SurveyService._internal();
  factory SurveyService() => _instance;
  SurveyService._internal();

  // Stream controllers
  final StreamController<List<SurveyModel>> _surveysController = 
      StreamController<List<SurveyModel>>.broadcast();
  final StreamController<SurveyModel?> _currentSurveyController = 
      StreamController<SurveyModel?>.broadcast();

  // Local storage
  final List<SurveyModel> _surveys = [];
  SurveyModel? _currentSurvey;

  // Getters
  List<SurveyModel> get surveys => List.unmodifiable(_surveys);
  SurveyModel? get currentSurvey => _currentSurvey;
  Stream<List<SurveyModel>> get surveysStream => _surveysController.stream;
  Stream<SurveyModel?> get currentSurveyStream => _currentSurveyController.stream;

  // Initialize service
  Future<void> initialize() async {
    try {
      // TODO: Load surveys from local storage
      await _loadStoredSurveys();
    } catch (e) {
      print('Error initializing survey service: $e');
    }
  }

  // Create new survey
  Future<SurveyModel> createSurvey({
    required String title,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    required String userId,
  }) async {
    try {
      final survey = SurveyModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        userId: userId,
        location: location,
        latitude: latitude,
        longitude: longitude,
        status: SurveyStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to local list
      _surveys.add(survey);
      
      // Set as current survey
      _currentSurvey = survey;

      // TODO: Save to local storage and sync with API
      await _storeSurveys();

      // Notify listeners
      _surveysController.add(List.from(_surveys));
      _currentSurveyController.add(_currentSurvey);

      return survey;
    } catch (e) {
      throw Exception('Failed to create survey: $e');
    }
  }

  // Update existing survey
  Future<SurveyModel> updateSurvey(SurveyModel survey) async {
    try {
      final updatedSurvey = survey.copyWith(
        updatedAt: DateTime.now(),
      );

      // Find and update in local list
      final index = _surveys.indexWhere((s) => s.id == survey.id);
      if (index != -1) {
        _surveys[index] = updatedSurvey;
        
        // Update current survey if it's the same
        if (_currentSurvey?.id == survey.id) {
          _currentSurvey = updatedSurvey;
          _currentSurveyController.add(_currentSurvey);
        }

        // TODO: Save to local storage and sync with API
        await _storeSurveys();

        // Notify listeners
        _surveysController.add(List.from(_surveys));

        return updatedSurvey;
      } else {
        throw Exception('Survey not found');
      }
    } catch (e) {
      throw Exception('Failed to update survey: $e');
    }
  }

  // Delete survey
  Future<void> deleteSurvey(String surveyId) async {
    try {
      // Remove from local list
      _surveys.removeWhere((s) => s.id == surveyId);
      
      // Clear current survey if it was deleted
      if (_currentSurvey?.id == surveyId) {
        _currentSurvey = null;
        _currentSurveyController.add(null);
      }

      // TODO: Remove from local storage and sync with API
      await _storeSurveys();

      // Notify listeners
      _surveysController.add(List.from(_surveys));
    } catch (e) {
      throw Exception('Failed to delete survey: $e');
    }
  }

  // Get survey by ID
  SurveyModel? getSurvey(String surveyId) {
    try {
      return _surveys.firstWhere((s) => s.id == surveyId);
    } catch (e) {
      return null;
    }
  }

  // Set current survey
  void setCurrentSurvey(SurveyModel? survey) {
    _currentSurvey = survey;
    _currentSurveyController.add(_currentSurvey);
  }

  // Get surveys by status
  List<SurveyModel> getSurveysByStatus(SurveyStatus status) {
    return _surveys.where((s) => s.status == status).toList();
  }

  // Get surveys by user
  List<SurveyModel> getSurveysByUser(String userId) {
    return _surveys.where((s) => s.userId == userId).toList();
  }

  // Start survey (change status to in progress)
  Future<SurveyModel> startSurvey(String surveyId) async {
    try {
      final survey = getSurvey(surveyId);
      if (survey == null) {
        throw Exception('Survey not found');
      }

      final updatedSurvey = survey.copyWith(
        status: SurveyStatus.inProgress,
        updatedAt: DateTime.now(),
      );

      return await updateSurvey(updatedSurvey);
    } catch (e) {
      throw Exception('Failed to start survey: $e');
    }
  }

  // Complete survey
  Future<SurveyModel> completeSurvey(String surveyId) async {
    try {
      final survey = getSurvey(surveyId);
      if (survey == null) {
        throw Exception('Survey not found');
      }

      final updatedSurvey = survey.copyWith(
        status: SurveyStatus.completed,
        updatedAt: DateTime.now(),
      );

      return await updateSurvey(updatedSurvey);
    } catch (e) {
      throw Exception('Failed to complete survey: $e');
    }
  }

  // Add measurement to survey
  Future<SurveyModel> addMeasurementToSurvey(
    String surveyId, 
    String measurementId,
  ) async {
    try {
      final survey = getSurvey(surveyId);
      if (survey == null) {
        throw Exception('Survey not found');
      }

      final updatedMeasurementIds = List<String>.from(survey.measurementIds)
        ..add(measurementId);

      final updatedSurvey = survey.copyWith(
        measurementIds: updatedMeasurementIds,
        updatedAt: DateTime.now(),
      );

      return await updateSurvey(updatedSurvey);
    } catch (e) {
      throw Exception('Failed to add measurement to survey: $e');
    }
  }

  // Remove measurement from survey
  Future<SurveyModel> removeMeasurementFromSurvey(
    String surveyId, 
    String measurementId,
  ) async {
    try {
      final survey = getSurvey(surveyId);
      if (survey == null) {
        throw Exception('Survey not found');
      }

      final updatedMeasurementIds = List<String>.from(survey.measurementIds)
        ..remove(measurementId);

      final updatedSurvey = survey.copyWith(
        measurementIds: updatedMeasurementIds,
        updatedAt: DateTime.now(),
      );

      return await updateSurvey(updatedSurvey);
    } catch (e) {
      throw Exception('Failed to remove measurement from survey: $e');
    }
  }

  // Search surveys
  List<SurveyModel> searchSurveys(String query) {
    if (query.isEmpty) return surveys;
    
    final lowerQuery = query.toLowerCase();
    return _surveys.where((survey) {
      return survey.title.toLowerCase().contains(lowerQuery) ||
             survey.description.toLowerCase().contains(lowerQuery) ||
             survey.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Export survey data
  Future<Map<String, dynamic>> exportSurveyData(String surveyId) async {
    try {
      final survey = getSurvey(surveyId);
      if (survey == null) {
        throw Exception('Survey not found');
      }

      // TODO: Include measurement data in export
      return {
        'survey': survey.toJson(),
        'measurements': [], // TODO: Get associated measurements
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to export survey data: $e');
    }
  }

  // Sync with remote server
  Future<void> syncSurveys() async {
    try {
      // TODO: Implement sync with remote API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    } catch (e) {
      throw Exception('Failed to sync surveys: $e');
    }
  }

  // Private methods
  Future<void> _loadStoredSurveys() async {
    try {
      // TODO: Load surveys from local storage (SharedPreferences/SQLite)
    } catch (e) {
      print('Error loading stored surveys: $e');
    }
  }

  Future<void> _storeSurveys() async {
    try {
      // TODO: Store surveys to local storage
    } catch (e) {
      print('Error storing surveys: $e');
    }
  }

  // Get statistics
  Map<String, int> getSurveyStatistics() {
    return {
      'total': _surveys.length,
      'draft': getSurveysByStatus(SurveyStatus.draft).length,
      'inProgress': getSurveysByStatus(SurveyStatus.inProgress).length,
      'completed': getSurveysByStatus(SurveyStatus.completed).length,
      'verified': getSurveysByStatus(SurveyStatus.verified).length,
    };
  }

  // Dispose resources
  void dispose() {
    _surveysController.close();
    _currentSurveyController.close();
  }
}
