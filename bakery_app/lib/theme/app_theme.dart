import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.brown.shade900,
        primary: Colors.brown.shade900,
        secondary: Colors.brown.shade700,
        surface: Colors.brown.shade50,
      ),
      useMaterial3: true,
      textTheme: TextTheme(
        // Large titles
        displayLarge: const TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: Colors.brown,
        ),
        // Medium titles
        displayMedium: const TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: Colors.brown,
        ),
        // Section headers
        titleLarge: const TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: Colors.brown,
        ),
        // Regular text
        bodyLarge: const TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          color: Colors.brown,
        ),
        // Smaller text
        bodyMedium: const TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          color: Colors.brown,
        ),
      ),
      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown.shade900,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.brown.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.brown.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.brown.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.brown.shade700, width: 2),
        ),
        labelStyle: TextStyle(
          fontFamily: 'Playfair Display',
          color: Colors.brown.shade700,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Playfair Display',
          color: Colors.brown.shade400,
        ),
      ),
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.brown.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
