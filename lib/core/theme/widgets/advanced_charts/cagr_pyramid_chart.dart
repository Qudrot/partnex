import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:intl/intl.dart';

class CAGRPyramidData {
  final double baseRevenue;
  final double year2Revenue;

  const CAGRPyramidData({
    required this.baseRevenue,
    required this.year2Revenue,
  });
}

class CAGRPyramidChart extends StatelessWidget {
  final CAGRPyramidData data;
  final Color baseColor;
  final Color positiveColor;
  final Color positiveLightColor;
  final Color negativeColor;
  final Color negativeLightColor;

  const CAGRPyramidChart({
    super.key,
    required this.data,
    this.baseColor = AppColors.slate400,
    this.positiveColor = AppColors.successGreen,
    this.positiveLightColor = const Color(0xFF34D399),
    this.negativeColor = AppColors.dangerRed,
    this.negativeLightColor = const Color(0xFFF87171),
  });

  @override
  Widget build(BuildContext context) {
    final double multiplier = data.baseRevenue > 0 ? data.year2Revenue / data.baseRevenue : 1.0;
    final bool isPositive = multiplier >= 1.0;
    final double cagr = data.baseRevenue > 0 ? ((data.year2Revenue - data.baseRevenue) / data.baseRevenue) * 100 : 0.0;
    
    final double growthY2 = data.year2Revenue - data.baseRevenue;
    final double projectedY3 = data.year2Revenue * multiplier;
    final double growthY3 = projectedY3 - data.year2Revenue;

    final double absBase = data.baseRevenue.abs();
    final double absY2 = growthY2.abs();
    final double absY3 = growthY3.abs();
    final double totalAbs = absBase + absY2 + absY3;

    final List<_PyramidLayerData> layers = [
      _PyramidLayerData(
        label: 'Year 3 (Projected)',
        value: growthY3,
        absoluteValue: absY3,
        percentage: totalAbs > 0 ? (absY3 / totalAbs) * 100 : 0,
        color: isPositive ? positiveLightColor : negativeLightColor,
        isBase: false,
      ),
      _PyramidLayerData(
        label: 'Year 2 (Growth)',
        value: growthY2,
        absoluteValue: absY2,
        percentage: totalAbs > 0 ? (absY2 / totalAbs) * 100 : 0,
        color: isPositive ? positiveColor : negativeColor,
        isBase: false,
      ),
      _PyramidLayerData(
        label: 'Year 1 (Base Year)',
        value: data.baseRevenue,
        absoluteValue: absBase,
        percentage: totalAbs > 0 ? (absBase / totalAbs) * 100 : 0,
        color: baseColor,
        isBase: true,
      ),
    ];

    final formatCurrency = NumberFormat('#,##0.00', 'en_US');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Pyramid Graphic
          SizedBox(
            height: 240,
            width: double.infinity,
            child: CustomPaint(
              painter: _PyramidPainter(layers: layers),
            ),
          ),
          const SizedBox(height: 32),
          
          // Composition Breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Growth Composition:',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 12),
                ...layers.reversed.map((layer) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: layer.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          layer.label,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.slate600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${layer.isBase ? '' : (layer.value >= 0 ? '+' : '')}₦${formatCurrency.format(layer.value / 1000000)}M (${layer.percentage.toStringAsFixed(1)}%)',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.slate900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.slate200),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CAGR: ${cagr.toStringAsFixed(2)}%',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.slate600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          isPositive ? '↗ ' : '↘ ',
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: isPositive ? AppColors.successGreen : AppColors.dangerRed,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          isPositive ? 'Accelerating' : 'Decelerating',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: isPositive ? AppColors.successGreen : AppColors.dangerRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PyramidLayerData {
  final String label;
  final double value;
  final double absoluteValue;
  final double percentage;
  final Color color;
  final bool isBase;

  const _PyramidLayerData({
    required this.label,
    required this.value,
    required this.absoluteValue,
    required this.percentage,
    required this.color,
    required this.isBase,
  });
}

class _PyramidPainter extends CustomPainter {
  final List<_PyramidLayerData> layers;

  _PyramidPainter({required this.layers});

  @override
  void paint(Canvas canvas, Size size) {
    if (layers.isEmpty) return;

    final double width = size.width;
    final double height = size.height;
    final double topWidth = 80.0;
    final double baseWidth = width * 0.8; // 80% of container width at the base
    final double centerX = width / 2;

    double currentY = 0; // Starts from top (Year 3)
    final formatCurrency = NumberFormat('#,##0.00', 'en_US');

    // To compute heights properly, we note layers are ordered from top to bottom
    // Top = Year 3, Middle = Year 2, Bottom = Base.
    
    // Total absolute value to calculate proportional heights
    final double totalAbs = layers.fold(0, (sum, layer) => sum + layer.absoluteValue);

    // Draw layers from Top (y=0) to Bottom (y=height)
    for (int i = 0; i < layers.length; i++) {
      final layer = layers[i];
      final double layerHeightRatio = totalAbs > 0 ? layer.absoluteValue / totalAbs : 1 / layers.length;
      
      // Ensure minimum height for visibility
      final double minHeightRatio = 0.15;
      double adjustedRatio = layerHeightRatio;
      if (adjustedRatio < minHeightRatio) adjustedRatio = minHeightRatio;
      
      // We must re-normalize heights if we adjusted for minimums, but for simplicity we'll just draw them directly if we scale the total height.
      // A better way is to just let the math dictate it unless it's extremely small.
      final double layerHeight = height * layerHeightRatio;

      final double nextY = currentY + layerHeight;

      // Calculate trapezoid widths at currentY and nextY
      // y=0 is topWidth, y=height is baseWidth.
      final double currentLayerTopWidth = topWidth + (baseWidth - topWidth) * (currentY / height);
      final double currentLayerBottomWidth = topWidth + (baseWidth - topWidth) * (nextY / height);

      final Path path = Path()
        ..moveTo(centerX - currentLayerTopWidth / 2, currentY)
        ..lineTo(centerX + currentLayerTopWidth / 2, currentY)
        ..lineTo(centerX + currentLayerBottomWidth / 2, nextY)
        ..lineTo(centerX - currentLayerBottomWidth / 2, nextY)
        ..close();

      final Paint fillPaint = Paint()
        ..color = layer.color
        ..style = PaintingStyle.fill;

      final Paint strokePaint = Paint()
        ..color = AppColors.neutralWhite
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      // Draw shadow
      canvas.drawShadow(path, Colors.black.withValues(alpha: 0.1), 2.0, true);
      
      // Draw Fill
      canvas.drawPath(path, fillPaint);
      
      // Draw Stroke separation
      canvas.drawPath(path, strokePaint);

      // Draw Text inside Layer
      final TextPainter labelPainter = TextPainter(
        text: TextSpan(
          text: layer.label.split(' ').first, // 'Year 3'
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      
      final TextPainter valuePainter = TextPainter(
        text: TextSpan(
          text: '${layer.isBase ? '' : (layer.value >= 0 ? '+' : '')}₦${formatCurrency.format(layer.value / 1000000)}M',
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      labelPainter.layout(maxWidth: currentLayerBottomWidth);
      valuePainter.layout(maxWidth: currentLayerBottomWidth);

      final double textMidY = currentY + layerHeight / 2;
      
      labelPainter.paint(
        canvas,
        Offset(centerX - labelPainter.width / 2, textMidY - labelPainter.height / 2 - 8),
      );
      valuePainter.paint(
        canvas,
        Offset(centerX - valuePainter.width / 2, textMidY - valuePainter.height / 2 + 6),
      );

      currentY = nextY;
    }
  }

  @override
  bool shouldRepaint(covariant _PyramidPainter oldDelegate) => true;
}
