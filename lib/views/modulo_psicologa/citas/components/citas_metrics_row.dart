import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CitasMetricsRow extends StatelessWidget {
  final int todaysCount;
  final int pendingCount;
  final int upcomingWeek;

  const CitasMetricsRow({
    super.key,
    required this.todaysCount,
    required this.pendingCount,
    required this.upcomingWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Hoy',
            value: '$todaysCount',
            icon: Icons.event_available_outlined,
            color: AppColors.mint,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Solicitudes',
            value: '$pendingCount',
            icon: Icons.mark_email_unread_outlined,
            color: AppColors.lavender,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Próx. 7 días',
            value: '$upcomingWeek',
            icon: Icons.upcoming_outlined,
            color: AppColors.tertiary,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
