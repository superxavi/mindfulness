import 'package:flutter/material.dart';

class PatientNavigationHelper {
  const PatientNavigationHelper._();

  static void returnToMainMenu(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
