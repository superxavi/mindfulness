import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../models/routine_model.dart';
import 'breathing_sphere.dart';
import 'session_progress_widgets.dart';

class AudioRunner extends StatefulWidget {
  final String audioUrl;
  final int durationSeconds;
  final RoutineCategory? category;
  final VoidCallback onComplete;

  const AudioRunner({
    super.key,
    required this.audioUrl,
    required this.durationSeconds,
    this.category,
    required this.onComplete,
  });

  @override
  State<AudioRunner> createState() => _AudioRunnerState();
}

class _AudioRunnerState extends State<AudioRunner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final AudioPlayer _player = AudioPlayer();

  Timer? _timer;
  int _elapsed = 0;
  bool _isPlaying = false;
  bool _isBuffering = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _player.setUrl(widget.audioUrl);
      await _player.setLoopMode(LoopMode.one);

      if (mounted) {
        setState(() => _isBuffering = false);
        _player.play();
        _startTimer();
      }
    } catch (e) {
      debugPrint("Error cargando audio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Error: No se pudo cargar el sonido de ${widget.category?.label ?? 'la rutina'}.",
            ),
          ),
        );
        _startTimer();
      }
    }

    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isBuffering = state.processingState == ProcessingState.buffering;
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted || !_isPlaying) return;
      setState(() {
        _elapsed++;
      });

      final remaining = widget.durationSeconds - _elapsed;

      if (remaining <= 3 && remaining > 0) {
        final newVolume = (remaining / 3.0).clamp(0.0, 1.0);
        _player.setVolume(newVolume);
      }

      if (_elapsed >= widget.durationSeconds) {
        _timer?.cancel();
        await _player.stop();
        await _player.setVolume(1.0);
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.durationSeconds - _elapsed;
    final minutes = (remaining / 60).floor();
    final seconds = remaining % 60;
    final progress = (_elapsed / widget.durationSeconds).clamp(0.0, 1.0);

    return Column(
      children: [
        const Spacer(),
        if (_isBuffering)
          const CircularProgressIndicator(color: Colors.cyanAccent)
        else
          _CategoryVisualizer(
            category: widget.category ?? RoutineCategory.terapiaSonido,
            animation: _animationController,
          ),
        const Spacer(),

        Text(
          widget.category?.label ?? 'Sesion de Audio',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
            letterSpacing: 2,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 20),

        // Controles de audio
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
              ),
              iconSize: 80,
              color: Colors.cyanAccent,
              onPressed: () {
                if (_isPlaying) {
                  _player.pause();
                } else {
                  _player.play();
                }
              },
            ),
          ],
        ),

        const Spacer(),
        PhaseProgressBar(
          label: _isBuffering ? 'Cargando audio...' : 'Sesion en curso',
          time: '$minutes:${seconds.toString().padLeft(2, '0')}',
          progress: progress,
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class _CategoryVisualizer extends StatelessWidget {
  final RoutineCategory category;
  final AnimationController animation;

  const _CategoryVisualizer({required this.category, required this.animation});

  @override
  Widget build(BuildContext context) {
    final IconData icon = switch (category) {
      RoutineCategory.breathing => Icons.air_rounded,
      RoutineCategory.relaxation => Icons.spa_rounded,
      RoutineCategory.sleepInduction => Icons.bedtime_rounded,
      RoutineCategory.soundscape => Icons.forest_rounded,
      RoutineCategory.terapiaSonido => Icons.graphic_eq_rounded,
      RoutineCategory.all => Icons.audiotrack_rounded,
    };

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: 0.15 * animation.value),
                blurRadius: 40,
                spreadRadius: 20 * animation.value,
              ),
            ],
            border: Border.all(
              color: Colors.cyanAccent.withValues(alpha: 0.3 * animation.value),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 80,
            color: Colors.cyanAccent.withValues(alpha: 0.6 + (0.4 * animation.value)),
          ),
        );
      },
    );
  }
}
