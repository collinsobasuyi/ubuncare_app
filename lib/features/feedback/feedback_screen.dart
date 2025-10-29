import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Tell us what to improve'),
          ),
          const Spacer(),
          FilledButton(onPressed: ()=>Navigator.of(context).pop(), child: const Text('Submit')),
        ]),
      ),
    );
  }
}
