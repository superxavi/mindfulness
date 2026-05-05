import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/routine_model.dart';
import '../../../../moduloPsiquiatra/model_ps/routine_model.dart';
import '../routine_preview_screen.dart';

class ActivityItemCard extends StatelessWidget {
  final RoutineTemplate routine;

  const ActivityItemCard({
    super.key,
    required this.routine,
  });

  String get _emoji {
    final category = RoutineCategoryX.fromValue(routine.category);
    return switch (category) {
      RoutineCategory.breathing => '🌬️',
      RoutineCategory.relaxation => '🧘',
      RoutineCategory.sleepInduction => '🌙',
      RoutineCategory.soundscape => '🎧',
      RoutineCategory.terapiaSonido => '🎶',
      _ => '✨',
    };
  }

  String get _durationLabel {
    final minutes = (routine.durationSeconds / 60).ceil();
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoutinePreviewScreen(routine: routine),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cuadro del Icono (Fondo suave + Emoji)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(_emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),

            // Info Central
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.title,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    RoutineCategoryX.fromValue(routine.category).label,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Fila de tiempo y reproducciones con iconos modernos
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppColors.mint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _durationLabel,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: AppColors.lavender,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Previsualizar",
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.lavender,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(
              Icons.play_circle_outline_rounded,
              size: 24,
              color: AppColors.mint,
            ),
          ],
        ),
      ),
    );
  }
}
