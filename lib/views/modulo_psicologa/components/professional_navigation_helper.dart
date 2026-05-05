import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/psicologa_nav_viewmodel.dart';

class ProfessionalNavigationHelper {
  const ProfessionalNavigationHelper._();

  static void returnToHome(BuildContext context, {int tabIndex = 0}) {
    final target = tabIndex.clamp(0, 4);
    context.read<PsicologaNavViewModel>().updateIndex(target);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
