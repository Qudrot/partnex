import 'package:flutter/material.dart';
import 'package:partnest/core/theme/app_colors.dart';
import 'package:partnest/core/constants/app_spacing.dart';
import 'package:partnest/core/constants/app_enums.dart';

/// Partnex Card Widget
/// 
/// A versatile card component for displaying content in elevated containers.
/// Supports multiple variants and customizable padding.
/// 
/// Usage:
/// ```dart
/// PartnerCard(
///   variant: CardVariant.elevated,
///   padding: EdgeInsets.all(16),
///   child: Text('Card content'),
/// )
/// ```
class PartnerCard extends StatelessWidget {
  final AppEnums.CardVariant variant;
  final EdgeInsets padding;
  final Widget child;
  final VoidCallback? onTap;
  final double elevation;
  final Color? backgroundColor;
  final Border? border;
  final BorderRadius? borderRadius;
  
  const PartnerCard({
    Key? key,
    this.variant = AppEnums.CardVariant.elevated,
    this.padding = const EdgeInsets.all(16),
    required this.child,
    this.onTap,
    this.elevation = 0,
    this.backgroundColor,
    this.border,
    this.borderRadius,
  }) : super(key: key);
  
  /// Get card styling based on variant
  Map<String, dynamic> _getVariantStyle() {
    switch (variant) {
      case AppEnums.CardVariant.elevated:
        return {
          'bg': AppColors.ink000,
          'border': Border.all(color: AppColors.ink200, width: 1.5),
          'elevation': 0,
        };
      case AppEnums.CardVariant.filled:
        return {
          'bg': AppColors.ink100,
          'border': null,
          'elevation': 0,
        };
      case AppEnums.CardVariant.outlined:
        return {
          'bg': Colors.transparent,
          'border': Border.all(color: AppColors.ink200, width: 1.5),
          'elevation': 0,
        };
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final style = _getVariantStyle();
    final br = borderRadius ?? BorderRadius.circular(AppSpacing.radiusXxl);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: br,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? style['bg'],
            border: border ?? style['border'],
            borderRadius: br,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Card Row Widget
/// 
/// A row within a card displaying a label and value with optional sub-text.
class CardRow extends StatelessWidget {
  final String label;
  final String value;
  final String? subLabel;
  final bool isLast;
  final bool isMonospace;
  final TextAlign valueAlign;
  final CrossAxisAlignment crossAxisAlignment;
  
  const CardRow({
    Key? key,
    required this.label,
    required this.value,
    this.subLabel,
    this.isLast = false,
    this.isMonospace = false,
    this.valueAlign = TextAlign.right,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.ink150,
                  width: 1,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.ink600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (subLabel != null) ...[
                  SizedBox(height: 2),
                  Text(
                    subLabel!,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.ink400,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Text(
            value,
            textAlign: valueAlign,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
              fontFamily: isMonospace ? 'JetBrains Mono' : 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }
}

/// Card Header Widget
/// 
/// A header section for cards with optional actions.
class CardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsets padding;
  
  const CardHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.ink150,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.ink400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: AppSpacing.lg),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Card Grid Widget
/// 
/// Displays multiple cards in a responsive grid layout.
class CardGrid extends StatelessWidget {
  final List<CardItem> items;
  final int crossAxisCount;
  final double spacing;
  final EdgeInsets padding;
  
  const CardGrid({
    Key? key,
    required this.items,
    this.crossAxisCount = 2,
    this.spacing = 16,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return PartnerCard(
          variant: item.variant,
          onTap: item.onTap,
          child: item.child,
        );
      },
    );
  }
}

/// Card Item Data Model
class CardItem {
  final AppEnums.CardVariant variant;
  final Widget child;
  final VoidCallback? onTap;
  
  CardItem({
    this.variant = AppEnums.CardVariant.elevated,
    required this.child,
    this.onTap,
  });
}

/// Metric Card Widget
/// 
/// A specialized card for displaying metrics with value and label.
class MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final bool isMonospace;
  final double? fontSize;
  
  const MetricCard({
    Key? key,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
    this.isMonospace = true,
    this.fontSize,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return PartnerCard(
      variant: AppEnums.CardVariant.elevated,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 24,
              color: iconColor ?? AppColors.brand,
            ),
            SizedBox(height: AppSpacing.md),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize ?? 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink900,
              fontFamily: isMonospace ? 'JetBrains Mono' : 'DM Sans',
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.ink400,
              letterSpacing: 0.05,
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
        ],
      ),
    );
  }
}
