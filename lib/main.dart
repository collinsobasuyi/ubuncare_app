import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/consent_state.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final consent = ConsentState();
  await consent.loadConsent(); // Load user consent + avatar before UI starts

  runApp(
    ChangeNotifierProvider.value(
      value: consent,
      child: const UbuncareRoot(),
    ),
  );
}

class UbuncareRoot extends StatefulWidget {
  const UbuncareRoot({super.key});

  @override
  State<UbuncareRoot> createState() => _UbuncareRootState();
}

class _UbuncareRootState extends State<UbuncareRoot> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Delay a tiny bit to allow router sync after hot restart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final consent = context.read<ConsentState>();
      consent.syncAfterStartup();
      setState(() => _initialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final consent = context.watch<ConsentState>();

    // Until sync completes, show loader to prevent unwanted redirect
    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0D896C),
            ),
          ),
        ),
      );
    }

    // Once initialized, show the real app
    return const UbuncareApp();
  }
}
