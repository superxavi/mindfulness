import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class BubbleData {
  final int id;
  Offset position;
  bool isPopped;
  double scale;

  BubbleData({
    required this.id,
    required this.position,
    this.isPopped = false,
    this.scale = 1.0,
  });
}

class BubblesExerciseView extends StatefulWidget {
  const BubblesExerciseView({super.key});

  @override
  State<BubblesExerciseView> createState() => _BubblesExerciseViewState();
}

class _BubblesExerciseViewState extends State<BubblesExerciseView> {
  final List<BubbleData> _bubbles = [];
  final double _bubbleSize = 60.0;
  late Size _screenSize;

  @override
  void initState() {
    super.initState();
    // Generar burbujas después del primer frame para tener las medidas de pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateBubbles();
    });
  }

  void _generateBubbles() {
    final renderBox = context.findRenderObject() as RenderBox;
    _screenSize = renderBox.size;

    // Calcular cuántas entran restando padding y AppBar
    final cols = (_screenSize.width / (_bubbleSize + 10)).floor();
    final rows = ((_screenSize.height - 100) / (_bubbleSize + 10)).floor();

    _bubbles.clear();
    int idCounter = 0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        _bubbles.add(
          BubbleData(
            id: idCounter++,
            position: Offset(
              15 + (c * (_bubbleSize + 10)),
              15 + (r * (_bubbleSize + 10)),
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  void _popBubble(int index) {
    if (_bubbles[index].isPopped) return;

    setState(() {
      _bubbles[index].isPopped = true;
      _bubbles[index].scale = 1.3; // Efecto expansión antes de desaparecer
    });

    // Feedback visual rápido
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        _bubbles[index].scale = 0.0;
      });
    });

    // Feedback háptico (vibración leve si está disponible)
    // HapticFeedback.lightImpact();

    // Regenerar la burbuja después de un tiempo
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _bubbles[index].isPopped = false;
        _bubbles[index].scale = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explotar Burbujas'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _bubbles.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: _bubbles.asMap().entries.map((entry) {
                  int index = entry.key;
                  BubbleData bubble = entry.value;

                  return Positioned(
                    left: bubble.position.dx,
                    top: bubble.position.dy,
                    child: GestureDetector(
                      onTap: () => _popBubble(index),
                      child: AnimatedScale(
                        scale: bubble.scale,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutBack,
                        child: Opacity(
                          opacity: bubble.isPopped ? 0.0 : 1.0,
                          child: Container(
                            width: _bubbleSize,
                            height: _bubbleSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.mint.withOpacity(0.3),
                                  AppColors.mint.withOpacity(0.7),
                                ],
                                center: const Alignment(-0.3, -0.3),
                              ),
                              border: Border.all(
                                color: AppColors.mint.withOpacity(0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 2,
                                  offset: const Offset(-1, -1),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
