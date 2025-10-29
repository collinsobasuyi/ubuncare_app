import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgeGateScreen extends StatefulWidget {
  const AgeGateScreen({super.key});

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> {
  bool _confirmed = false;

  Future<void> _saveAgeConfirmed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ageConfirmed', true);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF0D896C);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user_rounded,
                size: 80,
                color: primaryTeal,
                semanticLabel: 'Age confirmation icon',
              ),
              const SizedBox(height: 32),
              const Text(
                'Are you 18 or older?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryTeal,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ubuncare is designed for adults (18+) and may include reflective wellbeing content not suitable for younger users.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    await _saveAgeConfirmed();
                    if (context.mounted) context.go('/consent');
                  },
                  child: const Text('Yes, I am 18 or older'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _showUnderageDialog(context),
                child: const Text(
                  'No, I am under 18',
                  style: TextStyle(
                    color: primaryTeal,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnderageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sorry'),
        content: const Text(
          'Ubuncare is for adults aged 18 and above.\n'
          'We recommend speaking with a trusted adult or accessing free youth mental health support such as Childline (0800 1111 in the UK).',
          textAlign: TextAlign.start,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
