import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../moduloCitas/model/appointment_model.dart';
import '../../moduloCitas/viewmodels/appointments_viewmodel.dart';
import 'components/professional_navigation_helper.dart';

enum _CitasTab { agenda, solicitudes, historial }

enum _CalendarEventType { solicitada, propuesta, confirmada, completada }

class CitasView extends StatefulWidget {
  const CitasView({super.key});

  @override
  State<CitasView> createState() => _CitasViewState();
}

class _CitasViewState extends State<CitasView> {
  DateTime _selectedDay = _normalizeDate(DateTime.now());
  DateTime _focusedDay = _normalizeDate(DateTime.now());
  _CitasTab _currentTab = _CitasTab.agenda;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentsViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppointmentsViewModel>();
    final appointments = vm.allAppointments;
    final eventsByDay = _buildEventsByDay(appointments);

    final dailyAgenda = appointments.where((appointment) {
      if (appointment.scheduledDate == null) return false;
      return _isSameDay(appointment.scheduledDate!, _selectedDay) &&
          (appointment.status == 'CONFIRMADA' ||
              appointment.status == 'PROPUESTA');
    }).toList();
    final pendingRequests = vm.pendingRequests;
    final completedByDay = appointments.where((appointment) {
      if (appointment.status != 'COMPLETADA' ||
          appointment.scheduledDate == null) {
        return false;
      }
      return _isSameDay(appointment.scheduledDate!, _selectedDay);
    }).toList();

    final todaysCount = dailyAgenda.length;
    final pendingCount = pendingRequests.length;
    final upcomingWeek = appointments.where((appointment) {
      if (appointment.scheduledDate == null ||
          appointment.status != 'CONFIRMADA') {
        return false;
      }
      final now = DateTime.now();
      final limit = now.add(const Duration(days: 7));
      return appointment.scheduledDate!.isAfter(now) &&
          appointment.scheduledDate!.isBefore(limit);
    }).length;

