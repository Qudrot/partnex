import 'package:flutter/material.dart';
import 'package:partnest/core/theme/app_colors.dart';
import 'package:partnest/core/theme/app_typography.dart';
import 'package:partnest/core/constants/app_spacing.dart';
import 'package:partnest/core/constants/app_enums.dart';

/// Partnex Badge Widget
/// 
/// A versatile badge component for displaying status, tags, and labels.
/// Always pairs color with an icon for accessibility.
/// 
/// Usage:
/// ```dart
/// Badge(
///   variant: BadgeVariant.positive,
///   size: BadgeSize.small,
///   icon: Icons.check,
///   label: 'Verified',
/// )
/// ```
class Badge extends StatelessWidget {
  final AppEnums.BadgeVariant variant;
  final AppEnums.BadgeSize size;
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  
  const Badge({
    Key? key,
    this.variant = AppEnums.BadgeVariant.gray,
    this.size = AppEnums.BadgeSize.small,
    this.icon,
    required this.label,
    this.onTap,
  }) : super(key: key);
  
  /// Get background and text colors based on variant
  Map<String, Color> _getColors() {
    switch (variant) {
      case AppEnums.BadgeVariant.brand:
        return {
          'bg': AppColors.brandLt,
          'text': AppColors.brand,
        };
      case AppEnums.BadgeVariant.positive:
        return {
          'bg': AppColors.positiveLt,
          'text': AppColors.positive,
        };
      case AppEnums.BadgeVariant.caution:
        return {
          'bg': AppColors.cautionLt,
          'text': AppColors.caution,
        };
      case AppEnums.BadgeVariant.critical:
        return {
          'bg': AppColors.criticalLt,
          'text': AppColors.critical,
        };
      case AppEnums.BadgeVariant.info:
        return {
          'bg': AppColors.infoLt,
          'text': AppColors.info,
        };
      case AppEnums.BadgeVariant.dark:
        return {
          'bg': AppColors.ink800,
          'text': AppColors.ink000,
        };
      case AppEnums.BadgeVariant.gray:
      default:
        return {
          'bg': AppColors.ink100,
          'text': AppColors.ink600,
        };
    }
  }
  
  /// Get padding based on size
  EdgeInsets _getPadding() {
    switch (size) {
      case AppEnums.BadgeSize.small:
        return EdgeInsets.symmetric(
          horizontal: AppSpacing.badgePaddingSmall,
          vertical: 2,
        );
      case AppEnums.BadgeSize.medium:
        return EdgeInsets.symmetric(
          horizontal: AppSpacing.badgePaddingMedium,
          vertical: 4,
        );
    }
  }
  
  /// Get font size based on size
  double _getFontSize() {
    switch (size) {
      case AppEnums.BadgeSize.small:
        return 11;
      case AppEnums.BadgeSize.medium:
        return 12;
    }
  }
  
  /// Get icon size based on size
  double _getIconSize() {
    switch (size) {
      case AppEnums.BadgeSize.small:
        return 9;
      case AppEnums.BadgeSize.medium:
        return 10;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final textColor = colors['text']!;
    
    return Container(
      padding: _getPadding(),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: _getIconSize(),
                color: textColor,
              ),
              SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: _getFontSize(),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.01,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge List Widget
/// 
/// Displays multiple badges in a horizontal scrollable list.
class BadgeList extends StatelessWidget {
  final List<BadgeItem> badges;
  final EdgeInsets padding;
  
  const BadgeList({
    Key? key,
    required this.badges,
    this.padding = const EdgeInsets.all(0),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (int i = 0; i < badges.length; i++) ...[
            Badge(
              variant: badges[i].variant,
              size: badges[i].size,
              icon: badges[i].icon,
              label: badges[i].label,
              onTap: badges[i].onTap,
            ),
            if (i < badges.length - 1)
              SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// Badge Item Data Model
class BadgeItem {
  final AppEnums.BadgeVariant variant;
  final AppEnums.BadgeSize size;
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  
  BadgeItem({
    this.variant = AppEnums.BadgeVariant.gray,
    this.size = AppEnums.BadgeSize.small,
    this.icon,
    required this.label,
    this.onTap,
  });
}
