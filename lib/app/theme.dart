import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single source of truth for all design tokens in Ubuncare.
/// Target audience: adults 18-45 seeking calm, trust, and emotional support.
/// Palette: warm forest-teal primary + amber accent on cream backgrounds.
class AppTheme {
  AppTheme._();

  // ─── Core Brand ────────────────────────────────────────────────────────────
  static const Color primary        = Color(0xFF1D6B52); // Deep forest teal
  static const Color primaryMid     = Color(0xFF2E9B78); // Medium teal
  static const Color primaryLight   = Color(0xFF4BAF8A); // Light teal
  static const Color primarySurface = Color(0xFFEBF5F0); // Teal wash (chip bg, etc.)
  static const Color primaryPale    = Color(0xFFF2FAF6); // Faintest teal tint

  // ─── Accent (Warm Amber — Ubuntu sunshine) ─────────────────────────────────
  static const Color accent        = Color(0xFFE9963A);
  static const Color accentSurface = Color(0xFFFDF3E7);

  // ─── Backgrounds ───────────────────────────────────────────────────────────
  static const Color bgPage    = Color(0xFFFDFAF6); // Warm cream — welcoming, not clinical
  static const Color bgSurface = Color(0xFFFFFFFF); // White cards
  static const Color bgBorder  = Color(0xFFE2EBE6); // Subtle warm border

  // ─── Text ──────────────────────────────────────────────────────────────────
  static const Color textDark  = Color(0xFF1A2420); // Near-black with forest undertone
  static const Color textBody  = Color(0xFF4A5E57); // Warm grey-green
  static const Color textMuted = Color(0xFF4D7068); // Muted for captions / hints — WCAG AA ✅ ~5.3:1 on cream

  // ─── Semantic ──────────────────────────────────────────────────────────────
  static const Color crisisRed        = Color(0xFFC62828);
  static const Color crisisRedSurface = Color(0xFFFCEBEB);
  static const Color success          = Color(0xFF2D9B6B);

  // ─── Legacy aliases (screens that still use these names compile without changes)
  static const Color ubuncareColor  = primary;
  static const Color lighterTeal    = primaryMid;
  static const Color accentTeal     = primaryLight;
  static const Color surface        = bgSurface;
  static const Color illustrationBg = bgPage;
  static const Color textBody_      = textBody;  // avoid conflict with getter name

  // ─── Spacing Tokens ────────────────────────────────────────────────────────
  static const double pagePadding    = 24.0;
  static const double elementSpacing = 16.0;
  static const double sectionSpacing = 32.0;
  static const double cornerRadius   = 16.0;
  static const double cornerRadiusLg = 24.0;
  static const double avatarRadius   = 24.0;

  // ─── Splash Tokens ─────────────────────────────────────────────────────────
  static const double splashRadius = 120.0;
  static const Color  rippleColor  = Colors.white;
  static const Color  iconGlow     = Colors.white;
  static const double rippleOpacity = 0.4;
  static const double rippleStroke  = 2.0;

  // ─── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryMid],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Typography — Poppins ──────────────────────────────────────────────────

  static TextStyle get display => GoogleFonts.poppins(
    fontSize: 32, fontWeight: FontWeight.w700,
    color: textDark, letterSpacing: -0.3,
  );

  static TextStyle get headingLg => GoogleFonts.poppins(
    fontSize: 26, fontWeight: FontWeight.w700, color: textDark,
  );

  static TextStyle get headingMd => GoogleFonts.poppins(
    fontSize: 22, fontWeight: FontWeight.w600, color: textDark,
  );

  static TextStyle get headingSm => GoogleFonts.poppins(
    fontSize: 18, fontWeight: FontWeight.w600, color: textDark,
  );

  static TextStyle get bodyLg => GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w400, color: textBody, height: 1.55,
  );

  static TextStyle get bodyMd => GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w400, color: textBody, height: 1.5,
  );

  static TextStyle get bodySm => GoogleFonts.poppins(
    fontSize: 12, fontWeight: FontWeight.w400, color: textMuted, height: 1.4,
  );

  static TextStyle get label => GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w600, color: bgSurface,
  );

  static TextStyle get labelPrimary => GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w600, color: primary,
  );

  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 13, fontWeight: FontWeight.w400, color: textMuted,
    fontStyle: FontStyle.italic,
  );

  // Splash-specific (white text on coloured bg)
  static TextStyle get splashDisplay => GoogleFonts.poppins(
    fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white,
  );
  static TextStyle get splashBody => GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white, height: 1.55,
  );
  static TextStyle get splashCaption => GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70,
    fontStyle: FontStyle.italic,
  );

  // ─── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light();

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primaryMid,
        surface: bgSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
        error: crisisRed,
        outline: bgBorder,
      ),
      scaffoldBackgroundColor: bgPage,

      // Global Poppins text theme
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: textBody,
        displayColor: textDark,
      ),

      // AppBar — always brand-coloured in this app
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
          shadowColor: primary.withValues(alpha:0.3),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: bgSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
          side: const BorderSide(color: bgBorder, width: 1),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: bgBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: bgBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.8),
        ),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: textMuted),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: primarySurface,
        selectedColor: primarySurface,
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: textDark),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        side: const BorderSide(color: bgBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        inactiveTrackColor: primarySurface,
        overlayColor: primary.withValues(alpha:0.12),
      ),

      dividerTheme: const DividerThemeData(color: bgBorder, thickness: 1),
    );
  }
}
