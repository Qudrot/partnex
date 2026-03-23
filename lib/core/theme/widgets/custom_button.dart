import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';

enum ButtonVariant { primary, secondary, tertiary, danger, dangerOutline, dangerTertiary }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.icon,
  });

  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return _buildPrimaryButton(context);
      case ButtonVariant.secondary:
        return _buildSecondaryButton(context);
      case ButtonVariant.tertiary:
        return _buildTertiaryButton(context);
      case ButtonVariant.danger:
        return _buildDangerButton(context);
      case ButtonVariant.dangerOutline:
        return _buildDangerOutlineButton(context);
      case ButtonVariant.dangerTertiary:
        return _buildDangerTertiaryButton(context);
    }
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style:
          ElevatedButton.styleFrom(
            backgroundColor: AppColors.trustBlue,
            disabledBackgroundColor: AppColors.neutralGray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.smd,
              horizontal: AppSpacing.xl,
            ),
            minimumSize: const Size(0, AppSizes.buttonHeight),
            elevation: 0,
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.disabled)) {
                return AppColors.neutralGray;
              }
              if (states.contains(WidgetState.pressed)) {
                return AppColors.trustBlue.withValues(alpha: 0.8);
              }
              if (states.contains(WidgetState.hovered)) {
                return AppColors.trustBlue.withValues(alpha: 0.9);
              }
              return AppColors.trustBlue;
            }),
          ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                if (isLoading) ...[
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: variant == ButtonVariant.primary || variant == ButtonVariant.danger ? AppColors.neutralWhite : AppColors.trustBlue,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: _getTextColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style:
          OutlinedButton.styleFrom(
            backgroundColor: AppColors.background(context),
            side: BorderSide(color: AppColors.border(context), width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.smd,
              horizontal: AppSpacing.xl,
            ),
            minimumSize: const Size(0, AppSizes.buttonHeight),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.pressed) && !isDisabled) {
                return AppColors.border(context);
              }
              if (states.contains(WidgetState.hovered) && !isDisabled) {
                return AppColors.background(context).withValues(alpha: 0.8);
              }
              return AppColors.background(context);
            }),
          ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                if (isLoading) ...[
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: AppColors.textPrimary(context),
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildTertiaryButton(BuildContext context) {
    return TextButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style:
          TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.smd,
              horizontal: AppSpacing.xl,
            ),
            minimumSize: const Size(0, AppSizes.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.pressed) && !isDisabled) {
                return AppColors.background(context);
              }
              if (states.contains(WidgetState.hovered) && !isDisabled) {
                return AppColors.background(context).withValues(alpha: 0.5);
              }
              return Colors.transparent;
            }),
          ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                if (isLoading) ...[
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: AppColors.trustBlue,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.trustBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildDangerButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style:
          ElevatedButton.styleFrom(
            backgroundColor: AppColors.dangerRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.smd,
              horizontal: AppSpacing.xl,
            ),
            minimumSize: const Size(0, AppSizes.buttonHeight),
            elevation: 0,
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.disabled)) {
                return AppColors.neutralGray;
              }
              if (states.contains(WidgetState.pressed)) {
                return AppColors.dangerRed.withValues(alpha: 0.8);
              }
              if (states.contains(WidgetState.hovered)) {
                return AppColors.dangerRed.withValues(alpha: 0.9);
              }
              return AppColors.dangerRed;
            }),
          ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                if (isLoading) ...[
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: AppColors.neutralWhite,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      color: AppColors.neutralWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildDangerOutlineButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        side: const BorderSide(
          color: AppColors.dangerRed,
          width: AppSizes.borderMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.smd,
          horizontal: AppSpacing.xl,
        ),
        minimumSize: const Size(0, AppSizes.buttonHeight),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed) && !isDisabled) {
            return AppColors.dangerRed.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered) && !isDisabled) {
            return AppColors.dangerRed.withValues(alpha: 0.05);
          }
          return Colors.transparent;
        }),
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: isLoading
            ? const [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.dangerRed,
                    strokeWidth: 2,
                  ),
                )
              ]
            : [
                if (icon != null) ...[
                  Theme(
                    data: Theme.of(context).copyWith(
                      iconTheme: const IconThemeData(color: AppColors.dangerRed),
                    ),
                    child: icon!,
                  ),
                  const SizedBox(width: 8)
                ],
                Flexible(
                  child: Text(
                    text,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.dangerRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildDangerTertiaryButton(BuildContext context) {
    return TextButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.smd,
          horizontal: AppSpacing.xl,
        ),
        minimumSize: const Size(0, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed) && !isDisabled) {
            return AppColors.dangerRed.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered) && !isDisabled) {
            return AppColors.dangerRed.withValues(alpha: 0.05);
          }
          return Colors.transparent;
        }),
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: isLoading
            ? const [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.dangerRed,
                    strokeWidth: 2,
                  ),
                )
              ]
            : [
                if (icon != null) ...[
                  Theme(
                    data: Theme.of(context).copyWith(
                      iconTheme: const IconThemeData(color: AppColors.dangerRed),
                    ),
                    child: icon!,
                  ),
                  SizedBox(width: AppSpacing.sm)
                ],
                Text(
                  text,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.dangerRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
      ),
    );
  }

  Color _getTextColor(BuildContext context) {
    if (isDisabled) return AppColors.slate400;
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.danger:
        return AppColors.neutralWhite;
      case ButtonVariant.secondary:
        return AppColors.textPrimary(context);
      case ButtonVariant.tertiary:
        return AppColors.trustBlue;
      case ButtonVariant.dangerOutline:
      case ButtonVariant.dangerTertiary:
        return AppColors.dangerRed;
    }
  }
}
