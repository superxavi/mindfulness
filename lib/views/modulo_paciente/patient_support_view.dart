import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'componet/patient_navigation_helper.dart';

class PatientSupportView extends StatelessWidget {
  const PatientSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Ayuda y soporte',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            tooltip: 'Menú principal',
            onPressed: () => PatientNavigationHelper.returnToMainMenu(context),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SupportCard(
            icon: Icons.help_outline_rounded,
            title: 'Centro de ayuda',
            subtitle:
                'Consulta guías de uso sobre rutinas, hábitos y seguimiento.',
          ),
          const SizedBox(height: 12),
          _SupportCard(
            icon: Icons.shield_outlined,
            title: 'Privacidad',
            subtitle:
                'Si tienes dudas sobre tus datos, contacta al equipo de administración institucional.',
          ),
          const SizedBox(height: 12),
          _SupportCard(
            icon: Icons.contact_support_outlined,
            title: 'Contacto',
            subtitle:
                'Correo sugerido: soporte@mindfulness.app\nRespuesta estimada: 24-48 horas.',
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.mint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
