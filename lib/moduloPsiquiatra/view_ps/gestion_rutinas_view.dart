import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../views/modulo_psicologa/components/professional_navigation_helper.dart';
import '../viewmodels_ps/routines_viewmodel2.dart';
import 'asignar_tarea_view.dart';
import 'crear_rutina_view.dart';

class GestionRutinasView extends StatefulWidget {
  const GestionRutinasView({super.key});

  @override
  State<GestionRutinasView> createState() => _GestionRutinasViewState();
}

class _GestionRutinasViewState extends State<GestionRutinasView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutinesViewModel2>().loadRoutines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RoutinesViewModel2>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de rutinas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AsignarTareaView()),
            ),
            tooltip: 'Asignar a paciente',
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => ProfessionalNavigationHelper.returnToHome(context),
            tooltip: 'Volver al panel',
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.routines.isEmpty
          ? const Center(child: Text('No has creado rutinas aún.'))
          : ListView.builder(
              itemCount: vm.routines.length,
              itemBuilder: (context, i) {
                final routine = vm.routines[i];
                return Card(
                  color: AppColors.surfaceLow,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.auto_awesome_motion,
                      color: AppColors.lavender,
                    ),
                    title: Text(routine.title),
                    subtitle: Text(routine.description),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CrearRutinaView()),
        ),
        label: const Text('Nueva rutina'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
