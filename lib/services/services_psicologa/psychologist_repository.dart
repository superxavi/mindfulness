import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/model_psicologa/patient_model.dart';
import '../../models/routine_model.dart';

import '../../models/model_psicologa/assignment_group_model.dart';
import '../../models/assigned_activity_model.dart';

class PsychologistRepository {
  final _client = Supabase.instance.client;

  Future<List<PatientAssignmentGroup>> getAllAssignmentsGrouped() async {
    try {
      final response = await _client
          .from('assignments')
          .select('''
            id,
            status,
            assigned_at,
            patient_id,
            profiles:patient_id(full_name),
            routines:routine_id(title, category)
          ''')
          .order('assigned_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      // Agrupar por paciente
      final Map<String, List<PatientAssignmentDetail>> groups = {};
      final Map<String, String> patientNames = {};

      for (var item in data) {
        final patientId = item['patient_id'] as String;
        final profile = item['profiles'] as Map<String, dynamic>?;
        final routine = item['routines'] as Map<String, dynamic>?;

        if (profile != null) {
          patientNames[patientId] = profile['full_name'] ?? 'Sin nombre';
        }

        final detail = PatientAssignmentDetail(
          assignmentId: item['id'],
          routineTitle: routine?['title'] ?? 'Sin título',
          category: RoutineCategoryX.fromValue(routine?['category']),
          status: AssignmentStatusX.fromValue(item['status']),
          assignedAt: DateTime.parse(item['assigned_at']),
        );

        groups.putIfAbsent(patientId, () => []).add(detail);
      }

      return groups.entries.map((e) {
        return PatientAssignmentGroup(
          patientId: e.key,
          patientName: patientNames[e.key] ?? 'Paciente Desconocido',
          assignments: e.value,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener asignaciones: $e');
    }
  }

  Future<List<PatientModel>> getPatients() async {
    try {
      // 1. Obtener todos los perfiles que son pacientes
      final List<dynamic> patientsData = await _client
          .from('profiles')
          .select('id, full_name, email')
          .eq('role', 'patient')
          .eq('is_active', true);

      final List<PatientModel> patients = [];

      for (var data in patientsData) {
        final patientId = data['id'];

        // 2. Obtener estadísticas de asignaciones para este paciente
        // Nota: En una app real, esto se optimizaría con una View en SQL o una RPC
        final assignmentsResponse = await _client
            .from('assignments')
            .select('status, routines(title)')
            .eq('patient_id', patientId);

        final List<dynamic> assignments = assignmentsResponse as List<dynamic>;

        int total = assignments.length;
        int completed = assignments
            .where((a) => a['status'] == 'completed')
            .length;

        double progress = total > 0 ? (completed / total) : 0.0;

        // Obtener la tarea más reciente (asumiendo que la última en la lista es la más nueva o podríamos ordenar por fecha)
        String? latestTask;
        if (assignments.isNotEmpty) {
          // Intentamos sacar el título de la rutina si existe el join
          final routineData = assignments.last['routines'];
          if (routineData != null) {
            latestTask = routineData['title'] as String?;
          }
        }

        patients.add(
          PatientModel.fromMap(
            data as Map<String, dynamic>,
            progress: progress,
            totalAssigned: total,
            totalCompleted: completed,
            currentTask: latestTask,
          ),
        );
      }

      return patients;
    } catch (e) {
      throw Exception('Error al obtener pacientes: $e');
    }
  }

  Future<void> assignRoutine({
    required String patientId,
    required String professionalId,
    required String routineId,
    DateTime? targetCompletion,
  }) async {
    try {
      await _client.from('assignments').insert({
        'patient_id': patientId,
        'professional_id': professionalId,
        'routine_id': routineId,
        'status': 'pending',
        'target_completion': targetCompletion?.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error al asignar rutina: $e');
    }
  }

  Future<List<RoutineModel>> getAvailableRoutines() async {
    try {
      final List<dynamic> data = await _client
          .from('routines')
          .select('*')
          .eq('is_active', true)
          .eq('is_visible_to_patients', true);

      return data
          .map((r) => RoutineModel.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener rutinas: $e');
    }
  }
}
