import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app/consent_state.dart';
import '../../app/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ── Guide data (mirrors avatar_screen) ─────────────────────────────────────
  static const _guideAccents = {
    'Amani': Color(0xFF2E9B78),
    'Kora':  Color(0xFFE9963A),
    'Nova':  Color(0xFF5C6BC0),
    'Zuri':  Color(0xFF8E44AD),
  };

  static const _guideIcons = {
    'Amani': Icons.eco_rounded,
    'Kora':  Icons.local_fire_department_rounded,
    'Nova':  Icons.nights_stay_rounded,
    'Zuri':  Icons.auto_awesome_rounded,
  };

  static const _guideTaglines = {
    'Amani': 'Calm & grounded',
    'Kora':  'Warm & encouraging',
    'Nova':  'Reflective & insightful',
    'Zuri':  'Gentle & uplifting',
  };

  Future<void> _confirmReset(BuildContext context) async {
    final consent = context.read<ConsentState>();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ResetDialog(),
    );

    if (confirmed == true && context.mounted) {
      await consent.resetApp();
      if (context.mounted) context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final consent = context.watch<ConsentState>();
    final name    = consent.userName;
    final avatar  = consent.selectedAvatar;
    final accent  = _guideAccents[avatar] ?? AppTheme.primary;
    final icon    = _guideIcons[avatar]   ?? Icons.spa_rounded;
    final tagline = _guideTaglines[avatar] ?? 'Your wellness guide';

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button row
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Go back',
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white, size: 20),
                            onPressed: () => context.pop(),
                          ),
                          const Expanded(
                            child: Text(
                              'Settings',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Profile card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            // Guide avatar
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: Colors.white, size: 30),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (name != null && name.isNotEmpty)
                                        ? name
                                        : 'Hello there',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (avatar != null) ...[
                                    Text(
                                      'Guide: $avatar',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                            alpha: 0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      tagline,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                            alpha: 0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Personalisation ───────────────────────────────────────────
                _SectionHeader(title: 'Personalisation', icon: Icons.person_rounded),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.badge_rounded,
                  accent: AppTheme.primary,
                  title: 'Your Name',
                  subtitle: (name != null && name.isNotEmpty) ? name : 'Not set',
                  onTap: () => context.push('/your_name?from=settings'),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: icon,
                  accent: accent,
                  title: 'Your Guide',
                  subtitle: avatar != null ? '$avatar — $tagline' : 'Not selected',
                  onTap: () => context.push('/avatar?from=settings'),
                ),

                const SizedBox(height: 28),

                // ── Privacy & Data ────────────────────────────────────────────
                _SectionHeader(title: 'Privacy & Data', icon: Icons.lock_rounded),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.smartphone_rounded,
                  text: 'All your reflections and data are stored only on this device. Ubuncare never uploads or shares your personal information.',
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  accent: AppTheme.primary,
                  title: 'Terms of Use',
                  subtitle: 'Read our terms',
                  onTap: () => context.push('/terms'),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  accent: AppTheme.primary,
                  title: 'Privacy Policy',
                  subtitle: 'How we protect you',
                  onTap: () => context.push('/privacy'),
                ),

                const SizedBox(height: 28),

                // ── About ─────────────────────────────────────────────────────
                _SectionHeader(title: 'About', icon: Icons.info_outline_rounded),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.bgBorder),
                  ),
                  child: Column(
                    children: [
                      _AboutRow(
                          label: 'App Name', value: 'Ubuncare'),
                      const Divider(height: 24),
                      _AboutRow(
                          label: 'Version', value: '1.0.0'),
                      const Divider(height: 24),
                      _AboutRow(
                          label: 'Platform', value: 'iOS · Android'),
                      const Divider(height: 24),
                      _AboutRow(
                          label: 'Purpose',
                          value: 'Mental wellness & self-reflection'),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Danger Zone ───────────────────────────────────────────────
                _SectionHeader(
                    title: 'Danger Zone',
                    icon: Icons.warning_amber_rounded,
                    isWarning: true),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.crisisRedSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.crisisRed.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reset All Data',
                        style: AppTheme.headingSm.copyWith(
                            color: AppTheme.crisisRed),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'This permanently deletes all your reflections, mood history, preferences, and account data. This action cannot be undone.',
                        style: AppTheme.bodyMd,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.delete_forever_rounded,
                              size: 18),
                          label: const Text('Reset Everything'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.crisisRed,
                            side: BorderSide(
                                color: AppTheme.crisisRed.withValues(
                                    alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => _confirmReset(context),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Footer
                Center(
                  child: Text(
                    'Made with care · Private by design',
                    style: AppTheme.bodySm,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reset dialog
// ─────────────────────────────────────────────────────────────────────────────

class _ResetDialog extends StatelessWidget {
  const _ResetDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Space for X button
                const SizedBox(height: 4),

                // Warning icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.crisisRedSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: AppTheme.crisisRed,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'This Can\'t Be Undone',
                  textAlign: TextAlign.center,
                  style: AppTheme.headingSm.copyWith(color: AppTheme.crisisRed),
                ),

                const SizedBox(height: 12),

                Text(
                  'You\'re about to permanently delete:',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMd,
                ),

                const SizedBox(height: 16),

                // List of what gets deleted
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.crisisRedSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _DeleteItem('All mood check-ins & history'),
                      _DeleteItem('Your reflections & notes'),
                      _DeleteItem('Your name & guide preferences'),
                      _DeleteItem('Consent & onboarding state'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Actions — stacked vertically
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.delete_forever_rounded, size: 18),
                    label: const Text('Yes, Delete Everything'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.crisisRed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.bgBorder),
                    ),
                    child: const Text('Keep My Data'),
                  ),
                ),
              ],
            ),

            // Close / X button
            Positioned(
              top: -8,
              right: -8,
              child: Semantics(
                label: 'Close dialog',
                button: true,
                child: InkWell(
                  onTap: () => Navigator.pop(context, false),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.bgBorder,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppTheme.textMuted),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteItem extends StatelessWidget {
  final String text;
  const _DeleteItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.remove_circle_outline_rounded,
              size: 14, color: AppTheme.crisisRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: AppTheme.bodySm.copyWith(color: AppTheme.crisisRed)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isWarning;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? AppTheme.crisisRed : AppTheme.primary;
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.bgSurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTheme.bodyMd.copyWith(
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w600)),
                    Text(subtitle, style: AppTheme.bodySm),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTheme.bodySm)),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodySm),
        Text(value,
            style: AppTheme.bodyMd.copyWith(
                color: AppTheme.textDark, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
