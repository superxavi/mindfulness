import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';
import 'package:mindfulness_app/models/assigned_activity_model.dart';
import 'package:mindfulness_app/models/routine_model.dart';
import 'package:mindfulness_app/models/self_assessment_model.dart';
import 'package:mindfulness_app/services/routines_repository.dart';
import 'package:mindfulness_app/services/self_assessments_repository.dart';
import 'package:mindfulness_app/viewmodels/routines_viewmodel.dart';
import 'package:mindfulness_app/viewmodels/self_assessments_viewmodel.dart';
import 'package:mindfulness_app/views/modulo_paciente/self_assessment_flow.dart';
import 'package:provider/provider.dart';

class FakeRoutinesDataSource implements RoutinesDataSource {
  @override
  Future<void> completeSession({
    required String sessionId,
    required DateTime completedAt,
  }) async {}

  @override
  Future<List<AssignedActivityModel>> fetchAssignedActivities() async =>
      const [];

  @override
  Future<List<RoutineModel>> fetchRoutines() async => const [];

  @override
  Future<String> startSession({
    required String routineId,
    required DateTime startedAt,
  }) async {
    return 'session-1';
  }
}

class FakeSelfAssessmentsRepository implements SelfAssessmentsRepository {
  @override
  Future<void> createAssessment({
    required String sessionId,
    required AssessmentContext context,
    required String emotionId,
    required int intensity,
  }) async {}

  @override
  Future<List<SelfAssessmentModel>> listBySession(String sessionId) async {
    return const [];
  }
}

const _routine = RoutineModel(
  id: 'routine-1',
  title: 'Respiración guiada',
  description: 'desc',
  category: RoutineCategory.breathing,
  durationSeconds: 180,
);

Widget _wrapWithProviders(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => RoutinesViewModel(repository: FakeRoutinesDataSource()),
      ),
      ChangeNotifierProvider(
        create: (_) => SelfAssessmentsViewModel(
          repository: FakeSelfAssessmentsRepository(),
        ),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: child,
    ),
  );
}

void main() {
  testWidgets('pre assessment blocks start until emotion is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithProviders(const PreSessionAssessmentView(routine: _routine)),
    );
    await tester.pumpAndSettle();

    ElevatedButton startButton = tester.widget(
      find.widgetWithText(ElevatedButton, 'Iniciar sesión'),
    );
    expect(startButton.onPressed, isNull);

    await tester.tap(find.text('Calma'));
    await tester.pumpAndSettle();

    startButton = tester.widget(
      find.widgetWithText(ElevatedButton, 'Iniciar sesión'),
    );
    expect(startButton.onPressed, isNotNull);
  });

  testWidgets('post assessment blocks finish until emotion is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithProviders(
        const Scaffold(
          body: PostSessionAssessmentSheet(
            sessionId: 'session-1',
            routineTitle: 'Respiración guiada',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    ElevatedButton finishButton = tester.widget(
      find.widgetWithText(ElevatedButton, 'Guardar y finalizar'),
    );
    expect(finishButton.onPressed, isNull);

    await tester.tap(find.text('Calma'));
    await tester.pumpAndSettle();

    finishButton = tester.widget(
      find.widgetWithText(ElevatedButton, 'Guardar y finalizar'),
    );
    expect(finishButton.onPressed, isNotNull);
  });
}