    final visibleAppointments = switch (_currentTab) {
      _CitasTab.agenda => dailyAgenda,
      _CitasTab.solicitudes => pendingRequests,
      _CitasTab.historial => completedByDay,
    };

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: vm.loadAll,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  Text(
                    'Agenda clínica',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gestiona próximas citas, solicitudes pendientes y sesiones completadas.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMetricsRow(
                    todaysCount: todaysCount,
                    pendingCount: pendingCount,
                    upcomingWeek: upcomingWeek,
                  ),
                  const SizedBox(height: 16),
                  _buildCalendarCard(eventsByDay),
                  const SizedBox(height: 12),
                  _buildCalendarLegend(eventsByDay),
                  const SizedBox(height: 14),
                  _buildTabSelector(),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              ProfessionalNavigationHelper.returnToHome(
                                context,
                              ),
                          icon: const Icon(Icons.home_outlined),
                          label: const Text('Ir al dashboard'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filledTonal(
                        tooltip: 'Recargar',
                        onPressed: vm.loadAll,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (vm.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (visibleAppointments.isEmpty)
                    _buildEmptyState()
                  else
                    ...visibleAppointments.map(
                      (appointment) =>
                          _buildAppointmentCard(context, appointment),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow({
    required int todaysCount,
    required int pendingCount,
    required int upcomingWeek,
  }) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            label: 'Hoy',
            value: '$todaysCount',
            icon: Icons.event_available_outlined,
            color: AppColors.mint,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            label: 'Solicitudes',
            value: '$pendingCount',
            icon: Icons.mark_email_unread_outlined,
            color: AppColors.lavender,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            label: 'Próx. 7 días',
            value: '$upcomingWeek',
            icon: Icons.upcoming_outlined,
            color: AppColors.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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

  Widget _buildCalendarCard(
    Map<DateTime, Set<_CalendarEventType>> eventsByDay,
  ) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: TableCalendar<_CalendarEventType>(
        locale: 'es',
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
        eventLoader: (day) => eventsByDay[_normalizeDate(day)]?.toList() ?? [],
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppColors.textSecondary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: AppColors.textPrimary),
          defaultTextStyle: TextStyle(color: AppColors.textPrimary),
          todayTextStyle: TextStyle(
            color: AppColors.buttonPrimaryText,
            fontWeight: FontWeight.w700,
          ),
          selectedTextStyle: TextStyle(
            color: AppColors.buttonPrimaryText,
            fontWeight: FontWeight.w700,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.lavender.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.buttonPrimary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 4,
          markerDecoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        calendarBuilders: CalendarBuilders<_CalendarEventType>(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox.shrink();
            final uniqueEvents = events.toSet().toList();

            return Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: uniqueEvents
                      .take(3)
                      .map((eventType) => _buildMarkerDot(eventType))
                      .toList(),
                ),
              ),
            );
          },
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = _normalizeDate(selectedDay);
            _focusedDay = _normalizeDate(focusedDay);
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = _normalizeDate(focusedDay);
        },
      ),
    );
  }

  Widget _buildMarkerDot(_CalendarEventType eventType) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: _eventColor(eventType),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCalendarLegend(
    Map<DateTime, Set<_CalendarEventType>> eventsByDay,
  ) {
    final hasSolicitadas = _hasEvent(
      eventsByDay,
      _CalendarEventType.solicitada,
    );
    final hasPropuestas = _hasEvent(eventsByDay, _CalendarEventType.propuesta);
    final hasConfirmadas = _hasEvent(
      eventsByDay,
      _CalendarEventType.confirmada,
    );
    final hasCompletadas = _hasEvent(
      eventsByDay,
      _CalendarEventType.completada,
    );

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
            _legendItem('Solicitada', _CalendarEventType.solicitada),
          if (hasPropuestas)
            _legendItem('Propuesta', _CalendarEventType.propuesta),
          if (hasConfirmadas)
            _legendItem('Confirmada', _CalendarEventType.confirmada),
          if (hasCompletadas)
            _legendItem('Completada', _CalendarEventType.completada),
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

  Widget _legendItem(String label, _CalendarEventType eventType) {
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

  Widget _buildTabSelector() {
    return SegmentedButton<_CitasTab>(
      segments: [
        ButtonSegment<_CitasTab>(
          value: _CitasTab.agenda,
          icon: Icon(Icons.calendar_month_outlined),
          label: _segmentLabel('Agenda'),
        ),
        ButtonSegment<_CitasTab>(
          value: _CitasTab.solicitudes,
          icon: Icon(Icons.mail_outline),
          label: _segmentLabel('Solicitudes'),
        ),
        ButtonSegment<_CitasTab>(
          value: _CitasTab.historial,
          icon: Icon(Icons.history),
          label: _segmentLabel('Historial'),
        ),
      ],
      selected: {_currentTab},
      showSelectedIcon: false,
      onSelectionChanged: (selection) {
        setState(() => _currentTab = selection.first);
      },
    );
  }

  Widget _segmentLabel(String label) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(label, maxLines: 1, softWrap: false),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    final dateLabel = appointment.scheduledDate == null
        ? 'Sin fecha propuesta'
        : DateFormat(
            'EEEE dd MMM, HH:mm',
            'es',
          ).format(appointment.scheduledDate!);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.surfaceLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statusChip(appointment.status),
                const Spacer(),
                Text(
                  appointment.type,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appointment.motive,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _capitalize(dateLabel),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            if (appointment.durationMinutes != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.timelapse_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${appointment.durationMinutes} min',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
            if (appointment.professionalNotes != null &&
                appointment.professionalNotes!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Notas: ${appointment.professionalNotes}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
            const SizedBox(height: 10),
            _buildActions(context, appointment),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, Appointment appointment) {
    if (appointment.id == null) return const SizedBox.shrink();

    if (appointment.status == 'SOLICITADA') {
      return Align(
        alignment: Alignment.centerLeft,
        child: ElevatedButton.icon(
          onPressed: () => _showProposeDialog(context, appointment),
          icon: const Icon(Icons.event_available_outlined),
          label: const Text('Proponer horario'),
        ),
      );
    }

    if (appointment.status == 'CONFIRMADA') {
      return Align(
        alignment: Alignment.centerLeft,
        child: ElevatedButton.icon(
          onPressed: () => _showCompleteDialog(context, appointment),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Finalizar sesión'),
        ),
      );
    }

    if (appointment.status == 'PROPUESTA') {
      return Text(
        'Esperando confirmación del paciente.',
        style: TextStyle(color: AppColors.lavender, fontSize: 13),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    final message = switch (_currentTab) {
      _CitasTab.agenda =>
        'No hay citas para la fecha seleccionada. Cambia la fecha o revisa solicitudes.',
      _CitasTab.solicitudes => 'No hay solicitudes pendientes por gestionar.',
      _CitasTab.historial => 'No hay sesiones completadas para esta fecha.',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final (background, foreground, text) = switch (status) {
      'SOLICITADA' => (AppColors.warningBg, AppColors.lavender, 'Solicitada'),
      'PROPUESTA' => (AppColors.tertiaryBg, AppColors.tertiary, 'Propuesta'),
      'CONFIRMADA' => (AppColors.successBg, AppColors.mint, 'Confirmada'),
      'COMPLETADA' => (
        AppColors.surfaceHighest,
        AppColors.textPrimary,
        'Completada',
      ),
      _ => (AppColors.surfaceHighest, AppColors.textSecondary, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _showProposeDialog(
    BuildContext context,
    Appointment appointment,
  ) async {
    DateTime selectedDate = _selectedDay;
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    int selectedDuration = 45;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Proponer horario'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule_outlined),
                    title: Text(selectedTime.format(dialogContext)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: dialogContext,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setDialogState(() => selectedTime = picked);
                      }
                    },
                  ),
                  DropdownButtonFormField<int>(
                    initialValue: selectedDuration,
                    decoration: const InputDecoration(labelText: 'Duración'),
                    items: const [30, 45, 60, 90]
                        .map(
                          (minutes) => DropdownMenuItem<int>(
                            value: minutes,
                            child: Text('$minutes min'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedDuration = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final scheduled = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                    await context.read<AppointmentsViewModel>().proposeFromPro(
                      appointment.id!,
                      scheduled,
                      selectedDuration,
                    );
                    if (!context.mounted) return;
                    setState(() {
                      _selectedDay = _normalizeDate(selectedDate);
                      _focusedDay = _normalizeDate(selectedDate);
                    });
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Horario propuesto correctamente.'),
                      ),
                    );
                  },
                  child: const Text('Enviar propuesta'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCompleteDialog(
    BuildContext context,
    Appointment appointment,
  ) async {
    final notesController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finalizar sesión'),
          content: TextField(
            controller: notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Escribe notas de seguimiento',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await context.read<AppointmentsViewModel>().markAsDone(
                  appointment.id!,
                  notesController.text.trim(),
                );
                if (!context.mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cita finalizada y guardada.')),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Map<DateTime, Set<_CalendarEventType>> _buildEventsByDay(
    List<Appointment> appointments,
  ) {
    final map = <DateTime, Set<_CalendarEventType>>{};
    for (final appointment in appointments) {
      final scheduled = appointment.scheduledDate;
      if (scheduled == null) continue;
      final key = _normalizeDate(scheduled);
      map.putIfAbsent(key, () => <_CalendarEventType>{});

      switch (appointment.status) {
        case 'SOLICITADA':
          map[key]!.add(_CalendarEventType.solicitada);
          break;
        case 'PROPUESTA':
          map[key]!.add(_CalendarEventType.propuesta);
          break;
        case 'CONFIRMADA':
          map[key]!.add(_CalendarEventType.confirmada);
          break;
        case 'COMPLETADA':
          map[key]!.add(_CalendarEventType.completada);
          break;
      }
    }
    return map;
  }

  bool _hasEvent(
    Map<DateTime, Set<_CalendarEventType>> eventsByDay,
    _CalendarEventType eventType,
  ) {
    for (final events in eventsByDay.values) {
      if (events.contains(eventType)) {
        return true;
      }
    }
    return false;
  }

  Color _eventColor(_CalendarEventType eventType) {
    return switch (eventType) {
      _CalendarEventType.solicitada => AppColors.lavender,
      _CalendarEventType.propuesta => AppColors.tertiary,
      _CalendarEventType.confirmada => AppColors.mint,
      _CalendarEventType.completada => AppColors.textSecondary,
    };
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
