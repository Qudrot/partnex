import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

class TimelineMilestone {
  final int year;
  final String label;

  const TimelineMilestone({
    required this.year,
    required this.label,
  });
}

class TimelineChart extends StatelessWidget {
  final int currentYear;
  final Color statusColor;
  final List<TimelineMilestone> milestones;

  const TimelineChart({
    super.key,
    required this.currentYear,
    required this.statusColor,
    required this.milestones,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: CustomPaint(
        painter: _TimelinePainter(
          currentYear: currentYear,
          statusColor: statusColor,
          milestones: milestones,
        ),
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final int currentYear;
  final Color statusColor;
  final List<TimelineMilestone> milestones;

  _TimelinePainter({
    required this.currentYear,
    required this.statusColor,
    required this.milestones,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (milestones.isEmpty) return;

    final int minYear = milestones.first.year;
    final int maxYear = milestones.last.year;
    final double range = (maxYear - minYear).toDouble();

    final double lineY = size.height / 2 - 10;
    
    // Draw background line
    canvas.drawLine(
      Offset(10, lineY),
      Offset(size.width - 10, lineY),
      Paint()
        ..color = AppColors.slate300
        ..strokeWidth = 2,
    );

    // Draw active line up to current
    final double currentFraction = ((currentYear - minYear) / range).clamp(0.0, 1.0);
    final double currentX = 10 + (size.width - 20) * currentFraction;

    canvas.drawLine(
      Offset(10, lineY),
      Offset(currentX, lineY),
      Paint()
        ..color = statusColor
        ..strokeWidth = 3,
    );

    // Draw milestones
    for (int i = 0; i < milestones.length; i++) {
      final m = milestones[i];
      final double mFraction = ((m.year - minYear) / range).clamp(0.0, 1.0);
      final double mX = 10 + (size.width - 20) * mFraction;

      final bool isPast = m.year <= currentYear;
      final bool isCurrent = m.year == currentYear;

      // Draw dot
      final Paint dotPaint = Paint()
        ..color = isCurrent ? statusColor : (isPast ? statusColor : AppColors.neutralWhite)
        ..style = PaintingStyle.fill;
        
      final Paint StrokePaint = Paint()
        ..color = isPast ? statusColor : AppColors.slate300
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(mX, lineY), 5, dotPaint);
      if (!isCurrent && !isPast) {
         canvas.drawCircle(Offset(mX, lineY), 5, StrokePaint);
      } else if (isCurrent) {
         // Highlight current
         canvas.drawCircle(Offset(mX, lineY), 8, Paint()..color = statusColor.withValues(alpha: 0.3)..style = PaintingStyle.fill);
      }

      // Draw label below
      if (m.label.isNotEmpty && (i % 2 == 0 || i == milestones.length - 1)) {
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: m.label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: isCurrent ? AppColors.slate900 : AppColors.slate500,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
              fontSize: 10,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(mX - tp.width / 2, lineY + 12));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) {
    return oldDelegate.currentYear != currentYear || oldDelegate.statusColor != statusColor;
  }
}
