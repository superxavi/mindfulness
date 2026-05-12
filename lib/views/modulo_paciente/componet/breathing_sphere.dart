import 'dart:math';
import 'package:flutter/material.dart';
import 'breathing_visualizer.dart';

class BreathingSphere extends StatefulWidget {
  final Animation<double> animation;
  final String label;

  const BreathingSphere({
    super.key,
    required this.animation,
    required this.label,
  });

  @override
  State<BreathingSphere> createState() => _BreathingSphereState();
}

class _BreathingSphereState extends State<BreathingSphere> {
  late final BreathingShape _randomShape;

  @override
  void initState() {
    super.initState();
    // Elegimos una forma al azar al iniciar para que cada sesión sea diferente
    final shapes = BreathingShape.values;
    _randomShape = shapes[Random().nextInt(shapes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return BreathingVisualizer(
      animation: widget.animation,
      label: widget.label,
      shape: _randomShape,
    );
  }
}
