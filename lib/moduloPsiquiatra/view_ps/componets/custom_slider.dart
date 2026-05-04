import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomSlider extends StatelessWidget {
  final String label;
  final int value;
  final double min;
  final double max;
  final String unit;
  final Function(double) onChanged;

  const CustomSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              "$value $unit",
              style: TextStyle(
                color: AppColors.mint,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: (max - min).toInt() > 0 ? (max - min).toInt() : 1,
          activeColor: AppColors.mint,
          inactiveColor: AppColors.mint.withValues(alpha: 0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
