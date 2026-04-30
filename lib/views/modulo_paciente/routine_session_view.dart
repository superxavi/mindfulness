import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/routine_model.dart';
import '../../moduloTareas/viewmodels/tasks_viewmodel.dart';
import '../../viewmodels/routines_viewmodel.dart';
import 'componet/breathing_session_ui.dart';
import 'componet/timed_session_ui.dart';
import 'self_assessment_flow.dart';

enum _BreathPhase { inhale, holdIn, exhale, holdOut }

class RoutineSessionView extends StatefulWidget {
  final RoutineModel routine;
  final String sessionId;
  final String? assignmentId;

  const RoutineSessionView({
    super.key,
    required this.routine,
    required this.sessionId,
    this.assignmentId,
  });

  @override
  State<RoutineSessionView> createState() => _RoutineSessionViewState();
}

class _RoutineSessionViewState extends State<RoutineSessionView>
    with SingleTickerProviderStateMixin {
  bool _countdownDone = false;
  bool _finishRequested = false;
  late final AnimationController _sphereController;

  Timer? _timer;
  
  // Estado para rutinas de respiración
  _BreathPhase _phase = _BreathPhase.inhale;
  int _phaseElapsed = 0;
  int _cyclesCompleted = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _sphereController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  void _startSession() {
    setState(() => _countdownDone = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _updatePhaseUI();
  }

  void _tick() {
    if (!mounted) return;

    if (widget.routine.breathingPattern != null) {
      final p = widget.routine.breathingPattern!;
      final duration = _getDurationFor(_phase, p);

      setState(() {
        _phaseElapsed++;
        if (_phaseElapsed >= duration) {
          _advancePhase(p);
        }
      });
    } else {
      setState(() {
        _phaseElapsed++;
        if (_phaseElapsed >= widget.routine.durationSeconds) {
          _finishSession();
        }
      });
    }
  }

  int _getDurationFor(_BreathPhase phase, BreathingPatternModel p) =>
      switch (phase) {
        _BreathPhase.inhale => p.inhaleSec,
        _BreathPhase.holdIn => p.holdInSec,
        _BreathPhase.exhale => p.exhaleSec,
        _BreathPhase.holdOut => p.holdOutSec,
      };

  void _advancePhase(BreathingPatternModel p) {
    final phases = [
      _BreathPhase.inhale,
      _BreathPhase.holdIn,
      _BreathPhase.exhale,
      _BreathPhase.holdOut,
    ].where((ph) => _getDurationFor(ph, p) > 0).toList();

    int currentIndex = phases.indexOf(_phase);
    if (currentIndex == phases.length - 1) {
      _cyclesCompleted++;
      if (_cyclesCompleted >= p.cyclesRecommended) {
        _finishSession();
        return;
      }
      _phase = phases[0];
    } else {
      _phase = phases[currentIndex + 1];
    }

    _phaseElapsed = 0;
    _playBell();
    _updatePhaseUI();
  }

  void _updatePhaseUI() {
    if (widget.routine.breathingPattern == null) {
      _sphereController.duration = const Duration(seconds: 8);
      _sphereController.repeat(reverse: true);
      return;
    }

    final p = widget.routine.breathingPattern!;
    _sphereController.duration = Duration(seconds: _getDurationFor(_phase, p));
    if (_phase == _BreathPhase.inhale) _sphereController.forward(from: 0);
    if (_phase == _BreathPhase.exhale) _sphereController.reverse(from: 1);
  }

  Future<void> _playBell() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/bell.wav'), volume: 0.5);
    } catch (_) {}
  }

  Future<void> _finishSession() async {
    if (_finishRequested) return;
    _finishRequested = true;
    _timer?.cancel();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      builder: (_) => PostSessionAssessmentSheet(
        sessionId: widget.sessionId,
        routineTitle: widget.routine.title,
      ),
    );

    if (ok == true && mounted) {
      await context.read<RoutinesViewModel>().completeSession(
        sessionId: widget.sessionId,
      );

      if (widget.assignmentId != null && mounted) {
        await context.read<TasksViewModel>().markAsDone(
          widget.sessionId,
          widget.assignmentId!,
        );
      }

      if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
    } else {
      _finishRequested = false;
      _startSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_countdownDone) return _buildCountdown();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildSessionUI(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionUI() {
    final pattern = widget.routine.breathingPattern;
    
    // GUARDIA: Si tiene patrón de respiración, usar UI especializada
    if (pattern != null) {
      final phaseDuration = _getDurationFor(_phase, pattern);
      return BreathingSessionUI(
        currentLabel: _getPhaseLabel(_phase),
        remainingTime: '${phaseDuration - _phaseElapsed}s',
        phaseProgress: phaseDuration > 0 ? (_phaseElapsed / phaseDuration).clamp(0.0, 1.0) : 0.0,
        completedCycles: _cyclesCompleted,
        totalCycles: pattern.cyclesRecommended,
        animationController: _sphereController,
        onFinish: _finishSession,
      );
    }

    // De lo contrario, usar UI de tiempo genérica
    return TimedSessionUI(
      title: widget.routine.title,
      elapsedSeconds: _phaseElapsed,
      totalSeconds: widget.routine.durationSeconds,
      animationController: _sphereController,
      onFinish: _finishSession,
    );
  }

  String _getPhaseLabel(_BreathPhase phase) => switch (phase) {
    _BreathPhase.inhale => 'Inhala',
    _BreathPhase.holdIn => 'Retén',
    _BreathPhase.exhale => 'Exhala',
    _BreathPhase.holdOut => 'Pausa',
  };

  Widget _buildCountdown() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.routine.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.routine.category.label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _startSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mint,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text("Comenzar Sesión"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white70),
        ),
        Text(
          widget.routine.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sphereController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
