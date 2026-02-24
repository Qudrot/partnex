import 'package:flutter/material.dart';
import 'package:partnest/core/theme/app_colors.dart';
import 'package:partnest/core/theme/app_typography.dart';
import 'package:partnest/core/constants/app_spacing.dart';
import 'package:partnest/core/constants/app_enums.dart';

/// Score Tier Information
class ScoreTierData {
  final String label;
  final IconData icon;
  final Color color;
  final String textColor;
  
  const ScoreTierData({
    required this.label,
    required this.icon,
    required this.color,
    this.textColor = '#fff',
  });
  
  factory ScoreTierData.fromScore(int score) {
    if (score >= 75) {
      return ScoreTierData(
        label: 'Strong',
        icon: Icons.check_circle,
        color: AppColors.positive,
      );
    } else if (score >= 60) {
      return ScoreTierData(
        label: 'Good',
        icon: Icons.trending_up,
        color: AppColors.brand,
      );
    } else if (score >= 40) {
      return ScoreTierData(
        label: 'Moderate',
        icon: Icons.warning,
        color: AppColors.caution,
      );
    } else {
      return ScoreTierData(
        label: 'Weak',
        icon: Icons.close_circle,
        color: AppColors.critical,
      );
    }
  }
}

/// Score Display Widget
/// 
/// Displays a credibility score with visual feedback.
/// Always pairs color with icon for accessibility.
/// 
/// Usage:
/// ```dart
/// ScoreDisplay(
///   score: 85,
///   size: ScoreDisplaySize.large,
/// )
/// ```
class ScoreDisplay extends StatelessWidget {
  final int score;
  final ScoreDisplaySize size;
  final bool showTier;
  final bool showPercentage;
  final VoidCallback? onTap;
  
  const ScoreDisplay({
    Key? key,
    required this.score,
    this.size = ScoreDisplaySize.medium,
    this.showTier = true,
    this.showPercentage = true,
    this.onTap,
  }) : super(key: key);
  
  /// Get display size configuration
  Map<String, dynamic> _getSizeConfig() {
    switch (size) {
      case ScoreDisplaySize.small:
        return {
          'scoreSize': 24.0,
          'labelSize': 10.0,
          'padding': AppSpacing.md,
        };
      case ScoreDisplaySize.medium:
        return {
          'scoreSize': 40.0,
          'labelSize': 12.0,
          'padding': AppSpacing.lg,
        };
      case ScoreDisplaySize.large:
        return {
          'scoreSize': 48.0,
          'labelSize': 16.0,
          'padding': AppSpacing.xl,
        };
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final tier = ScoreTierData.fromScore(score);
    final config = _getSizeConfig();
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: EdgeInsets.all(config['padding']),
        decoration: BoxDecoration(
          color: AppColors.ink000,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.ink200,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Score value
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: score.toString(),
                    style: TextStyle(
                      fontSize: config['scoreSize'],
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink900,
                      fontFamily: 'DM Sans',
                      letterSpacing: -0.04,
                    ),
                  ),
                  TextSpan(
                    text: '/100',
                    style: TextStyle(
                      fontSize: config['scoreSize'] * 0.35,
                      fontWeight: FontWeight.w400,
                      color: AppColors.ink300,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
            
            // Tier badge
            if (showTier) ...[
              SizedBox(height: AppSpacing.md),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: tier.color,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tier.icon,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      '${tier.label} Credibility',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.01,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Score Gauge Widget
/// 
/// Displays score as a circular progress indicator.
class ScoreGauge extends StatelessWidget {
  final int score;
  final double size;
  final bool animated;
  
  const ScoreGauge({
    Key? key,
    required this.score,
    this.size = 120,
    this.animated = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final tier = ScoreTierData.fromScore(score);
    final progress = score / 100;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.ink200,
                width: 8,
              ),
            ),
          ),
          
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: animated ? progress : 1.0,
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation<Color>(tier.color),
              backgroundColor: AppColors.ink150,
            ),
          ),
          
          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                score.toString(),
                style: TextStyle(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink900,
                  fontFamily: 'DM Sans',
                ),
              ),
              Text(
                tier.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tier.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Score Bar Widget
/// 
/// Displays score as a horizontal progress bar.
class ScoreBar extends StatelessWidget {
  final int score;
  final double height;
  final bool showLabel;
  final bool showValue;
  final bool animated;
  
  const ScoreBar({
    Key? key,
    required this.score,
    this.height = 8,
    this.showLabel = true,
    this.showValue = true,
    this.animated = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final tier = ScoreTierData.fromScore(score);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Credibility Score',
                style: AppTypography.labelSmall,
              ),
              if (showValue)
                Text(
                  '$score/100',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
        ],
        
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: height,
            backgroundColor: AppColors.ink150,
            valueColor: AlwaysStoppedAnimation<Color>(tier.color),
          ),
        ),
        
        // Tier label
        SizedBox(height: AppSpacing.sm),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: tier.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tier.icon,
                size: 12,
                color: tier.color,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                tier.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tier.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Score Comparison Widget
/// 
/// Compares current score with potential score.
class ScoreComparison extends StatelessWidget {
  final int currentScore;
  final int potentialScore;
  final String description;
  
  const ScoreComparison({
    Key? key,
    required this.currentScore,
    required this.potentialScore,
    required this.description,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final currentTier = ScoreTierData.fromScore(currentScore);
    final potentialTier = ScoreTierData.fromScore(potentialScore);
    
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.ink900,
            AppColors.ink800,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score Opportunity',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.07,
                      textTransform: TextTransform.uppercase,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Boost by up to +${potentialScore - currentScore} pts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.02,
                    ),
                  ),
                ],
              ),
              // Score comparison
              Column(
                children: [
                  Text(
                    '$currentScore→$potentialScore',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
              lineHeight: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Score Display Size Enum
enum ScoreDisplaySize {
  small,
  medium,
  large,
}
