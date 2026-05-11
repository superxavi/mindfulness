import 'package:flutter/material.dart';
import 'citas_enums.dart';

class CitasTabSelector extends StatelessWidget {
  final CitasTab currentTab;
  final ValueChanged<CitasTab> onTabChanged;

  const CitasTabSelector({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<CitasTab>(
      segments: [
        ButtonSegment<CitasTab>(
          value: CitasTab.agenda,
          icon: const Icon(Icons.calendar_month_outlined),
          label: _segmentLabel('Agenda'),
        ),
        ButtonSegment<CitasTab>(
          value: CitasTab.solicitudes,
          icon: const Icon(Icons.mail_outline),
          label: _segmentLabel('Solicitudes'),
        ),
        ButtonSegment<CitasTab>(
          value: CitasTab.historial,
          icon: const Icon(Icons.history),
          label: _segmentLabel('Historial'),
        ),
      ],
      selected: {currentTab},
      showSelectedIcon: false,
      onSelectionChanged: (selection) {
        onTabChanged(selection.first);
      },
    );
  }

  Widget _segmentLabel(String label) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(label, maxLines: 1, softWrap: false),
    );
  }
}
