import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/models/assigned_activity_model.dart';
import 'package:mindfulness_app/models/routine_model.dart';
import 'package:mindfulness_app/services/routines_repository.dart';
import 'package:mindfulness_app/viewmodels/routines_viewmodel.dart';

class FakeRoutinesDataSource implements RoutinesDataSource {
  bool failOnStart = false;
  bool failOnComplete = false;
  String startedSessionId = 'session-123';
  String? lastCompletedSessionId;

  @override
  Future<List<AssignedActivityModel>> fetchAssignedActivities() async {
    return const [];
  }

  @override
  Future<List<RoutineModel>> fetchRoutines() async {
    return const [];
  }

  @override
  Future<String> startSession({
    required String routineId,
    required DateTime startedAt,
  }) async {
    if (failOnStart) throw Exception('start error');
    return startedSessionId;
  }

  @override
  Future<void> completeSession({
    required String sessionId,
    required DateTime completedAt,
  }) async {
    if (failOnComplete) throw Exception('complete error');
    lastCompletedSessionId = sessionId;
  }
}

void main() {
  group('RoutinesViewModel session flow', () {
    const routine = RoutineModel(
      id: 'routine-1',
      title: 'Respiracion',
      description: 'desc',
      category: RoutineCategory.breathing,
      durationSeconds: 180,
    );

    test('starts session and returns session id', () async {
      final repository = FakeRoutinesDataSource();
      final viewModel = RoutinesViewModel(repository: repository);

      final sessionId = await viewModel.startSession(
        routine: routine,
        startedAt: DateTime.now(),
      );

      expect(sessionId, 'session-123');
      expect(viewModel.errorMessage, isNull);
    });

    test('completes session by session id', () async {
      final repository = FakeRoutinesDataSource();
      final viewModel = RoutinesViewModel(repository: repository);

      final completed = await viewModel.completeSession(
        sessionId: 'session-abc',
      );

      expect(completed, isTrue);
      expect(repository.lastCompletedSessionId, 'session-abc');
    });

    test('handles start session failure', () async {
      final repository = FakeRoutinesDataSource()..failOnStart = true;
      final viewModel = RoutinesViewModel(repository: repository);

      final sessionId = await viewModel.startSession(
        routine: routine,
        startedAt: DateTime.now(),
      );

      expect(sessionId, isNull);
      expect(
        viewModel.errorMessage,
        'No se pudo iniciar la sesión. Verifica tu conexión e intenta nuevamente.',
      );
    });
  });
}
