import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/circular_score_ring.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/driver_card.dart';
import 'package:partnex/core/theme/widgets/metric_mini_card.dart';
import 'package:partnex/core/theme/widgets/data_source_badge.dart';
import 'package:partnex/core/theme/widgets/sme_bio_contact_card.dart';
import 'package:partnex/core/utils/url_helper.dart';
import 'package:partnex/features/auth/data/models/sme_profile_data.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_full_bio_page.dart';
import 'package:partnex/features/auth/presentation/blocs/discovery_cubit/discovery_cubit.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/score_drivers_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      decoration: const BoxDecoration(
        color: AppColors.neutralWhite,
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
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Choose how you'd like to reach out",
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: AppColors.slate600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: AppColors.slate900),
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
                                'assets/icons/twitter.png',
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
            if (widget.email != null && widget.email!.isNotEmpty)
              _buildDirectContact(
                'Email',
                widget.email!,
                LucideIcons.mail,
                onTap: () => UrlHelper.launchEmail(widget.email!),
              ),
            if (widget.email != null && widget.email!.isNotEmpty)
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
            color: AppColors.slate50,
            border: Border.all(color: AppColors.slate200),
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
                  color: AppColors.slate900,
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
            Icon(icon, size: 16, color: AppColors.slate400),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.slate600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.slate900,
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

// ---------------------------------------------------------------------------
// SME Profile Expanded Page
// ---------------------------------------------------------------------------
class SmeProfileExpandedPage extends StatefulWidget {
  final SmeCardData sme;
  const SmeProfileExpandedPage({super.key, required this.sme});
  @override
  State<SmeProfileExpandedPage> createState() => _SmeProfileExpandedPageState();
}

class _SmeProfileExpandedPageState extends State<SmeProfileExpandedPage> {
  String get _initials {
    final parts = widget.sme.companyName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
  }

  void _openMessageSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageSmeBottomSheet(
        companyName: widget.sme.companyName,
        email: widget.sme.email,
        phoneNumber: widget.sme.phoneNumber,
        website: widget.sme.website,
        whatsappNumber: widget.sme.whatsappNumber,
        linkedinUrl: widget.sme.linkedinUrl,
        twitterHandle: widget.sme.twitterHandle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'SME Profile',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.slate900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              LucideIcons.moreVertical,
              color: AppColors.slate900,
            ),
            onPressed: () {},
          ),
        ],
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
                padding: EdgeInsets.symmetric(vertical: 16.0),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: AppSpacing.xxxxl,
                          height: AppSpacing.xxxxl,
                          decoration: BoxDecoration(
                            color: AppColors.trustBlue,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Center(
                            child: Text(
                              _initials,
                              style: AppTypography.textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppColors.neutralWhite,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.sme.companyName,
                                style: AppTypography.textTheme.headlineMedium
                                    ?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.slate900,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.sme.industry} • ${widget.sme.displayLocation} • ${widget.sme.yearsOfOperationText}',
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                      fontSize: 13,
                                      color: AppColors.slate600,
                                    ),
                              ),
                              if (widget.sme.website != null &&
                                  widget.sme.website!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () {},
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.globe,
                                        size: 12,
                                        color: AppColors.trustBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.sme.website!,
                                        style: AppTypography
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontSize: 13,
                                              color: AppColors.trustBlue,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      border: Border.all(color: AppColors.slate200),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Credibility Score',
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: AppColors.slate600,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScoreDriversDetailPage(sme: widget.sme),
                                ),
                              ),
                              child: CircularScoreRing(
                                score: widget.sme.score,
                                size: 140,
                              ),
                            ),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.sme.riskLevel} Risk',
                                    style: AppTypography.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: AppColors.slate900,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Generated today at ${TimeOfDay.now().format(context)}',
                                    style: AppTypography.textTheme.bodySmall
                                        ?.copyWith(color: AppColors.slate500),
                                  ),
                                  SizedBox(height: AppSpacing.sm),
                                  DataSourceBadge(
                                    source: widget.sme.dataSource,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // KEY METRICS GRID
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 640;
                        return GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile ? 2 : 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.4,
                              ),
                          children: [
                            MetricMiniCard(
                              label: 'Revenue Trend',
                              value: widget.sme.revenueTrendText,
                              status: widget.sme.revenueTrendSignal,
                              statusColor: widget.sme.revenueTrendColor,
                            ),
                            MetricMiniCard(
                              label: 'Expense Ratio',
                              value: widget.sme.expenseRatioText,
                              status: widget.sme.expenseRatioSignal,
                              statusColor: widget.sme.expenseRatioColor,
                            ),
                            MetricMiniCard(
                              label: 'Profit Margin',
                              value: widget.sme.profitMarginText,
                              status: widget.sme.profitMarginSignal,
                              statusColor: widget.sme.profitMarginColor,
                            ),
                            MetricMiniCard(
                              label: 'Impact Score',
                              value: widget.sme.impactScore.toStringAsFixed(1),
                              status: widget.sme.impactScoreSignal,
                              statusColor: widget.sme.impactScoreColor,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: SmeBioContactCard(
                      bio: widget.sme.bio,
                      contactPersonName: widget.sme.contactPersonName,
                      contactPersonTitle: widget.sme.contactPersonTitle,
                      smeId: widget.sme.id,
                      smeName: widget.sme.companyName,
                      onReadMore: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvestorFullBioPage(
                              smeName: widget.sme.companyName,
                              bio: widget.sme.bio,
                              contactPersonName: widget.sme.contactPersonName,
                              contactPersonTitle: widget.sme.contactPersonTitle,
                              whatsappNumber: widget.sme.whatsappNumber,
                              linkedinUrl: widget.sme.linkedinUrl,
                              twitterHandle: widget.sme.twitterHandle,
                              email: widget.sme.email,
                              phoneNumber: widget.sme.phoneNumber,
                              website: widget.sme.website,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: AppSpacing.md),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   'What Drives Your Score',
                        //   style: AppTypography.textTheme.headlineMedium
                        //       ?.copyWith(
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.w600,
                        //         color: AppColors.slate900,
                        //       ),
                        // ),
                        // const SizedBox(height: 4),
                        // Text(
                        //   'Top 3 factors contributing to your credibility',
                        //   style: AppTypography.textTheme.bodyMedium?.copyWith(
                        //     fontSize: 12,
                        //     color: AppColors.slate600,
                        //   ),
                        // ),
                        // const SizedBox(height: 12),
                        ...widget.sme.drivers.map(
                          (driver) => DriverCard(
                            driverName: driver.name,
                            riskLevel: driver.riskLevel,
                            percentage: driver.percentage,
                            impactPoints: driver.impactPoints,
                            description: driver.description,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.smd,
              ),
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                border: Border(top: BorderSide(color: AppColors.slate200)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton(
                      text: 'Message SME',
                      onPressed: _openMessageSheet,
                      variant: ButtonVariant.primary,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Deep dive',
                      onPressed: () => context
                          .read<DiscoveryCubit>()
                          .viewDeepDiveEvidence(widget.sme),
                      variant: ButtonVariant.secondary,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
