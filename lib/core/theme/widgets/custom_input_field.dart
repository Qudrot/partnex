import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final String? errorText;
  final bool obscureText;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? maxLength;
  final void Function(String)? onChanged;
  final Iterable<String>? autofillHints;
  final TextInputType? keyboardType;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;

  const CustomInputField({
    super.key,
    required this.label,
    this.placeholder,
    this.errorText,
    this.obscureText = false,
    this.controller,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.autofillHints,
    this.keyboardType,
    this.fillColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: AppTypography.textTheme.labelLarge),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          maxLines: maxLines,
          onChanged: onChanged,
          autofillHints: autofillHints,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            counterText: '', // Hides the maxLength character counter to fix alignment
            hintText: placeholder,
            hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary(context),
            ),
            errorText: errorText,
            errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.dangerRed,
            ),
            filled: true,
            fillColor: fillColor ?? WidgetStateColor.resolveWith((Set<WidgetState> states) {
              if (states.contains(WidgetState.error) || states.contains(WidgetState.focused)) {
                return AppColors.background(context);
              }
              return Theme.of(context).brightness == Brightness.dark ? AppColors.slate800 : AppColors.slate100;
            }),
            contentPadding: contentPadding ?? EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppColors.trustBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppColors.dangerRed,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppColors.dangerRed,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
