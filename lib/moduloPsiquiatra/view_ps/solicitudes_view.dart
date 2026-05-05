import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../moduloCitas/viewmodels/appointments_viewmodel.dart';
import '../../views/modulo_psicologa/components/professional_navigation_helper.dart';
import '../componets_ps/appointment_request_card.dart';

class SolicitudesView extends StatefulWidget {
  const SolicitudesView({super.key});

  @override
  State<SolicitudesView> createState() => _SolicitudesViewState();
}

class _SolicitudesViewState extends State<SolicitudesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentsViewModel>().loadAll();
    });
  }

  void _showProposeDialog(BuildContext context, String appointmentId) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    int selectedDuration = 45;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Proponer horario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: dialogContext,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) setDialogState(() => selectedDate = date);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(selectedTime.format(dialogContext)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: dialogContext,
                    initialTime: selectedTime,
                  );
                  if (time != null) setDialogState(() => selectedTime = time);
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: selectedDuration,
                decoration: const InputDecoration(
                  labelText: 'Duración (minutos)',
                ),
                items: const [30, 45, 60, 90]
                    .map(
                      (duration) => DropdownMenuItem(
                        value: duration,
                        child: Text('$duration min'),
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
                  appointmentId,
                  scheduled,
                  selectedDuration,
                );

                if (!context.mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Propuesta enviada al paciente.'),
                  ),
                );
              },
              child: const Text('Enviar propuesta'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AppointmentsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de cita'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Volver al panel',
            onPressed: () =>
                ProfessionalNavigationHelper.returnToHome(context, tabIndex: 3),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.pendingRequests.isEmpty
          ? const Center(child: Text('No tienes solicitudes pendientes.'))
          : ListView.builder(
              itemCount: viewModel.pendingRequests.length,
              itemBuilder: (context, index) {
                final appointment = viewModel.pendingRequests[index];
                return AppointmentRequestCard(
                  appointment: appointment,
                  onTap: () => _showProposeDialog(context, appointment.id!),
                );
              },
            ),
    );
  }
}
