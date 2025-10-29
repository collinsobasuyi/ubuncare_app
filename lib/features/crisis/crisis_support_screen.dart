import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CrisisSupportScreen extends StatelessWidget {
  const CrisisSupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crisis Support')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('If you are in immediate danger, call 999.', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('999 (Emergency Services)'),
            trailing: const Icon(Icons.call),
            onTap: ()=>launchUrlString('tel:999'),
          ),
          ListTile(
            title: const Text('Samaritans (116 123)'),
            subtitle: const Text('Free, 24/7 listening support'),
            trailing: const Icon(Icons.call),
            onTap: ()=>launchUrlString('tel:116123'),
          ),
          const SizedBox(height: 12),
          const Text('Ubuncare is not a crisis service.'),
        ]),
      ),
    );
  }
}
