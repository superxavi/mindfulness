import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../moduloCitas/viewmodels/appointments_viewmodel.dart';
import '../../../../moduloCitas/model/appointment_model.dart';

class CitasDialogs {
  static Future<void> showProposeDialog({
    required BuildContext context,
    required Appointment appointment,
    required DateTime initialDate,
    required Function(DateTime) onSuccess,
  }) async {
    DateTime selectedDate = initialDate;
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
                    // Ocultar teclado
                    FocusManager.instance.primaryFocus?.unfocus();

                    final scheduled = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    // Cerrar diálogo de inmediato
                    Navigator.pop(dialogContext);

                    try {
                      await context.read<AppointmentsViewModel>().proposeFromPro(
                            appointment.id!,
                            scheduled,
                            selectedDuration,
                          );
                      
                      onSuccess(selectedDate);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Horario propuesto correctamente.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al proponer: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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

  static Future<void> showCompleteDialog({
    required BuildContext context,
    required Appointment appointment,
  }) async {
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
                // Ocultar teclado
                FocusManager.instance.primaryFocus?.unfocus();
                final notes = notesController.text.trim();

                // Cerrar diálogo de inmediato
                Navigator.pop(dialogContext);

                try {
                  await context.read<AppointmentsViewModel>().markAsDone(
                        appointment.id!,
                        notes,
                      );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cita finalizada y guardada.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al finalizar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
