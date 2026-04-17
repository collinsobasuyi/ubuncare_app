import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _ringPulse;

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Logo fades + scales in 0–40% of timeline
    _logoFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // App name slides up 30–70%
    _textFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    // Tagline fades in last 50–100%
    _taglineFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    // Pulsing outer ring
    _ringPulse = Tween<double>(begin: 0.85, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _mainCtrl.forward();

    // Navigate after animation completes + short pause
    _mainCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) context.go('/welcome');
        });
      }
    });
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary,
              AppTheme.primaryMid,
              Color(0xFF3DAA88),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([_mainCtrl, _pulseCtrl]),
            builder: (context, _) {
              return Stack(
                children: [
                  // Background decorative circles (excluded from semantics)
                  ExcludeSemantics(
                    child: Positioned(
                      top: -60,
                      right: -60,
                      child: Opacity(
                        opacity: 0.06,
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ExcludeSemantics(
                    child: Positioned(
                      bottom: -80,
                      left: -40,
                      child: Opacity(
                        opacity: 0.05,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Logo ──────────────────────────────────────────────
                        FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulsing outer ring
                                Transform.scale(
                                  scale: _ringPulse.value,
                                  child: Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.2),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                // Inner icon circle
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        Colors.white.withValues(alpha: 0.15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.12),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.spa_rounded,
                                    color: Colors.white,
                                    size: 50,
                                    semanticLabel: 'Ubuncare',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── App name ──────────────────────────────────────────
                        FadeTransition(
                          opacity: _textFade,
                          child: SlideTransition(
                            position: _textSlide,
                            child: Column(
                              children: [
                                const Text(
                                  'Ubuncare',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 40,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Tagline ───────────────────────────────────────────
                        FadeTransition(
                          opacity: _taglineFade,
                          child: Text(
                            'Your space for calm and clarity',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Bottom loading indicator ──────────────────────────────
                  Positioned(
                    bottom: 48,
                    left: 0,
                    right: 0,
                    child: FadeTransition(
                      opacity: _taglineFade,
                      child: Column(
                        children: [
                          Semantics(
                            label: 'Loading, please wait',
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Preparing your wellness space…',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
