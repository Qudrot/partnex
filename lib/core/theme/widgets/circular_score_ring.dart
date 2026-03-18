import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

class CircularScoreRing extends StatelessWidget {
  final int score;
  final double size;

  const CircularScoreRing({
    super.key,
    required this.score,
    this.size = 180.0,
  });

  @override
  Widget build(BuildContext context) {
    Color activeColor;
    if (score < 50) {
      activeColor = AppColors.dangerRed;
    } else if (score < 70) {
      activeColor = AppColors.warningOrange;
    } else {
      activeColor = AppColors.successGreen;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ScoreRingPainter(
              score: score,
              activeColor: activeColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.toString(),
                style: AppTypography.textTheme.displayLarge?.copyWith(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate900,
                  height: 1.1,
                ),
              ),
              Text(
                'out of 100',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.trustBlue.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                  fontSize: size * 0.08,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final int score;
  final Color activeColor;

  _ScoreRingPainter({
    required this.score,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    final strokeWidth = size.width * 0.08;

    final backgroundPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = AppColors.neutralWhite
      ..style = PaintingStyle.fill;

    // Draw the 3 background segments
    // We break the 360 degrees into 3 parts, with small gaps
    final startAngle = -math.pi * 1.5; // Start from top (-90 degrees)
    final sweepAngle = (math.pi * 2) / 3;
    final gap = 0.1; // small gap in radians
    final segmentSweep = sweepAngle - gap;

    for (int i = 0; i < 3; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + (i * sweepAngle) + (gap / 2),
        segmentSweep,
        false,
        backgroundPaint,
      );
    }

    // Determine how much of the ring is active based on score
    // Score is 0-100, maps to 0 to 3 sweeps
    // Just draw a single continuous arc over the background segments for the filled portion
    final fillSweep = (score / 100) * (math.pi * 2);
    final adjustedFillSweep = math.max(0.01, fillSweep); // Ensure a tiny dot at least

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      adjustedFillSweep,
      false,
      activePaint,
    );

    // Draw the dot at the end
    final currentAngle = startAngle + fillSweep;
    final dotCenter = Offset(
      center.dx + radius * math.cos(currentAngle),
      center.dy + radius * math.sin(currentAngle),
    );

    // Subtle dark shadow for the dot
    canvas.drawCircle(
      dotCenter,
      strokeWidth / 2 - 2,
      Paint()
        ..color = AppColors.slate900.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    canvas.drawCircle(dotCenter, strokeWidth / 2 - 3, activePaint);
    canvas.drawCircle(dotCenter, strokeWidth / 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.activeColor != activeColor;
  }
}
