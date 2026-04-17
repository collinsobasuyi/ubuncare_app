import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../app/theme.dart';

class CrisisSupportScreen extends StatelessWidget {
  const CrisisSupportScreen({super.key});

  Future<void> _call(String number) async {
    final uri = 'tel:$number';
    if (await canLaunchUrlString(uri)) await launchUrlString(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: const Text('Crisis Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Urgent banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.crisisRedSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.crisisRed.withValues(alpha:0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_rounded,
                      color: AppTheme.crisisRed, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'If you are in immediate danger or need urgent medical help, call 999 now.',
                      style: AppTheme.bodyMd.copyWith(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text('24/7 Crisis Helplines', style: AppTheme.headingSm),

            const SizedBox(height: 14),

            _SupportTile(
              title: 'Samaritans',
              subtitle: '24/7 free emotional support for anyone in distress',
              number: '116 123',
              leadingIcon: Icons.phone_in_talk_rounded,
              color: AppTheme.primary,
              onTap: () => _call('116123'),
            ),
            _SupportTile(
              title: 'NHS 111 (Mental Health)',
              subtitle: 'Non-emergency mental health advice and support',
              number: '111',
              leadingIcon: Icons.local_hospital_outlined,
              color: AppTheme.primaryMid,
              onTap: () => _call('111'),
            ),
            _SupportTile(
              title: 'Shout',
              subtitle: "Text 'SHOUT' to 85258 — 24/7 confidential text support",
              leadingIcon: Icons.sms_outlined,  // text-based, not phone
              color: Colors.indigo,
              onTap: () => launchUrlString('sms:85258?body=SHOUT'),
            ),
            _SupportTile(
              title: 'Mind',
              subtitle: 'Mental health information and helplines (non-crisis)',
              leadingIcon: Icons.language_rounded,  // website-based
              color: AppTheme.accent,
              onTap: () => launchUrlString('https://www.mind.org.uk/'),
            ),

            const SizedBox(height: 28),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha:0.12),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppTheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ubuncare is not a crisis or emergency service.\n'
                      'If you are in danger or at risk, please reach out to one of the numbers above or your local emergency service.',
                      style: AppTheme.bodyMd,
                    ),
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

class _SupportTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? number;
  final IconData leadingIcon;
  final Color color;
  final VoidCallback onTap;

  const _SupportTile({
    required this.title,
    this.subtitle,
    this.number,
    required this.leadingIcon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hint = number != null
        ? 'Tap to call $title on $number'
        : 'Tap to contact $title';
    return Semantics(
      hint: hint,
      child: Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(leadingIcon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: AppTheme.bodyLg.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(subtitle!, style: AppTheme.bodyMd),
              )
            : null,
        trailing: number != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    number!,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppTheme.textMuted),
                ],
              )
            : const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.textMuted),
        onTap: onTap,
      ),
      ),
    );
  }
}
