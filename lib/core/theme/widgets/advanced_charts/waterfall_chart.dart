import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'dart:math' as math;

class WaterfallDataPoint {
  final String label;
  final double value;

  const WaterfallDataPoint({required this.label, required this.value});
}

class WaterfallChart extends StatelessWidget {
  final List<WaterfallDataPoint> data;
  final Color baseColor;
  final Color positiveColor;
  final Color negativeColor;

  const WaterfallChart({
    super.key,
    required this.data,
    this.baseColor = AppColors.trustBlue,
    this.positiveColor = AppColors.successGreen,
    this.negativeColor = AppColors.dangerRed,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return const SizedBox.shrink();

    // Prepare segments: Base -> Growth -> Base -> Growth -> ...
    List<_WaterfallSegment> segments = [];
    double currentBase = data[0].value;

    segments.add(_WaterfallSegment(
      label: data[0].label,
      startValue: 0,
      endValue: currentBase,
      isBase: true,
      color: baseColor,
    ));

    for (int i = 1; i < data.length; i++) {
      final double nextValue = data[i].value;
      final double growth = nextValue - currentBase;

      // Growth segment
      segments.add(_WaterfallSegment(
        label: 'Growth',
        startValue: currentBase,
        endValue: nextValue,
        isBase: false,
        color: growth >= 0 ? positiveColor : negativeColor,
      ));

      // Next Base segment
      segments.add(_WaterfallSegment(
        label: data[i].label,
        startValue: 0,
        endValue: nextValue,
        isBase: true,
        color: baseColor,
      ));

      currentBase = nextValue;
    }

    final double maxVal = segments.map((s) => math.max(s.startValue, s.endValue)).reduce(math.max);
    final double minVal = segments.map((s) => math.min(s.startValue, s.endValue)).reduce(math.min);
    final double range = math.max(maxVal * 1.2, 1.0); // 20% headroom
    
    // Y-axis minimum is 0 for revenue mostly
    final double effectiveMin = math.min(0.0, minVal);
    final double effectiveRange = range - effectiveMin;

    return Container(
      height: 240,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double h = constraints.maxHeight - 24; // 24 for bottom labels
          final double w = constraints.maxWidth;
          // Improved UX: Fixed gap size for bolder bars
          final double spacing = 16.0;
          final double totalSpacing = spacing * (segments.length - 1);
          final double barWidth = math.max((w - totalSpacing) / segments.length, 20.0);

          return Stack(
            children: [
              // Connectors & Bars
              ...List.generate(segments.length, (index) {
                final seg = segments[index];
                final double leftOffset = index * (barWidth + spacing);
                
                final double topVal = math.max(seg.startValue, seg.endValue);
                final double bottomVal = math.min(seg.startValue, seg.endValue);
                
                final double topFrac = (topVal - effectiveMin) / effectiveRange;
                final double bottomFrac = (bottomVal - effectiveMin) / effectiveRange;
                
                final double barTop = h - (topFrac * h);
                final double barBottom = h - (bottomFrac * h);
                final double barH = math.max(barBottom - barTop, 4.0); // Min 4px height

                Widget connector = const SizedBox.shrink();
                if (index > 0) {
                  final double connectFrac = (seg.startValue - effectiveMin) / effectiveRange;
                  final double connectY = h - (connectFrac * h);
                  
                  connector = Positioned(
                    left: leftOffset - spacing,
                    top: connectY,
                    width: spacing,
                    height: 1,
                    child: Container(color: AppColors.slate300),
                  );
                }

                // Data label value
                final double displayVal = seg.endValue - seg.startValue;
                final String labelText = seg.isBase 
                   ? '₦${(seg.endValue/1000000).toStringAsFixed(1)}M'
                   : '${displayVal >= 0 ? '+' : ''}₦${(displayVal/1000000).toStringAsFixed(1)}M';

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    connector,
                    Positioned(
                      left: leftOffset,
                      top: barTop,
                      width: barWidth,
                      height: barH,
                      child: Container(
                        decoration: BoxDecoration(
                          color: seg.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    // Value Label above the bar
                    Positioned(
                      left: leftOffset - barWidth/2,
                      width: barWidth * 2,
                      top: barTop - 20,
                      child: Text(
                        labelText,
                        textAlign: TextAlign.center,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          fontSize: 12, // Larger bolder font
                          fontWeight: FontWeight.w700,
                          color: seg.color,
                        ),
                      ),
                    ),
                    // Bottom X-axis label
                    Positioned(
                      left: leftOffset - 10,
                      width: barWidth + 20,
                      bottom: -24,
                      child: Text(
                        seg.label,
                        textAlign: TextAlign.center,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          fontSize: 12, // Clearer x-axis text
                          color: AppColors.slate600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _WaterfallSegment {
  final String label;
  final double startValue;
  final double endValue;
  final bool isBase;
  final Color color;

  _WaterfallSegment({
    required this.label,
    required this.startValue,
    required this.endValue,
    required this.isBase,
    required this.color,
  });
}
