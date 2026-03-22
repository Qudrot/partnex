import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.slate50,
      colorScheme: const ColorScheme.light(
        primary: AppColors.trustBlue,
        secondary: AppColors.slate900,
        error: AppColors.dangerRed,
        surface: AppColors.neutralWhite,
        onSurface: AppColors.slate900,
        surfaceContainer: AppColors.slate50,
      ),
      textTheme: AppTypography.textTheme,
      dividerTheme: const DividerThemeData(color: AppColors.slate200),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.slate950,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.trustBlue,
        secondary: AppColors.slate100,
        error: AppColors.dangerRed,
        surface: AppColors.slate900,
        onSurface: AppColors.slate50,
        surfaceContainer: AppColors.slate950,
      ),
      textTheme: AppTypography.textTheme,
      dividerTheme: const DividerThemeData(color: AppColors.slate800),
    );
  }
}
