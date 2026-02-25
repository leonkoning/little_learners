import 'package:flutter/material.dart';

class AppTheme {
  // World palette colors
  static const Color jungleGreen = Color(0xFF4CAF50);
  static const Color jungleDark = Color(0xFF2E7D32);
  static const Color jungleLight = Color(0xFFA5D6A7);

  static const Color spacePurple = Color(0xFF7C4DFF);
  static const Color spaceDark = Color(0xFF311B92);
  static const Color spaceLight = Color(0xFFCE93D8);

  static const Color oceanTeal = Color(0xFF00BCD4);
  static const Color oceanDark = Color(0xFF006064);
  static const Color oceanLight = Color(0xFFB2EBF2);

  static const Color candyPink = Color(0xFFE91E8C);
  static const Color candyDark = Color(0xFF880E4F);
  static const Color candyLight = Color(0xFFF8BBD0);

  static const Color gardenPurple = Color(0xFF9C27B0);
  static const Color gardenDark = Color(0xFF4A148C);
  static const Color gardenLight = Color(0xFFE1BEE7);

  // UI colors
  static const Color starGold = Color(0xFFFFD700);
  static const Color correctGreen = Color(0xFF66BB6A);
  static const Color wrongRed = Color(0xFFEF5350);
  static const Color background = Color(0xFFFFFDE7);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: spacePurple,
          brightness: Brightness.light,
        ),
        // Use Fredoka if available, otherwise falls back to system rounded font
        fontFamily: 'Fredoka',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
          displayMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Color(0xFF424242),
          ),
        ),
        scaffoldBackgroundColor: background,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(80, 80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
