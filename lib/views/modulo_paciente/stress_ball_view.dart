import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class StressBallView extends StatefulWidget {
  const StressBallView({super.key});

  @override
  State<StressBallView> createState() => _StressBallViewState();
}

class _StressBallViewState extends State<StressBallView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _squeezeCount = 0;
  bool _isSqueezing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150), // Velocidad de apretón
    );

    // Animación de escala va de 1.0 (normal) a 0.7 (apretada)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSqueezeStart() {
    setState(() {
      _isSqueezing = true;
      _squeezeCount++;
    });
    _controller.forward(); // Achicar
    // HapticFeedback.heavyImpact();
  }

  void _onSqueezeEnd() {
    setState(() {
      _isSqueezing = false;
    });
    // Volver a tamaño normal más lento para simular material foam
    _controller.animateTo(
      0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pelota Antiestrés'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              'Manten presionado para apretar',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: GestureDetector(
                onLongPressDown: (_) => _onSqueezeStart(),
                onLongPressUp: () => _onSqueezeEnd(),
                onLongPressCancel: () => _onSqueezeEnd(),
                // También funciona con tap simple para apretón rápido
                onTapDown: (_) => _onSqueezeStart(),
                onTapUp: (_) => _onSqueezeEnd(),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.mint, // Color base
                      gradient: RadialGradient(
                        colors: [
                          AppColors.mint.withOpacity(0.5),
                          AppColors.mint,
                          AppColors.mint.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                        center: const Alignment(-0.2, -0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(5, 10),
                        ),
                        // Brillo interno
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(-5, -5),
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.touch_app,
                        size: 50,
                        color: Colors.white.withOpacity(
                          _isSqueezing ? 0.3 : 0.7,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Veces apretada:',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    '$_squeezeCount',
                    style: TextStyle(
                      color: AppColors.mint,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
