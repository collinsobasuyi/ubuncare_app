import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ubuncare Design System — "Warm Depth" edition.
/// Premium wellness: calm, warm, editorial, emotionally intelligent.
class AppTheme {
  AppTheme._();

  // ─── Core Brand ────────────────────────────────────────────────────────────
  static const Color primary        = Color(0xFF1D6B52);
  static const Color primaryMid     = Color(0xFF2E9B78);
  static const Color primaryLight   = Color(0xFF4BAF8A);
  static const Color primarySurface = Color(0xFFEBF5F0);
  static const Color primaryPale    = Color(0xFFF2FAF6);

  // ─── Accent (Warm Amber) ───────────────────────────────────────────────────
  static const Color accent        = Color(0xFFE9963A);
  static const Color accentDark    = Color(0xFFBF7424);
  static const Color accentSurface = Color(0xFFFDF3E7);
  static const Color accentPale    = Color(0xFFFEF9F2);

  // ─── Sage (secondary neutral) ──────────────────────────────────────────────
  static const Color sage        = Color(0xFF8FAD96);
  static const Color sageSurface = Color(0xFFF0F5F1);

  // ─── Backgrounds ───────────────────────────────────────────────────────────
  static const Color bgPage    = Color(0xFFF7F3EE); // Warm sand — more depth than cream
  static const Color bgSurface = Color(0xFFFFFFFF);
  static const Color bgElevated= Color(0xFFFFFDF9); // Slightly warm white for elevated cards
  static const Color bgBorder  = Color(0xFFE2EBE6);
  static const Color bgDivider = Color(0xFFF0EAE0); // Warmer divider

  // ─── Text ──────────────────────────────────────────────────────────────────
  static const Color textDark  = Color(0xFF1A2420);
  static const Color textBody  = Color(0xFF4A5E57);
  static const Color textMuted = Color(0xFF7A8E87);
  static const Color textHint  = Color(0xFFAFC0B8);

  // ─── Semantic ──────────────────────────────────────────────────────────────
  static const Color crisisRed        = Color(0xFFC62828);
  static const Color crisisRedSurface = Color(0xFFFCEBEB);
  static const Color success          = Color(0xFF2D9B6B);
  static const Color warning          = Color(0xFFE9963A);

  // ─── Legacy aliases ────────────────────────────────────────────────────────
  static const Color ubuncareColor  = primary;
  static const Color lighterTeal    = primaryMid;
  static const Color accentTeal     = primaryLight;
  static const Color surface        = bgSurface;
  static const Color illustrationBg = bgPage;
  static const Color textBody_      = textBody;

  // ─── Spacing Tokens ────────────────────────────────────────────────────────
  static const double pagePadding    = 24.0;
  static const double pagePaddingLg  = 28.0;
  static const double elementSpacing = 16.0;
  static const double sectionSpacing = 32.0;
  static const double cornerRadius   = 16.0;
  static const double cornerRadiusMd = 20.0;
  static const double cornerRadiusLg = 24.0;
  static const double cornerRadiusXl = 32.0;
  static const double avatarRadius   = 24.0;

  // ─── Splash Tokens ─────────────────────────────────────────────────────────
  static const double splashRadius   = 120.0;
  static const Color  rippleColor    = Colors.white;
  static const Color  iconGlow       = Colors.white;
  static const double rippleOpacity  = 0.4;
  static const double rippleStroke   = 2.0;

  // ─── Shadow System ─────────────────────────────────────────────────────────
  static List<BoxShadow> get shadowXs => [
    BoxShadow(
      color: const Color(0xFF1D6B52).withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: const Color(0xFF1A2420).withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: const Color(0xFF1D6B52).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: const Color(0xFF1A2420).withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF1D6B52).withValues(alpha: 0.06),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: const Color(0xFF1A2420).withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF1D6B52).withValues(alpha: 0.08),
      blurRadius: 48,
      offset: const Offset(0, 20),
    ),
  ];

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

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF164E3C), primary, primaryMid],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFC8702A), accent, Color(0xFFEFB660)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient calmGradient = LinearGradient(
    colors: [Color(0xFF3A6B82), Color(0xFF4A8FA8), Color(0xFF62B0C8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Typography — Poppins ──────────────────────────────────────────────────

  static TextStyle get displayLg => GoogleFonts.poppins(
    fontSize: 40, fontWeight: FontWeight.w800,
    color: textDark, letterSpacing: -1.0, height: 1.1,
  );

  static TextStyle get display => GoogleFonts.poppins(
    fontSize: 32, fontWeight: FontWeight.w700,
    color: textDark, letterSpacing: -0.5,
  );

  static TextStyle get headingLg => GoogleFonts.poppins(
    fontSize: 26, fontWeight: FontWeight.w700, color: textDark, letterSpacing: -0.3,
  );

  static TextStyle get headingMd => GoogleFonts.poppins(
    fontSize: 22, fontWeight: FontWeight.w600, color: textDark,
  );

  static TextStyle get headingSm => GoogleFonts.poppins(
    fontSize: 18, fontWeight: FontWeight.w600, color: textDark,
  );

  static TextStyle get headingXs => GoogleFonts.poppins(
    fontSize: 15, fontWeight: FontWeight.w600, color: textDark, letterSpacing: 0.1,
  );

  static TextStyle get overline => GoogleFonts.poppins(
    fontSize: 11, fontWeight: FontWeight.w600, color: textMuted,
    letterSpacing: 1.2,
  );

  static TextStyle get bodyLg => GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w400, color: textBody, height: 1.6,
  );

  static TextStyle get bodyMd => GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w400, color: textBody, height: 1.55,
  );

  static TextStyle get bodySm => GoogleFonts.poppins(
    fontSize: 12, fontWeight: FontWeight.w400, color: textMuted, height: 1.45,
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

      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: textBody,
        displayColor: textDark,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: bgPage,
        foregroundColor: textDark,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: textDark,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(double.infinity, 54),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(double.infinity, 54),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      cardTheme: CardThemeData(
        color: bgSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusMd),
          side: const BorderSide(color: bgBorder, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: bgBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: bgBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: textHint),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: primarySurface,
        selectedColor: primarySurface,
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: textDark),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        overlayColor: primary.withValues(alpha: 0.12),
        trackHeight: 5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      ),

      dividerTheme: const DividerThemeData(color: bgDivider, thickness: 1),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgSurface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
