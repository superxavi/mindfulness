import 'package:flutter/material.dart';

import 'patient_appointments_view.dart';

class SolicitarCitaView extends StatelessWidget {
  const SolicitarCitaView({super.key});

  @override
  Widget build(BuildContext context) {
    return const PatientAppointmentsView(
      initialTab: PatientAppointmentsTab.requests,
      openRequestComposerOnStart: true,
    );
  }
}
