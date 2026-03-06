import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';

class DataSourceBadge extends StatelessWidget {
  final DataSource source;

  const DataSourceBadge({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final isUploaded = source == DataSource.uploaded;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isUploaded
            ? AppColors.trustBlue.withValues(alpha: 0.08)
            : AppColors.slate100,
        borderRadius: BorderRadius.circular(AppRadius.circular),
        border: Border.all(
          color: isUploaded
              ? AppColors.trustBlue.withValues(alpha: 0.2)
              : AppColors.slate200,
          width: AppSizes.borderThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUploaded ? LucideIcons.fileCheck2 : LucideIcons.pencil,
            size: AppSizes.iconSm,
            color: isUploaded ? AppColors.trustBlue : AppColors.slate600,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            isUploaded ? 'Uploaded Bank Statement' : 'Self-Reported',
            style: AppTypography.labelSmaller.copyWith(
              color: isUploaded ? AppColors.trustBlue : AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }
}
