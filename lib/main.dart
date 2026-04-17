import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/consent_state.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final consent = ConsentState();
  await consent.loadConsent();
  runApp(
    ChangeNotifierProvider.value(
      value: consent,
      child: const UbuncareApp(),
    ),
  );
}
