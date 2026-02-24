import 'package:flutter/material.dart';
import 'package:partnest/core/theme/app_colors.dart';
import 'package:partnest/core/theme/app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.slate50,
      colorScheme: const ColorScheme.light(
        primary: AppColors.trustBlue,
        secondary: AppColors.slate900,
        error: AppColors.dangerRed,
        surface: AppColors.neutralWhite,
        background: AppColors.slate50,
      ),
      textTheme: AppTypography.textTheme,
    );
  }
}
