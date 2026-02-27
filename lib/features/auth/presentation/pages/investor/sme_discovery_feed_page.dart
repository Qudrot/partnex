import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/partnex_logo.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_profile_expanded_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/deep_dive_evidence_page.dart';

class SmeDiscoveryFeedPage extends StatefulWidget {
  const SmeDiscoveryFeedPage({super.key});

  @override
  State<SmeDiscoveryFeedPage> createState() => _SmeDiscoveryFeedPageState();
}

class _SmeDiscoveryFeedPageState extends State<SmeDiscoveryFeedPage> {
  final List<String> _activeFilters = ['Manufacturing', 'Score: 80+', 'Revenue: ₦500K+'];

  void _navigateToProfile(SmeCardData sme) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SmeProfileExpandedPage(sme: sme)),
    );
  }

  void _navigateToEvidence() {
     Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeepDiveEvidencePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                children: [
                   // The redesigned SME Profile Card (Investor-Centric)
                  _buildSmeCard(
                    companyName: 'Acme Manufacturing',
                    industry: 'Manufacturing',
                    location: 'Lagos, Nigeria',
                    employees: '25',
                    revenue: '₦750K',
                    growthSignal: '↑ 22% YoY',
                    isGrowthPositive: true,
                    trustFunded: true,
                    trustPayments: true,
                    trustStable: true,
                    score: 85,
                    riskLevel: 'Low',
                    scoreColor: AppColors.successGreen,
                  ),
                   _buildSmeCard(
                    companyName: 'TechStart Solutions',
                    industry: 'Technology',
                    location: 'Abuja, Nigeria',
                    employees: '12',
                    revenue: '₦500K',
                    growthSignal: '↑ 45% YoY',
                    isGrowthPositive: true,
                    trustFunded: true,
                    trustPayments: true,
                    trustStable: false,
                    score: 62,
                    riskLevel: 'Med',
                    scoreColor: AppColors.warningAmber,
                  ),
                  _buildSmeCard(
                    companyName: 'Traditional Retail Ltd',
                    industry: 'Retail',
                    location: 'Kano, Nigeria',
                    employees: '8',
                    revenue: '₦300K',
                    growthSignal: '↓ 5% YoY',
                    isGrowthPositive: false,
                    trustFunded: false,
                    trustPayments: false,
                    trustStable: false,
                    score: 45,
                    riskLevel: 'High',
                    scoreColor: AppColors.dangerRed,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Load More',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: AppColors.slate600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                   _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          const PartnexLogo(size: 32, variant: PartnexLogoVariant.iconOnly),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.slate200),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  const Icon(LucideIcons.search, size: 16, color: AppColors.slate400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by company name, industry...',
                        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.slate400,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(bottom: 14), // Align text vertically
                      ),
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(6),
              hoverColor: AppColors.slate50,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(LucideIcons.sliders, size: 20, color: AppColors.slate600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 44,
      color: Colors.white,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _activeFilters.map((filter) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                border: Border.all(color: AppColors.slate200),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(
                    filter,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.slate900,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _activeFilters.remove(filter);
                      });
                    },
                    child: const Icon(LucideIcons.x, size: 14, color: AppColors.slate400),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSmeCard({
    required String companyName,
    required String industry,
    required String location,
    required String employees,
    required String revenue,
    required String growthSignal,
    required bool isGrowthPositive,
    required bool trustFunded,
    required bool trustPayments,
    required bool trustStable,
    required int score,
    required String riskLevel,
    required Color scoreColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.slate200),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToProfile(SmeCardData(
            companyName: companyName,
            industry: industry,
            location: location,
            employees: employees,
            revenue: revenue,
            growthSignal: growthSignal,
            isGrowthPositive: isGrowthPositive,
            trustFunded: trustFunded,
            trustPayments: trustPayments,
            trustStable: trustStable,
            score: score,
            riskLevel: riskLevel,
            scoreColor: scoreColor,
          )),
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColors.slate50,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Section (Business Information) ~70% width logically
                Expanded(
                  flex: 5,
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text(
                         companyName,
                         style: AppTypography.textTheme.bodyMedium?.copyWith(
                           fontWeight: FontWeight.w600,
                           fontSize: 16,
                           color: AppColors.slate900,
                         ),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                       const SizedBox(height: 4),
                       Row(
                         children: [
                            const Icon(LucideIcons.mapPin, size: 12, color: AppColors.slate400),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$industry · $location',
                                style: AppTypography.textTheme.bodySmall?.copyWith(
                                  color: AppColors.slate600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                         ],
                       ),
                       const SizedBox(height: 4),
                       Row(
                         children: [
                            const Icon(LucideIcons.users, size: 12, color: AppColors.slate400),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$employees employees · $revenue revenue',
                                style: AppTypography.textTheme.bodySmall?.copyWith(
                                  color: AppColors.slate600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                         ],
                       ),
                     ],
                  ),
                ),
                // Center Section (Growth & Trust Signals)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        growthSignal,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                           fontWeight: FontWeight.w600,
                           fontSize: 14,
                           color: isGrowthPositive ? AppColors.successGreen : AppColors.dangerRed,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Trust Signals Row
                      Row(
                         children: [
                           if(trustFunded) const Icon(LucideIcons.checkCircle, size: 12, color: AppColors.successGreen),
                           if(trustFunded) const SizedBox(width: 2),
                           if(trustPayments) const Icon(LucideIcons.checkCircle, size: 12, color: AppColors.successGreen),
                           if(trustPayments) const SizedBox(width: 2),
                           if(trustStable) const Icon(LucideIcons.checkCircle, size: 12, color: AppColors.successGreen),
                         ],
                      ),
                    ],
                  ),
                ),
                // Right Section (Score Badge)
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     GestureDetector(
                       onTap: _navigateToEvidence,
                       child: Container(
                         width: 48,
                         height: 48,
                         decoration: BoxDecoration(
                           color: scoreColor,
                           shape: BoxShape.circle,
                           boxShadow: const [
                             BoxShadow(
                               color: Color.fromRGBO(0, 0, 0, 0.05),
                               blurRadius: 2,
                               offset: Offset(0, 1),
                             )
                           ],
                         ),
                         child: Center(
                           child: Text(
                             score.toString(),
                             style: AppTypography.textTheme.headlineSmall?.copyWith(
                               color: Colors.white,
                               fontSize: 20,
                               fontWeight: FontWeight.w700,
                             ),
                           ),
                         ),
                       ),
                     ),
                     const SizedBox(height: 4),
                     Text(
                       riskLevel,
                       style: AppTypography.textTheme.labelSmall?.copyWith(
                         color: scoreColor, // Using colored text or can be a small badge
                         fontSize: 10,
                         fontWeight: FontWeight.w600,
                       ),
                     ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Help',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.slate600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
             '·',
             style: AppTypography.textTheme.bodySmall?.copyWith(
               color: AppColors.slate400,
             ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () {},
            child: Text(
              'Contact Support',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.slate600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
