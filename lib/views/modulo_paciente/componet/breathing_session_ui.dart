import 'package:flutter/material.dart';

import 'breathing_sphere.dart';
import 'session_progress_widgets.dart';

class BreathingSessionUI extends StatelessWidget {
  final String currentLabel;
  final String remainingTime;
  final double phaseProgress;
  final int completedCycles;
  final int totalCycles;
  final AnimationController animationController;
  final VoidCallback onFinish;

  const BreathingSessionUI({
    super.key,
    required this.currentLabel,
    required this.remainingTime,
    required this.phaseProgress,
    required this.completedCycles,
    required this.totalCycles,
    required this.animationController,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        // Visualizador central adaptable
        Expanded(
          flex: 4,
          child: BreathingSphere(
            animation: animationController,
            label: currentLabel,
          ),
        ),
        const Spacer(),

        // Indicadores de progreso
        PhaseProgressBar(
          label: currentLabel,
          time: remainingTime,
          progress: phaseProgress,
        ),
        const SizedBox(height: 16),
        CycleSegmentsBar(total: totalCycles, completed: completedCycles),
        // Eliminamos el botón de aquí porque RoutineSessionView ya tiene uno
      ],
    );
  }
} // Eliminado _buildFinishButton y el Stack inmersivo de aquí
