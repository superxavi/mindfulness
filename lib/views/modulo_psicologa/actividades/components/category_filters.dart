import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryFilters extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilters({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const Map<String, String> categoryLabels = {
    'Todas': 'Todas',
    'breathing': 'Respiración',
    'relaxation': 'Relajación',
    'sleep_induction': 'Sueño',
    'soundscape': 'Paisajes',
    'terapia_sonido': 'Terapia',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorías',
          style: TextStyle(
            color: AppColors.surfaceLowest,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...categoryLabels.entries.map((entry) {
                final isActive = selectedCategory == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onCategorySelected(entry.key),
                    child: _buildChip(entry.value, isActive),
                  ),
                );
              }),
              _buildCreateButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.figmaBlack : AppColors.figmaGrayBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.surfaceLowest : AppColors.figmaBlack,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Crear',
        style: TextStyle(
          color: AppColors.surfaceLowest,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
