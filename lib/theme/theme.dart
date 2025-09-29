import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryPurple = Color(0xFF6A0DAD);
  static const Color secondaryBlue = Color(0xFF4A90E2);
  static const Color backgroundLight = Color(0xFFF8F9FB);
  static const Color backgroundGradientEnd = Color(0xFFECE9F1);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6B7280);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ThemeData
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPurple,
      primary: primaryPurple,
      secondary: secondaryBlue,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,

    // AppBar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryPurple,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    // Card theme
    cardTheme: CardThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // ElevatedButton theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // Text theme
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 16,
        color: textPrimary,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 14,
        color: textSecondary,
      ),
    ),
  );
}
