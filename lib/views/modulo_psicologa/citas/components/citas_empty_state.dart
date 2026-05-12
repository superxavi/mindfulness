import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'citas_enums.dart';

class CitasEmptyState extends StatelessWidget {
  final CitasTab currentTab;

  const CitasEmptyState({super.key, required this.currentTab});

  @override
  Widget build(BuildContext context) {
    final message = switch (currentTab) {
      CitasTab.agenda =>
        'No hay citas para la fecha seleccionada. Cambia la fecha o revisa solicitudes.',
      CitasTab.solicitudes => 'No hay solicitudes pendientes por gestionar.',
      CitasTab.historial => 'No hay sesiones completadas para esta fecha.',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
