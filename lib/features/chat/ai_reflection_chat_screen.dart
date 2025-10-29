import 'package:flutter/material.dart';

class AIReflectionChatScreen extends StatelessWidget {
  const AIReflectionChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reflection Chat')),
      body: Column(
        children: [
          const Expanded(child: Center(child: Text('Chat stream goes here...'))),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(child: TextField(decoration: const InputDecoration(hintText: 'Type a message'))),
              const SizedBox(width: 8),
              FilledButton(onPressed: () {}, child: const Text('Send')),
            ]),
          )
        ],
      ),
    );
  }
}
