import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';

class AgeGateScreen extends StatefulWidget {
  const AgeGateScreen({super.key});

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  final int _currentYear = DateTime.now().year;
  late final int _minYear; // oldest (100 years ago)
  late final int _maxYear; // youngest (10 years ago)

  int _selectedYear = 0;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _minYear = _currentYear - 100;
    _maxYear = _currentYear - 10;
    _selectedYear = _currentYear - 18; // default: exactly 18
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int get _age => _currentYear - _selectedYear;
  bool get _isEligible => _age >= 18;

  void _increment() {
    // go younger (increase year, decrease age)
    if (_selectedYear < _maxYear) {
      HapticFeedback.selectionClick();
      setState(() => _selectedYear++);
    }
  }

  void _decrement() {
    // go older (decrease year, increase age)
    if (_selectedYear > _minYear) {
      HapticFeedback.selectionClick();
      setState(() => _selectedYear--);
    }
  }

  Future<void> _confirm() async {
    if (!_isEligible) return;
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ageConfirmed', true);
    await prefs.setInt('birthYear', _selectedYear);
    if (mounted) context.go('/feature_tour');
  }

  void _showUnderageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.child_care_rounded,
                color: AppTheme.primary, size: 22),
            const SizedBox(width: 8),
            Text('For Your Safety',
                style: AppTheme.headingSm.copyWith(color: AppTheme.primary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubuncare is designed for adults aged 18 and over to ensure the content is safe and appropriate.',
              style: AppTheme.bodyMd,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support for young people:',
                    style: AppTheme.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Childline: 0800 1111 (free, 24/7)\n'
                    '• Talk to a trusted adult or teacher\n'
                    '• School or college counselling services',
                    style: AppTheme.bodyMd,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.go('/welcome'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16),
                    label: const Text('Back'),
                  ),
                ),

                const SizedBox(height: 20),

                // Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primarySurface,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        blurRadius: 28,
                        spreadRadius: 4,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    size: 48,
                    color: AppTheme.primary,
                    semanticLabel: 'Age verification',
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'What year were you born?',
                  textAlign: TextAlign.center,
                  style: AppTheme.headingMd.copyWith(color: AppTheme.primary),
                ),

                const SizedBox(height: 8),

                Text(
                  'Ubuncare is for adults 18 and over.',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMd,
                ),

                const Spacer(),

                // ── Year picker ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 32),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.bgBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Tap to change year',
                        style: AppTheme.bodySm,
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Decrease (go older)
                          _ChevronButton(
                            icon: Icons.chevron_left_rounded,
                            tooltip: 'Earlier year (older)',
                            onTap: _decrement,
                            enabled: _selectedYear > _minYear,
                          ),

                          const SizedBox(width: 24),

                          // Year display
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, anim) =>
                                FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.15),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: child,
                              ),
                            ),
                            child: Text(
                              '$_selectedYear',
                              key: ValueKey(_selectedYear),
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w800,
                                color: _isEligible
                                    ? AppTheme.primary
                                    : AppTheme.crisisRed,
                                letterSpacing: -1,
                              ),
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Increase (go younger)
                          _ChevronButton(
                            icon: Icons.chevron_right_rounded,
                            tooltip: 'Later year (younger)',
                            onTap: _increment,
                            enabled: _selectedYear < _maxYear,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Age badge
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: _isEligible
                              ? AppTheme.primarySurface
                              : AppTheme.crisisRedSurface,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _isEligible
                                ? AppTheme.primary.withValues(alpha: 0.25)
                                : AppTheme.crisisRed.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isEligible
                                  ? Icons.check_circle_rounded
                                  : Icons.info_rounded,
                              size: 16,
                              color: _isEligible
                                  ? AppTheme.primary
                                  : AppTheme.crisisRed,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isEligible
                                  ? 'Age $_age · Eligible'
                                  : 'Age $_age · Must be 18+',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _isEligible
                                    ? AppTheme.primary
                                    : AppTheme.crisisRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Continue
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: const Text('Continue'),
                    onPressed: _isEligible ? _confirm : null,
                  ),
                ),

                const SizedBox(height: 12),

                if (!_isEligible)
                  TextButton(
                    onPressed: _showUnderageDialog,
                    child: const Text('Find support for under 18s'),
                  ),

                const SizedBox(height: 8),

                Text(
                  'Your birth year is not stored or shared.',
                  textAlign: TextAlign.center,
                  style: AppTheme.caption,
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChevronButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool enabled;

  const _ChevronButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip,
      button: true,
      enabled: enabled,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: enabled
                  ? AppTheme.primarySurface
                  : AppTheme.bgBorder.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: enabled
                    ? AppTheme.primary.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Icon(
              icon,
              color: enabled ? AppTheme.primary : AppTheme.textMuted,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
