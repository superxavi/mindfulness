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
                CategoryFilters(
                  selectedCategory: routinesVM.selectedCategory,
                  onCategorySelected: (cat) =>
                      routinesVM.setSelectedCategory(cat),
                ),

                const SizedBox(height: 20),
                ActivitySearch(
                  onChanged: (query) => routinesVM.setSearchQuery(query),
                ),

                const SizedBox(height: 32),

                // Subtítulo consistente con estilo moderno
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Explorar Catálogo de Rutinas ",
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Basado en tus preferencias",
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.sort_rounded, color: AppColors.mint, size: 24),
                  ],
                ),

                const SizedBox(height: 16),

                // Lista de Actividades con diseño unificado
                if (routinesVM.isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(60.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.mint,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  )
                else if (routinesVM.filteredRoutines.isEmpty)
                  _buildEmptyState(routinesVM.routines.isEmpty)
                else
                  ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: routinesVM.filteredRoutines.length,
                    itemBuilder: (context, index) {
                      final routine = routinesVM.filteredRoutines[index];
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

  Widget _buildEmptyState(bool noRoutinesAtAll) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                noRoutinesAtAll
                    ? Icons.add_task_rounded
                    : Icons.search_off_rounded,
                size: 40,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              noRoutinesAtAll
                  ? "No has creado rutinas aún"
                  : "No se encontraron resultados",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              noRoutinesAtAll
                  ? "Comienza agregando tu primera actividad"
                  : "Intenta con otras palabras o filtros",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
