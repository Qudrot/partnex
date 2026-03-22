import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/utils/url_helper.dart';

// ---------------------------------------------------------------------------
// Message SME Bottom Sheet
// ---------------------------------------------------------------------------
class MessageSmeBottomSheet extends StatefulWidget {
  final String companyName;
  final String? email;
  final String? phoneNumber;
  final String? website;
  final String? whatsappNumber;
  final String? linkedinUrl;
  final String? twitterHandle;

  const MessageSmeBottomSheet({
    super.key,
    required this.companyName,
    this.email,
    this.phoneNumber,
    this.website,
    this.whatsappNumber,
    this.linkedinUrl,
    this.twitterHandle,
  });
  @override
  State<MessageSmeBottomSheet> createState() => _MessageSmeBottomSheetState();
}

class _MessageSmeBottomSheetState extends State<MessageSmeBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact ${widget.companyName}',
                        style: AppTypography.textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Choose how you'd like to reach out",
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: AppColors.textPrimary(context)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final hasWhatsapp =
                    widget.whatsappNumber != null &&
                    widget.whatsappNumber!.isNotEmpty;
                final hasLinkedin =
                    widget.linkedinUrl != null &&
                    widget.linkedinUrl!.isNotEmpty;
                final hasTwitter =
                    widget.twitterHandle != null &&
                    widget.twitterHandle!.isNotEmpty;

                if (hasWhatsapp || hasLinkedin || hasTwitter) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          if (hasWhatsapp)
                            Expanded(
                              child: _buildSocialOption(
                                'WhatsApp',
                                'assets/icons/whatsapp.png',
                                onTap: () => UrlHelper.launchWhatsApp(
                                  widget.whatsappNumber!,
                                ),
                              ),
                            ),
                          if (hasWhatsapp && (hasLinkedin || hasTwitter))
                            const SizedBox(width: 12),
                          if (hasLinkedin)
                            Expanded(
                              child: _buildSocialOption(
                                'LinkedIn',
                                'assets/icons/linkedin.png',
                                onTap: () => UrlHelper.launchWebsite(
                                  widget.linkedinUrl!,
                                ),
                              ),
                            ),
                          if (hasLinkedin && hasTwitter)
                            const SizedBox(width: 12),
                          if (hasTwitter)
                            Expanded(
                              child: _buildSocialOption(
                                'Twitter',
                                context.isDarkMode ? 'assets/icons/twitter_light.png' : 'assets/icons/twitter.png',
                                onTap: () => UrlHelper.launchWebsite(
                                  'https://twitter.com/${widget.twitterHandle!.replaceAll('@', '')}',
                                ),
                              ),
                            ),

                          // Empty space filler if less than 3 socials
                          if (!hasWhatsapp && !hasLinkedin) const Spacer(),
                          if (!hasWhatsapp && !hasTwitter) const Spacer(),
                          if (!hasLinkedin && !hasTwitter) const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
            _buildDirectContact(
              'Email',
              (widget.email != null && widget.email!.isNotEmpty)
                  ? widget.email!
                  : 'Not provided',
              LucideIcons.mail,
              onTap: () {
                if (widget.email != null && widget.email!.isNotEmpty) {
                  UrlHelper.launchEmail(widget.email!);
                }
              },
            ),
            const SizedBox(height: 12),
            if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty)
              _buildDirectContact(
                'Phone',
                widget.phoneNumber!,
                LucideIcons.phone,
                onTap: () => UrlHelper.launchPhone(widget.phoneNumber!),
              ),
            if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty)
              const SizedBox(height: 12),
            if (widget.website != null && widget.website!.isNotEmpty)
              _buildDirectContact(
                'Website',
                widget.website!,
                LucideIcons.globe,
                onTap: () => UrlHelper.launchWebsite(widget.website!),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialOption(
    String label,
    String assetPath, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background(context),
            border: Border.all(color: AppColors.border(context)),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(assetPath, width: 32, height: 32),
              SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectContact(
    String label,
    String value,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary(context)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
