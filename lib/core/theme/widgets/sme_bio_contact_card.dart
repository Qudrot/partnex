import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/two_line_text.dart';

class SmeBioContactCard extends StatelessWidget {
  final String? bio;
  final String? contactPersonName;
  final String? contactPersonTitle;
  final String smeId;
  final String smeName;
  final VoidCallback? onReadMore;

  const SmeBioContactCard({
    super.key,
    this.bio,
    this.contactPersonName,
    this.contactPersonTitle,
    required this.smeId,
    required this.smeName,
    this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    bool hasContact = (contactPersonName != null && contactPersonName!.isNotEmpty) ||
                      (contactPersonTitle != null && contactPersonTitle!.isNotEmpty);
    bool hasBio = bio != null && bio!.isNotEmpty;

    List<String> contactParts = [];
    if (contactPersonName != null && contactPersonName!.isNotEmpty) {
      contactParts.add(contactPersonName!);
    }
    if (contactPersonTitle != null && contactPersonTitle!.isNotEmpty) {
      contactParts.add(contactPersonTitle!);
    }
    String contactDisplay = contactParts.join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border.all(color: AppColors.border(context)),
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
          Text(
            'About',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          if (hasBio)
            TwoLineText(
              text: bio ?? '',
              ctaText: 'Read more',
              onCtaTap: onReadMore,
              textStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary(context),
                height: 1.5,
              ),
              ctaStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.linkBlue,
              ),
            )
          else
            Text(
              "No company bio has been added yet. This business hasn't shared their story.",
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary(context),
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),

          const SizedBox(height: 12),
          if (hasBio) ...[
            Container(
              height: 1,
              color: AppColors.border(context),
            ),
            const SizedBox(height: 12),
          ],

          Text(
            'Primary Contact',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hasContact ? contactDisplay : "$smeName Business Representative",
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
