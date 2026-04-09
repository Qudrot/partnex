import 'package:flutter/material.dart';
import 'dart:math' as math;

class AdvancedAreaChart extends StatelessWidget {
  final List<double> dataPoints;
  final Color statusColor;
  final double height;
  final bool showPoints;
  final bool showTrendLine;

  const AdvancedAreaChart({
    super.key,
    required this.dataPoints,
    required this.statusColor,
    this.height = 140,
    this.showPoints = true,
    this.showTrendLine = true,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _AdvancedAreaChartPainter(
          dataPoints: dataPoints,
          color: statusColor,
          showPoints: showPoints,
          showTrendLine: showTrendLine,
        ),
      ),
    );
  }
}

class _AdvancedAreaChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;
  final bool showPoints;
  final bool showTrendLine;

  _AdvancedAreaChartPainter({
    required this.dataPoints,
    required this.color,
    required this.showPoints,
    required this.showTrendLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final double maxVal = dataPoints.reduce(math.max);
    final double minVal = dataPoints.reduce(math.min);
    final double range = (maxVal - minVal).clamp(0.01, double.infinity);

    final double effectiveMax = maxVal + (range * 0.2);
    final double effectiveMin = math.max(0, minVal - (range * 0.1));
    final double effectiveRange = effectiveMax - effectiveMin;

    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint areaPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final double spacing = dataPoints.length > 1 ? size.width / (dataPoints.length - 1) : size.width;
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
        path.lineTo(x, y);
      }
    }

    if (dataPoints.length > 1) {
      for (int i = 1; i < points.length; i++) {
        areaPath.lineTo(points[i].dx, points[i].dy);
      }
      areaPath.lineTo(size.width, size.height);
      areaPath.lineTo(0, size.height);
      areaPath.close();
      canvas.drawPath(areaPath, areaPaint);
    }

    canvas.drawPath(path, linePaint);

    if (showTrendLine && points.length > 1) {
      final Paint trendPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      final double dashWidth = 5, dashSpace = 5;
      double distance = 0;
      final P1 = points.first;
      final P2 = points.last;
      bool draw = true;
      final Path dashPath = Path();

      final diffX = P2.dx - P1.dx;
      final diffY = P2.dy - P1.dy;
      final length = math.sqrt(diffX * diffX + diffY * diffY);

      while (distance < length) {
        final t1 = distance / length;
        final x1 = P1.dx + diffX * t1;
        final y1 = P1.dy + diffY * t1;
        
        distance += dashWidth;
        if (distance > length) distance = length;
        final t2 = distance / length;
        final x2 = P1.dx + diffX * t2;
        final y2 = P1.dy + diffY * t2;

        if (draw) {
          dashPath.moveTo(x1, y1);
          dashPath.lineTo(x2, y2);
        }
        draw = !draw;
        distance += dashSpace;
      }
      canvas.drawPath(dashPath, trendPaint);
    }

    if (showPoints) {
      final dotPaint = Paint()..color = color..style = PaintingStyle.fill;
      final whitePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;

      for (final point in points) {
        canvas.drawCircle(point, 6, dotPaint);
        canvas.drawCircle(point, 3, whitePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AdvancedAreaChartPainter oldDelegate) =>
      oldDelegate.dataPoints != dataPoints || oldDelegate.color != color;
}
