import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/features/auth/presentation/pages/investor/deep_dive_evidence_page.dart';

// ---------------------------------------------------------------------------
// Data model passed from the discovery feed into the expanded profile page
// ---------------------------------------------------------------------------
class SmeCardData {
  final String id;
  final String companyName;
  final String industry;
  final String location;
  final int yearsOfOperation;
  final int numberOfEmployees;
  final double annualRevenue;
  final double monthlyExpenses;
  final double liabilities;
  final String fundingHistory;
  final int score;
  final String riskLevel;
  
  // Computed fields for UI:
  String get employeesText => '$numberOfEmployees employees';
  String get revenueText => '₦${(annualRevenue / 1000).toStringAsFixed(0)}K revenue';
  String get growthSignal => '↑ 22% YoY'; // Simulated YoY growth
  bool get isGrowthPositive => true;
  bool get trustFunded => fundingHistory.toLowerCase() != 'no prior funding';
  bool get trustPayments => true; // Simulated based on logic
  bool get trustStable => true; // Simulated based on logic
  
  Color get scoreColor {
    final lowerRisk = riskLevel.toLowerCase();
    if (lowerRisk.contains('low') || score >= 80) return const Color(0xFF10B981); // Success Green
    if (lowerRisk.contains('medium') || score >= 50) return const Color(0xFFF59E0B); // Warning Amber
    return const Color(0xFFEF4444); // Danger Red
  }

  const SmeCardData({
    required this.id,
    required this.companyName,
    required this.industry,
    required this.location,
    required this.yearsOfOperation,
    required this.numberOfEmployees,
    required this.annualRevenue,
    required this.monthlyExpenses,
    required this.liabilities,
    required this.fundingHistory,
    required this.score,
    required this.riskLevel,
  });

  factory SmeCardData.fromMap(Map<String, dynamic> map) {
    return SmeCardData(
      id: map['id']?.toString() ?? map['sme_id']?.toString() ?? '',
      companyName: map['business_name']?.toString() ?? 'Unknown SME',
      industry: map['industry_sector']?.toString() ?? map['industry']?.toString() ?? 'Various',
      location: map['location']?.toString() ?? 'Unknown',
      yearsOfOperation: int.tryParse(map['years_of_operation']?.toString() ?? '1') ?? 1,
      numberOfEmployees: int.tryParse(map['number_of_employees']?.toString() ?? '0') ?? 0,
      annualRevenue: double.tryParse(map['annual_revenue_amount_1']?.toString() ?? '0') ?? 0.0,
      monthlyExpenses: double.tryParse(map['monthly_expenses']?.toString() ?? '0') ?? 0.0,
      liabilities: double.tryParse(map['existing_liabilities']?.toString() ?? '0') ?? 0.0,
      fundingHistory: map['prior_funding_history']?.toString() ?? 'No prior funding',
      score: int.tryParse(map['score']?.toString() ?? '0') ?? 0,
      riskLevel: map['risk_level']?.toString() ?? 'Unknown',
    );
  }
}

