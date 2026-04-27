import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';
import 'package:mindfulness_app/models/patient_history_model.dart';
import 'package:mindfulness_app/services/patient_history_repository.dart';
import 'package:mindfulness_app/viewmodels/patient_history_viewmodel.dart';
import 'package:mindfulness_app/views/modulo_paciente/patient_home_view.dart';
import 'package:provider/provider.dart';

class FakePatientHistoryRepository implements PatientHistoryRepository {
  bool shouldThrow = false;

  List<HistorySessionItem> sessions = const [];
  List<HistoryEmotionItem> emotions = const [];
  List<HistoryThoughtItem> thoughts = const [];

  @override
  Future<List<HistorySessionItem>> getSessions(int rangeDays) async {
    if (shouldThrow) throw Exception('sessions error');
    return sessions;
  }

  @override
  Future<List<HistoryEmotionItem>> getAssessments(int rangeDays) async {
    if (shouldThrow) throw Exception('emotions error');
    return emotions;
  }

  @override
  Future<List<HistoryThoughtItem>> getThoughtEntries(int rangeDays) async {
    if (shouldThrow) throw Exception('thoughts error');
    return thoughts;
  }
}

Widget _buildApp(PatientHistoryRepository repository) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => PatientHistoryViewModel(
          repository: repository,
          nowProvider: () => DateTime(2026, 4, 24, 21, 0),
        ),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const PatientHomeView(),
    ),
  );
}

void main() {
  testWidgets('renders home progress summary metrics', (tester) async {
    final repository = FakePatientHistoryRepository()
      ..sessions = [
        HistorySessionItem(
          id: 's1',
          routineTitle: 'Rutina 1',
          startedAt: DateTime(2026, 4, 22, 21, 0),
          completedAt: DateTime(2026, 4, 22, 21, 8),
          status: HistorySessionStatus.completed,
          assignmentContext: 'self-initiated',
        ),
      ]
      ..emotions = [
        HistoryEmotionItem(
          id: 'e1',
          sessionId: 's1',
          recordedAt: DateTime(2026, 4, 22, 21, 0),
          preEmotion: 'ansiedad',
          preIntensity: 7,
          postEmotion: 'calma',
          postIntensity: 4,
        ),
      ];

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Progreso reciente (7 dias)'), findsOneWidget);
    expect(find.text('Frecuencia'), findsOneWidget);
    expect(find.text('Completadas'), findsOneWidget);
    expect(find.text('Constancia'), findsOneWidget);
    expect(find.text('1 dias'), findsOneWidget);
    expect(find.text('1/7'), findsOneWidget);
  });

  testWidgets('shows error state when home metrics fail', (tester) async {
    final repository = FakePatientHistoryRepository()..shouldThrow = true;

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudo cargar tu progreso reciente. Intenta nuevamente.'),
      findsOneWidget,
    );
  });
}
