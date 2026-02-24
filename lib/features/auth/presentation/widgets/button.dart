import 'package:flutter/material.dart';
import 'package:partnest/core/theme/app_colors.dart';
import 'package:partnest/core/theme/app_typography.dart';
import 'package:partnest/core/constants/app_spacing.dart';
import 'package:partnest/core/constants/app_enums.dart';

/// Partnex Button Widget
/// 
/// A versatile button component supporting multiple variants and sizes.
/// Provides consistent styling and interaction feedback.
/// 
/// Usage:
/// ```dart
/// PartnerButton(
///   variant: ButtonVariant.primary,
///   size: ButtonSize.medium,
///   label: 'Submit',
///   onPressed: () => print('Pressed'),
///   icon: Icons.send,
/// )
/// ```
class PartnerButton extends StatefulWidget {
  final AppEnums.ButtonVariant variant;
  final AppEnums.ButtonSize size;
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final bool fullWidth;
  final EdgeInsets? padding;
  
  const PartnerButton({
    Key? key,
    this.variant = AppEnums.ButtonVariant.primary,
    this.size = AppEnums.ButtonSize.medium,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.fullWidth = true,
    this.padding,
  }) : super(key: key);
  
  @override
  State<PartnerButton> createState() => _PartnerButtonState();
}

class _PartnerButtonState extends State<PartnerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// Get button colors based on variant
  Map<String, Color> _getColors() {
    switch (widget.variant) {
      case AppEnums.ButtonVariant.primary:
        return {
          'bg': AppColors.brand,
          'text': AppColors.ink000,
        };
      case AppEnums.ButtonVariant.positive:
        return {
          'bg': AppColors.positive,
          'text': AppColors.ink000,
        };
      case AppEnums.ButtonVariant.outline:
        return {
          'bg': Colors.transparent,
          'text': AppColors.ink700,
          'border': AppColors.ink200,
        };
      case AppEnums.ButtonVariant.ghost:
        return {
          'bg': AppColors.ink100,
          'text': AppColors.ink700,
        };
      case AppEnums.ButtonVariant.danger:
        return {
          'bg': AppColors.criticalLt,
          'text': AppColors.critical,
          'border': AppColors.criticalLt,
        };
      case AppEnums.ButtonVariant.dark:
        return {
          'bg': AppColors.ink900,
          'text': AppColors.ink000,
        };
      case AppEnums.ButtonVariant.ghostDark:
        return {
          'bg': Colors.transparent,
          'text': Colors.white.withOpacity(0.8),
          'border': Colors.white.withOpacity(0.14),
        };
    }
  }
  
  /// Get padding based on size
  EdgeInsets _getPadding() {
    switch (widget.size) {
      case AppEnums.ButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        );
      case AppEnums.ButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 13,
        );
      case AppEnums.ButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        );
    }
  }
  
  /// Get border radius based on size
  double _getBorderRadius() {
    switch (widget.size) {
      case AppEnums.ButtonSize.small:
        return AppSpacing.radiusMd;
      case AppEnums.ButtonSize.medium:
        return AppSpacing.radiusLg;
      case AppEnums.ButtonSize.large:
        return AppSpacing.radiusLg;
    }
  }
  
  /// Get font size based on size
  double _getFontSize() {
    switch (widget.size) {
      case AppEnums.ButtonSize.small:
        return 13;
      case AppEnums.ButtonSize.medium:
        return 15;
      case AppEnums.ButtonSize.large:
        return 16;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final backgroundColor = colors['bg'] as Color;
    final textColor = colors['text'] as Color;
    final borderColor = colors['border'] as Color?;
    
    final padding = widget.padding ?? _getPadding();
    final borderRadius = _getBorderRadius();
    final fontSize = _getFontSize();
    
    final isDisabled = widget.isLoading || !widget.isEnabled;
    final opacity = isDisabled ? 0.45 : 1.0;
    
    return SizedBox(
      width: widget.fullWidth ? double.infinity : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : widget.onPressed,
          onTapDown: (_) {
            _animationController.forward();
          },
          onTapUp: (_) {
            _animationController.reverse();
          },
          onTapCancel: () {
            _animationController.reverse();
          },
          borderRadius: BorderRadius.circular(borderRadius),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.98).animate(
              CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(opacity),
                borderRadius: BorderRadius.circular(borderRadius),
                border: borderColor != null
                    ? Border.all(
                        color: borderColor.withOpacity(opacity),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  else
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.01,
                        color: textColor.withOpacity(opacity),
                      ),
                    ),
                  if (widget.icon != null && !widget.isLoading) ...[
                    SizedBox(width: AppSpacing.iconTextGap),
                    Icon(
                      widget.icon,
                      size: 15,
                      color: textColor.withOpacity(opacity),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Button Group Widget
/// 
/// Displays multiple buttons in a horizontal layout.
class ButtonGroup extends StatelessWidget {
  final List<ButtonGroupItem> buttons;
  final MainAxisAlignment mainAxisAlignment;
  final double spacing;
  
  const ButtonGroup({
    Key? key,
    required this.buttons,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.spacing = 12,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          Expanded(
            flex: buttons[i].flex,
            child: PartnerButton(
              variant: buttons[i].variant,
              size: buttons[i].size,
              label: buttons[i].label,
              onPressed: buttons[i].onPressed,
              icon: buttons[i].icon,
              isLoading: buttons[i].isLoading,
              isEnabled: buttons[i].isEnabled,
              fullWidth: true,
            ),
          ),
          if (i < buttons.length - 1)
            SizedBox(width: spacing),
        ],
      ],
    );
  }
}

/// Button Group Item Data Model
class ButtonGroupItem {
  final AppEnums.ButtonVariant variant;
  final AppEnums.ButtonSize size;
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final int flex;
  
  ButtonGroupItem({
    this.variant = AppEnums.ButtonVariant.primary,
    this.size = AppEnums.ButtonSize.medium,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.flex = 1,
  });
}
