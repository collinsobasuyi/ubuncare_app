import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {

  late final AnimationController _entryCtrl;
  late final AnimationController _orbitCtrl;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentFade;
  late final Animation<double> _ctaScale;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _logoFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
    ));
    _contentFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );
    _ctaScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _orbitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Stack(
        children: [
          // ── Slow-orbit decorative arcs ─────────────────────────────────────
          ExcludeSemantics(
            child: AnimatedBuilder(
              animation: _orbitCtrl,
              builder: (_, __) {
                final angle = _orbitCtrl.value * 2 * math.pi;
                return Stack(children: [
                  Positioned(
                    top: -size.width * 0.3,
                    right: -size.width * 0.2,
                    child: Transform.rotate(
                      angle: angle,
                      child: Container(
                        width: size.width * 0.8,
                        height: size.width * 0.8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -size.width * 0.25,
                    left: -size.width * 0.25,
                    child: Transform.rotate(
                      angle: -angle * 0.7,
                      child: Container(
                        width: size.width * 0.7,
                        height: size.width * 0.7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.04),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]);
              },
            ),
          ),

          // ── Layout ─────────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Hero — top ~42%
                Expanded(
                  flex: 42,
                  child: Center(
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 40,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.spa_rounded,
                                size: 46,
                                color: Colors.white,
                                semanticLabel: 'Ubuncare',
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Ubuncare',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your space for calm & clarity',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Content — bottom ~58%
                Expanded(
                  flex: 58,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.bgPage,
                          borderRadius: const BorderRadius.only(
                            topLeft:  Radius.circular(36),
                            topRight: Radius.circular(36),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Drag handle
                            const SizedBox(height: 12),
                            Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppTheme.bgBorder,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 24),

                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Built for your wellbeing',
                                      style: AppTheme.headingMd,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'A calm, private space to check in with yourself — no accounts, no data sharing.',
                                      style: AppTheme.bodyMd,
                                    ),

                                    const SizedBox(height: 28),

                                    _FeatureItem(
                                      icon: Icons.psychology_alt_rounded,
                                      color: AppTheme.primary,
                                      bg: AppTheme.primarySurface,
                                      title: 'Daily Mood Check-in',
                                      body: 'A guided conversation to understand how you feel right now.',
                                    ),
                                    const SizedBox(height: 14),
                                    _FeatureItem(
                                      icon: Icons.air_rounded,
                                      color: const Color(0xFF3A6B82),
                                      bg: const Color(0xFFEDF5F9),
                                      title: 'Wellness Toolkit',
                                      body: 'Breathing, grounding, body scan — tools for real moments of stress.',
                                    ),
                                    const SizedBox(height: 14),
                                    _FeatureItem(
                                      icon: Icons.lock_rounded,
                                      color: const Color(0xFF6B4E82),
                                      bg: const Color(0xFFF4EFF9),
                                      title: 'Private by Design',
                                      body: 'Everything stays on your device. Nothing is stored externally.',
                                    ),

                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),

                            // CTA pinned at bottom
                            ScaleTransition(
                              scale: _ctaScale,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: FilledButton(
                                        onPressed: () => context.go('/age'),
                                        child: const Text(
                                          'Get Started',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 8,
                                      children: const [
                                        _TrustBadge('✓  Free'),
                                        _TrustBadge('✓  No account'),
                                        _TrustBadge('✓  Private'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String title, body;

  const _FeatureItem({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(title, style: AppTheme.headingXs),
              const SizedBox(height: 3),
              Text(body, style: AppTheme.bodyMd),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _TrustBadge extends StatelessWidget {
  final String label;
  const _TrustBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTheme.bodySm.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
