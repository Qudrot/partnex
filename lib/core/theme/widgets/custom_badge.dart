import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';

class CustomBadge extends StatelessWidget {
  final String text;
  final RiskLevel riskLevel;

  const CustomBadge({super.key, required this.text, required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = AppColors.neutralWhite;

    switch (riskLevel) {
      case RiskLevel.low:
        backgroundColor = AppColors.successGreen;
        break;
      case RiskLevel.medium:
        backgroundColor = AppColors.warningAmber;
        break;
      case RiskLevel.high:
        backgroundColor = AppColors.dangerRed;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.textTheme.labelLarge?.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}

class NeutralBadge extends StatelessWidget {
  final String text;

  const NeutralBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.textTheme.labelLarge?.copyWith(
          color: AppColors.slate900,
        ),
      ),
    );
  }
}
