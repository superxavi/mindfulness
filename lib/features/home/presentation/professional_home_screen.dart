import 'package:flutter/material.dart';
import 'package:mindfulness_app/moduloPsiquiatra/view_ps/dashboard_tareas_view.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/nocturne_bottom_nav.dart';
import '../../../../core/presentation/widgets/nocturne_drawer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../viewmodels/auth_viewmodel.dart';
import '../../../../viewmodels/psicologa_nav_viewmodel.dart';
import '../../../../views/modulo_psicologa/actividades_view.dart';
import '../../../../views/modulo_psicologa/asignar_view.dart';
import '../../../../views/modulo_psicologa/citas_view.dart';
import '../../../../views/modulo_psicologa/pacientes_view.dart';

class ProfessionalHomeScreen extends StatelessWidget {
  const ProfessionalHomeScreen({super.key});

  static const List<String> _sectionTitles = [
    'Dashboard profesional',
    'Pacientes asignados',
    'Actividades y recomendaciones',
    'Citas y agenda',
    'Gestión y recomendaciones',
  ];

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final navVM = Provider.of<PsicologaNavViewModel>(context);
    final currentIndex = navVM.currentIndex.clamp(0, 4);

    final pages = <Widget>[
      const DashboardTareasView(),
      const PacientesView(),
      const ActividadesView(),
      const CitasView(),
      const AsignarView(),
    ];

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && currentIndex != 0) {
          navVM.updateIndex(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            _sectionTitles[currentIndex],
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          actions: [
            if (currentIndex != 0)
              IconButton(
                tooltip: 'Volver al dashboard',
                onPressed: () => navVM.updateIndex(0),
                icon: const Icon(Icons.home_outlined),
              ),
          ],
        ),
        drawer: NocturneDrawer(
          userName:
              authViewModel.currentUser?.userMetadata?['full_name'] ??
              'Profesional de salud',
          userEmail: authViewModel.currentUser?.email ?? 'Gestión de pacientes',
          roleText: 'Psicóloga',
          onLogout: () async {
            await authViewModel.signOut();
          },
          menuItems: [
            const _DrawerSectionLabel(label: 'Opciones profesionales'),
            ListTile(
              leading: Icon(
                Icons.dashboard_outlined,
                color: AppColors.textPrimary,
              ),
              title: Text(
                'Dashboard profesional',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                navVM.updateIndex(0);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.people_alt_outlined,
                color: AppColors.textPrimary,
              ),
              title: Text(
                'Pacientes asignados',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                navVM.updateIndex(1);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.auto_awesome_motion_outlined,
                color: AppColors.textPrimary,
              ),
              title: Text(
                'Actividades y recomendaciones',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                navVM.updateIndex(2);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.calendar_month_outlined,
                color: AppColors.textPrimary,
              ),
              title: Text(
                'Citas y agenda',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                navVM.updateIndex(3);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.assignment_turned_in_outlined,
                color: AppColors.textPrimary,
              ),
              title: Text(
                'Gestión y recomendaciones',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                navVM.updateIndex(4);
              },
            ),
            const _DrawerSectionLabel(label: 'Gestión interna'),
            ListTile(
              leading: Icon(
                Icons.settings_outlined,
                color: AppColors.textPrimary,
              ),
              title: Text(
                'Configuración',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: AppColors.textPrimary),
              title: Text(
                'Ayuda y soporte',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        body: IndexedStack(index: currentIndex, children: pages),
        bottomNavigationBar: NocturneBottomNav(
          currentIndex: currentIndex,
          onTap: navVM.updateIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: 'Pacientes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_motion_rounded),
              label: 'Actividades',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Citas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in_rounded),
              label: 'Asignaciones',
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.lavender,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
