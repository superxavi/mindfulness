import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
// 👇 IMPORTA LAS NUEVAS VISTAS AQUÍ 👇
import '../bubbles_exercise_view.dart';
import '../spinner_view.dart';
import '../stress_ball_view.dart';

// 1. Modelo de datos ficticios (Mock)
class QuickExerciseMock {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  QuickExerciseMock({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

// 2. Lista de datos falsos (Tus 3 ejercicios)
final List<QuickExerciseMock> mockExercises = [
  QuickExerciseMock(
    id: '1',
    title: 'Burbujas',
    subtitle: 'Explota y relaja',
    icon: Icons.bubble_chart, // Puedes cambiarlo por un asset de imagen luego
  ),
  QuickExerciseMock(
    id: '2',
    title: 'Pelota Antiestrés',
    subtitle: 'Libera tensión',
    icon: Icons.sports_baseball,
  ),
  QuickExerciseMock(
    id: '3',
    title: 'Fidget Spinner',
    subtitle: 'Gira y concentra',
    icon: Icons.sync,
  ),
];

// 3. El Widget Contenedor (La vista que llamarás desde tu archivo principal)
class QuickExercisesSection extends StatelessWidget {
  const QuickExercisesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            'Ejercicios Rápidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors
                  .white, // Ajusta según tu AppColors si tienes un textPrimary
            ),
          ),
        ),
        // Lista horizontal de Cards
        SizedBox(
          height: 170, // Altura de las tarjetas
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            scrollDirection: Axis.horizontal,
            itemCount: mockExercises.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final exercise = mockExercises[index];
              return _QuickExerciseCard(exercise: exercise);
            },
          ),
        ),
      ],
    );
  }
}

// 4. El diseño individual de cada Card
class _QuickExerciseCard extends StatelessWidget {
  final QuickExerciseMock exercise;

  const _QuickExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Aquí pondrás tu Navigator cuando crees las vistas de los ejercicios
        /* if (exercise.id == '1') {
           Navigator.push(context, MaterialPageRoute(builder: (_) => BurbujasView()));
        }
        */

        // 👇 ACTUALIZA ESTA LÓGICA 👇
        Widget nextView;

        switch (exercise.id) {
          case '1':
            nextView = const BubblesExerciseView();
            break;
          case '2':
            nextView = const StressBallView();
            break;
          case '3':
            nextView = const SpinnerView();
            break;
          default:
            return; // No hacer nada si no coincide id
        }

        Navigator.of(context).push(MaterialPageRoute(builder: (_) => nextView));
      },
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface, // Fondo de la tarjeta usando tu tema
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(exercise.icon, size: 32, color: AppColors.mint),
            ),
            const SizedBox(height: 12),
            Text(
              exercise.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              exercise.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey, // O AppColors.textSecondary
              ),
            ),
          ],
        ),
      ),
    );
  }
}
