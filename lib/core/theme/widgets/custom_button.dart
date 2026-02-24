import 'package:flutter/material.dart';
import 'package:partnest/core/theme/app_colors.dart';
import 'package:partnest/core/theme/app_typography.dart';

enum ButtonVariant { primary, secondary, tertiary, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
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
    }
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.trustBlue,
        disabledBackgroundColor: AppColors.slate400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        elevation: 0,
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return AppColors.slate400;
            }
            if (states.contains(MaterialState.pressed)) {
              return AppColors.trustBlueActive;
            }
            if (states.contains(MaterialState.hovered)) {
              return AppColors.trustBlueHover;
            }
            return AppColors.trustBlue;
          },
        ),
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
          : Text(
              text,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: isDisabled ? AppColors.slate600 : AppColors.neutralWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.slate100,
        side: const BorderSide(color: AppColors.slate200, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered) && !isDisabled) {
              return AppColors.slate50;
            }
            return AppColors.slate100;
          },
        ),
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
          : Text(
              text,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.slate900,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildTertiaryButton(BuildContext context) {
    return TextButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered) && !isDisabled) {
              return AppColors.slate50;
            }
            return Colors.transparent;
          },
        ),
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
          : Text(
              text,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.trustBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }

  Widget _buildDangerButton(BuildContext context) {
    return ElevatedButton(
       onPressed: isDisabled || isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.dangerRed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        elevation: 0,
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
             if (states.contains(MaterialState.disabled)) {
              return AppColors.slate400;
            }
            if (states.contains(MaterialState.hovered)) {
              return AppColors.dangerRedHover;
            }
            return AppColors.dangerRed;
          },
        ),
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
          : Text(
              text,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.neutralWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