// ---------------------------------------------------------------------------
// Message SME Bottom Sheet (Screen 14B)
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
        color: Colors.white,
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
                    Icons.chat_bubble_outline,
                    const Color(0xFF25D366),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSocialOption(
                    'LinkedIn',
                    LucideIcons.linkedin,
                    const Color(0xFF0A66C2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSocialOption(
                    'Twitter',
                    LucideIcons.twitter,
                    const Color(0xFF1DA1F2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: AppColors.slate600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {},
                    child: Text(
                      'Edit message',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppColors.trustBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildDirectContact(
              'Email',
              'contact@${widget.companyName.toLowerCase().replaceAll(' ', '')}.com',
              LucideIcons.mail,
            ),
            const SizedBox(height: 12),
            _buildDirectContact(
              'Phone',
              '+234 (0) 123 456 7890',
              LucideIcons.phone,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialOption(
    String label,
    IconData iconData,
    Color colorHex,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: colorHex.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.slate200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, size: 32, color: colorHex),
              const SizedBox(height: 8),
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
// SME Profile Expanded Page (Screen 14)
// ---------------------------------------------------------------------------
class SmeProfileExpandedPage extends StatefulWidget {
  /// Real SME data passed from the discovery feed card.
  final SmeCardData sme;

  const SmeProfileExpandedPage({super.key, required this.sme});

  @override
  State<SmeProfileExpandedPage> createState() => _SmeProfileExpandedPageState();
}

class _SmeProfileExpandedPageState extends State<SmeProfileExpandedPage> {
  bool _isWatchlisted = false;

  String get _initials {
    final parts = widget.sme.companyName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
  }

  void _navigateToEvidence() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeepDiveEvidencePage()),
    );
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

  void _toggleWatchlist() {
    setState(() => _isWatchlisted = !_isWatchlisted);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isWatchlisted ? 'Added to watchlist' : 'Removed from watchlist',
          style: AppTypography.textTheme.bodyMedium
              ?.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.slate900,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
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
            icon: const Icon(LucideIcons.moreVertical,
                color: AppColors.slate900),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          children: [
            // Company Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.trustBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        color: AppColors.trustBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
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
                        widget.sme.companyName,
                        style:
                            AppTypography.textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.sme.industry} · ${widget.sme.location}',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: AppColors.slate600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.sme.yearsOfOperation} years in operation',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: AppColors.slate600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.externalLink,
                              size: 14,
                              color: AppColors.trustBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'www.${widget.sme.companyName.toLowerCase().replaceAll(' ', '')}.com',
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: AppColors.trustBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Score Badge
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _navigateToEvidence,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: widget.sme.scoreColor,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${widget.sme.score}',
                          style: AppTypography.textTheme.displayLarge?.copyWith(
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.sme.scoreColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${widget.sme.riskLevel} Risk',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generated today at ${TimeOfDay.now().format(context)}',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.slate600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Key Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.0,
              children: [
                _buildMetricCard(
                  'Annual Revenue',
                  widget.sme.revenueText.split(' ')[0], // extracts e.g. "₦750K"
                  widget.sme.isGrowthPositive ? 'Positive' : 'Declining',
                  widget.sme.isGrowthPositive ? AppColors.successGreen : AppColors.dangerRed,
                ),
                _buildMetricCard(
                  'Employees',
                  '${widget.sme.numberOfEmployees}',
                  'Stable',
                  AppColors.successGreen,
                ),
                _buildMetricCard(
                  'Liabilities',
                  '₦${(widget.sme.liabilities / 1000).toStringAsFixed(0)}K',
                  widget.sme.liabilities > widget.sme.annualRevenue ? 'High' : 'Moderate',
                  widget.sme.liabilities > widget.sme.annualRevenue ? AppColors.dangerRed : AppColors.warningAmber,
                ),
                _buildMetricCard(
                  'Profit Margin',
                  '${(widget.sme.annualRevenue > 0 ? ((widget.sme.annualRevenue - widget.sme.monthlyExpenses * 12) / widget.sme.annualRevenue * 100).clamp(0, 100).toStringAsFixed(0) : 0)}%',
                  'Healthy', // Assuming healthy for MVP
                  AppColors.successGreen,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Trust Signals
            if (widget.sme.trustFunded)
              _buildTrustSignalCard(
                title: 'Received Prior Funding',
                explanation: widget.sme.fundingHistory,
              ),
            if (widget.sme.trustPayments)
              _buildTrustSignalCard(
                title: 'Payment Timeliness',
                explanation: 'Consistently makes payments on time (estimated)',
              ),
            if (widget.sme.trustStable)
              _buildTrustSignalCard(
                title: 'Revenue Stability',
                explanation: 'Consistent revenue growth over time (estimated)',
              ),
            if (!widget.sme.trustFunded &&
                !widget.sme.trustPayments &&
                !widget.sme.trustStable)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.warningAmber),
                ),
                child: Text(
                  'No trust signals available for this SME yet.',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.slate700,
                    fontSize: 13,
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openMessageSheet,
                icon: const Icon(LucideIcons.messageCircle, size: 16, color: Colors.white),
                label: Text(
                  'Message SME',
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.trustBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    String statusText,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.slate600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  statusText,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.slate900,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustSignalCard({
    required String title,
    required String explanation,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.successGreen),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            LucideIcons.checkCircle,
            color: AppColors.successGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  explanation,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.slate600,
                    fontSize: 12,
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
