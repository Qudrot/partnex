import 'package:flutter/material.dart';

class AppTypography {
  static final TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.64, // -0.02em * 32
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      height: 1.3,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.56, // -0.02em * 28
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      height: 1.4,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.24, // -0.01em * 24
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      height: 1.4,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.24, // 0.02em * 12
    ),
    labelLarge: TextStyle(
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.60, // 0.05em * 12
    ),
    labelMedium: TextStyle(
      fontSize: 11,
      height: 1.3,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.11, // 0.01em * 11
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
  );

  static const TextStyle bodySmaller = TextStyle(
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelSmaller = TextStyle(
    fontSize: 10,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle displayHero = TextStyle(
    fontSize: 112,
    height: 1.1,
    fontWeight: FontWeight.w900,
  );
}
