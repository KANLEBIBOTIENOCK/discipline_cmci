import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Thème Floral & Féminin optimisé pour une haute lisibilité (WCAG AA) et une élégance spirituelle
class AppTheme {
  // Couleurs principales Florales Contrastées
  static const Color primaryRose = Color(0xFFC8466D); // Rose framboise soutenu
  static const Color primaryRoseDark = Color(0xFF8F2245);
  static const Color primaryRoseLight = Color(0xFFFDE8EF); // Rose poudré doux
  static const Color primaryBlush = Color(0xFFF5C6D6);

  // Accents & Harmonies
  static const Color lavender = Color(0xFF8352D4);
  static const Color lavenderLight = Color(0xFFEFE7FC);
  static const Color softPeach = Color(0xFFFF9EAA);
  static const Color warmGold = Color(0xFFC9822B);
  static const Color warmGoldLight = Color(0xFFFDF4E7);
  static const Color sageGreen = Color(0xFF3F8A65);
  static const Color sageGreenLight = Color(0xFFE6F4ED);

  // Arrière-plans & Typographie Haute Lisibilité
  static const Color backgroundLight = Color(0xFFFFF9FA);
  static const Color cardSurface = Colors.white;
  static const Color textMain = Color(0xFF24141C); // Prune noir très net et lisible
  static const Color textMuted = Color(0xFF5C4A54); // Gris rosé soutenu
  static const Color dividerColor = Color(0xFFEBD6DD);

  // Dégradés Floraux
  static const LinearGradient rosePetalGradient = LinearGradient(
    colors: [Color(0xFFDF6186), Color(0xFFC8466D), Color(0xFFB03058)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lavenderBlossomGradient = LinearGradient(
    colors: [Color(0xFFB588F7), Color(0xFF8352D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldenSunbeamGradient = LinearGradient(
    colors: [Color(0xFFF6C88A), Color(0xFFC9822B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Décorations d'ombres
  static List<BoxShadow> softCardShadow = [
    BoxShadow(
      color: const Color(0xFF8F2245).withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> roseGlowShadow = [
    BoxShadow(
      color: const Color(0xFFC8466D).withOpacity(0.35),
      blurRadius: 18,
      offset: const Offset(0, 8),
      spreadRadius: 1,
    ),
  ];

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRose,
        primary: primaryRose,
        secondary: lavender,
        surface: cardSurface,
        background: backgroundLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textMain,
        onBackground: textMain,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textMain,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: textMain,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textMain,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textMuted,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: dividerColor, width: 1.2),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textMain),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textMain,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRose,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: primaryRose.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryRose, width: 2),
        ),
      ),
    );
  }
}
