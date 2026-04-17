import 'package:flutter/material.dart';

class SafePlaceScreen extends StatelessWidget {
  const SafePlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0D896C);

    return Scaffold(
      backgroundColor: primaryTeal,
      appBar: AppBar(
        title: const Text("Safe Place Visualization"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.landscape_rounded, size: 80, color: Colors.white70),
              SizedBox(height: 24),
              Text(
                "Close your eyes.\nImagine a place where you feel completely safe, warm, and peaceful.\n\nFocus on every detail — the colors, sounds, scents, and sensations.\n\nStay there for a few breaths.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primaryTeal,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "I FEEL GROUNDED",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
