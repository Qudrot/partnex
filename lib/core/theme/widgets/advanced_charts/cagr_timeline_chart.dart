import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'dart:ui' as ui;

/// A data point on the CAGR timeline
class CAGRTimelinePoint {
  final String yearLabel;  // "Year 1", "Year 2", "Year 3 (Proj)"
  final double revenue;    // absolute revenue value
  final double? growthRate; // nullable — null for base year
  final bool isProjected;

  const CAGRTimelinePoint({
    required this.yearLabel,
    required this.revenue,
    this.growthRate,
    this.isProjected = false,
  });
}

class CAGRTimelineChart extends StatefulWidget {
  final List<CAGRTimelinePoint> points;
  final Color positiveColor;
  final Color negativeColor;
  final Color projectedColor;
  final Color baseColor;

  const CAGRTimelineChart({
    super.key,
    required this.points,
    this.positiveColor = AppColors.successGreen,
    this.negativeColor = AppColors.dangerRed,
    this.projectedColor = const Color(0xFF34D399),
    this.baseColor = AppColors.trustBlue,
  });

  @override
  State<CAGRTimelineChart> createState() => _CAGRTimelineChartState();
}

class _CAGRTimelineChartState extends State<CAGRTimelineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    if (points.isEmpty) return const SizedBox.shrink();

    final double maxRevenue = points.map((p) => p.revenue).reduce((a, b) => a > b ? a : b);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bar chart + timeline area
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(points.length * 2 - 1, (i) {
                  // Odd indices are connectors between bars
                  if (i.isOdd) {
                    return _buildConnector(points[i ~/ 2], points[(i ~/ 2) + 1]);
                  }
                  final point = points[i ~/ 2];
                  final barHeight = maxRevenue > 0
                      ? (point.revenue / maxRevenue) * 120 * _animation.value
                      : 0.0;
                  
                  final Color barColor = point.isProjected
                      ? widget.projectedColor
                      : (i == 0
                          ? widget.baseColor
                          : (point.growthRate != null && point.growthRate! >= 0
                              ? widget.positiveColor
                              : widget.negativeColor));

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Growth rate badge above bar
                        if (point.growthRate != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (point.growthRate! >= 0 ? widget.positiveColor : widget.negativeColor).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${point.growthRate! >= 0 ? '+' : ''}${point.growthRate!.toStringAsFixed(1)}%',
                              style: AppTypography.textTheme.labelSmall?.copyWith(
                                color: point.growthRate! >= 0 ? widget.positiveColor : widget.negativeColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        // Revenue value label
                        Text(
                          _formatRevenue(point.revenue),
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.slate700,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        // Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                            boxShadow: [
                              BoxShadow(
                                color: barColor.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          // Dashed border for projected bar
                          child: point.isProjected
                              ? CustomPaint(
                                  painter: _DashedBorderPainter(color: barColor),
                                )
                              : null,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // Horizontal timeline with dots
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildTimelineRail(points),
            ),

            const SizedBox(height: 8),

            // Year labels row
            Row(
              children: List.generate(points.length * 2 - 1, (i) {
                if (i.isOdd) return const Expanded(child: SizedBox.shrink());
                final point = points[i ~/ 2];
                return Expanded(
                  child: Text(
                    point.yearLabel,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: point.isProjected ? AppColors.slate400 : AppColors.slate600,
                      fontWeight: FontWeight.w500,
                      fontSize: 9,
                      fontStyle: point.isProjected ? FontStyle.italic : FontStyle.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConnector(CAGRTimelinePoint from, CAGRTimelinePoint to) {
    return const SizedBox(
      width: 24,
    );
  }

  Widget _buildTimelineRail(List<CAGRTimelinePoint> points) {
    return SizedBox(
      height: 12,
      child: LayoutBuilder(builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, 12),
          painter: _TimelineRailPainter(
            pointCount: points.length,
            positiveColor: widget.positiveColor,
            projectedColor: widget.projectedColor,
            baseColor: widget.baseColor,
            isProjectedFlags: points.map((p) => p.isProjected).toList(),
          ),
        );
      }),
    );
  }

  String _formatRevenue(double value) {
    if (value >= 1000000) return '₦${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '₦${(value / 1000).toStringAsFixed(0)}K';
    return '₦${value.toStringAsFixed(0)}';
  }
}

class _TimelineRailPainter extends CustomPainter {
  final int pointCount;
  final Color positiveColor;
  final Color projectedColor;
  final Color baseColor;
  final List<bool> isProjectedFlags;

  _TimelineRailPainter({
    required this.pointCount,
    required this.positiveColor,
    required this.projectedColor,
    required this.baseColor,
    required this.isProjectedFlags,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pointCount < 2) return;
    
    final double lineY = size.height / 2;
    final double step = size.width / (pointCount - 1);

    // Draw connecting line segments
    for (int i = 0; i < pointCount - 1; i++) {
      final double x1 = i * step;
      final double x2 = (i + 1) * step;
      final bool dashed = isProjectedFlags.length > i + 1 && isProjectedFlags[i + 1];

      final Paint linePaint = Paint()
        ..color = dashed ? projectedColor.withValues(alpha: 0.5) : positiveColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      if (dashed) {
        const double dashWidth = 5;
        const double dashSpace = 3;
        double currentX = x1;
        while (currentX < x2) {
          canvas.drawLine(Offset(currentX, lineY), Offset((currentX + dashWidth).clamp(0, x2), lineY), linePaint);
          currentX += dashWidth + dashSpace;
        }
      } else {
        canvas.drawLine(Offset(x1, lineY), Offset(x2, lineY), linePaint);
      }
    }

    // Draw dots
    for (int i = 0; i < pointCount; i++) {
      final double x = i * step;
      final bool isProjected = isProjectedFlags.length > i && isProjectedFlags[i];
      final Color dotColor = i == 0
          ? baseColor
          : (isProjected ? projectedColor : positiveColor);

      // Glow
      canvas.drawCircle(Offset(x, lineY), 7, Paint()..color = dotColor.withValues(alpha: 0.15)..style = PaintingStyle.fill);
      // Main dot
      canvas.drawCircle(Offset(x, lineY), 4, Paint()..color = dotColor..style = PaintingStyle.fill);
      // White inner
      canvas.drawCircle(Offset(x, lineY), 2, Paint()..color = Colors.white..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineRailPainter oldDelegate) => false;
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    const double dashH = 6;
    const double gapH = 4;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, (y + dashH).clamp(0, size.height)), paint);
      canvas.drawLine(Offset(size.width, y), Offset(size.width, (y + dashH).clamp(0, size.height)), paint);
      y += dashH + gapH;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}
