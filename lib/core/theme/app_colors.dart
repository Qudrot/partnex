import 'package:flutter/material.dart';

class AppColors {
  // Neutral Palette
  static const Color neutralBlack = Color(0xFF0F0F0F);
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  // Accent Colors (Functional)
  static const Color trustBlue = Color(0xFF0066CC);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningOrange = Color(0xFFF97316); // moderate-risk signals
  static const Color dangerRed = Color(0xFFEF4444);

  // Surface & Accent Shades
  static const Color linkBlue = Color(0xFF2563EB);
  static const Color successBg = Color(0xFFDCFCE7);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningAmberText = Color(0xFFD97706);
  static const Color successGreenText = Color(0xFF16A34A);

  static const Color neutralGray = Color(0xFF6B7280);

  // Semantic mappings for themes
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? slate950 : slate50;
  
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? slate900 : neutralWhite;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? slate800 : slate200;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? slate50 : slate900;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? slate400 : slate600;
}

extension ThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

