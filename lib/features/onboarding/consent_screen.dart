import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app/consent_state.dart';
import '../../app/theme.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _checked  = false;
  bool _loading  = false;


  Future<void> _handleConsent() async {
    setState(() => _loading = true);
    final consent = context.read<ConsentState>();
    await consent.acceptConsent();
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) context.go('/avatar');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.go('/your_name'),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  label: const Text('Back'),
                ),
              ),

              const SizedBox(height: 24),

              // Icon
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primarySurface,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.18),
                      blurRadius: 28,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppTheme.primary,
                  size: 48,
                  semanticLabel: 'Privacy and consent',
                ),
              ),

              const SizedBox(height: 28),

              Consumer<ConsentState>(
                builder: (_, state, __) {
                  final name = state.userName;
                  final greeting = (name != null && name.isNotEmpty)
                      ? 'One last thing, ${name.split(' ').first}'
                      : 'Before we begin';
                  return Column(
                    children: [
                      Text(greeting,
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyLg.copyWith(
                              color: AppTheme.textMuted,
                              fontStyle: FontStyle.italic)),
                      const SizedBox(height: 6),
                      Text(
                        'Your Privacy & Consent',
                        textAlign: TextAlign.center,
                        style: AppTheme.headingLg.copyWith(color: AppTheme.primary),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 22),

              // Info cards
              _InfoRow(
                icon: Icons.medical_information_outlined,
                text: 'Ubuncare is designed for self-reflection and emotional awareness. It does not replace professional mental-health care.',
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.warning_amber_rounded,
                text: 'If you feel unsafe or in crisis, contact emergency services immediately.',
                isWarning: true,
              ),

              const SizedBox(height: 22),

              Text(
                'Your reflections are stored securely on your device and only used to personalise your experience. Ubuncare never shares or sells your personal data.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMd,
              ),

              const SizedBox(height: 20),

              // Policy links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PolicyButton(
                    label: 'Terms of Use',
                    onTap: () => context.push('/terms'),
                  ),
                  const SizedBox(width: 12),
                  _PolicyButton(
                    label: 'Privacy Policy',
                    onTap: () => context.push('/privacy'),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Checkbox
              GestureDetector(
                onTap: () => setState(() => _checked = !_checked),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _checked ? AppTheme.primarySurface : AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _checked
                          ? AppTheme.primary.withValues(alpha: 0.4)
                          : AppTheme.bgBorder,
                      width: _checked ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _checked,
                        onChanged: (v) => setState(() => _checked = v ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'I agree to the Terms of Use and Privacy Policy.',
                            style: AppTheme.bodyMd.copyWith(color: AppTheme.textDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Agree button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Semantics(
                  enabled: _checked,
                  child: AnimatedOpacity(
                  opacity: _checked ? 1.0 : 0.45,
                  duration: const Duration(milliseconds: 200),
                  child: FilledButton.icon(
                    icon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 20),
                    label: const Text('I Agree & Continue'),
                    onPressed: _checked && !_loading ? _handleConsent : null,
                  ),
                ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isWarning;

  const _InfoRow({required this.icon, required this.text, this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? AppTheme.accent : AppTheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isWarning ? AppTheme.accentSurface : AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTheme.bodyMd)),
        ],
      ),
    );
  }
}

class _PolicyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PolicyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          // minimum 44px height for touch target
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primarySurface,
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
          ),
          child: Text(
            label,
            style: AppTheme.labelPrimary.copyWith(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
