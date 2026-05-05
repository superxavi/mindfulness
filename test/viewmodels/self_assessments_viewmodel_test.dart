import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/models/self_assessment_model.dart';
import 'package:mindfulness_app/services/self_assessments_repository.dart';
import 'package:mindfulness_app/viewmodels/self_assessments_viewmodel.dart';

class FakeSelfAssessmentsRepository implements SelfAssessmentsRepository {
  bool shouldThrowOnCreate = false;
  int createCalls = 0;

  @override
  Future<void> createAssessment({
    required String sessionId,
    required AssessmentContext context,
    required String emotionId,
    required int intensity,
  }) async {
    if (shouldThrowOnCreate) throw Exception('create error');
    createCalls += 1;
  }

  @override
  Future<List<SelfAssessmentModel>> listBySession(String sessionId) async {
    return const [];
  }
}

void main() {
  group('SelfAssessmentsViewModel', () {
    test('validates emotion selection', () async {
      final repository = FakeSelfAssessmentsRepository();
      final viewModel = SelfAssessmentsViewModel(repository: repository);

      final success = await viewModel.createAssessment(
        sessionId: 'session-1',
        context: AssessmentContext.preSession,
        emotionId: '',
        intensity: 5,
      );

      expect(success, isFalse);
      expect(repository.createCalls, 0);
      expect(viewModel.errorMessage, 'Selecciona una emoción para continuar.');
    });

    test('creates assessment successfully', () async {
      final repository = FakeSelfAssessmentsRepository();
      final viewModel = SelfAssessmentsViewModel(repository: repository);

      final success = await viewModel.createAssessment(
        sessionId: 'session-1',
        context: AssessmentContext.postSession,
        emotionId: 'calma',
        intensity: 7,
      );

      expect(success, isTrue);
      expect(repository.createCalls, 1);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.successMessage, 'Registro posterior guardado.');
    });

    test('handles repository errors', () async {
      final repository = FakeSelfAssessmentsRepository()
        ..shouldThrowOnCreate = true;
      final viewModel = SelfAssessmentsViewModel(repository: repository);

      final success = await viewModel.createAssessment(
        sessionId: 'session-1',
        context: AssessmentContext.postSession,
        emotionId: 'ansiedad',
        intensity: 4,
      );

      expect(success, isFalse);
      expect(
        viewModel.errorMessage,
        'No se pudo guardar la autoevaluación. Revisa tu conexión e intenta nuevamente.',
      );
    });
  });
}
