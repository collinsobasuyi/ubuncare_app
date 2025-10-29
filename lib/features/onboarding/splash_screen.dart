import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _breathing;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    );

    _breathing = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) context.go('/welcome');
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ------------------ UI ------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6FFFA),
      body: SafeArea(
        child: Semantics(
          label:
              'Ubuncare loading screen. Your mental wellbeing companion. Please wait while the app loads.',
          readOnly: true,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final scaleValue =
                  (0.8 + 0.2 * _scale.value) * (1.0 + 0.05 * _breathing.value);
              return Stack(
                children: [
                  _background(),
                  Center(
                    child: Transform.scale(
                      scale: scaleValue,
                      child: Opacity(
                        opacity: _fade.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _logo(),
                            const SizedBox(height: 36),
                            _appName(),
                            const SizedBox(height: 20),
                            _tagline(),
                            const SizedBox(height: 48),
                            _progress(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _footer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ------------------ Widgets ------------------

  Widget _background() {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D896C),
              Color(0xFF11A985),
              Color(0xFF4FE2B5),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D896C).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D896C),
            Color(0xFF11A985),
            Color(0xFF4FE2B5),
          ],
        ),
      ),
      child: const Icon(
        Icons.psychology_alt_rounded,
        color: Colors.white,
        size: 56,
        semanticLabel: 'Ubuncare logo icon',
      ),
    );
  }

  Widget _appName() {
    return const Text(
      'Ubuncare',
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 1.2,
        shadows: [
          Shadow(
            offset: Offset(1.5, 2),
            blurRadius: 8,
            color: Colors.black26,
          ),
        ],
      ),
    );
  }

  Widget _tagline() {
    return AnimatedOpacity(
      opacity: _controller.value > 0.5 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: const Text(
        'A gentle space for reflection',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 4,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _progress() {
    return SizedBox(
      width: 44,
      height: 44,
      child: CircularProgressIndicator(
        value: _controller.value,
        strokeWidth: 3,
        backgroundColor: Colors.white24,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        semanticsLabel: 'Loading progress indicator',
      ),
    );
  }

  Widget _footer() {
    return Positioned(
      bottom: 36,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _controller.value > 0.7 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 600),
        child: const Column(
          children: [
            Text(
              'Your mental wellbeing companion',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 4,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Safe • Private • Compassionate',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w400,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
