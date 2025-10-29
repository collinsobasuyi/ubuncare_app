import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/consent_state.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    const Color primaryTeal = Color(0xFF0D896C);
    final consent = context.read<ConsentState>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset App?'),
        content: const Text(
          'This will erase all stored reflections, preferences, and consent, returning Ubuncare to its original state. '
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: primaryTeal),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await consent.resetApp();
      if (context.mounted) {
        context.go('/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF0D896C);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Preferences',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.refresh_rounded, color: primaryTeal),
              title: const Text(
                'Reset App',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Clear all stored data and start fresh.',
                style: TextStyle(color: Colors.black54),
              ),
              onTap: () => _confirmReset(context),
            ),
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'Ubuncare v1.0.0',
              style: TextStyle(color: Colors.black45, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
