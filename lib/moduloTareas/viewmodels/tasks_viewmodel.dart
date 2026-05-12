import 'package:flutter/material.dart';
import '../model/assignment_model.dart';
import '../services/tasks_service.dart';

class TasksViewModel extends ChangeNotifier {
  final _service = TasksService();

  List<Assignment> pendingTasks = [];
  List<Assignment> completedTasks = [];
  bool isLoading = false;
  String? error;

  /// Carga y clasifica las tareas
  Future<void> loadTasks() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final all = await _service.getAllPatientTasks();
      debugPrint("DEBUG: Tareas crudas recibidas: ${all.length}");

      // .toList() ya crea una nueva instancia de lista, suficiente para que Provider detecte el cambio
      pendingTasks = all.where((t) => t.status == 'pending').toList();
      completedTasks = all.where((t) => t.status == 'completed').toList();

      debugPrint(
        "DEBUG: Pendientes: ${pendingTasks.length}, Completadas: ${completedTasks.length}",
      );
    } catch (e) {
      error = "No se pudieron cargar las tareas";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    pendingTasks = [];
    completedTasks = [];
    isLoading = false;
    error = null;
    notifyListeners();
  }

  /// Inicia una sesión y retorna su ID
  Future<String?> startSession(String routineId) async {
    try {
      return await _service.createSession(routineId);
    } catch (e) {
      debugPrint("Error al iniciar sesión: $e");
      return null;
    }
  }

  /// Finaliza la tarea y actualiza la lista local
  Future<bool> markAsDone(String sessionId, String assignmentId) async {
    try {
      await _service.completeTask(sessionId, assignmentId);
      await loadTasks(); // Refrescar listas
      return true;
    } catch (e) {
      debugPrint("Error al marcar como hecho: $e");
      return false;
    }
  }
}
