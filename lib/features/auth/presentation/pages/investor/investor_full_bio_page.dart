import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';

import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/message_sme_bottom_sheet.dart';

class InvestorFullBioPage extends StatelessWidget {
  final String smeName;
  final String? bio;
  final String? contactPersonName;
  final String? contactPersonTitle;
  final String? whatsappNumber;
  final String? linkedinUrl;
  final String? twitterHandle;
  final String? email;
  final String? phoneNumber;
  final String? website;

  const InvestorFullBioPage({
    super.key,
    required this.smeName,
    this.bio,
    this.contactPersonName,
    this.contactPersonTitle,
    this.whatsappNumber,
    this.linkedinUrl,
    this.twitterHandle,
    this.email,
    this.phoneNumber,
    this.website,
  });

  @override
  Widget build(BuildContext context) {
    final hasBio = bio != null && bio!.isNotEmpty;
    final hasContact = (contactPersonName != null && contactPersonName!.isNotEmpty) ||
                       (contactPersonTitle != null && contactPersonTitle!.isNotEmpty);

    List<String> contactParts = [];
    if (contactPersonName != null && contactPersonName!.isNotEmpty) {
      contactParts.add(contactPersonName!);
    }
    if (contactPersonTitle != null && contactPersonTitle!.isNotEmpty) {
      contactParts.add(contactPersonTitle!);
    }
    final contactDisplay = contactParts.join(', ');

    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.neutralWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About $smeName',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.slate900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.slate200, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  if (hasBio) ...[
                    Text(
                      bio!,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.slate700,
                        height: 1.6,
                      ),
                    ),
                  ] else ...[
                    // Empty state
                    const SizedBox(height: 48),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.fileText,
                            size: 32,
                            color: AppColors.slate400,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'No Bio Available',
                            style: AppTypography.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "This company hasn't added a bio yet.",
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (hasContact) ...[
                    SizedBox(height: AppSpacing.xl),
                    Container(
                      height: 1,
                      color: AppColors.slate200,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Primary Contact',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contactDisplay,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate900,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CustomButton(
                text: 'Message SME',
                variant: ButtonVariant.primary,
                isFullWidth: true,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => MessageSmeBottomSheet(
                      companyName: smeName,
                      email: email,
                      phoneNumber: phoneNumber,
                      website: website,
                      whatsappNumber: whatsappNumber,
                      linkedinUrl: linkedinUrl,
                      twitterHandle: twitterHandle,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}