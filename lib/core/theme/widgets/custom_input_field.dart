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
  final String? Function(String?)? validator;
  final int? maxLines;
  final void Function(String)? onChanged;
  final Iterable<String>? autofillHints;

  const CustomInputField({
    super.key,
    required this.label,
    this.placeholder,
    this.errorText,
    this.obscureText = false,
    this.controller,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.onChanged,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          maxLines: maxLines,
          onChanged: onChanged,
          autofillHints: autofillHints,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.slate900,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.slate400,
            ),
            errorText: errorText,
            errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.dangerRed,
            ),
            filled: true,
            fillColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.error) || states.contains(MaterialState.focused)) {
                return AppColors.slate50;
              }
              return AppColors.slate100;
            }),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.slate200),
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
