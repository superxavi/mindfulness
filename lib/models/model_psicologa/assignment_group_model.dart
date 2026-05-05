import 'package:mindfulness_app/models/assigned_activity_model.dart';
import 'package:mindfulness_app/models/routine_model.dart';

class PatientAssignmentGroup {
  final String patientId;
  final String patientName;
  final List<PatientAssignmentDetail> assignments;

  PatientAssignmentGroup({
    required this.patientId,
    required this.patientName,
    required this.assignments,
  });

  int get totalTasks => assignments.length;
  int get completedTasks =>
      assignments.where((a) => a.status == AssignmentStatus.completed).length;
  double get progress => totalTasks > 0 ? completedTasks / totalTasks : 0.0;
}

class PatientAssignmentDetail {
  final String assignmentId;
  final String routineTitle;
  final RoutineCategory category;
  final AssignmentStatus status;
  final DateTime assignedAt;

  PatientAssignmentDetail({
    required this.assignmentId,
    required this.routineTitle,
    required this.category,
    required this.status,
    required this.assignedAt,
  });
}
