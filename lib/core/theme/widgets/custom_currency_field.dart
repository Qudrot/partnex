import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

class CustomCurrencyField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final TextEditingController? controller;
  final String? errorText;
  final String? warningText;
  final String prefixText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;

  const CustomCurrencyField({
    super.key,
    required this.label,
    this.placeholder,
    this.controller,
    this.errorText,
    this.warningText,
    this.prefixText = '₦',
    this.onChanged,
    this.validator,
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ThousandsSeparatorInputFormatter(),
          ],
          onChanged: onChanged,
          validator: validator,
          textAlign: TextAlign.right,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.slate900,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.slate400,
            ),
            prefixText: prefixText,
            prefixStyle: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.slate600,
            ),
            errorText: errorText,
            errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.dangerRed,
            ),
            filled: true,
            fillColor: fillColor ?? MaterialStateColor.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.error) || states.contains(MaterialState.focused)) {
                return AppColors.slate50;
              }
              return AppColors.slate100;
            }),
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.trustBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.dangerRed,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.dangerRed,
                width: 2,
              ),
            ),
          ),
        ),
        if (warningText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.warningAmber,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  warningText!,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.warningAmber,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    String cleanString = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    List<String> parts = cleanString.split('.');
    String whole = parts[0];
    
    whole = whole.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},');
    
    String result = whole;
    if (parts.length > 1) {
      String decimal = parts[1];
      if (decimal.length > 2) decimal = decimal.substring(0, 2);
      result = '$whole.$decimal';
    } else if (cleanString.endsWith('.')) {
      result = '$whole.';
    }

    final newOffset = result.length - (newValue.text.length - newValue.selection.end);

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(
        offset: newOffset.clamp(0, result.length),
      ),
    );
  }
}
