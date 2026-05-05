import 'package:flutter/material.dart';

import 'patient_appointments_view.dart';

class MisCitasView extends StatelessWidget {
  const MisCitasView({super.key});

  @override
  Widget build(BuildContext context) {
    return const PatientAppointmentsView(
      initialTab: PatientAppointmentsTab.requests,
    );
  }
}
