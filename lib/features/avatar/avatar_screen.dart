import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app/consent_state.dart';
import '../../app/theme.dart';

class _AvatarOption {
  final String name;
  final String tagline;
  final String desc;
  final IconData icon;
  final Color accent;

  const _AvatarOption({
    required this.name,
    required this.tagline,
    required this.desc,
    required this.icon,
    required this.accent,
  });
}

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen>
    with SingleTickerProviderStateMixin {
  String? _selected;

  late final AnimationController _animCtrl;
  late final Animation<double> _fade;

  static const _avatars = [
    _AvatarOption(
      name: 'Amani',
      tagline: 'Calm & grounded',
      desc: 'Steady, peaceful energy that helps you feel settled and safe.',
      icon: Icons.eco_rounded,
      accent: Color(0xFF2E9B78),
    ),
    _AvatarOption(
      name: 'Kora',
      tagline: 'Warm & encouraging',
      desc: 'Brings warmth and gentle encouragement when you need it most.',
      icon: Icons.local_fire_department_rounded,
      accent: Color(0xFFE9963A),
    ),
    _AvatarOption(
      name: 'Nova',
      tagline: 'Reflective & insightful',
      desc: 'Thoughtful and perceptive, helps you find clarity within.',
      icon: Icons.nights_stay_rounded,
      accent: Color(0xFF5C6BC0),
    ),
    _AvatarOption(
      name: 'Zuri',
      tagline: 'Gentle & uplifting',
      desc: 'Light-hearted and kind, lifts your spirit one small step at a time.',
      icon: Icons.auto_awesome_rounded,
      accent: Color(0xFF8E44AD),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

    final saved = context.read<ConsentState>().selectedAvatar;
    if (saved != null) _selected = saved;
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  bool get _fromSettings =>
      GoRouterState.of(context).uri.queryParameters['from'] == 'settings';

  Future<void> _continue() async {
    if (_selected == null) return;
    HapticFeedback.lightImpact();
    await context.read<ConsentState>().selectAvatar(_selected!);
    if (!mounted) return;
    context.go(_fromSettings ? '/settings' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.read<ConsentState>().userName;
    final heading = (userName != null && userName.isNotEmpty)
        ? 'Choose Your Guide, ${userName.split(' ').first}'
        : 'Choose Your Guide';

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.go(
                        _fromSettings ? '/settings' : '/consent'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                    label: const Text('Back'),
                  ),
                ),

                const SizedBox(height: 20),

                // Header icon
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
                    Icons.people_rounded,
                    color: AppTheme.primary,
                    size: 44,
                    semanticLabel: 'Choose your wellness guide',
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  heading,
                  textAlign: TextAlign.center,
                  style: AppTheme.headingMd.copyWith(color: AppTheme.primary),
                ),

                const SizedBox(height: 8),

                Text(
                  'Your guide sets the tone for your conversations.\nYou can change this anytime in Settings.',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMd,
                ),

                const SizedBox(height: 28),

                // Avatar cards — 2-column grid
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.88,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _avatars.map((a) {
                    final isSelected = _selected == a.name;
                    return Semantics(
                      button: true,
                      selected: isSelected,
                      label: '${a.name} — ${a.tagline}',
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = a.name);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppTheme.cornerRadiusLg),
                            color: isSelected
                                ? a.accent.withValues(alpha: 0.08)
                                : AppTheme.bgSurface,
                            border: Border.all(
                              color: isSelected ? a.accent : AppTheme.bgBorder,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? a.accent.withValues(alpha: 0.18)
                                    : Colors.black.withValues(alpha: 0.04),
                                blurRadius: isSelected ? 16 : 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon circle
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: a.accent.withValues(alpha: 0.12),
                                    ),
                                    child: Icon(a.icon,
                                        color: a.accent, size: 30),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.bgSurface,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check_circle_rounded,
                                          color: a.accent,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Text(
                                a.name,
                                style: AppTheme.headingSm.copyWith(
                                  color: isSelected ? a.accent : AppTheme.textDark,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                a.tagline,
                                textAlign: TextAlign.center,
                                style: AppTheme.bodySm.copyWith(
                                  color: isSelected
                                      ? a.accent.withValues(alpha: 0.8)
                                      : AppTheme.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                a.desc,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.bodySm.copyWith(
                                    color: AppTheme.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // Continue
                AnimatedOpacity(
                  opacity: _selected != null ? 1.0 : 0.45,
                  duration: const Duration(milliseconds: 200),
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text('Start with this Guide'),
                    onPressed: _selected != null ? _continue : null,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
