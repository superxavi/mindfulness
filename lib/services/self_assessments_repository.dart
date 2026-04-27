import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/self_assessment_model.dart';

abstract class SelfAssessmentsRepository {
  Future<void> createAssessment({
    required String sessionId,
    required AssessmentContext context,
    required String emotionId,
    required int intensity,
  });

  Future<List<SelfAssessmentModel>> listBySession(String sessionId);
}

class SupabaseSelfAssessmentsRepository implements SelfAssessmentsRepository {
  SupabaseSelfAssessmentsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<void> createAssessment({
    required String sessionId,
    required AssessmentContext context,
    required String emotionId,
    required int intensity,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    await _client.from('self_assessments').insert({
      'patient_id': user.id,
      'session_id': sessionId,
      'context': context.dbValue,
      'emotion_id': emotionId,
      'intensity': intensity,
    });
  }

  @override
  Future<List<SelfAssessmentModel>> listBySession(String sessionId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client
        .from('self_assessments')
        .select(
          'id,patient_id,session_id,context,emotion_id,intensity,recorded_at',
        )
        .eq('patient_id', user.id)
        .eq('session_id', sessionId)
        .order('recorded_at', ascending: true);

    final rows = List<Map<String, dynamic>>.from(response as List);
    return rows.map(SelfAssessmentModel.fromJson).toList();
  }
}
