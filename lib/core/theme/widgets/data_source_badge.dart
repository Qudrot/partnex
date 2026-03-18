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
    final isBank = source == DataSource.bankData;
    
    String label = 'Manual Data';
    IconData icon = LucideIcons.pencil;
    Color color = AppColors.slate600;
    Color bgColor = AppColors.slate100;
    Color borderColor = AppColors.slate200;

    if (isUploaded || isBank) {
      label = 'Bank Data';
      icon = isBank ? LucideIcons.landmark : LucideIcons.fileCheck2;
      color = AppColors.trustBlue;
      bgColor = AppColors.trustBlue.withValues(alpha: 0.08);
      borderColor = AppColors.trustBlue.withValues(alpha: 0.2);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.circular),
        border: Border.all(
          color: borderColor,
          width: AppSizes.borderThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSizes.iconSm,
            color: color,
          ),
          SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.labelSmaller.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
