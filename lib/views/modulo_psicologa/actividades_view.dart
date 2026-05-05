import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:mindfulness_app/moduloPsiquiatra/viewmodels_ps/routines_viewmodel2.dart';
import 'package:mindfulness_app/views/modulo_psicologa/actividades/components/activity_action_buttons.dart';
import 'package:mindfulness_app/views/modulo_psicologa/actividades/components/category_filters.dart';
import 'package:provider/provider.dart';

import 'actividades/components/activity_item_card.dart';
import 'actividades/components/activity_search.dart';

class ActividadesView extends StatefulWidget {
  const ActividadesView({super.key});

  @override
  State<ActividadesView> createState() => _ActividadesViewState();
}

class _ActividadesViewState extends State<ActividadesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutinesViewModel2>().loadRoutines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final routinesVM = context.watch<RoutinesViewModel2>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => routinesVM.loadRoutines(),
        color: AppColors.mint,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Título con jerarquía clara (Heurística: Reconocimiento)
                Text(
                  "Gestión de Actividades",
                  style: textTheme.displayMedium?.copyWith(
                    fontSize: 28,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Administra y explora las rutinas disponibles.",
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 30),
                const ActivityActionButtons(),

                const SizedBox(height: 30),
                const CategoryFilters(),

                const SizedBox(height: 20),
                ActivitySearch(),

                const SizedBox(height: 32),

                // Subtítulo consistente
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Explorar Catálogo",
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Lista de Actividades con diseño unificado
                if (routinesVM.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (routinesVM.routines.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        "No has creado rutinas aún.",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: routinesVM.routines.length,
                    itemBuilder: (context, index) {
                      final routine = routinesVM.routines[index];
                      return ActivityItemCard(routine: routine);
                    },
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
