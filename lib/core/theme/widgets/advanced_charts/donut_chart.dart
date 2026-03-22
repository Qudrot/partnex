import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'dart:math' as math;

class DonutChart extends StatelessWidget {
  final double primaryPercentage;
  final double secondaryPercentage;
  final Color primaryColor;
  final Color secondaryColor;
  final String centerLabel;
  final String centerSubLabel;

  const DonutChart({
    super.key,
    required this.primaryPercentage,
    required this.secondaryPercentage,
    required this.primaryColor,
    required this.secondaryColor,
    required this.centerLabel,
    required this.centerSubLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(160, 160),
            painter: _DonutChartPainter(
              primaryPercentage: primaryPercentage,
              secondaryPercentage: secondaryPercentage,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerLabel,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary(context),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                centerSubLabel,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double primaryPercentage;
  final double secondaryPercentage;
  final Color primaryColor;
  final Color secondaryColor;

  _DonutChartPainter({
    required this.primaryPercentage,
    required this.secondaryPercentage,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    final double strokeWidth = 24.0;
    
    final Paint secondaryPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint primaryPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Draw secondary (e.g., profit)
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      -math.pi / 2,
      math.pi * 2,
      false,
      secondaryPaint,
    );

    // Draw primary (e.g., expenses)
    final double sweepAngle = (primaryPercentage / 100) * 2 * math.pi;
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      -math.pi / 2,
      sweepAngle,
      false,
      primaryPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.primaryPercentage != primaryPercentage;
  }
}
