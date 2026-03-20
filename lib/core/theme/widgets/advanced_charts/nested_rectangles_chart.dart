import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'dart:math' as math;

class NestedRectanglesChartData {
  final String baseLabel;
  final double baseValue;
  final String finalLabel;
  final double finalValue;

  const NestedRectanglesChartData({
    required this.baseLabel,
    required this.baseValue,
    required this.finalLabel,
    required this.finalValue,
  });
}

class NestedRectanglesChart extends StatelessWidget {
  final NestedRectanglesChartData data;
  final Color baseColor;
  final Color intermediateColor;
  final Color finalPositiveColor;
  final Color finalNegativeColor;

  const NestedRectanglesChart({
    super.key,
    required this.data,
    this.baseColor = AppColors.slate400,
    this.intermediateColor = AppColors.trustBlue,
    this.finalPositiveColor = AppColors.successGreen,
    this.finalNegativeColor = AppColors.dangerRed,
  });

  @override
  Widget build(BuildContext context) {
    final double growth = data.finalValue - data.baseValue;
    final bool isPositive = growth >= 0;
    final Color outerColor = isPositive ? finalPositiveColor : finalNegativeColor;

    // Spec: "Each rectangle 25% larger than previous"
    // We visually represent this by having 3 boxes, zooming outwards.
    // Box 1 (Base): 50% width/height
    // Box 2 (Intermed): 75% width/height
    // Box 3 (Final): 100% width/height
    
    return Container(
      height: 240,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutBack,
          builder: (context, anim, child) {
            return AspectRatio(
              aspectRatio: 1.5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Rect (Final)
                  _buildAnimatedRect(
                    widthFactor: 1.0 * anim,
                    heightFactor: 1.0 * anim,
                    color: outerColor,
                    label: '${data.finalLabel}: ₦${(data.finalValue / 1000000).toStringAsFixed(2)}M',
                  ),
                  
                  // Middle Rect
                  _buildAnimatedRect(
                    widthFactor: 0.75 * anim,
                    heightFactor: 0.75 * anim,
                    color: intermediateColor,
                    label: '',
                  ),
                  
                  // Inner Rect (Base)
                  _buildAnimatedRect(
                    widthFactor: 0.5 * anim,
                    heightFactor: 0.5 * anim,
                    color: baseColor,
                    label: '${data.baseLabel}: ₦${(data.baseValue / 1000000).toStringAsFixed(2)}M',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedRect({
    required double widthFactor,
    required double heightFactor,
    required Color color,
    required String label,
  }) {
    if (widthFactor <= 0.01) return const SizedBox.shrink();
    
    return FractionallySizedBox(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          color: color.withValues(alpha: 0.05),
        ),
        padding: const EdgeInsets.all(8),
        alignment: Alignment.topLeft,
        child: label.isNotEmpty
            ? Text(
                label,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              )
            : null,
      ),
    );
  }
}
