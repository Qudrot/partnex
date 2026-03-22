import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/two_line_text.dart';

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
        color: AppColors.surface(context),
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
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
              color: AppColors.textPrimary(context),
            ),
          ),

          const SizedBox(height: 12),

          if (hasBio)
            TwoLineText(
              text: bio!,
              ctaText: 'Read more',
              onCtaTap: onEditBio,
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
                      color: AppColors.textSecondary(context),
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
