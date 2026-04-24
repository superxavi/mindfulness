import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/reminder_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/reminders_viewmodel.dart';

class RemindersView extends StatefulWidget {
  const RemindersView({super.key});

  @override
  State<RemindersView> createState() => _RemindersViewState();
}

class _RemindersViewState extends State<RemindersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final viewModel = context.read<RemindersViewModel>();
      await viewModel.ensureNotificationPermissions();
      await viewModel.loadReminders();
    });
  }

  void _showReminderDialog([ReminderModel? reminder]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ReminderFormSheet(reminder: reminder),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RemindersViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Recordatorios',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
      ),
      body: viewModel.isLoading && viewModel.reminders.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.mint),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manten la constancia',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Configura avisos para tu higiene del sueno y relajacion.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (viewModel.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withAlpha(30),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              viewModel.errorMessage!,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (viewModel.reminders.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No tienes recordatorios configurados.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final reminder = viewModel.reminders[index];
                        return _buildReminderCard(reminder, viewModel);
                      },
                      childCount: viewModel.reminders.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReminderDialog(),
        backgroundColor: AppColors.mint,
        icon: const Icon(Icons.add, color: AppColors.buttonPrimaryText),
        label: const Text(
          'Nuevo Aviso',
          style: TextStyle(
            color: AppColors.buttonPrimaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(ReminderModel reminder, RemindersViewModel viewModel) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: () => _showReminderDialog(reminder),
        title: Text(
          reminder.triggerTime.format(context),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Wrap(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mint.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reminder.type.label,
                    style: const TextStyle(color: AppColors.mint, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getDaysSummary(reminder.daysOfWeek),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        trailing: Switch(
          value: reminder.isActive,
          activeThumbColor: AppColors.mint,
          onChanged: (_) => viewModel.toggleReminder(reminder),
        ),
      ),
    );
  }

  String _getDaysSummary(int daysOfWeek) {
    if (daysOfWeek == 127) return 'Todos los dias';
    if (daysOfWeek == 0) return 'Ningun dia';

    final days = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    final selected = <String>[];
    for (int i = 0; i < 7; i++) {
      if ((daysOfWeek & (1 << i)) != 0) {
        selected.add(days[i]);
      }
    }
    return selected.join(', ');
  }
}

class ReminderFormSheet extends StatefulWidget {
  final ReminderModel? reminder;

  const ReminderFormSheet({super.key, this.reminder});

  @override
  State<ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<ReminderFormSheet> {
  late TimeOfDay _time;
  late int _days;
  late ReminderType _type;

  @override
  void initState() {
    super.initState();
    _time = widget.reminder?.triggerTime ?? const TimeOfDay(hour: 21, minute: 0);
    _days = widget.reminder?.daysOfWeek ?? 127;
    _type = widget.reminder?.type ?? ReminderType.routineStart;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<RemindersViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.reminder == null ? 'Nuevo Recordatorio' : 'Editar Recordatorio',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.reminder != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final success = await viewModel.deleteReminder(widget.reminder!.id!);
                    if (success) {
                      navigator.pop();
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Tipo de aviso', style: TextStyle(color: AppColors.lavender)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ReminderType.values.map((type) {
              final isSelected = _type == type;
              return ChoiceChip(
                label: Text(type.label),
                selected: isSelected,
                onSelected: (val) {
                  if (val) setState(() => _type = type);
                },
                selectedColor: AppColors.mint,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.buttonPrimaryText : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Horario', style: TextStyle(color: AppColors.lavender)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _time.format(context),
              style: const TextStyle(
                color: AppColors.mint,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.access_time, color: AppColors.mint),
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _time);
              if (time != null) setState(() => _time = time);
            },
          ),
          const SizedBox(height: 24),
          const Text('Dias', style: TextStyle(color: AppColors.lavender)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dayButton('L', 1),
              _dayButton('M', 2),
              _dayButton('M', 4),
              _dayButton('J', 8),
              _dayButton('V', 16),
              _dayButton('S', 32),
              _dayButton('D', 64),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    final currentUserId = authViewModel.currentUser?.id;
                    if (currentUserId == null) return;

                    final navigator = Navigator.of(context);
                    final newReminder = ReminderModel(
                      id: widget.reminder?.id,
                      patientId: currentUserId,
                      triggerTime: _time,
                      daysOfWeek: _days,
                      type: _type,
                      isActive: widget.reminder?.isActive ?? true,
                    );

                    bool success;
                    if (widget.reminder == null) {
                      success = await viewModel.addReminder(newReminder);
                    } else {
                      success = await viewModel.updateReminder(newReminder);
                    }

                    if (success) {
                      navigator.pop();
                    }
                  },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
            child: viewModel.isLoading
                ? const CircularProgressIndicator(color: AppColors.buttonPrimaryText)
                : const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _dayButton(String label, int bitValue) {
    final isSelected = (_days & bitValue) != 0;
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _days &= ~bitValue;
          } else {
            _days |= bitValue;
          }
        });
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mint : AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.mint : AppColors.navBorder,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.buttonPrimaryText : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
