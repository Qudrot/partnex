import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

import 'package:partnex/features/auth/data/models/sme_profile_data.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_full_bio_page.dart';
import 'package:partnex/features/auth/presentation/blocs/discovery_cubit/discovery_cubit.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/score_drivers_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/core/theme/widgets/message_sme_bottom_sheet.dart';


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
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SME Profile',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        titleSpacing: 0,
        centerTitle: false,
        actions: [],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border(context), height: 1.0),
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
                            border: Border.all(color: AppColors.border(context)),
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
                                      color: AppColors.textPrimary(context),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.sme.industry} • ${widget.sme.displayLocation} • ${widget.sme.yearsOfOperationText}',
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                      fontSize: 13,
                                      color: AppColors.textSecondary(context),
                                    ),
                              ),
                              // if (widget.sme.website != null &&
                              //     widget.sme.website!.isNotEmpty) ...[
                              //   const SizedBox(height: 4),
                              //   InkWell(
                              //     onTap: () {},
                              //     child: Row(
                              //       children: [
                              //         const Icon(
                              //           LucideIcons.globe,
                              //           size: 12,
                              //           color: AppColors.trustBlue,
                              //         ),
                              //         const SizedBox(width: 4),
                              //         Text(
                              //           widget.sme.website!,
                              //           style: AppTypography
                              //               .textTheme
                              //               .bodyMedium
                              //               ?.copyWith(
                              //                 fontSize: 13,
                              //                 color: AppColors.trustBlue,
                              //                 fontWeight: FontWeight.w500,
                              //               ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ],
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
                      color: AppColors.surface(context),
                      border: Border.all(color: AppColors.border(context)),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Credibility Score',
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary(context),
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
                                size: 110,
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.sme.riskLevel} RISK',
                                    style: AppTypography.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textPrimary(context),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  SizedBox(height: AppSpacing.xs),
                                  // Use the actual timestamp from the database!
                                  Builder(
                                    builder: (context) {
                                      final now = DateTime.now();
                                      final genAt = widget.sme.generatedAt;
                                      final isToday = genAt.year == now.year &&
                                          genAt.month == now.month &&
                                          genAt.day == now.day;
                                      final formattedDate = isToday
                                          ? 'today at ${DateFormat('h:mm a').format(genAt)}'
                                          : 'on ${DateFormat('MMM d, yyyy').format(genAt)}';
                                      return Text(
                                        'Generated $formattedDate',
                                        style: AppTypography.textTheme.bodySmall
                                            ?.copyWith(color: AppColors.textSecondary(context)),
                                      );
                                    },
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
                color: AppColors.surface(context),
                border: Border(top: BorderSide(color: AppColors.border(context))),
                boxShadow: [
                  BoxShadow(
                    color: context.isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1),
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
                      text: 'Contact SME',
                      onPressed: _openMessageSheet,
                      variant: ButtonVariant.primary,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'View Business Insights',
                      onPressed: () => context
                          .read<DiscoveryCubit>()
                          .viewBusinessInsights(widget.sme),
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