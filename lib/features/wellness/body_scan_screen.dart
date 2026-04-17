import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';
import '../../widgets/completion_dialog.dart';

// ── Step model ────────────────────────────────────────────────────────────────

class _ScanStep {
  final String region;
  final String instruction;
  final IconData icon;
  final String breathCue; // short breathing reminder
  const _ScanStep(this.region, this.instruction, this.icon, this.breathCue);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class BodyScanScreen extends StatefulWidget {
  const BodyScanScreen({super.key});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends State<BodyScanScreen>
    with SingleTickerProviderStateMixin {
  static const _steps = [
    _ScanStep(
      'Settle In',
      'Find a comfortable position and gently close your eyes. Take a slow, deep breath and let your body begin to soften.',
      Icons.self_improvement_rounded,
      'Breathe in... breathe out',
    ),
    _ScanStep(
      'Head & Face',
      'Bring warm awareness to your forehead and scalp. Notice any tension and let your face soften — your jaw, cheeks, the space around your eyes.',
      Icons.face_rounded,
      'With each exhale, soften your face',
    ),
    _ScanStep(
      'Neck & Shoulders',
      'Let your shoulders drop gently away from your ears. Feel any tightness in your neck begin to dissolve with every slow exhale.',
      Icons.accessibility_rounded,
      'Drop your shoulders with each breath out',
    ),
    _ScanStep(
      'Chest & Back',
      'Notice your chest rising and falling. Feel your back fully held by whatever supports you. Breathe gently into any tight spaces.',
      Icons.favorite_border_rounded,
      'Your chest rises... and falls',
    ),
    _ScanStep(
      'Hands & Arms',
      'Allow your arms to feel heavy and completely still. Notice warmth or tingling in your palms and fingertips — a sign of deep relaxation.',
      Icons.pan_tool_rounded,
      'Let your arms grow heavy',
    ),
    _ScanStep(
      'Stomach & Hips',
      'Soften your belly with every exhale. Allow your hips and lower back to fully release into the surface beneath you.',
      Icons.airline_seat_recline_normal_rounded,
      'Release your belly on each exhale',
    ),
    _ScanStep(
      'Legs & Feet',
      'Feel the weight of your legs. Notice your feet. Release any remaining tension slowly, moving from your toes all the way up.',
      Icons.directions_walk_rounded,
      'Let your legs grow warm and heavy',
    ),
    _ScanStep(
      'Whole Body',
      'Take one final deep breath and sense your whole body at ease. You have arrived in this moment. Carry this stillness with you.',
      Icons.spa_rounded,
      'Your whole body is at rest',
    ),
  ];

  static const _autoSeconds = 20;

  int _step = 0;
  bool _autoAdvance = false;
  int _autoCountdown = _autoSeconds;
  Timer? _countdownTimer;

  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Auto-advance ───────────────────────────────────────────────────────────

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _autoCountdown = _autoSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _autoCountdown--);
      if (_autoCountdown <= 0) {
        t.cancel();
        _next();
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    if (mounted) setState(() => _autoCountdown = _autoSeconds);
  }

  void _toggleAuto(bool v) {
    setState(() => _autoAdvance = v);
    v ? _startCountdown() : _stopCountdown();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
      HapticFeedback.selectionClick();
      if (_autoAdvance) _startCountdown();
    } else {
      _stopCountdown();
      HapticFeedback.mediumImpact();
      CompletionDialog.show(
        context: context,
        title: 'Body Scan Complete',
        message: 'You have moved through your whole body with care.\nRest in this stillness.',
        color: AppTheme.primary,
        icon: Icons.spa_rounded,
        primaryLabel: 'Done',
        secondaryLabel: 'Go Again',
        onPrimary: () => Navigator.pop(context),
        onSecondary: () {
          setState(() { _step = 0; });
          if (_autoAdvance) _startCountdown();
        },
      );
    }
  }

  void _prev() {
    if (_step > 0) {
      setState(() => _step--);
      if (_autoAdvance) _startCountdown();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final current = _steps[_step];
    final isLast  = _step == _steps.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: const Text('Body Scan')),
      body: Column(
        children: [
          // ── Hero section ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              children: [
                // Step dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) {
                    final active = i == _step;
                    final past   = i < _step;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width:  active ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white
                            : past
                                ? Colors.white.withValues(alpha: 0.55)
                                : Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Pulsing icon circle
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Stack(
                    alignment: Alignment.center,
                    children: [
                      // Soft outer glow ring
                      Container(
                        width: 116 + _pulseCtrl.value * 12,
                        height: 116 + _pulseCtrl.value * 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white
                              .withValues(alpha: 0.10 * (1 - _pulseCtrl.value)),
                        ),
                      ),
                      // Main circle
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.18),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.55),
                              width: 2),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            key: ValueKey(_step),
                            current.icon,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Region name
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    key: ValueKey('r$_step'),
                    current.region,
                    style: AppTheme.headingMd.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 6),

                // Breath cue
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    key: ValueKey('cue$_step'),
                    current.breathCue,
                    style: AppTheme.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // ── Instruction card ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instruction
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius:
                          BorderRadius.circular(AppTheme.cornerRadiusLg),
                      border: Border.all(color: AppTheme.bgBorder),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: Text(
                        key: ValueKey('inst$_step'),
                        current.instruction,
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyLg.copyWith(height: 1.65),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Auto-advance row
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySurface,
                      borderRadius:
                          BorderRadius.circular(AppTheme.cornerRadius),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_rounded,
                            color: AppTheme.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Auto-advance every 20 s',
                                  style: AppTheme.bodyMd.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600)),
                              if (_autoAdvance)
                                Text(
                                  'Moving on in $_autoCountdown s',
                                  style: AppTheme.bodySm,
                                ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _autoAdvance,
                          onChanged: _toggleAuto,
                          activeTrackColor: AppTheme.primary,
                          activeThumbColor: Colors.white,
                        ),
                      ],
                    ),
                  ),

                  // Auto progress bar
                  if (_autoAdvance) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 1 - (_autoCountdown / _autoSeconds),
                        backgroundColor: AppTheme.primarySurface,
                        minHeight: 5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Navigation ────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (_step > 0) ...[
                    OutlinedButton(
                      onPressed: _prev,
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52)),
                      child: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _next,
                      icon: Icon(isLast
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded),
                      label: Text(
                        isLast
                            ? 'Complete'
                            : 'Next  (${_step + 1}/${_steps.length})',
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
