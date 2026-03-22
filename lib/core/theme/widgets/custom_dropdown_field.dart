import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final String? value;
  final List<String> items;
  final void Function(String?)? onChanged;
  final String? errorText;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.placeholder,
    this.value,
    this.onChanged,
    this.errorText,
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
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: value,
          icon: Icon(LucideIcons.chevronDown, color: AppColors.textSecondary(context)),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary(context),
            ),
            errorText: errorText,
            errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.dangerRed,
            ),
            filled: true,
            fillColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
              if (states.contains(WidgetState.error) || states.contains(WidgetState.focused)) {
                return AppColors.background(context);
              }
              return Theme.of(context).brightness == Brightness.dark ? AppColors.slate800 : AppColors.slate100;
            }),
            contentPadding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
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
          dropdownColor: AppColors.surface(context),
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary(context),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
