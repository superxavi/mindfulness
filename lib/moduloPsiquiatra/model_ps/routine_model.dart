import '../../models/routine_model.dart';

class RoutineTemplate {
  final String id;
  final String title;
  final String description;
  final String category;
  final int durationSeconds;
  final BreathingPatternModel? breathingPattern;
  final String? audioUrl;

  RoutineTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.durationSeconds = 300,
    this.breathingPattern,
    this.audioUrl,
  });

  factory RoutineTemplate.fromJson(
    Map<String, dynamic> json, {
    BreathingPatternModel? breathingPattern,
    String? audioUrl,
  }) => RoutineTemplate(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? 'Sin título',
    description: json['description']?.toString() ?? '',
    category: json['category']?.toString() ?? 'general',
    durationSeconds: json['duration_seconds'] as int? ?? 300,
    breathingPattern: breathingPattern,
    audioUrl: audioUrl,
  );
}
