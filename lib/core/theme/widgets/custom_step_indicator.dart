import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnest/core/theme/app_colors.dart';
import 'package:partnest/core/theme/app_typography.dart';

enum StepState { pending, current, completed }

class CustomStepIndicator extends StatelessWidget {
  final int stepNumber;
  final StepState state;

  const CustomStepIndicator({
    super.key,
    required this.stepNumber,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color contentColor;
    Widget content;

    switch (state) {
      case StepState.completed:
        backgroundColor = AppColors.successGreen;
        contentColor = AppColors.neutralWhite;
        content = Icon(LucideIcons.check, size: 16, color: contentColor);
        break;
      case StepState.current:
        backgroundColor = AppColors.trustBlue;
        contentColor = AppColors.neutralWhite;
        content = Text(
          stepNumber.toString(),
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: contentColor,
            fontWeight: FontWeight.w600,
          ),
        );
        break;
      case StepState.pending:
        backgroundColor = AppColors.slate200;
        contentColor = AppColors.slate600;
        content = Text(
          stepNumber.toString(),
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: contentColor,
            fontWeight: FontWeight.w500,
          ),
        );
        break;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: content,
      ),
    );
  }
}
