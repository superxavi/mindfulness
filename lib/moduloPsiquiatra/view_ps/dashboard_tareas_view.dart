import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../moduloCitas/viewmodels/appointments_viewmodel.dart';
import '../../../viewmodels/viewmodels_psicologa/patients_viewmodel.dart';
import '../../../views/modulo_psicologa/actividades_view.dart';
import '../componets_ps/psychiatrist_components.dart';
import '../viewmodels_ps/routines_viewmodel2.dart';
import 'asignar_tarea_view.dart';
import 'crear_rutina_view.dart';
import 'gestion_rutinas_view.dart';

class DashboardTareasView extends StatefulWidget {
  const DashboardTareasView({super.key});

  @override
  State<DashboardTareasView> createState() => _DashboardTareasViewState();
}

class _DashboardTareasViewState extends State<DashboardTareasView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentsViewModel>().loadAll();
      context.read<PatientsViewModel>().loadPatients();
      context.read<RoutinesViewModel2>().loadRoutines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsVM = context.watch<AppointmentsViewModel>();
    final patientsVM = context.watch<PatientsViewModel>();
    final routinesVM = context.watch<RoutinesViewModel2>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          children: [
            MetricCard(
              label: 'Solicitudes',
              value: appointmentsVM.pendingRequests.length.toString(),
              icon: Icons.pending_actions_rounded,
              color: AppColors.tertiary,
            ),
            MetricCard(
              label: 'Citas hoy',
              value: appointmentsVM.confirmedAgenda.length.toString(),
              icon: Icons.calendar_today_rounded,
              color: AppColors.lavender,
            ),
            MetricCard(
              label: 'Pacientes',
              value: patientsVM.patients.length.toString(),
              icon: Icons.people_alt_rounded,
              color: AppColors.mint,
            ),
            MetricCard(
              label: 'Tus rutinas',
              value: routinesVM.routines.length.toString(),
              icon: Icons.auto_awesome_motion_rounded,
              color: AppColors.lavender,
            ),
          ],
        ),
        const SizedBox(height: 25),
        Text(
          'Accesos rápidos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        PsychiatristActionCard(
          title: 'Catálogo de rutinas',
          subtitle: 'Ver tus plantillas guardadas',
          icon: Icons.library_books,
          color: AppColors.lavender,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GestionRutinasView()),
          ),
        ),
        const SizedBox(height: 15),
        PsychiatristActionCard(
          title: 'Crear nueva rutina',
          subtitle: 'Diseñar ejercicio de respiración',
          icon: Icons.add_circle,
          color: AppColors.mint,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CrearRutinaView()),
          ),
        ),
        const SizedBox(height: 15),
        PsychiatristActionCard(
          title: 'Asignar a paciente',
          subtitle: 'Enviar tarea a un usuario',
          icon: Icons.person_add,
          color: AppColors.tertiary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AsignarTareaView()),
          ),
        ),
        const SizedBox(height: 15),
        PsychiatristActionCard(
          title: 'Actividades',
          subtitle: 'Revisar actividades de los pacientes',
          icon: Icons.auto_awesome_motion_rounded,
          color: AppColors.lavender,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ActividadesView()),
          ),
        ),
      ],
    );
  }
}
