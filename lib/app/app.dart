import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/router.dart';
import 'consent_state.dart';

class UbuncareApp extends StatefulWidget {
  const UbuncareApp({super.key});

  @override
  State<UbuncareApp> createState() => _UbuncareAppState();
}

class _UbuncareAppState extends State<UbuncareApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // ✅ Build the router immediately — consent already loaded in main.dart
    final consent = Provider.of<ConsentState>(context, listen: false);
    _router = buildRouter(consent);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsentState>(
      builder: (context, consent, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Ubuncare',
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF0D896C),
            fontFamily: 'Sans',
            useMaterial3: true,
          ),
          routerConfig: _router,
        );
      },
    );
  }
}
