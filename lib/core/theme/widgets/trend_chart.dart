import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'dart:math' as math;

enum ChartType { line, bar }

class TrendChart extends StatelessWidget {
  final List<double> dataPoints;
  final List<String>? labels;
  final Color barColor;
  final double height;
  final ChartType type;
  final bool showPoints;

  const TrendChart({
    super.key,
    required this.dataPoints,
    this.labels,
    this.barColor = AppColors.trustBlue,
    this.height = 120,
    this.type = ChartType.line,
    this.showPoints = true,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) return const SizedBox.shrink();

    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: CustomPaint(
        painter: _TrendChartPainter(
          dataPoints: dataPoints,
          color: barColor,
          type: type,
          showPoints: showPoints,
        ),
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;
  final ChartType type;
  final bool showPoints;

  _TrendChartPainter({
    required this.dataPoints,
    required this.color,
    required this.type,
    required this.showPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final double maxVal = dataPoints.reduce(math.max);
    final double minVal = dataPoints.reduce(math.min);
    final double range = (maxVal - minVal).clamp(0.01, double.infinity);
    
    // Normalize and add some padding to max value for visual headroom
    final double effectiveMax = maxVal + (range * 0.2);
    final double effectiveMin = math.max(0, minVal - (range * 0.1));
    final double effectiveRange = effectiveMax - effectiveMin;

    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.2),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    final double spacing = size.width / (dataPoints.length - 1);
    final Path path = Path();
    final Path areaPath = Path();

    List<Offset> points = [];

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = i * spacing;
      final double normalizedY = (dataPoints[i] - effectiveMin) / effectiveRange;
      final double y = size.height - (normalizedY * size.height);
      
      final offset = Offset(x, y);
      points.add(offset);

      if (i == 0) {
        path.moveTo(x, y);
        areaPath.moveTo(x, size.height);
        areaPath.lineTo(x, y);
      } else {
        // Curve construction using quadratic bezier for smoothness if more than 2 points
        if (dataPoints.length > 2) {
           final prev = points[i-1];
           final controlPoint = Offset(prev.dx + (offset.dx - prev.dx) / 2, prev.dy);
           path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, offset.dx, offset.dy);
        } else {
           path.lineTo(x, y);
        }
      }
    }

    // Close area path
    if (dataPoints.length > 1) {
       for (int i = 1; i < points.length; i++) {
         if (dataPoints.length > 2) {
            final prev = points[i-1];
            final controlPoint = Offset(prev.dx + (points[i].dx - prev.dx) / 2, prev.dy);
            areaPath.quadraticBezierTo(controlPoint.dx, controlPoint.dy, points[i].dx, points[i].dy);
         } else {
            areaPath.lineTo(points[i].dx, points[i].dy);
         }
       }
       areaPath.lineTo(size.width, size.height);
       areaPath.lineTo(0, size.height);
       areaPath.close();
       canvas.drawPath(areaPath, areaPaint);
    }

    canvas.drawPath(path, linePaint);

    if (showPoints) {
      final dotPaint = Paint()..color = color..style = PaintingStyle.fill;
      final whitePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;

      for (final point in points) {
        canvas.drawCircle(point, 5, dotPaint);
        canvas.drawCircle(point, 2.5, whitePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) => 
      oldDelegate.dataPoints != dataPoints || oldDelegate.color != color;
}
