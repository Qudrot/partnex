import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

class GrowthMultiplierData {
  final double baseRevenue;
  final double finalRevenue;
  final String baseLabel;
  final String finalLabel;
  final double cagr;
  final double multiplier;
  
  const GrowthMultiplierData({
    required this.baseRevenue,
    required this.finalRevenue,
    required this.baseLabel,
    required this.finalLabel,
    required this.cagr,
    required this.multiplier,
  });
}

class GrowthMultiplierChart extends StatelessWidget {
  final GrowthMultiplierData data;
  final Color positiveColor;
  final Color negativeColor;

  const GrowthMultiplierChart({
    super.key,
    required this.data,
    this.positiveColor = AppColors.successGreen,
    this.negativeColor = AppColors.dangerRed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositive = data.multiplier >= 1.0;
    final Color mainColor = isPositive ? positiveColor : negativeColor;
    
    // Projection for next year if sustained
    final double projected = data.finalRevenue * data.multiplier;

    return Container(
      width: double.infinity,
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
            'Base Revenue: ₦${(data.baseRevenue / 1000000).toStringAsFixed(2)}M',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.slate600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          
          // Visual Equation Builder
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Base Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.slate300),
                ),
                child: Column(
                  children: [
                    Text(
                      '₦${(data.baseRevenue / 1000000).toStringAsFixed(2)}M',
                      style: AppTypography.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.baseLabel,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Multiplier Symbol & Value
              Text(
                '×',
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: AppColors.slate400,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${data.multiplier.toStringAsFixed(2)}',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: mainColor,
                ),
              ),
              const SizedBox(width: 8),
              
              // Equals Symbol
              Text(
                '=',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: AppColors.slate400,
                ),
              ),
              const SizedBox(width: 12),
              
              // Final Box Component
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₦${(data.finalRevenue / 1000000).toStringAsFixed(2)}M',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: mainColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.finalLabel,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          Divider(color: AppColors.slate200, height: 1),
          const SizedBox(height: 16),
          
          Text(
            'What this means:',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 8),
          
          // Bullet points
          _buildBulletPoint('Revenue multiplied by ${data.multiplier.toStringAsFixed(2)}x in one year'),
          _buildBulletPoint('If sustained: ₦${(projected / 1000000).toStringAsFixed(2)}M in Year 3 (${data.multiplier.toStringAsFixed(2)}x again)'),
          _buildBulletPoint(isPositive ? 'Exponential growth trajectory' : 'Exponential decay trajectory'),
          
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.slate500,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.slate600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
