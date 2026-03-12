import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';

class AppTypography {
  static final TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.64, // -0.02em * 32
      color: AppColors.neutralBlack,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      height: 1.3,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.56, // -0.02em * 28
      color: AppColors.neutralBlack,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      height: 1.4,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.24, // -0.01em * 24
      color: AppColors.neutralBlack,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      height: 1.4,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.neutralBlack,
    ),
    headlineSmall: TextStyle(
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.neutralBlack,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: AppColors.neutralBlack,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: AppColors.neutralBlack,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.24, // 0.02em * 12
      color: AppColors.neutralBlack,
    ),
    labelLarge: TextStyle(
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.60, // 0.05em * 12
      color: AppColors.neutralBlack,
    ),
    labelMedium: TextStyle(
      fontSize: 11,
      height: 1.3,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.11, // 0.01em * 11
      color: AppColors.neutralBlack,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.neutralBlack,
    ),
  );

  static final TextStyle bodySmaller = TextStyle(
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w400,
    color: AppColors.neutralBlack,
  );

  static final TextStyle labelSmaller = TextStyle(
    fontSize: 10,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.neutralBlack,
  );

  static final TextStyle displayHero = TextStyle(
    fontSize: 112,
    height: 1.1,
    fontWeight: FontWeight.w900,
    color: AppColors.neutralBlack,
  );
}
