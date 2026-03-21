import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

class HorizontalBarChart extends StatelessWidget {
  final double currentValue;
  final double benchmarkValue;
  final Color statusColor;
  final double maxValue;
  final String currentLabel;
  final bool showBenchmarkLabels;

  const HorizontalBarChart({
    super.key,
    required this.currentValue,
    required this.benchmarkValue,
    required this.statusColor,
    required this.maxValue,
    required this.currentLabel,
    this.showBenchmarkLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final normalizeMax = (currentValue > maxValue ? currentValue : maxValue);
    final benchmarkFraction = (benchmarkValue / normalizeMax).clamp(0.0, 1.0);
    final currentFraction = (currentValue / normalizeMax).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 32,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double barWidth = constraints.maxWidth * currentFraction;
              final bool fitsInside = barWidth > 60.0;
              
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background track
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Current Value Bar
                  FractionallySizedBox(
                    widthFactor: currentFraction,
                    child: Container(
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Benchmark Line
                  if (showBenchmarkLabels)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: benchmarkFraction,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 2,
                            color: AppColors.slate900,
                          ),
                        ),
                      ),
                    ),
                  // Current Value Label conditionally drawn inside or outside
                  Positioned(
                    left: fitsInside ? 0 : barWidth + 8.0,
                    top: 0,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.only(left: fitsInside ? 8.0 : 0.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          currentLabel,
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: fitsInside ? AppColors.neutralWhite : AppColors.slate900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ],
    );
  }
}
