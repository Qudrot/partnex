import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'dart:math' as math;

class ColumnChartData {
  final String label;
  final double value;
  final Color? color;

  const ColumnChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

class ColumnChart extends StatelessWidget {
  final List<ColumnChartData> data;
  final double? averageLineValue;
  final Color defaultColor;

  const ColumnChart({
    super.key,
    required this.data,
    this.averageLineValue,
    this.defaultColor = AppColors.trustBlue,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final double maxVal = data.map((d) => d.value).reduce(math.max);
    final double minVal = data.map((d) => d.value).reduce(math.min);
    final double upperLimit = math.max(maxVal * 1.1, averageLineValue ?? 0);
    
    // Normalize logic requires setting a base axis if values are positive. Default to 0 base.
    final double range = upperLimit;

    return Container(
      height: 160,
      padding: const EdgeInsets.only(top: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double graphHeight = constraints.maxHeight - 24; // reserve space for text
          
          return Stack(
            children: [
              // Bars
              Positioned(
                top: 0,
                bottom: 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: data.map((d) {
                    final double frac = (d.value / range).clamp(0.0, 1.0);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FractionallySizedBox(
                          heightFactor: frac,
                          child: Container(
                            decoration: BoxDecoration(
                              color: d.color ?? defaultColor,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // Average Line
              if (averageLineValue != null)
                Positioned(
                  bottom: 24 + (graphHeight * (averageLineValue! / range).clamp(0.0, 1.0)),
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    color: AppColors.slate900.withValues(alpha: 0.5),
                  ),
                ),
                
              // Labels
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: data.map((d) {
                    return Expanded(
                      child: Text(
                        d.label,
                        textAlign: TextAlign.center,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.slate600,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
