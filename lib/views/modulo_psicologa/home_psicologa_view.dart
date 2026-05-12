import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomePsicologaView extends StatelessWidget {
  const HomePsicologaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: AppColors.textPrimary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Este Home era solo de prueba.\nLa verdadera está en la carpeta siquitra profesional.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
