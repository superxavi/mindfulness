import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../views/modulo_psicologa/components/professional_navigation_helper.dart';
import '../viewmodels_ps/routines_viewmodel2.dart';

class AsignarTareaView extends StatefulWidget {
  const AsignarTareaView({super.key});

  @override
  State<AsignarTareaView> createState() => _AsignarTareaViewState();
}

class _AsignarTareaViewState extends State<AsignarTareaView> {
  String? _selectedPatientId;
  String? _selectedRoutineId;
  List<Map<String, dynamic>> _patients = [];
  bool _loadingPatients = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RoutinesViewModel2>().loadRoutines();
      }
    });
  }

  Future<void> _loadPatients() async {
    final res = await Supabase.instance.client
        .from('profiles')
        .select('id, full_name')
        .eq('role', 'patient');
    setState(() {
      _patients = List<Map<String, dynamic>>.from(res);
      _loadingPatients = false;
    });
  }

  Future<void> _assign() async {
    if (_selectedPatientId == null || _selectedRoutineId == null) return;

    await context.read<RoutinesViewModel2>().assignToPatient(
      _selectedPatientId!,
      _selectedRoutineId!,
    );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarea asignada al paciente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routinesVM = context.watch<RoutinesViewModel2>();
    final routines = routinesVM.routines;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar rutina'),
        actions: [
          IconButton(
            tooltip: 'Volver al panel',
            onPressed: () => ProfessionalNavigationHelper.returnToHome(context),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: (routinesVM.isLoading || _loadingPatients)
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    hint: const Text('Seleccionar paciente'),
                    items: _patients.map((patient) {
                      return DropdownMenuItem<String>(
                        value: patient['id']?.toString(),
                        child: Text(
                          patient['full_name'] ?? 'Paciente sin nombre',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedPatientId = value),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    hint: const Text('Seleccionar rutina'),
                    items: routines.isEmpty
                        ? const [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text('No hay rutinas creadas'),
                            ),
                          ]
                        : routines
                              .map(
                                (routine) => DropdownMenuItem<String>(
                                  value: routine.id,
                                  child: Text(routine.title),
                                ),
                              )
                              .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedRoutineId = value),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (_selectedPatientId != null &&
                              _selectedRoutineId != null)
                          ? _assign
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: AppColors.buttonPrimaryText,
                      ),
                      child: const Text(
                        'Confirmar asignación',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
