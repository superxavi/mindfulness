import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ActivitySearch extends StatelessWidget {
  final Function(String)? onChanged;

  const ActivitySearch({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.mint, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: '¿Qué actividad buscas hoy?',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (onChanged != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.tune_rounded, color: AppColors.mint, size: 18),
            ),
        ],
      ),
    );
  }
}
