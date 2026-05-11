import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'citas_enums.dart';

class CitasCalendarLegend extends StatelessWidget {
  final Map<DateTime, Set<CalendarEventType>> eventsByDay;

  const CitasCalendarLegend({super.key, required this.eventsByDay});

  @override
  Widget build(BuildContext context) {
    final hasSolicitadas = _hasEvent(eventsByDay, CalendarEventType.solicitada);
    final hasPropuestas = _hasEvent(eventsByDay, CalendarEventType.propuesta);
    final hasConfirmadas = _hasEvent(eventsByDay, CalendarEventType.confirmada);
    final hasCompletadas = _hasEvent(eventsByDay, CalendarEventType.completada);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          if (hasSolicitadas)
            _LegendItem(label: 'Solicitada', eventType: CalendarEventType.solicitada),
          if (hasPropuestas)
            _LegendItem(label: 'Propuesta', eventType: CalendarEventType.propuesta),
          if (hasConfirmadas)
            _LegendItem(label: 'Confirmada', eventType: CalendarEventType.confirmada),
          if (hasCompletadas)
            _LegendItem(label: 'Completada', eventType: CalendarEventType.completada),
          if (!hasSolicitadas &&
              !hasPropuestas &&
              !hasConfirmadas &&
              !hasCompletadas)
            Text(
              'No hay eventos con fecha para marcar en el calendario.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
        ],
      ),
    );
  }

  bool _hasEvent(
    Map<DateTime, Set<CalendarEventType>> eventsByDay,
    CalendarEventType eventType,
  ) {
    for (final events in eventsByDay.values) {
      if (events.contains(eventType)) {
        return true;
      }
    }
    return false;
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final CalendarEventType eventType;

  const _LegendItem({required this.label, required this.eventType});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _eventColor(eventType),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _eventColor(CalendarEventType eventType) {
    return switch (eventType) {
      CalendarEventType.solicitada => AppColors.lavender,
      CalendarEventType.propuesta => AppColors.tertiary,
      CalendarEventType.confirmada => AppColors.mint,
      CalendarEventType.completada => AppColors.textSecondary,
    };
  }
}
