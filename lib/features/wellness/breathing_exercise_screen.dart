import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';
import '../../widgets/completion_dialog.dart';

// ── Technique model ──────────────────────────────────────────────────────────

class _Technique {
  final String name;
  final String description;
  final int inhale;
  final int hold1;
  final int exhale;
  final int hold2;
  final IconData icon;

  const _Technique({
    required this.name,
    required this.description,
    required this.inhale,
    required this.hold1,
    required this.exhale,
    required this.hold2,
    required this.icon,
  });
}

enum _Phase { ready, inhale, hold1, exhale, hold2 }

// ── Screen ───────────────────────────────────────────────────────────────────

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  static const _techniques = [
    _Technique(
      name: 'Box Breathing',
      description: '4-4-4-4  — regain focus and calm under pressure',
      inhale: 4, hold1: 4, exhale: 4, hold2: 4,
      icon: Icons.crop_square_rounded,
    ),
    _Technique(
      name: '4-7-8 Relaxing',
      description: '4-7-8  — slows heart rate, ideal before sleep',
      inhale: 4, hold1: 7, exhale: 8, hold2: 0,
      icon: Icons.nights_stay_rounded,
    ),
    _Technique(
      name: 'Calm Breath',
      description: '4-6  — gentle rhythm to ease everyday anxiety',
      inhale: 4, hold1: 0, exhale: 6, hold2: 0,
      icon: Icons.air_rounded,
    ),
  ];

  int _techniqueIndex = 0;
  _Technique get _technique => _techniques[_techniqueIndex];

  late AnimationController _ctrl;
  _Phase _phase = _Phase.ready;
  int _countdown = 0;
  int _breathCount = 0;
  bool _isActive = false;
  bool _cycleRunning = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..value = 0.0;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    setState(() => _countdown = seconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _countdown--);
      if (_countdown <= 0) t.cancel();
    });
  }

  Future<void> _runCycle() async {
    _cycleRunning = true;
    while (_isActive && mounted) {
      final t = _technique;

      // Inhale
      setState(() { _phase = _Phase.inhale; });
      _startCountdown(t.inhale);
      _ctrl.duration = Duration(seconds: t.inhale);
      await _ctrl.animateTo(1.0, curve: Curves.easeIn);
      if (!_isActive || !mounted) break;

      // Hold 1
      if (t.hold1 > 0) {
        setState(() { _phase = _Phase.hold1; });
        _startCountdown(t.hold1);
        await Future.delayed(Duration(seconds: t.hold1));
        if (!_isActive || !mounted) break;
      }

      // Exhale
      setState(() { _phase = _Phase.exhale; });
      _startCountdown(t.exhale);
      _ctrl.duration = Duration(seconds: t.exhale);
      await _ctrl.animateTo(0.0, curve: Curves.easeOut);
      if (!_isActive || !mounted) break;

      // Hold 2
      if (t.hold2 > 0) {
        setState(() { _phase = _Phase.hold2; });
        _startCountdown(t.hold2);
        await Future.delayed(Duration(seconds: t.hold2));
        if (!_isActive || !mounted) break;
      }

      if (mounted) setState(() => _breathCount++);

      // Complete after 5 cycles
      if (_breathCount >= 5) {
        _isActive = false;
        _cycleRunning = false;
        if (mounted) {
          setState(() { _phase = _Phase.ready; _countdown = 0; });
          HapticFeedback.mediumImpact();
          _showComplete();
        }
        return;
      }
    }

    if (mounted) setState(() { _phase = _Phase.ready; _countdown = 0; });
    _cycleRunning = false;
  }

  void _toggle() {
    if (_isActive) {
      _countdownTimer?.cancel();
      _ctrl.stop();
      setState(() {
        _isActive = false;
        _phase = _Phase.ready;
        _countdown = 0;
      });
    } else {
      setState(() {
        _isActive = true;
        _breathCount = 0;
      });
      HapticFeedback.lightImpact();
      if (!_cycleRunning) _runCycle();
    }
  }

  void _showComplete() {
    CompletionDialog.show(
      context: context,
      title: 'Session Complete',
      message: 'You completed 5 breath cycles.\nCarry this calm with you.',
      color: AppTheme.primary,
      icon: Icons.air_rounded,
      primaryLabel: 'Done',
      secondaryLabel: 'Go Again',
      onPrimary: () => Navigator.pop(context),
      onSecondary: () {
        setState(() {
          _breathCount = 0;
          _isActive = true;
          _ctrl.value = 0.0;
        });
        if (!_cycleRunning) _runCycle();
      },
    );
  }

  String get _phaseLabel {
    switch (_phase) {
      case _Phase.inhale: return 'Inhale';
      case _Phase.hold1:  return 'Hold';
      case _Phase.exhale: return 'Exhale';
      case _Phase.hold2:  return 'Pause';
      case _Phase.ready:  return 'Ready';
    }
  }

  String get _phaseInstruction {
    switch (_phase) {
      case _Phase.inhale: return 'Breathe in slowly through your nose';
      case _Phase.hold1:  return 'Hold your breath gently';
      case _Phase.exhale: return 'Breathe out slowly through your mouth';
      case _Phase.hold2:  return 'Pause and let your body settle';
      case _Phase.ready:  return 'Tap Start when you are ready';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: const Text('Guided Breathing')),
      body: Column(
        children: [
          // Technique selector
          _TechniqueSelector(
            techniques: _techniques,
            selected: _techniqueIndex,
            enabled: !_isActive,
            onSelect: (i) {
              _countdownTimer?.cancel();
              _ctrl.stop();
              setState(() {
                _techniqueIndex = i;
                _isActive = false;
                _phase = _Phase.ready;
                _countdown = 0;
                _breathCount = 0;
                _ctrl.value = 0.0;
              });
            },
          ),

          // Breathing hero
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated circle
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) {
                      const baseSize = 200.0;
                      final scale = 0.6 + _ctrl.value * 0.4;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ripple ring
                          Container(
                            width: baseSize * scale + 28,
                            height: baseSize * scale + 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryLight
                                    .withValues(alpha: 0.35),
                                width: 2,
                              ),
                            ),
                          ),
                          // Main circle
                          Container(
                            width: baseSize * scale,
                            height: baseSize * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.primaryLight.withValues(alpha: 0.75),
                                  AppTheme.primary.withValues(alpha: 0.95),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.28),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    key: ValueKey(_phaseLabel),
                                    _phaseLabel,
                                    style: AppTheme.headingSm
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                                if (_isActive && _countdown > 0)
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Text(
                                      key: ValueKey(_countdown),
                                      '$_countdown',
                                      style: AppTheme.display.copyWith(
                                        color: Colors.white,
                                        fontSize: 44,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      key: ValueKey(_phaseInstruction),
                      _phaseInstruction,
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyLg,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (_isActive)
                    Text('Cycle ${_breathCount + 1} of 5',
                        style: AppTheme.bodySm),

                  const SizedBox(height: 36),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: FilledButton.icon(
                      onPressed: _toggle,
                      icon: Icon(_isActive
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded),
                      label: Text(_isActive ? 'Stop' : 'Start'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _isActive
                            ? AppTheme.textMuted
                            : AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Technique selector widget ────────────────────────────────────────────────

class _TechniqueSelector extends StatelessWidget {
  final List<_Technique> techniques;
  final int selected;
  final bool enabled;
  final ValueChanged<int> onSelect;

  const _TechniqueSelector({
    required this.techniques,
    required this.selected,
    required this.enabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgSurface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose a technique',
              style: AppTheme.bodySm.copyWith(color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          Row(
            children: List.generate(techniques.length, (i) {
              final t = techniques[i];
              final sel = i == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: enabled ? () => onSelect(i) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                        right: i < techniques.length - 1 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 6),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppTheme.primarySurface
                          : AppTheme.bgPage,
                      borderRadius:
                          BorderRadius.circular(AppTheme.cornerRadius),
                      border: Border.all(
                        color: sel
                            ? AppTheme.primary
                            : AppTheme.bgBorder,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(t.icon,
                            size: 20,
                            color: sel
                                ? AppTheme.primary
                                : AppTheme.textMuted),
                        const SizedBox(height: 4),
                        Text(
                          t.name,
                          textAlign: TextAlign.center,
                          style: AppTheme.bodySm.copyWith(
                            fontSize: 11,
                            color: sel
                                ? AppTheme.primary
                                : AppTheme.textMuted,
                            fontWeight: sel
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            techniques[selected].description,
            style: AppTheme.bodySm,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
