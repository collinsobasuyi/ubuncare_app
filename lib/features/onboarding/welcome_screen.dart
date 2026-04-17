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
  late final AnimationController _floatCtrl;
  late final AnimationController _rotateCtrl;

  late final Animation<double> _heroFade;
  late final Animation<double> _heroScale;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentFade;
  late final Animation<double> _ctaFade;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _heroFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _heroScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));
    _contentFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );
    _ctaFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A6B52),
              Color(0xFF2E9B78),
              Color(0xFF3DAA88),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Decorative background rings ─────────────────────────────
              AnimatedBuilder(
                animation: _rotateCtrl,
                builder: (_, __) => Positioned(
                  top: -size.width * 0.35,
                  right: -size.width * 0.25,
                  child: ExcludeSemantics(
                    child: Transform.rotate(
                    angle: _rotateCtrl.value * 2 * math.pi,
                    child: Container(
                      width: size.width * 0.85,
                      height: size.width * 0.85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.07),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  ),
                ),
              ),
              Positioned(
                bottom: -size.width * 0.2,
                left: -size.width * 0.3,
                child: ExcludeSemantics(
                  child: Container(
                  width: size.width * 0.75,
                  height: size.width * 0.75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                ),
                ),
              ),

              // ── Floating particles ──────────────────────────────────────
              AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, __) {
                  final float = _floatCtrl.value;
                  return Stack(children: [
                    _Particle(x: 0.15, y: 0.18, size: 8, opacity: 0.2,
                        offset: float * 12),
                    _Particle(x: 0.82, y: 0.12, size: 12, opacity: 0.15,
                        offset: -float * 10),
                    _Particle(x: 0.72, y: 0.55, size: 6, opacity: 0.18,
                        offset: float * 8),
                    _Particle(x: 0.08, y: 0.65, size: 10, opacity: 0.12,
                        offset: -float * 14),
                    _Particle(x: 0.55, y: 0.88, size: 7, opacity: 0.16,
                        offset: float * 6),
                  ]);
                },
              ),

              // ── Main content ────────────────────────────────────────────
              Column(
                children: [
                  // Hero area — top 45%
                  Expanded(
                    flex: 45,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_floatCtrl]),
                        builder: (_, __) {
                          return FadeTransition(
                            opacity: _heroFade,
                            child: ScaleTransition(
                              scale: _heroScale,
                              child: Transform.translate(
                                offset: Offset(
                                    0, -8 + _floatCtrl.value * 14),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Logo
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white
                                            .withValues(alpha: 0.15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.18),
                                            blurRadius: 32,
                                            offset: const Offset(0, 12),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.spa_rounded,
                                        size: 52,
                                        color: Colors.white,
                                        semanticLabel: 'Ubuncare',
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    const Text(
                                      'Ubuncare',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 44,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                        height: 1.1,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Your space for calm & clarity',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Content area — bottom 55%
                  Expanded(
                    flex: 55,
                    child: FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: const BorderRadius.only(
                              topLeft:  Radius.circular(36),
                              topRight: Radius.circular(36),
                            ),
                            border: Border(
                              top: BorderSide(
                                color:
                                    Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Everything you need\nfor your wellbeing',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                _FeatureRow(
                                  icon: Icons.psychology_alt_rounded,
                                  title: 'Daily Mood Check-in',
                                  body:
                                      'A guided, compassionate conversation to understand how you feel.',
                                ),
                                const SizedBox(height: 12),
                                _FeatureRow(
                                  icon: Icons.spa_rounded,
                                  title: 'Wellness Toolkit',
                                  body:
                                      'Breathing, grounding, body scan — tools for real moments of stress.',
                                ),
                                const SizedBox(height: 12),
                                _FeatureRow(
                                  icon: Icons.lock_rounded,
                                  title: 'Private by Design',
                                  body:
                                      'Everything stays on your device. No accounts, no data sharing.',
                                ),

                                const SizedBox(height: 28),

                                // CTA
                                FadeTransition(
                                  opacity: _ctaFade,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor:
                                                AppTheme.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      16),
                                            ),
                                          ),
                                          onPressed: () =>
                                              context.go('/age'),
                                          child: const Text(
                                            'Get Started',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Trust pills
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _TrustPill('Free'),
                                          const SizedBox(width: 8),
                                          _TrustPill('No account needed'),
                                          const SizedBox(width: 8),
                                          _TrustPill('Private'),
                                        ],
                                      ),

                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating particle
// ─────────────────────────────────────────────────────────────────────────────

class _Particle extends StatelessWidget {
  final double x, y, size, opacity, offset;
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return Positioned(
      left: x * sw,
      top: y * sh + offset,
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature row
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trust pill
// ─────────────────────────────────────────────────────────────────────────────

class _TrustPill extends StatelessWidget {
  final String label;
  const _TrustPill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
