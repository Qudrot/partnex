import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partnex/core/theme/app_colors.dart';

class AppTypography {
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 32,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.64, // -0.02em * 32
      color: AppColors.neutralBlack,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 28,
      height: 1.3,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.56, // -0.02em * 28
      color: AppColors.neutralBlack,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 24,
      height: 1.4,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.24, // -0.01em * 24
      color: AppColors.neutralBlack,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 20,
      height: 1.4,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.neutralBlack,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.neutralBlack,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: AppColors.neutralBlack,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: AppColors.neutralBlack,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.24, // 0.02em * 12
      color: AppColors.neutralBlack,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.60, // 0.05em * 12
      color: AppColors.neutralBlack,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 11,
      height: 1.3,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.11, // 0.01em * 11
      color: AppColors.neutralBlack,
    ),
  );
}
