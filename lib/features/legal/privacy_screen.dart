import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  Future<void> _openWebsite() async {
    final uri = Uri.parse('https://ubuncare.com/privacy');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Go back',
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: const Text('Privacy Policy'),
        actions: [
          Tooltip(
            message: 'View on website',
            child: IconButton(
              icon: const Icon(Icons.open_in_new_rounded),
              onPressed: _openWebsite,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
        children: [
          // Summary card — most important info first
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A6B52), Color(0xFF2E9B78)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Privacy at a Glance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...[
                  ('📱', 'All data stored on your device only'),
                  ('🔒', 'No accounts or cloud sync'),
                  ('🚫', 'We never sell your data'),
                  ('👁️', 'No third-party tracking or ads'),
                  ('🗑️', 'Delete your data any time in Settings'),
                ].map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(item.$1,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.$2,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Last updated: April 2026',
              style: AppTheme.bodySm,
            ),
          ),

          const SizedBox(height: 16),

          _Section(
            title: '1. Who We Are',
            body:
                'Ubuncare is a personal mental wellness app. We are committed to protecting your privacy and being transparent about how our app works.\n\n'
                'This Privacy Policy explains what information Ubuncare collects (or does not collect), how it is used, and your rights regarding your data.',
          ),

          _Section(
            title: '2. Data We Do NOT Collect',
            body:
                'Ubuncare is built on a "privacy by design" principle. We do NOT collect:\n\n'
                '• Your name, email address, or any personal identifiers\n'
                '• Your mood entries, journal reflections, or check-in data\n'
                '• Location data\n'
                '• Device identifiers or advertising IDs\n'
                '• Behavioural data or usage analytics\n\n'
                'There are no user accounts and no login required to use Ubuncare.',
          ),

          _Section(
            title: '3. Data Stored Locally on Your Device',
            body:
                'All data you enter into Ubuncare — including mood check-ins, reflections, selected guide preferences, and your name — is stored exclusively on your device using your device\'s local storage.\n\n'
                'This data never leaves your device and is not accessible to us or any third party.',
          ),

          _Section(
            title: '4. Data You Can Delete',
            body:
                'You are in full control of your data. You can:\n\n'
                '• Delete individual mood entries from the journal\n'
                '• Reset all app data from Settings → Danger Zone → Reset Everything\n'
                '• Uninstall the app to remove all stored data from your device\n\n'
                'There is no need to request data deletion from us — you hold the only copy.',
          ),

          _Section(
            title: '5. AI-Powered Features',
            body:
                'Ubuncare uses AI to generate supportive responses during mood check-ins. When you use these features:\n\n'
                '• Your check-in content may be sent to an AI processing service to generate a response\n'
                '• This data is processed in real-time and is not retained by the AI service\n'
                '• We do not link AI interactions to any persistent user profile\n\n'
                'We will always be transparent about when AI is being used within the app.',
          ),

          _Section(
            title: '6. Third-Party Services',
            body:
                'Ubuncare does not use:\n\n'
                '• Third-party analytics (e.g. Firebase, Mixpanel)\n'
                '• Advertising networks\n'
                '• Social media SDKs\n'
                '• Crash reporting services that collect personal data\n\n'
                'The app may contain links to external websites (e.g. crisis helplines). These are governed by their own privacy policies.',
          ),

          _Section(
            title: '7. Children\'s Privacy',
            body:
                'Ubuncare is intended for users aged 18 and over. We do not knowingly collect data from anyone under 18. If you are under 18, please do not use this app.',
          ),

          _Section(
            title: '8. Your Rights',
            body:
                'Depending on your location, you may have rights under applicable data protection law (such as GDPR or UK GDPR), including:\n\n'
                '• The right to access your data (your data is already on your device)\n'
                '• The right to erasure (delete via Settings or uninstall)\n'
                '• The right to data portability\n\n'
                'Since we do not collect your personal data, most requests can be fulfilled directly through the app.',
          ),

          _Section(
            title: '9. Changes to This Policy',
            body:
                'We may update this Privacy Policy periodically. We will notify you of significant changes through the app. Continued use after changes are posted means you accept the updated policy.',
          ),

          _Section(
            title: '10. Contact Us',
            body:
                'If you have questions or concerns about this Privacy Policy, please contact us:\n\n'
                'Email: privacy@ubuncare.com\n'
                'Website: ubuncare.com/privacy',
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('View full policy on website'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: BorderSide(
                  color: AppTheme.primary.withValues(alpha: 0.4)),
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            ),
            onPressed: _openWebsite,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section widget
// ─────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2420),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.65,
              color: Color(0xFF4A5E57),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: AppTheme.bgBorder, height: 1),
        ],
      ),
    );
  }
}
