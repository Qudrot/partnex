import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

class GaugeZone {
  final double startValue;
  final double endValue;
  final Color color;
  final String label;

  const GaugeZone({
    required this.startValue,
    required this.endValue,
    required this.color,
    required this.label,
  });
}

class GaugeChart extends StatelessWidget {
  final double currentValue;
  final double targetValue;
  final List<GaugeZone> zones;
  final Color markerColor;

  const GaugeChart({
    super.key,
    required this.currentValue,
    required this.targetValue,
    required this.zones,
    this.markerColor = AppColors.slate900,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          width: double.infinity,
          child: CustomPaint(
            painter: _HorizontalGaugePainter(
              currentValue: currentValue,
              targetValue: targetValue,
              zones: zones,
              markerColor: markerColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: zones.map((z) => _buildLegendItem(z.color, z.label)).toList(),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.slate600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _HorizontalGaugePainter extends CustomPainter {
  final double currentValue;
  final double targetValue;
  final List<GaugeZone> zones;
  final Color markerColor;

  _HorizontalGaugePainter({
    required this.currentValue,
    required this.targetValue,
    required this.zones,
    required this.markerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (zones.isEmpty) return;

    final double minVal = zones.first.startValue;
    final double maxVal = zones.last.endValue;
    final double range = maxVal - minVal;

    final double barHeight = 24.0;
    final double topOffset = 20.0;
    
    // Draw Zones
    for (int i = 0; i < zones.length; i++) {
      final zone = zones[i];
      final double startFraction = (zone.startValue - minVal) / range;
      final double endFraction = (zone.endValue - minVal) / range;

      final double startX = size.width * startFraction;
      final double endX = size.width * endFraction;

      final RRect rect = RRect.fromRectAndCorners(
        Rect.fromLTRB(startX, topOffset, endX, topOffset + barHeight),
        topLeft: i == 0 ? const Radius.circular(4) : Radius.zero,
        bottomLeft: i == 0 ? const Radius.circular(4) : Radius.zero,
        topRight: i == zones.length - 1 ? const Radius.circular(4) : Radius.zero,
        bottomRight: i == zones.length - 1 ? const Radius.circular(4) : Radius.zero,
      );

      final Paint zonePaint = Paint()
        ..color = zone.color.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(rect, zonePaint);
      
      // Draw tick line at right edge of zone if not last
      if (i < zones.length - 1) {
         canvas.drawLine(
           Offset(endX, topOffset - 4),
           Offset(endX, topOffset + barHeight),
           Paint()..color = AppColors.slate300..strokeWidth = 1,
         );
      }
    }

    // Draw Target Line
    final double targetFraction = ((targetValue - minVal) / range).clamp(0.0, 1.0);
    final double targetX = size.width * targetFraction;
    
    canvas.drawLine(
      Offset(targetX, topOffset - 8),
      Offset(targetX, topOffset + barHeight + 4),
      Paint()
        ..color = AppColors.slate700
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // Draw Current Value Marker (Diamond Shape)
    final double currentFraction = ((currentValue - minVal) / range).clamp(0.0, 1.0);
    final double currentX = size.width * currentFraction;

    final Path diamondPath = Path();
    final double dSize = 6.0;
    diamondPath.moveTo(currentX, topOffset + barHeight / 2 - dSize);
    diamondPath.lineTo(currentX + dSize, topOffset + barHeight / 2);
    diamondPath.lineTo(currentX, topOffset + barHeight / 2 + dSize);
    diamondPath.lineTo(currentX - dSize, topOffset + barHeight / 2);
    diamondPath.close();

    canvas.drawPath(diamondPath, Paint()..color = markerColor);

    // Text for Target (above)
    final TextPainter tpTarget = TextPainter(
      text: TextSpan(
        text: 'Target',
        style: AppTypography.textTheme.labelSmall?.copyWith(color: AppColors.slate700, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    tpTarget.layout();
    tpTarget.paint(canvas, Offset(targetX - tpTarget.width / 2, 0));
  }

  @override
  bool shouldRepaint(covariant _HorizontalGaugePainter oldDelegate) {
    return oldDelegate.currentValue != currentValue;
  }
}
