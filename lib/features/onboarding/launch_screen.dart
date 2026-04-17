import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    _checkIfReturningUser();
  }

  Future<void> _checkIfReturningUser() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('mood_history') ?? [];

    await Future.delayed(const Duration(milliseconds: 600)); // small splash delay

    if (!mounted) return;

    // Route all users to Home (UI will adapt automatically)
    context.go('/home', extra: {'isNewUser': history.isEmpty});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Semantics(
          label: 'Loading, please wait',
          child: const CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
