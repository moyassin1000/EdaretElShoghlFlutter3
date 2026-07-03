import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

class AppTheme {
  static const Color gold = Color(0xFFD6A84A);
  static const Color deepNavy = Color(0xFF071426);
  static const Color premiumBlack = Color(0xFF070A0F);
  static const Color cardDark = Color(0xFF111827);
  static const Color softGrey = Color(0xFFF3F4F6);

  static ThemeData themeFromName(String name) {
    switch (name) {
      case AppConstants.lightTheme:
        return light;
      case AppConstants.darkTheme:
        return dark;
      default:
        return premium;
    }
  }

  static ThemeData get premium => _base(Brightness.dark).copyWith(
        scaffoldBackgroundColor: premiumBlack,
        primaryColor: gold,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: Color(0xFF1E3A8A),
          surface: cardDark,
          error: Color(0xFFEF4444),
        ),
        cardColor: cardDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: premiumBlack,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      );

  static ThemeData get dark => _base(Brightness.dark).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF60A5FA),
          secondary: gold,
          surface: Color(0xFF1E293B),
          error: Color(0xFFF87171),
        ),
        cardColor: const Color(0xFF1E293B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      );

  static ThemeData get light => _base(Brightness.light).copyWith(
        scaffoldBackgroundColor: softGrey,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1E3A8A),
          secondary: gold,
          surface: Colors.white,
          error: Color(0xFFDC2626),
        ),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      );

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'sans',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF111827) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: isDark ? 8 : 4,
        shadowColor: Colors.black.withOpacity(0.25),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
