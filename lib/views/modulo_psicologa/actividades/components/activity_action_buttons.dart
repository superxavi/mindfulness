import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:mindfulness_app/moduloPsiquiatra/view_ps/favoritos_view.dart';
import 'package:mindfulness_app/moduloPsiquiatra/view_ps/recursos.dart';

class ActivityActionButtons extends StatelessWidget {
  const ActivityActionButtons({super.key});

  // Función para navegar a la pantalla de Recursos
  void _goToResources(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecursosView()),
    );

    // Navigator.push(context, MaterialPageRoute(builder: (context) => TuPantallaDeRecursos()));
    print("Navegando a Buscar Recursos...");
  }

  // Función para navegar a la pantalla de Favoritos
  void _goToFavorites(BuildContext context) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => TuPantallaDeFavoritos()));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FavoritosView()),
    );

    print("Navegando a Favoritos...");
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Botón Buscar Recursos
        Expanded(
          child: _ActionButton(
            label: 'Explorar Recursos',
            icon: Icons.auto_awesome_mosaic_rounded,
            color: AppColors.mint,
            onTap: () => _goToResources(context),
          ),
        ),
        const SizedBox(width: 16),
        // Botón Favoritos
        Expanded(
          child: _ActionButton(
            label: 'Mi Biblioteca',
            icon: Icons.bookmarks_rounded,
            color: AppColors.lavender,
            onTap: () => _goToFavorites(context),
          ),
        ),
      ],
    );
  }
}

// Widget privado para el diseño de los botones
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: color.withValues(alpha: 0.12),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.05),
                  color.withValues(alpha: 0.01),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  "Gestionar",
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
