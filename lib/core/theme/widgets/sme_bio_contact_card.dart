import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

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

    String bioSnippet = '';
    if (hasBio) {
      bioSnippet = bio!.length > 100 ? '${bio!.substring(0, 100)}... ' : '${bio!} ';
    }

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
        color: AppColors.slate50,
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
          Text(
            'About',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.slate600,
            ),
          ),
          const SizedBox(height: 8),
          if (hasBio) 
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: bioSnippet,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.slate700,
                      height: 1.5,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: onReadMore,
                      child: Text(
                        'Read More',
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
            Text(
              "No company bio has been added yet. $smeName is currently focusing on operations and hasn't shared their story.",
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.slate500,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),

          const SizedBox(height: 12),
          if (hasBio) ...[
            Container(
              height: 1,
              color: AppColors.slate200,
            ),
            const SizedBox(height: 12),
          ],

          Text(
            hasContact ? contactDisplay : "$smeName Business Representative",
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.slate900,
            ),
          ),
        ],
      ),
    );
  }
}
