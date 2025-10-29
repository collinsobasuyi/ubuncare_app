import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF0D896C);
  static const Color accentMint = Color(0xFF11A985);
  static const Color lightMint = Color(0xFF4FE2B5);
  static const Color backgroundAqua = Color(0xFFE6FFFA);
  static const Color textTeal = Color(0xFF055E47);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryTeal,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: backgroundAqua,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: textTeal,
          elevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: textTeal,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: textTeal,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textTeal,
          ),
        ),
      );
}
