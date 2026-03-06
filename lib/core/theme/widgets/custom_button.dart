import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';

enum ButtonVariant { primary, secondary, tertiary, danger, dangerOutline }

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
    this.icon,
  });

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
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            minimumSize: const Size(0, 44),
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
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: AppColors.neutralWhite,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  text,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: isDisabled ? AppColors.slate400 : AppColors.neutralWhite,
                    fontWeight: FontWeight.w600,
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
            backgroundColor: AppColors.slate100,
            side: const BorderSide(color: AppColors.slate200, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            minimumSize: const Size(0, 44),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.pressed) && !isDisabled) {
                return AppColors.slate100;
              }
              if (states.contains(WidgetState.hovered) && !isDisabled) {
                return AppColors.slate50;
              }
              return AppColors.slate100;
            }),
          ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: AppColors.slate900,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  text,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w600,
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            minimumSize: const Size(0, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.pressed) && !isDisabled) {
                return AppColors.slate100;
              }
              if (states.contains(WidgetState.hovered) && !isDisabled) {
                return AppColors.slate50;
              }
              return Colors.transparent;
            }),
          ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: AppColors.trustBlue,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  text,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.trustBlue,
                    fontWeight: FontWeight.w600,
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
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            minimumSize: const Size(0, 44),
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
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: AppColors.neutralWhite,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  text,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: AppColors.neutralWhite,
                    fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.symmetric(
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
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: AppColors.dangerRed,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  // If we use an Icon widget, we should try to tint it
                  Theme(
                    data: Theme.of(context).copyWith(
                      iconTheme: const IconThemeData(color: AppColors.dangerRed),
                    ),
                    child: icon!,
                  ),
                  const SizedBox(width: 8)
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
}
