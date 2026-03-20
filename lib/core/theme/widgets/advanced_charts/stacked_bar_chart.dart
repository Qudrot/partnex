import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'dart:math' as math;

class StackedBarChartData {
  final String baseLabel;
  final double baseValue;
  final String finalLabel;
  final double finalValue;

  const StackedBarChartData({
    required this.baseLabel,
    required this.baseValue,
    required this.finalLabel,
    required this.finalValue,
  });
}

class StackedBarChart extends StatelessWidget {
  final StackedBarChartData data;
  final Color baseColor;
  final Color positiveColor;
  final Color negativeColor;

  const StackedBarChart({
    super.key,
    required this.data,
    this.baseColor = AppColors.trustBlue,
    this.positiveColor = AppColors.successGreen,
    this.negativeColor = AppColors.dangerRed,
  });

  @override
  Widget build(BuildContext context) {
    final double growth = data.finalValue - data.baseValue;
    final bool isPositive = growth >= 0;
    final Color growthColor = isPositive ? positiveColor : negativeColor;
    
    final double maxVal = math.max(data.baseValue, data.finalValue);
    final double range = math.max(maxVal * 1.2, 1.0); // 20% headroom
    
    final double baseFrac = (data.baseValue / range).clamp(0.0, 1.0);
    final double growthFrac = (growth.abs() / range).clamp(0.0, 1.0);

    return Container(
      height: 240,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double h = constraints.maxHeight - 24;
          // Make bar much wider and properly centered
          final double w = math.min(constraints.maxWidth * 0.7, 240.0);
          final double centerOffset = (constraints.maxWidth - w) / 2;
          
          final double baseH = h * baseFrac;
          final double growthH = h * growthFrac;
          
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Bottom label
              Positioned(
                bottom: -24,
                child: Text(
                  'Compounding Growth',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.slate600,
                    fontSize: 12,
                  ),
                ),
              ),
              // Base Bar segment
              Positioned(
                left: centerOffset,
                bottom: 24,
                width: w,
                height: baseH,
                child: Container(
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.only(
                       bottomLeft: Radius.circular(4),
                       bottomRight: Radius.circular(4),
                       topLeft: isPositive ? Radius.zero : Radius.circular(4),
                       topRight: isPositive ? Radius.zero : Radius.circular(4),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Base\n₦${(data.baseValue/1000000).toStringAsFixed(1)}M',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutralWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Growth Bar Segment
              Positioned(
                left: centerOffset,
                bottom: 24 + (isPositive ? baseH : baseH - growthH),
                width: w,
                height: growthH,
                child: Container(
                  decoration: BoxDecoration(
                    color: growthColor,
                    borderRadius: BorderRadius.only(
                       topLeft: isPositive ? Radius.circular(4) : Radius.zero,
                       topRight: isPositive ? Radius.circular(4) : Radius.zero,
                       bottomLeft: isPositive ? Radius.zero : Radius.circular(4),
                       bottomRight: isPositive ? Radius.zero : Radius.circular(4),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${isPositive ? '+' : '-'}₦${(growth.abs()/1000000).toStringAsFixed(1)}M',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutralWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              // Final value label positioned near top right of the whole pillar
              Positioned(
                left: centerOffset + w + 12,
                bottom: 24 + (isPositive ? baseH + growthH - 20 : baseH - 20),
                child: Text(
                  'Final: ₦${(data.finalValue/1000000).toStringAsFixed(1)}M',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                     fontWeight: FontWeight.w700,
                     fontSize: 12,
                     color: AppColors.slate900,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
