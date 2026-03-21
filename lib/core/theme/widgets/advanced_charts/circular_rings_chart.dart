import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'dart:math' as math;

class CircularRingsChartData {
  final String baseLabel;
  final double baseValue;
  final String finalLabel;
  final double finalValue;
  final String? thirdLabel;
  final double? thirdValue;

  const CircularRingsChartData({
    required this.baseLabel,
    required this.baseValue,
    required this.finalLabel,
    required this.finalValue,
    this.thirdLabel,
    this.thirdValue,
  });
}

class CircularRingsChart extends StatelessWidget {
  final CircularRingsChartData data;
  final Color baseColor;
  final Color positiveColor;
  final Color negativeColor;
  final Color thirdColor;

  const CircularRingsChart({
    super.key,
    required this.data,
    this.baseColor = AppColors.trustBlue,
    this.positiveColor = AppColors.successGreen,
    this.negativeColor = AppColors.dangerRed,
    this.thirdColor = AppColors.slate400,
  });

  @override
  Widget build(BuildContext context) {
    final double maxVal = math.max(
      math.max(data.baseValue, data.finalValue),
      data.thirdValue ?? 0,
    );
    final double basePercentage = maxVal > 0 ? data.baseValue / maxVal : 0;
    final double finalPercentage = maxVal > 0 ? data.finalValue / maxVal : 0;
    final double thirdPercentage = (maxVal > 0 && data.thirdValue != null) ? data.thirdValue! / maxVal : 0;

    final double growth = data.finalValue - data.baseValue;
    final double growthPercentage = data.baseValue > 0 ? (growth / data.baseValue) * 100 : 0;
    final bool isPositive = growth >= 0;
    final Color outerColor = isPositive ? positiveColor : negativeColor;

    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Column(
        children: [
          // Main Chart Area
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Render concentric rings
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutBack,
                  builder: (context, animValue, _) {
                    return CustomPaint(
                      size: const Size(180, 180), // Increased from 140
                      painter: _RingsPainter(
                        basePercentage: basePercentage * animValue,
                        finalPercentage: finalPercentage * animValue,
                        thirdPercentage: thirdPercentage * animValue,
                        baseColor: baseColor,
                        outerColor: outerColor,
                        thirdColor: thirdColor,
                        strokeWidth: 12.0, // Increased for larger circles
                      ),
                    );
                  },
                ),

                // Center text - simplified
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${isPositive ? '+' : ''}${growthPercentage.toStringAsFixed(0)}%',
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: outerColor,
                        //fontSize: 24, // Increased for larger circles
                      ),
                    ),
                    Text(
                      'Growth',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.slate500,
                        fontSize: 10, // Slightly larger
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Structured Legend Area
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (data.thirdLabel != null)
                  _buildLegendItem(data.thirdLabel!, data.thirdValue!, thirdColor),
                _buildLegendItem(data.baseLabel, data.baseValue, baseColor),
                _buildLegendItem(data.finalLabel, data.finalValue, outerColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, double value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.slate500,
                fontSize: 9,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          _formatLegendValue(value),
          style: AppTypography.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.slate900,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _formatLegendValue(double value) {
    if (value >= 1000000) return '₦${(value / 1000000).toStringAsFixed(2)}M';
    if (value >= 1000) return '₦${(value / 1000).toStringAsFixed(0)}K';
    return '₦${value.toStringAsFixed(0)}';
  }
}

class _RingsPainter extends CustomPainter {
  final double basePercentage;
  final double finalPercentage;
  final double thirdPercentage;
  final Color baseColor;
  final Color outerColor;
  final Color thirdColor;
  final double strokeWidth;

  _RingsPainter({
    required this.basePercentage,
    required this.finalPercentage,
    required this.thirdPercentage,
    required this.baseColor,
    required this.outerColor,
    required this.thirdColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - strokeWidth / 2;
    final middleRadius = outerRadius - strokeWidth - 14.0; // Increased for breathing space
    final innerRadius = middleRadius - strokeWidth - 14.0; // Increased for breathing space

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

    final thirdPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = thirdColor;

    // Draw backgrounds
    canvas.drawCircle(center, outerRadius, bgPaint);
    canvas.drawCircle(center, middleRadius, bgPaint);
    if (thirdPercentage > 0) {
      canvas.drawCircle(center, innerRadius, bgPaint);
    }

    final double startAngle = -math.pi / 2;
    
    // Draw Inner Ring (Third Year / Earliest)
    if (thirdPercentage > 0) {
      final double innerSweep = 2 * math.pi * thirdPercentage;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle,
        innerSweep,
        false,
        thirdPaint,
      );
    }

    // Draw Middle Ring (Base Year / Previous)
    final double middleSweep = 2 * math.pi * basePercentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: middleRadius),
      startAngle,
      middleSweep,
      false,
      basePaint,
    );

    // Draw Outer Ring (Latest Year)
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
        oldDelegate.thirdPercentage != thirdPercentage ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.outerColor != outerColor ||
        oldDelegate.thirdColor != thirdColor;
  }
}
