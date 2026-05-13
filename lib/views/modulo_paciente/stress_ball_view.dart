import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class StressBallView extends StatefulWidget {
  const StressBallView({super.key});

  @override
  State<StressBallView> createState() => _StressBallViewState();
}

class _StressBallViewState extends State<StressBallView>
    with SingleTickerProviderStateMixin {
  // ── Física ────────────────────────────────────────────────────────────────
  static const double _ballRadius = 70.0;
  static const double _gravity = 980.0;
  static const double _restitution = 0.72;
  static const double _friction = 0.985;
  static const double _minBounceVelocity = 80;

  // Espacio reservado abajo: contador + botón + paddings
  static const double _bottomUiHeight = 160.0;

  Offset _position = const Offset(200, 400);
  Offset _velocity = Offset.zero;

  bool _isDragging = false;
  late Ticker _ticker;
  DateTime _lastTickTime = DateTime.now();
  int _bounceCount = 0;
  Size _screenSize = Size.zero;

  // [SONIDO] final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // [SONIDO] _audioPlayer.setSource(AssetSource('sounds/bounce.mp3'));

    _ticker = createTicker(_onTick)..start();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _position = Offset(size.width / 2, size.height / 2);
      });
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    // [SONIDO] _audioPlayer.dispose();
    super.dispose();
  }

  // Límite inferior real: pantalla menos UI inferior
  double get _floorY => _screenSize.height - _bottomUiHeight - _ballRadius;

  void _onTick(Duration elapsed) {
    if (_isDragging) return;

    final now = DateTime.now();
    final dt = now.difference(_lastTickTime).inMicroseconds / 1_000_000.0;
    _lastTickTime = now;

    if (dt <= 0 || dt > 0.1) return;

    _velocity = Offset(_velocity.dx, _velocity.dy + _gravity * dt);
    _velocity = _velocity * _friction;

    Offset newPos = _position + _velocity * dt;

    bool bounced = false;

    // Pared izquierda / derecha
    if (newPos.dx - _ballRadius < 0) {
      newPos = Offset(_ballRadius, newPos.dy);
      _velocity = Offset(-_velocity.dx * _restitution, _velocity.dy);
      bounced = true;
    } else if (newPos.dx + _ballRadius > _screenSize.width) {
      newPos = Offset(_screenSize.width - _ballRadius, newPos.dy);
      _velocity = Offset(-_velocity.dx * _restitution, _velocity.dy);
      bounced = true;
    }

    // Techo
    if (newPos.dy - _ballRadius < 0) {
      newPos = Offset(newPos.dx, _ballRadius);
      _velocity = Offset(_velocity.dx, -_velocity.dy * _restitution);
      bounced = true;
    }

    // Suelo virtual: justo encima del contador
    if (newPos.dy > _floorY) {
      newPos = Offset(newPos.dx, _floorY);
      _velocity = Offset(_velocity.dx, -_velocity.dy * _restitution);
      bounced = true;
    }

    if (bounced && _velocity.distance > _minBounceVelocity) {
      _onBounce();
    }

    setState(() {
      _position = newPos;
    });
  }

  Future<void> _onBounce() async {
    HapticFeedback.mediumImpact();
    setState(() => _bounceCount++);
    // [SONIDO] Descomenta:
    // await _audioPlayer.stop();
    // await _audioPlayer.play(AssetSource('sounds/bounce.mp3'));
  }

  void _onDragStart(DragStartDetails d) {
    _isDragging = true;
    _velocity = Offset.zero;
    _lastTickTime = DateTime.now();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _position = Offset(
        (_position.dx + d.delta.dx).clamp(
          _ballRadius,
          _screenSize.width - _ballRadius,
        ),
        (_position.dy + d.delta.dy).clamp(_ballRadius, _floorY),
      );
    });
  }

  void _onDragEnd(DragEndDetails d) {
    _isDragging = false;
    _lastTickTime = DateTime.now();

    final vx = d.velocity.pixelsPerSecond.dx;
    final vy = d.velocity.pixelsPerSecond.dy;
    const maxV = 3000.0;
    final speed = Offset(vx, vy).distance;
    _velocity = speed > maxV ? Offset(vx, vy) * (maxV / speed) : Offset(vx, vy);
  }

  void _resetCounter() {
    HapticFeedback.mediumImpact();
    setState(() => _bounceCount = 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _screenSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircleAvatar(radius: 9, backgroundColor: Color(0xFFE8622A)),
                SizedBox(width: 8),
                Text(
                  'Pelota Antiestrés',
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
          body: Stack(
            children: [
              // Instrucción
              const Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Text(
                  'Arrastra y suelta para lanzar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF888899), fontSize: 15),
                ),
              ),

              // Área de gestos (toda la zona de juego)
              GestureDetector(
                onPanStart: _onDragStart,
                onPanUpdate: _onDragUpdate,
                onPanEnd: _onDragEnd,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              // Sombra proyectada
              Positioned(
                left: _position.dx - _ballRadius * 0.7,
                top: _position.dy + _ballRadius * 0.65,
                child: Container(
                  width: _ballRadius * 1.4,
                  height: _ballRadius * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              // La bola
              Positioned(
                left: _position.dx - _ballRadius,
                top: _position.dy - _ballRadius,
                child: GestureDetector(
                  onPanStart: _onDragStart,
                  onPanUpdate: _onDragUpdate,
                  onPanEnd: _onDragEnd,
                  child: _StressBall(
                    radius: _ballRadius,
                    isDragging: _isDragging,
                  ),
                ),
              ),

              // ── UI inferior: contador + botón ────────────────────────────
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Contador
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Rebotes:',
                            style: TextStyle(
                              color: Color(0xFF555566),
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '$_bounceCount',
                            style: const TextStyle(
                              color: Color(0xFFE8622A),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Botón reiniciar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _resetCounter,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text(
                          'Reiniciar Contador',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8622A),
                          padding: const EdgeInsets.symmetric(vertical: 15),
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
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget visual de la bola
// ─────────────────────────────────────────────────────────────────────────────
class _StressBall extends StatelessWidget {
  final double radius;
  final bool isDragging;

  const _StressBall({required this.radius, required this.isDragging});

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;
    return AnimatedScale(
      scale: isDragging ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFFFFB347), Color(0xFFE8622A), Color(0xFFB84010)],
            stops: [0.0, 0.55, 1.0],
            center: Alignment(-0.3, -0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB84010).withValues(alpha: 0.45),
              blurRadius: isDragging ? 22 : 16,
              offset: const Offset(4, 8),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: size * 0.12,
              left: size * 0.2,
              child: Container(
                width: size * 0.28,
                height: size * 0.16,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            Positioned(
              top: size * 0.22,
              left: size * 0.28,
              child: Container(
                width: size * 0.1,
                height: size * 0.06,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
