import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color background = Color(0xFF0B0C0E);
  static const Color surface = Color(0xFF141519);
  static const Color surfaceLight = Color(0xFF1F2128);
  static const Color cardBorder = Color(0x33FFD700); // 20% opacity gold
  
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color secondaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB8860B);
  
  static const Color greenPositive = Color(0xFF00E676);
  static const Color redNegative = Color(0xFFFF5252);
  
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFD4AF37), Color(0xFF996515)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1B1C22), Color(0xFF121317)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryGold,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: secondaryGold,
        surface: surface,
        background: background,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
