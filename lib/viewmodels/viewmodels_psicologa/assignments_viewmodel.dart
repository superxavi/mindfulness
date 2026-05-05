import 'package:flutter/material.dart';
import '../../models/model_psicologa/assignment_group_model.dart';
import '../../services/services_psicologa/psychologist_repository.dart';

class AssignmentsViewModel extends ChangeNotifier {
  final PsychologistRepository _repository;

  AssignmentsViewModel({PsychologistRepository? repository})
    : _repository = repository ?? PsychologistRepository();

  List<PatientAssignmentGroup> _groups = [];
  List<PatientAssignmentGroup> _filteredGroups = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<PatientAssignmentGroup> get groups => _filteredGroups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAssignments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _groups = await _repository.getAllAssignmentsGrouped();
      _applySearch();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String query) {
    _searchQuery = query;
    _applySearch();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredGroups = List.from(_groups);
    } else {
      _filteredGroups = _groups.where((group) {
        return group.patientName.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
      }).toList();
    }
    notifyListeners();
  }

  Future<void> refresh() => loadAssignments();
}
