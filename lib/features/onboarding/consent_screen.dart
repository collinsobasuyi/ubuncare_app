import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/consent_state.dart';
import 'package:url_launcher/url_launcher.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _isChecked = false;
  bool _isLoading = false;

  void _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleConsent(BuildContext context) async {
    setState(() => _isLoading = true);
    final consent = context.read<ConsentState>();
    await consent.acceptConsent(); // save silently
    await Future.delayed(const Duration(milliseconds: 150));

    if (context.mounted) {
      context.go('/avatar'); // navigate forward
      consent.syncAfterStartup(); // router sync AFTER navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF0D896C);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.go('/welcome'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: primaryTeal, size: 18),
                    label: const Text(
                      'Back',
                      style: TextStyle(
                          color: primaryTeal,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0D896C),
                        Color(0xFF11A985),
                        Color(0xFF4FE2B5),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryTeal.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.psychology_alt_rounded,
                      color: Colors.white, size: 44),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Before You Begin',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Ubuncare is a wellbeing companion designed to support self-reflection and emotional awareness.\n\n'
                  'It does not replace therapy, counselling, or professional mental-health care. '
                  'If you feel unsafe or in crisis, contact emergency services immediately.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),

                const SizedBox(height: 24),

                const Text(
                  'By continuing, you agree to our Terms of Use and Privacy Policy. '
                  'Your reflections are stored securely on your device and only used to personalize your experience. '
                  'Ubuncare never shares or sells your personal data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => _openLink('https://ubuncare.com/terms'),
                      child: const Text(
                        'View Terms',
                        style: TextStyle(
                          color: primaryTeal,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () =>
                          _openLink('https://ubuncare.com/privacy'),
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: primaryTeal,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      activeColor: primaryTeal,
                      onChanged: (v) => setState(() => _isChecked = v ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'I confirm that I am over 18 and I agree to the above terms.',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _isChecked
                          ? primaryTeal
                          : primaryTeal.withOpacity(0.4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    onPressed:
                        _isChecked && !_isLoading ? () => _handleConsent(context) : null,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.4),
                          )
                        : const Text('I Agree & Continue'),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
