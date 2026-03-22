import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

class CircularScoreRing extends StatelessWidget {
  final int score;
  final double size;
  final double? fontSizeOverride;

  const CircularScoreRing({
    super.key,
    required this.score,
    this.size = 180.0,
    this.fontSizeOverride,
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
                  fontSize: fontSizeOverride ?? size * 0.35,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                  height: 1.1,
                ),
              ),
              if (size >= 100)
                Text(
                  'out of 100',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context).withValues(alpha: 0.6),
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
    final radius = (size.width / 2) - 12;
    final strokeWidth = size.width * 0.085;

    // Background ring
    final backgroundPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * 2 * math.pi;

    if (score > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }

    // Moving dot (only when score < 100)
    if (score < 100) {
      final angle = -math.pi / 2 + sweepAngle;
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      // Soft outer glow
      canvas.drawCircle(
        dotCenter,
        strokeWidth / 2 + 2,
        Paint()..color = activeColor.withValues(alpha: 0.25),
      );

      // Main dot
      canvas.drawCircle(
        dotCenter,
        strokeWidth / 2,
        Paint()..color = activeColor,
      );

      // Inner highlight
      canvas.drawCircle(
        dotCenter,
        strokeWidth / 3.5,
        Paint()..color = Colors.white,
      );
    }
    // When score == 100 → just a clean full ring (no dot, no checkmark)
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.activeColor != activeColor;
  }
}