import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../moduloTareas/model/assignment_model.dart';
import '../../moduloTareas/viewmodels/tasks_viewmodel.dart';

class EjecutarRespiracionView extends StatefulWidget {
  final Assignment assignment;
  const EjecutarRespiracionView({super.key, required this.assignment});

  @override
  State<EjecutarRespiracionView> createState() => _EjecutarRespiracionViewState();
}

class _EjecutarRespiracionViewState extends State<EjecutarRespiracionView>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;
  
  String _sessionId = "";
  int _secondsLeft = 0;
  String _currentAction = "Prepárate";
  bool _isInitialized = false;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.assignment.totalDuration;
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    
    _animation = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _initFlow();
  }

  Future<void> _initFlow() async {
    final vm = context.read<TasksViewModel>();
    // Usamos startSession definido en el ViewModel
    final sid = await vm.startSession(widget.assignment.routineId);
    
    if (sid != null && mounted) {
      _sessionId = sid;
      setState(() => _isInitialized = true);
      _startTimer();
      _runCycles();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al iniciar la sesión")),
      );
      Navigator.pop(context);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _onFinished();
      }
    });
  }

  Future<void> _runCycles() async {
    if (!mounted || _secondsLeft <= 0) return;

    final p = widget.assignment.breathingPattern;
    final int inhale = p['inhale_sec'] as int? ?? 4;
    final int holdIn = p['hold_in_sec'] as int? ?? 2;
    final int exhale = p['exhale_sec'] as int? ?? 6;
    final int holdOut = p['hold_out_sec'] as int? ?? 0;

    // INHALA
    if (!mounted || _secondsLeft <= 0) return;
    setState(() => _currentAction = "INHALA");
    _controller.duration = Duration(seconds: inhale > 0 ? inhale : 1);
    _controller.forward();
    await Future.delayed(Duration(seconds: inhale > 0 ? inhale : 1));

    // MANTÉN (Dentro)
    if (!mounted || _secondsLeft <= 0) return;
    if (holdIn > 0) {
      setState(() => _currentAction = "MANTÉN");
      await Future.delayed(Duration(seconds: holdIn));
    }

    // EXHALA
    if (!mounted || _secondsLeft <= 0) return;
    setState(() => _currentAction = "EXHALA");
    _controller.duration = Duration(seconds: exhale > 0 ? exhale : 1);
    _controller.reverse();
    await Future.delayed(Duration(seconds: exhale > 0 ? exhale : 1));

    // MANTÉN (Fuera/Pausa)
    if (!mounted || _secondsLeft <= 0) return;
    if (holdOut > 0) {
      setState(() => _currentAction = "PAUSA");
      await Future.delayed(Duration(seconds: holdOut));
    }

    if (mounted && _secondsLeft > 0) {
      _runCycles(); // Siguiente ciclo
    }
  }

  Future<void> _onFinished() async {
    if (_isCompleting) return;
    _isCompleting = true;
    _timer?.cancel();

    final vm = context.read<TasksViewModel>();
    // Usamos markAsDone definido en el ViewModel
    final ok = await vm.markAsDone(_sessionId, widget.assignment.id);

    if (mounted) {
      if (ok) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al guardar el progreso")),
        );
        Navigator.pop(context);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("¡Completado!"),
        content: const Text("Has finalizado tu actividad con éxito."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar dialogo
              Navigator.pop(context); // Volver al hub
            },
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    left: 20,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$_secondsLeft s",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 60),
                        ScaleTransition(
                          scale: _animation,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.cyanAccent.withValues(alpha: 0.1),
                              border: Border.all(color: Colors.cyanAccent, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent.withValues(alpha: 0.2),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                        Text(
                          _currentAction,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
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

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
