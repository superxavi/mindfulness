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
            label: 'Buscar Recursos sonidos',
            icon: Icons.search,
            color: AppColors.lavender, // Un azul llamativo
            onTap: () => _goToResources(context),
          ),
        ),
        SizedBox(width: 15),
        // Botón Favoritos
        Expanded(
          child: _ActionButton(
            label: 'Biblioteca de sonidos',
            icon: Icons.collections_bookmark,
            color: AppColors.error, // Un rojo suave
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: color.withValues(alpha: 0.15),
          highlightColor: color.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.15)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.05),
                  color.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
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
