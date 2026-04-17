import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Slide data
// ─────────────────────────────────────────────────────────────────────────────

class _Slide {
  final IconData icon;
  final String label;      // eyebrow
  final String title;
  final String body;
  final List<_Bullet> bullets;
  final Color accent;
  final Color accentLight;
  final List<Color> gradient;

  const _Slide({
    required this.icon,
    required this.label,
    required this.title,
    required this.body,
    required this.bullets,
    required this.accent,
    required this.accentLight,
    required this.gradient,
  });
}

class _Bullet {
  final IconData icon;
  final String text;
  const _Bullet(this.icon, this.text);
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class FeatureTourScreen extends StatefulWidget {
  const FeatureTourScreen({super.key});

  @override
  State<FeatureTourScreen> createState() => _FeatureTourScreenState();
}

class _FeatureTourScreenState extends State<FeatureTourScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  static const _slides = [
    _Slide(
      icon: Icons.psychology_alt_rounded,
      label: 'DAILY RITUAL',
      title: 'Check in with\nyourself every day',
      body: 'A gentle, guided conversation with your AI companion helps you name what you\'re feeling and why.',
      accent: Color(0xFF1A6B52),
      accentLight: Color(0xFFE8F5F0),
      gradient: [Color(0xFF1A6B52), Color(0xFF2E9B78)],
      bullets: [
        _Bullet(Icons.chat_bubble_outline_rounded, 'Conversational, not clinical'),
        _Bullet(Icons.trending_up_rounded, 'Track mood patterns over time'),
        _Bullet(Icons.auto_awesome_rounded, 'Personalised to your chosen guide'),
      ],
    ),
    _Slide(
      icon: Icons.spa_rounded,
      label: 'WELLNESS TOOLKIT',
      title: 'Tools for real\nmoments of stress',
      body: 'Science-backed exercises available any time — no internet needed, no subscription, no barriers.',
      accent: Color(0xFF7B5EA7),
      accentLight: Color(0xFFF3EEF9),
      gradient: [Color(0xFF7B5EA7), Color(0xFF9B7EC8)],
      bullets: [
        _Bullet(Icons.air_rounded, 'Guided breathing exercises'),
        _Bullet(Icons.self_improvement_rounded, 'Body scan & grounding techniques'),
        _Bullet(Icons.favorite_border_rounded, 'Gratitude journaling & intentions'),
      ],
    ),
    _Slide(
      icon: Icons.lock_rounded,
      label: 'PRIVACY FIRST',
      title: 'Your data stays\non your device',
      body: 'Ubuncare has no accounts, no cloud sync, and will never share or sell your personal information.',
      accent: Color(0xFFC0392B),
      accentLight: Color(0xFFFDF0EF),
      gradient: [Color(0xFFC0392B), Color(0xFFE74C3C)],
      bullets: [
        _Bullet(Icons.phone_android_rounded, 'Stored locally on your phone only'),
        _Bullet(Icons.no_accounts_rounded, 'No account or login required'),
        _Bullet(Icons.block_rounded, 'No ads, no tracking, no data sharing'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int p) {
    HapticFeedback.selectionClick();
    setState(() => _page = p);
    _entryCtrl.forward(from: 0);
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      HapticFeedback.lightImpact();
      context.go('/your_name');
    }
  }

  void _skip() {
    HapticFeedback.selectionClick();
    context.go('/your_name');
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];
    final isLast = _page == _slides.length - 1;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              slide.accentLight,
              AppTheme.bgPage,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    Semantics(
                      label: 'Go back',
                      button: true,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: slide.accent),
                        tooltip: 'Go back',
                        onPressed: () => context.go('/age'),
                      ),
                    ),

                    // Step counter
                    Semantics(
                      label: 'Step ${_page + 1} of ${_slides.length}',
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          '${_page + 1} of ${_slides.length}',
                          key: ValueKey(_page),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: slide.accent.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),

                    if (!isLast)
                      TextButton(
                        onPressed: _skip,
                        style: TextButton.styleFrom(
                          foregroundColor: slide.accent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          minimumSize: const Size(60, 44),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      )
                    else
                      const SizedBox(width: 60),
                  ],
                ),
              ),

              // ── Page view ─────────────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (_, i) => _SlidePage(
                    slide: _slides[i],
                    entryFade: _entryFade,
                    entrySlide: _entrySlide,
                    isActive: i == _page,
                    screenSize: size,
                  ),
                ),
              ),

              // ── Dots ──────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    final active = i == _page;
                    return Semantics(
                      label: 'Go to slide ${i + 1}',
                      button: true,
                      selected: active,
                      child: GestureDetector(
                        onTap: () => _pageCtrl.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        ),
                        // 44×44 minimum touch target wrapping the visual dot
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: active ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: active
                                    ? slide.accent
                                    : slide.accent.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // ── CTA ───────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: slide.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: _next,
                    icon: Icon(
                      isLast
                          ? Icons.arrow_forward_rounded
                          : Icons.chevron_right_rounded,
                      size: 22,
                    ),
                    label: Text(isLast ? 'Get Started' : 'Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide page
// ─────────────────────────────────────────────────────────────────────────────

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  final Animation<double> entryFade;
  final Animation<Offset> entrySlide;
  final bool isActive;
  final Size screenSize;

  const _SlidePage({
    required this.slide,
    required this.entryFade,
    required this.entrySlide,
    required this.isActive,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: isActive ? entryFade : const AlwaysStoppedAnimation(1),
        child: SlideTransition(
          position: isActive ? entrySlide : const AlwaysStoppedAnimation(Offset.zero),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Hero icon card ─────────────────────────────────────────
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring
                    Container(
                      width: 148,
                      height: 148,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: slide.accent.withValues(alpha: 0.08),
                        border: Border.all(
                          color: slide.accent.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Inner gradient circle
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: slide.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: slide.accent.withValues(alpha: 0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        slide.icon,
                        color: Colors.white,
                        size: 52,
                        semanticLabel: slide.title,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Eyebrow label ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: slide.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  slide.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: slide.accent,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Title ──────────────────────────────────────────────────
              Text(
                slide.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C2B2A),
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 14),

              // ── Body ───────────────────────────────────────────────────
              Text(
                slide.body,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: const Color(0xFF1C2B2A).withValues(alpha: 0.65),
                ),
              ),

              const SizedBox(height: 28),

              // ── Bullet cards ───────────────────────────────────────────
              ...slide.bullets.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: slide.accent.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: slide.accent.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: slide.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(b.icon,
                            color: slide.accent, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          b.text,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1C2B2A),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
