import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/theme/app_colors.dart';

class SpinnerView extends StatefulWidget {
  const SpinnerView({super.key});

  @override
  State<SpinnerView> createState() => _SpinnerViewState();
}

class _SpinnerViewState extends State<SpinnerView>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _angle = 0.0;
  double _angularVelocity = 0.0;
  final GlobalKey _spinnerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Creamos un ciclo (frame) manual. Esto es súper seguro y no da errores "NaN".
    _ticker = createTicker((Duration elapsed) {
      if (_angularVelocity.abs() > 0.001) {
        setState(() {
          _angle += _angularVelocity;
          // Aplicar fricción: pierde el 2% de su velocidad en cada frame
          _angularVelocity *= 0.98;
        });
      } else if (_angularVelocity != 0.0) {
        // Detenerlo completamente si ya va muy lento
        setState(() {
          _angularVelocity = 0.0;
        });
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // Obtenemos la caja exacta donde está el spinner para calcular su centro
    final renderBox =
        _spinnerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final center = Offset(size.width / 2, size.height / 2);

      // Vector desde el centro hacia donde está el dedo
      final dx = details.localPosition.dx - center.dx;
      final dy = details.localPosition.dy - center.dy;

      // Movimiento del dedo en este instante
      final deltaX = details.delta.dx;
      final deltaY = details.delta.dy;

      // Matemática de producto cruz (Física básica):
      // Calcula si el empuje hace girar el spinner a la derecha o a la izquierda
      final tangentialForce = (dx * deltaY) - (dy * deltaX);

      setState(() {
        // Convertimos la fuerza del dedo en velocidad (ajusta el 10000 para más o menos sensibilidad)
        _angularVelocity += tangentialForce / 10000.0;

        // Ponemos un límite máximo de velocidad para que no gire de forma extrema
        _angularVelocity = _angularVelocity.clamp(-1.0, 1.0);
      });
    }
  }

  void _stopSpinner() {
    setState(() {
      _angularVelocity = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fidget Spinner'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              'Desliza los bordes rápido para girar',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const Spacer(),
            Center(
              // El GestureDetector envuelve un área transparente fija
              // Así las coordenadas del dedo no rotan junto con el dibujo
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                child: Container(
                  key: _spinnerKey,
                  width: 280,
                  height: 280,
                  color: Colors
                      .transparent, // Importante para detectar toques en todo el cuadro
                  child: Transform.rotate(
                    angle: _angle,
                    child: const SpinnerWidget(size: 280),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: ElevatedButton.icon(
                onPressed: _stopSpinner,
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Frenar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget visual del Spinner
class SpinnerWidget extends StatelessWidget {
  final double size;
  const SpinnerWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    const double wingSize = 90;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Centro
        Container(
          width: wingSize,
          height: wingSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.mint,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        // Ala 1 (arriba)
        Transform.translate(
          offset: const Offset(0, -wingSize * 0.9),
          child: _buildWing(),
        ),
        // Ala 2 (abajo izquierda)
        Transform.rotate(
          angle: 2 * math.pi / 3, // 120 grados
          child: Transform.translate(
            offset: const Offset(0, -wingSize * 0.9),
            child: _buildWing(),
          ),
        ),
        // Ala 3 (abajo derecha)
        Transform.rotate(
          angle: 4 * math.pi / 3, // 240 grados
          child: Transform.translate(
            offset: const Offset(0, -wingSize * 0.9),
            child: _buildWing(),
          ),
        ),
      ],
    );
  }

  Widget _buildWing() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceHigh,
        border: Border.all(color: AppColors.mint, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      // Rodamiento interno visual
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.outlineVariant,
          ),
        ),
      ),
    );
  }
}
