import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/router.dart';
import 'consent_state.dart';
import 'theme.dart';

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
    final consent = Provider.of<ConsentState>(context, listen: false);
    _router = buildRouter(consent);
    // Sync consent state after startup (was previously in UbuncareRoot)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      consent.syncAfterStartup();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsentState>(
      builder: (context, consent, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Ubuncare',
          theme: AppTheme.light,
          routerConfig: _router,
        );
      },
    );
  }
}
