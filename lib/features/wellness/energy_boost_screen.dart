import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnergyBoostScreen extends StatefulWidget {
  const EnergyBoostScreen({super.key});

  @override
  State<EnergyBoostScreen> createState() => _EnergyBoostScreenState();
}

class _EnergyBoostScreenState extends State<EnergyBoostScreen>
    with SingleTickerProviderStateMixin {
  int _currentExercise = 0;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _completed = false;

  Timer? _timer;

  final List<EnergyExercise> _exercises = [
    EnergyExercise("Jumping Jacks", "Get your blood flowing!", 30, "🔄", Colors.teal),
    EnergyExercise("Power Pose", "Stand tall and confident", 20, "💪", Colors.blueAccent),
    EnergyExercise("Shoulder Rolls", "Release tension in your body", 30, "👐", Colors.orangeAccent),
    EnergyExercise("Deep Breaths", "Center yourself with slow breathing", 15, "🌬️", Colors.purple),
  ];

  void _startExercise() {
    setState(() {
      _isRunning = true;
      _secondsRemaining = _exercises[_currentExercise].duration;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _nextExercise();
      }
    });
  }

  void _nextExercise() {
    HapticFeedback.mediumImpact();
    if (_currentExercise < _exercises.length - 1) {
      setState(() {
        _currentExercise++;
        _isRunning = false;
      });
    } else {
      setState(() {
        _completed = true;
        _isRunning = false;
      });
    }
  }

  void _skipExercise() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    _nextExercise();
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _completed = false;
      _currentExercise = 0;
      _secondsRemaining = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercises[_currentExercise];
    final themeColor = const Color(0xFF0D896C);
    final progress = _isRunning
        ? 1 - (_secondsRemaining / exercise.duration)
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Energy Boost'),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeColor.withValues(alpha:0.1),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Column(
            children: [
              LinearProgressIndicator(
                value: (_currentExercise + progress) / _exercises.length,
                minHeight: 4,
                backgroundColor: Colors.grey[300],
                color: themeColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated circular progress
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, _) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 10,
                                  backgroundColor:
                                      exercise.color.withValues(alpha:0.1),
                                  color: exercise.color,
                                ),
                              ),
                              Text(
                                _isRunning
                                    ? '$_secondsRemaining'
                                    : exercise.emoji,
                                style: TextStyle(
                                  fontSize: _isRunning ? 48 : 60,
                                  fontWeight: FontWeight.bold,
                                  color: exercise.color,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exercise.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Exercise ${_currentExercise + 1} of ${_exercises.length}',
                        style: const TextStyle(
                            color: Colors.black45, fontSize: 14),
                      ),
                      const Spacer(),
                      if (!_isRunning)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: _startExercise,
                            style: FilledButton.styleFrom(
                              backgroundColor: exercise.color,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              _currentExercise == 0
                                  ? 'Start Energy Boost'
                                  : 'Next Exercise',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _skipExercise,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: exercise.color),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: exercise.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FilledButton(
                                onPressed: _nextExercise,
                                style: FilledButton.styleFrom(
                                  backgroundColor: exercise.color,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text(
                                  'Done',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_completed)
            Container(
              color: Colors.black.withValues(alpha:0.6),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withValues(alpha:0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded,
                          color: Colors.teal, size: 60),
                      const SizedBox(height: 16),
                      const Text(
                        'Energy Boost Complete!',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You’ve powered through every move.\nFeel that spark of energy!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _reset,
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Text(
                            'Done',
                            style: TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('About Energy Boost'),
        content: const Text(
          'A quick set of short movements to help you regain focus and energy.\n\n'
          'Each exercise takes under a minute. Do them daily when you feel tired or sluggish.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Got it', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }
}

class EnergyExercise {
  final String name;
  final String description;
  final int duration;
  final String emoji;
  final Color color;

  const EnergyExercise(
      this.name, this.description, this.duration, this.emoji, this.color);
}
