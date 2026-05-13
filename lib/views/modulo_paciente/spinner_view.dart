import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

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

  bool _audioEnabled = false; // Audio Off por defecto
  bool _wasSpinning = false;

  // [SONIDO] final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // [SONIDO] Configurar loop de audio:
    // _audioPlayer.setReleaseMode(ReleaseMode.loop);

    _ticker = createTicker((_) {
      if (_angularVelocity.abs() > 0.001) {
        setState(() {
          _angle += _angularVelocity;
          _angularVelocity *= 0.982; // fricción suave
        });
        _onSpinning();
      } else if (_angularVelocity != 0.0) {
        setState(() => _angularVelocity = 0.0);
        _onSpinStopped();
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    // [SONIDO] _audioPlayer.dispose();
    super.dispose();
  }

  // ── Audio helpers ─────────────────────────────────────────────────────────
  void _onSpinning() {
    if (!_wasSpinning) {
      _wasSpinning = true;
      if (_audioEnabled) {
        // [SONIDO] _audioPlayer.play(AssetSource('sounds/spin_loop.mp3'));
      }
    }
  }

  void _onSpinStopped() {
    if (_wasSpinning) {
      _wasSpinning = false;
      // [SONIDO] _audioPlayer.stop();
    }
  }

  void _toggleAudio() {
    HapticFeedback.selectionClick();
    setState(() => _audioEnabled = !_audioEnabled);
    if (!_audioEnabled) {
      // [SONIDO] _audioPlayer.stop();
    } else if (_wasSpinning) {
      // [SONIDO] _audioPlayer.play(AssetSource('sounds/spin_loop.mp3'));
    }
  }

  // ── Física de giro ────────────────────────────────────────────────────────
  void _onPanUpdate(DragUpdateDetails details) {
    final renderBox =
        _spinnerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;
    final tangentialForce = (dx * details.delta.dy) - (dy * details.delta.dx);

    setState(() {
      _angularVelocity += tangentialForce / 9000.0;
      _angularVelocity = _angularVelocity.clamp(-1.2, 1.2);
    });
  }

  void _impulso() {
    HapticFeedback.heavyImpact();
    setState(() {
      // Agrega velocidad en la dirección actual de giro (o clockwise si está parado)
      final boost = _angularVelocity >= 0 ? 0.6 : -0.6;
      _angularVelocity = (_angularVelocity + boost).clamp(-1.2, 1.2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.refresh, color: Color(0xFF1AAA7A), size: 22),
            SizedBox(width: 8),
            Text(
              'Fidget Spinner',
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF0F4F8),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A1A2E)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.info_outline, color: Color(0xFF1A1A2E)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Instrucción
            Text(
              'Desliza los bordes rápido para girar',
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),

            const Spacer(),

            // Spinner
            Center(
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                child: Container(
                  key: _spinnerKey,
                  width: 300,
                  height: 300,
                  color: Colors.transparent,
                  child: Transform.rotate(
                    angle: _angle,
                    child: const _SpinnerWidget(size: 300),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // ── Botones ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Row(
                children: [
                  // Audio Off / On
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _toggleAudio,
                      icon: Icon(
                        _audioEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        size: 20,
                        color: const Color(0xFF1A1A2E),
                      ),
                      label: Text(
                        _audioEnabled ? 'Audio On' : 'Audio Off',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: Color(0xFFCCCCDD),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Impulso rápido
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _impulso,
                      icon: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Impulso rápido',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1AAA7A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget visual del Spinner con gradientes 3D
// ─────────────────────────────────────────────────────────────────────────────
class _SpinnerWidget extends StatelessWidget {
  final double size;
  const _SpinnerWidget({required this.size});

  static const double _wingOffset = 82.0;
  static const double _wingSize = 108.0;
  static const double _centerSize = 88.0;
  static const double _bearingSize = 36.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Sombra global del conjunto ────────────────────────────────────
        Container(
          width: size * 0.55,
          height: size * 0.55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1AAA7A).withValues(alpha: 0.18),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),

        // ── Ala 1 (arriba) ────────────────────────────────────────────────
        Transform.translate(
          offset: const Offset(0, -_wingOffset),
          child: _buildWing(),
        ),

        // ── Ala 2 (abajo izquierda, 120°) ─────────────────────────────────
        Transform.rotate(
          angle: 2 * math.pi / 3,
          child: Transform.translate(
            offset: const Offset(0, -_wingOffset),
            child: _buildWing(),
          ),
        ),

        // ── Ala 3 (abajo derecha, 240°) ───────────────────────────────────
        Transform.rotate(
          angle: 4 * math.pi / 3,
          child: Transform.translate(
            offset: const Offset(0, -_wingOffset),
            child: _buildWing(),
          ),
        ),

        // ── Centro (rodamiento principal) ─────────────────────────────────
        Container(
          width: _centerSize,
          height: _centerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFF6EDDB8), // highlight claro
                Color(0xFF1AAA7A), // verde base
                Color(0xFF0D7A55), // sombra
              ],
              stops: [0.0, 0.5, 1.0],
              center: Alignment(-0.3, -0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(3, 5),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: _bearingSize,
              height: _bearingSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFABEDD4), Color(0xFF3DC996)],
                  center: Alignment(-0.3, -0.4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWing() {
    return Container(
      width: _wingSize,
      height: _wingSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF8DEFD0), // highlight blanco-verdoso
            Color(0xFF2DC99A), // verde medio
            Color(0xFF0F8A60), // verde oscuro borde
          ],
          stops: [0.0, 0.5, 1.0],
          center: Alignment(-0.25, -0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(3, 6),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: _wingSize * 0.38,
          height: _wingSize * 0.38,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0xFFD0F7EC), Color(0xFF5DD4A8)],
              center: Alignment(-0.3, -0.4),
            ),
          ),
        ),
      ),
    );
  }
}
