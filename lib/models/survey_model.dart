enum SurveyStatus {
  draft,
  inProgress,
  completed,
  verified,
}

class SurveyModel {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String location;
  final double latitude;
  final double longitude;
  final SurveyStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> measurementIds;
  final Map<String, dynamic>? additionalData;

  SurveyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.measurementIds = const [],
    this.additionalData,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      userId: json['userId'],
      location: json['location'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      status: SurveyStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SurveyStatus.draft,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      measurementIds: List<String>.from(json['measurementIds'] ?? []),
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'measurementIds': measurementIds,
      'additionalData': additionalData,
    };
  }

  SurveyModel copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    String? location,
    double? latitude,
    double? longitude,
    SurveyStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? measurementIds,
    Map<String, dynamic>? additionalData,
  }) {
    return SurveyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      measurementIds: measurementIds ?? this.measurementIds,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
