import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

// ── Step model ────────────────────────────────────────────────────────────────

class _CalmStep {
  final String title;
  final String instruction;
  final IconData icon;
  const _CalmStep(this.title, this.instruction, this.icon);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class EmergencyCalmScreen extends StatefulWidget {
  const EmergencyCalmScreen({super.key});

  @override
  State<EmergencyCalmScreen> createState() => _EmergencyCalmScreenState();
}

class _EmergencyCalmScreenState extends State<EmergencyCalmScreen>
    with SingleTickerProviderStateMixin {
  static const _steps = [
    _CalmStep(
      'You Are Safe',
      'Find a comfortable position.\nYou do not need to do anything right now except breathe.',
      Icons.shield_rounded,
    ),
    _CalmStep(
      'Ground Yourself',
      'Press both feet flat on the floor.\nFeel the surface beneath you. You are held and supported.',
      Icons.download_rounded,
    ),
    _CalmStep(
      'Breathe In',
      'Place one hand on your chest.\nSlowly breathe in through your nose for 4 counts.',
      Icons.north_rounded,
    ),
    _CalmStep(
      'Hold Gently',
      'Hold your breath for just 2 counts.\nNo force — just a soft, gentle pause.',
      Icons.pause_circle_rounded,
    ),
    _CalmStep(
      'Breathe Out',
      'Slowly breathe out through your mouth for 6 counts.\nLet everything go with the breath.',
      Icons.south_rounded,
    ),
    _CalmStep(
      'Notice Your Body',
      'Feel your shoulders soften.\nYour jaw, your hands, your belly. This feeling will pass.',
      Icons.accessibility_new_rounded,
    ),
    _CalmStep(
      'Repeat',
      'Take 2 more slow breath cycles.\nWith each exhale, a little more tension leaves your body.',
      Icons.refresh_rounded,
    ),
    _CalmStep(
      'You Did It',
      'You moved through a hard moment with courage.\nYou are still here. That is enough.',
      Icons.favorite_rounded,
    ),
  ];

  late final AnimationController _pulseCtrl;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
      HapticFeedback.selectionClick();
    }
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    final current  = _steps[_step];
    final isLast   = _step == _steps.length - 1;
    final progress = (_step + 1) / _steps.length;

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      // ── Standard AppBar with back button ───────────────────────────────────
      appBar: AppBar(title: const Text('Emergency Calm')),
      body: Column(
        children: [
          // ── Progress bar ──────────────────────────────────────────────────
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.primarySurface,
            minHeight: 4,
          ),

          // ── Hero gradient card ────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
            child: Column(
              children: [
                // Step counter
                Text(
                  'Step ${_step + 1} of ${_steps.length}',
                  style: AppTheme.bodySm
                      .copyWith(color: Colors.white.withValues(alpha: 0.70)),
                ),

                const SizedBox(height: 20),

                // Pulsing icon circle
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 116 + _pulseCtrl.value * 14,
                        height: 116 + _pulseCtrl.value * 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(
                              alpha: 0.08 * (1 - _pulseCtrl.value)),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.50),
                            width: 2,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            key: ValueKey(_step),
                            current.icon,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Step title
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    key: ValueKey('t$_step'),
                    current.title,
                    style: AppTheme.headingMd
                        .copyWith(color: Colors.white),
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
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(
                          AppTheme.cornerRadiusLg),
                      border: Border.all(color: AppTheme.bgBorder),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        key: ValueKey('i$_step'),
                        current.instruction,
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyLg.copyWith(height: 1.65),
                      ),
                    ),
                  ),

                  // Crisis support card on last step
                  if (isLast) ...[
                    const SizedBox(height: 20),
                    _CrisisCard(),
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
                    child: isLast
                        ? FilledButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('I Feel Calmer'),
                          )
                        : FilledButton.icon(
                            onPressed: _next,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('Next'),
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

// ── Crisis contact card ────────────────────────────────────────────────────────

class _CrisisCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.crisisRedSurface,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
        border: Border.all(
            color: AppTheme.crisisRed.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            'Still feeling overwhelmed?',
            style: AppTheme.bodyMd.copyWith(
                color: AppTheme.crisisRed, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'It is okay to reach out for more support.',
            style: AppTheme.bodySm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/crisis'),
            icon: const Icon(Icons.support_agent_rounded, size: 18),
            label: const Text('Crisis Support'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.crisisRed,
              side: BorderSide(
                  color: AppTheme.crisisRed.withValues(alpha: 0.6)),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
