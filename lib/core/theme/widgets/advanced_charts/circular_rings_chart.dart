import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'dart:math' as math;

class CircularRingsChartData {
  final String baseLabel;
  final double baseValue;
  final String finalLabel;
  final double finalValue;

  const CircularRingsChartData({
    required this.baseLabel,
    required this.baseValue,
    required this.finalLabel,
    required this.finalValue,
  });
}

class CircularRingsChart extends StatelessWidget {
  final CircularRingsChartData data;
  final Color baseColor;
  final Color positiveColor;
  final Color negativeColor;

  const CircularRingsChart({
    super.key,
    required this.data,
    this.baseColor = AppColors.slate400,
    this.positiveColor = AppColors.successGreen,
    this.negativeColor = AppColors.dangerRed,
  });

  @override
  Widget build(BuildContext context) {
    final double maxVal = math.max(data.baseValue, data.finalValue);
    final double basePercentage = maxVal > 0 ? data.baseValue / maxVal : 0;
    final double finalPercentage = maxVal > 0 ? data.finalValue / maxVal : 0;

    final double growth = data.finalValue - data.baseValue;
    final double growthPercentage = data.baseValue > 0 ? (growth / data.baseValue) * 100 : 0;
    final bool isPositive = growth >= 0;
    final Color outerColor = isPositive ? positiveColor : negativeColor;

    return Container(
      height: 240,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Legend / Side labels
          Positioned(
            left: 16,
            top: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.baseLabel,
                  style: AppTypography.textTheme.labelSmall?.copyWith(color: AppColors.slate500),
                ),
                Text(
                  '₦${(data.baseValue / 1000000).toStringAsFixed(2)}M',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: baseColor,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data.finalLabel,
                  style: AppTypography.textTheme.labelSmall?.copyWith(color: AppColors.slate500),
                ),
                Text(
                  '₦${(data.finalValue / 1000000).toStringAsFixed(2)}M',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: outerColor,
                  ),
                ),
              ],
            ),
          ),

          // Render concentric rings using TweenAnimationBuilder for load animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, _) {
              return CustomPaint(
                size: const Size(160, 160),
                painter: _RingsPainter(
                  basePercentage: basePercentage * animValue,
                  finalPercentage: finalPercentage * animValue,
                  baseColor: baseColor,
                  outerColor: outerColor,
                  strokeWidth: 16.0,
                ),
              );
            },
          ),

          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isPositive ? '+' : ''}${growthPercentage.toStringAsFixed(0)}%',
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: outerColor,
                ),
              ),
              Text(
                'Growth',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.slate600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final double basePercentage;
  final double finalPercentage;
  final Color baseColor;
  final Color outerColor;
  final double strokeWidth;

  _RingsPainter({
    required this.basePercentage,
    required this.finalPercentage,
    required this.baseColor,
    required this.outerColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - strokeWidth / 2;
    final innerRadius = outerRadius - strokeWidth - 8.0; // 8px gap

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppColors.slate200;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = baseColor;

    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = outerColor;

    // Draw backgrounds
    canvas.drawCircle(center, outerRadius, bgPaint);
    canvas.drawCircle(center, innerRadius, bgPaint);

    final double startAngle = -math.pi / 2;
    
    // Draw Inner Ring (Base)
    final double innerSweep = 2 * math.pi * basePercentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      startAngle,
      innerSweep,
      false,
      basePaint,
    );

    // Draw Outer Ring (Final)
    final double outerSweep = 2 * math.pi * finalPercentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      startAngle,
      outerSweep,
      false,
      outerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) {
    return oldDelegate.basePercentage != basePercentage ||
        oldDelegate.finalPercentage != finalPercentage ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.outerColor != outerColor;
  }
}
