import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final double progress; // between 0.0 and 1.0
  final double height;

  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
    this.height = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.slate200,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.trustBlue,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
