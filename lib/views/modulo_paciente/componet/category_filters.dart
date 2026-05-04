import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/routine_model.dart';
import 'category_icon.dart';

class CategoryFilters extends StatelessWidget {
  const CategoryFilters({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  final RoutineCategory selectedCategory;
  final ValueChanged<RoutineCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    const categories = RoutineCategory.values;

    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category == selectedCategory;
          final style = styleForCategory(category);
          return ChoiceChip(
            label: Text(category.label),
            selected: selected,
            onSelected: (_) => onSelected(category),
            avatar: Icon(
              style.icon,
              size: 16,
              color: selected ? AppColors.buttonPrimaryText : style.iconColor,
            ),
            backgroundColor: AppColors.surfaceLow,
            selectedColor: AppColors.mint,
            side: BorderSide(
              color: selected ? AppColors.mint : AppColors.outlineVariant,
            ),
            labelStyle: TextStyle(
              color: selected
                  ? AppColors.buttonPrimaryText
                  : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            showCheckmark: false,
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemCount: categories.length,
      ),
    );
  }
}
