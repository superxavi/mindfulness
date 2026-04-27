enum AssessmentContext { preSession, postSession, standalone }

extension AssessmentContextX on AssessmentContext {
  String get dbValue {
    return switch (this) {
      AssessmentContext.preSession => 'pre_session',
      AssessmentContext.postSession => 'post_session',
      AssessmentContext.standalone => 'standalone',
    };
  }

  static AssessmentContext fromDbValue(String? value) {
    return switch (value) {
      'pre_session' => AssessmentContext.preSession,
      'post_session' => AssessmentContext.postSession,
      _ => AssessmentContext.standalone,
    };
  }
}

class SelfAssessmentModel {
  const SelfAssessmentModel({
    required this.id,
    required this.patientId,
    required this.sessionId,
    required this.context,
    required this.emotionId,
    required this.intensity,
    required this.recordedAt,
  });

  final String id;
  final String patientId;
  final String? sessionId;
  final AssessmentContext context;
  final String emotionId;
  final int intensity;
  final DateTime recordedAt;

  factory SelfAssessmentModel.fromJson(Map<String, dynamic> json) {
    final recordedAt = DateTime.tryParse(json['recorded_at'] as String? ?? '');
    return SelfAssessmentModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      sessionId: json['session_id'] as String?,
      context: AssessmentContextX.fromDbValue(json['context'] as String?),
      emotionId: json['emotion_id'] as String? ?? '',
      intensity: json['intensity'] as int? ?? 1,
      recordedAt: recordedAt ?? DateTime.now(),
    );
  }
}
