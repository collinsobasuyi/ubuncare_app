import 'package:flutter/material.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Summary')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Key takeaways, suggested next step, and a gentle self-care nudge.'),
      ),
    );
  }
}
