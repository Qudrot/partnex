import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_profile_expanded_page.dart';
import 'package:partnex/features/auth/data/models/sme_profile_data.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';

class ComparisonWatchlistPage extends StatefulWidget {
  const ComparisonWatchlistPage({super.key});

  @override
  State<ComparisonWatchlistPage> createState() =>
      _ComparisonWatchlistPageState();
}

class _ComparisonWatchlistPageState extends State<ComparisonWatchlistPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _watchlist = [
    {
      'id': '1',
      'name': 'Acme Manufacturing',
      'industry': 'Manufacturing',
      'growthSignal': '↑ 22% YoY',
      'isGrowthPositive': true,
      'score': 85,
      'scoreColor': AppColors.successGreen,
      'revenue': '₦750K',
      'expenseRatio': '60%',
      'paymentReliability': '100% On-Time ✓',
      'fundingHistory': 'Seed Funded ✓',
    },
    {
      'id': '2',
      'name': 'TechStart',
      'industry': 'Technology',
      'growthSignal': '↑ 45% YoY',
      'isGrowthPositive': true,
      'score': 62,
      'scoreColor': AppColors.warningAmber,
      'revenue': '₦500K',
      'expenseRatio': '80%',
      'paymentReliability': '90% On-Time',
      'fundingHistory': 'Bootstrapped',
    },
    {
      'id': '3',
      'name': 'Retail Ltd',
      'industry': 'Retail',
      'growthSignal': '↓ 5% YoY',
      'isGrowthPositive': false,
      'score': 45,
      'scoreColor': AppColors.dangerRed,
      'revenue': '₦300K',
      'expenseRatio': '95%',
      'paymentReliability': '60% On-Time',
      'fundingHistory': 'None',
    },
  ];

  final Set<String> _selectedForComparison = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedForComparison.contains(id)) {
        _selectedForComparison.remove(id);
      } else {
        if (_selectedForComparison.length < 3) {
          _selectedForComparison.add(id);
        } else {
          uiService.showSnackBar(
            'You can only compare up to 3 businesses at a time.',
            isError: true,
          );
        }
      }
    });
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SmeProfileExpandedPage(
          sme: SmeCardData(
            id: '0',
            companyName: 'SME Profile',
            industry: 'Unknown',
            location: 'Nigeria',
            yearsOfOperation: 1,
            numberOfEmployees: 0,
            annualRevenue: 0.0,
            monthlyExpenses: 0.0,
            liabilities: 0.0,
            fundingHistory: 'None',
            score: 0,
            riskLevel: 'N/A',
            generatedAt: DateTime.now(),
          ),
        ),
      ),
    );
  }

  bool _isMetricBest(
    String key,
    String value,
    List<Map<String, dynamic>> comparedItems,
  ) {
    if (comparedItems.length < 2) return false;

    if (value.contains('↑') || value.contains('✓')) return true;

    if (key == 'score') {
      int maxScore = 0;
      for (var item in comparedItems) {
        if ((item['score'] as int) > maxScore) {
          maxScore = item['score'] as int;
        }
      }
      return value == maxScore.toString();
    }

    return false;
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
          'Watchlist & Compare',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border(context), width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.trustBlue,
              unselectedLabelColor: AppColors.textSecondary(context),
              indicatorColor: AppColors.trustBlue,
              indicatorWeight: 3,
              labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(text: 'Watchlist (${_watchlist.length})'),
                Tab(text: 'Comparison (${_selectedForComparison.length}/3)'),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [_buildWatchlistView(), _buildComparisonView()],
        ),
      ),
    );
  }

  Widget _buildWatchlistView() {
    if (_watchlist.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          'Select up to 3 SMEs to compare side-by-side.',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        ..._watchlist.map((sme) => _buildWatchlistCard(sme)),
      ],
    );
  }

  Widget _buildComparisonView() {
    final comparingItems = _watchlist
        .where((item) => _selectedForComparison.contains(item['id']))
        .toList();

    if (comparingItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.gitCompare,
              size: AppSpacing.avatar,
              color: AppColors.textSecondary(context),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'No SMEs selected',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Select SMEs from your watchlist to compare',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            CustomButton(
              text: 'Go to Watchlist',
              variant: ButtonVariant.tertiary,
              onPressed: () {
                _tabController.animateTo(0); // Switch to Watchlist tab
              },
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [_buildComparisonTable(comparingItems)],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.heart,
            size: AppSpacing.avatar,
            color: AppColors.textSecondary(context),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No companies yet',
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Start adding companies to your watchlist',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          CustomButton(
            text: 'Explore Companies',
            variant: ButtonVariant.tertiary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistCard(Map<String, dynamic> sme) {
    final isSelected = _selectedForComparison.contains(sme['id']);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.smd),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode ? Colors.black.withValues(alpha: 0.2) : const Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              _navigateToProfile, // Routing directly to correct component on entire card tap
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Explicit Checkbox for Comparison
                SizedBox(
                  height: AppSpacing.xl,
                  width: AppSpacing.xl,
                  child: Checkbox(
                    value: isSelected,
                    activeColor: AppColors.trustBlue,
                    side: BorderSide(
                      color: AppColors.textSecondary(context),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    onChanged: (val) {
                      _toggleSelection(sme['id']);
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              sme['name'],
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColors.textPrimary(context),
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              LucideIcons.trash2,
                              size: AppSpacing.md,
                              color: AppColors.textSecondary(context),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _watchlist.removeWhere(
                                  (item) => item['id'] == sme['id'],
                                );
                                _selectedForComparison.remove(sme['id']);
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        sme['industry'],
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      SizedBox(height: AppSpacing.smd),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: sme['scoreColor'],
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              sme['score'].toString(),
                              style: AppTypography.textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.neutralWhite,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            sme['growthSignal'],
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: (sme['isGrowthPositive'] as bool)
                                  ? AppColors.successGreen
                                  : AppColors.dangerRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonTable(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    final metrics = [
      {'label': 'Credibility Score', 'key': 'score'},
      {'label': 'Revenue', 'key': 'revenue'},
      {'label': 'YoY Growth', 'key': 'growthSignal'},
      {'label': 'Expense Ratio', 'key': 'expenseRatio'},
      {'label': 'Payment Reliability', 'key': 'paymentReliability'},
      {'label': 'Funding History', 'key': 'fundingHistory'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: AppSpacing.xl,
          headingRowColor: WidgetStateProperty.all(AppColors.background(context)),
          columns: [
            const DataColumn(label: Text('')),
            ...items.map(
              (item) => DataColumn(
                label: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['name'],
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: AppSpacing.xs),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item['scoreColor'],
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          item['score'].toString(),
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.neutralWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          rows: metrics.map((metricDict) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    metricDict['label']!,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
                ...items.map((item) {
                  final valStr = item[metricDict['key']!].toString();
                  final isBest = _isMetricBest(
                    metricDict['key']!,
                    valStr,
                    items,
                  );
                  return DataCell(
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: isBest
                          ? BoxDecoration(
                              color: AppColors.successGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            )
                          : null,
                      child: Text(
                        valStr,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: isBest
                              ? AppColors.successGreen
                              : AppColors.textPrimary(context),
                          fontWeight: isBest
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
