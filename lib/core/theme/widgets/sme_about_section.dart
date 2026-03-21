import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

class SmeAboutSection extends StatelessWidget {
  final String? bio;
  final VoidCallback? onEditBio;

  const SmeAboutSection({
    super.key,
    this.bio,
    this.onEditBio,
  });

  @override
  Widget build(BuildContext context) {
    final hasBio = bio != null && bio!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        border: Border.all(color: AppColors.slate200),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'About',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.slate900,
            ),
          ),

          const SizedBox(height: 12),

          // Bio content with inline Edit Bio
          if (hasBio)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: bio!.length > 100 ? '${bio!.substring(0, 100)}... ' : '${bio!} ',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.slate700,
                      height: 1.6,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: onEditBio,
                      child: Text(
                        'Edit Bio',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.linkBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Add a bio to build credibility and help investors reach you. ",
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.slate500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: onEditBio,
                      child: Text(
                        'Add Now',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.linkBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
