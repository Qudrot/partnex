import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/driver_card.dart';
import 'package:partnex/core/theme/widgets/metric_mini_card.dart';
import 'package:partnex/features/auth/presentation/pages/investor/deep_dive_evidence_page.dart';
import 'package:partnex/features/auth/data/models/sme_profile_data.dart';


// ---------------------------------------------------------------------------
// Message SME Bottom Sheet
// ---------------------------------------------------------------------------
class MessageSmeBottomSheet extends StatefulWidget {
  final String companyName;
  const MessageSmeBottomSheet({super.key, required this.companyName});
  @override
  State<MessageSmeBottomSheet> createState() => _MessageSmeBottomSheetState();
}

class _MessageSmeBottomSheetState extends State<MessageSmeBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final message =
        "Hi ${widget.companyName}, I'm interested in learning more about your business and potential investment opportunities. Your credibility score caught my attention. Let's connect!";

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            Row(
              children: [
                Expanded(
                  child: _buildSocialOption(
                    'WhatsApp',
                    'assets/icons/whatsapp.png',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSocialOption(
                    'LinkedIn',
                    'assets/icons/linkedin.png',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSocialOption(
                    'Twitter',
                    'assets/icons/twitter.png',
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 24),
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     color: AppColors.slate50,
            //     borderRadius: BorderRadius.circular(6),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         message,
            //         style: AppTypography.textTheme.bodyMedium?.copyWith(
            //           fontSize: 12,
            //           color: AppColors.slate600,
            //         ),
            //       ),
            //       const SizedBox(height: 8),
            //       InkWell(
            //         onTap: () {},
            //         child: Text(
            //           'Edit message',
            //           style: AppTypography.textTheme.bodySmall?.copyWith(
            //             fontSize: 12,
            //             color: AppColors.trustBlue,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 24),
            _buildDirectContact(
              'Email',
              'contact@${widget.companyName.toLowerCase().replaceAll(' ', '')}.com',
              LucideIcons.mail,
            ),
            const SizedBox(height: 12),
            _buildDirectContact(
              'Phone',
              '+234 805 678 9012',
              LucideIcons.phone,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialOption(String label, String assetPath) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            border: Border.all(color: AppColors.slate200),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(assetPath, width: 32, height: 32),
              const SizedBox(height: AppSpacing.sm),
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

  Widget _buildDirectContact(String label, String value, IconData icon) {
    return Row(
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
      builder: (context) =>
          MessageSmeBottomSheet(companyName: widget.sme.companyName),
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
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.trustBlue,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Center(
                            child: Text(
                              _initials,
                              style: const TextStyle(
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
                                '${widget.sme.industry} • ${widget.sme.location} • ${widget.sme.yearsOfOperation} years',
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                      fontSize: 13,
                                      color: AppColors.slate600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      border: Border.all(color: AppColors.slate200),
                      borderRadius: BorderRadius.circular(8),
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
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: widget.sme.scoreColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${widget.sme.score}',
                                  style: AppTypography.textTheme.displayLarge
                                      ?.copyWith(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.neutralWhite,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
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
                                          fontSize: 13,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Generated today at ${TimeOfDay.now().format(context)}',
                                    style: AppTypography.textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.slate500,
                                          fontSize: 12,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // KEY METRICS GRID
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        const DriverCard(
                          driverName: 'Revenue Growth & Stability',
                          riskLevel: DriverRiskLevel.critical,
                          percentage: 25,
                          impactPoints: -14.4,
                          description:
                              'Measures your business\'s revenue trajectory. You have a -57.8% YoY growth rate. Consistent growth is key to credibility.',
                        ),
                        const DriverCard(
                          driverName: 'Profitability & Expense Management',
                          riskLevel: DriverRiskLevel.good,
                          percentage: 65,
                          impactPoints: 8.2,
                          description:
                              'Measures your operational efficiency and margin health. Strong cost controls reflect disciplined financial management.',
                        ),
                        const DriverCard(
                          driverName: 'Debt Management & Leverage',
                          riskLevel: DriverRiskLevel.excellent,
                          percentage: 85,
                          impactPoints: 12.1,
                          description:
                              'Measures your financial leverage and debt repayment capacity. Your debt service ratio is 25%, which is healthy and indicates strong ability to meet obligations.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Message SME',
                        onPressed: _openMessageSheet,
                        variant: ButtonVariant.primary,
                      ),
                    ),
                    // const SizedBox(width: 12),
                    // Expanded(
                    //   child: SizedBox(
                    //     height: 44,
                    //     child: ElevatedButton(
                    //       onPressed: _navigateToEvidence,
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor: AppColors.slate100,
                    //         elevation: 0,
                    //         side: BorderSide(color: AppColors.slate300),
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(8),
                    //         ),
                    //       ),
                    //       child: Text(
                    //         'Deep Dive',
                    //         style: AppTypography.textTheme.labelLarge?.copyWith(
                    //           color: AppColors.slate900,
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(width: 12),
                    // SizedBox(
                    //   width: 44,
                    //   height: 44,
                    //   child: IconButton(
                    //     onPressed: _toggleWatchlist,
                    //     icon: Icon(
                    //       _isWatchlisted ? Icons.favorite : LucideIcons.heart,
                    //       color: _isWatchlisted
                    //           ? AppColors.dangerRed
                    //           : AppColors.slate600,
                    //       size: 20,
                    //     ),
                    //     style: IconButton.styleFrom(
                    //       backgroundColor: AppColors.slate100,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //         side: BorderSide(color: AppColors.slate300),
                    //       ),
                    //     ),
                    //   ),
                    // ),
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
