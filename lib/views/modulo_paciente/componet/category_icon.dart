import 'package:flutter/material.dart';
import '../../../models/routine_model.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category, this.size = 44});

  final RoutineCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = styleForCategory(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Icon(style.icon, color: style.iconColor, size: size * 0.50),
    );
  }
}

class CategoryIconStyle {
  const CategoryIconStyle({
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
}

CategoryIconStyle styleForCategory(RoutineCategory category) {
  return switch (category) {
    RoutineCategory.breathing => const CategoryIconStyle(
      icon: Icons.air_rounded,
      background: Color(0xFFCCF0EC),
      iconColor: Color(0xFF006B63),
    ),
    RoutineCategory.relaxation => const CategoryIconStyle(
      icon: Icons.spa_outlined,
      background: Color(0xFFD6EAD0),
      iconColor: Color(0xFF2E7D32),
    ),
    RoutineCategory.sleepInduction => const CategoryIconStyle(
      icon: Icons.dark_mode_outlined,
      background: Color(0xFFD5E8F5),
      iconColor: Color(0xFF1565C0),
    ),
    RoutineCategory.soundscape => const CategoryIconStyle(
      icon: Icons.music_note_rounded,
      background: Color(0xFFE8D5F5),
      iconColor: Color(0xFF6A1B9A),
    ),
    RoutineCategory.terapiaSonido => const CategoryIconStyle(
      icon: Icons.graphic_eq_rounded,
      background: Color(0xFFF5D5D5),
      iconColor: Color(0xFFB71C1C),
    ),
    RoutineCategory.all => const CategoryIconStyle(
      icon: Icons.checklist_rounded,
      background: Color(0xFFFFF3CC),
      iconColor: Color(0xFFF57F17),
    ),
  };
}
