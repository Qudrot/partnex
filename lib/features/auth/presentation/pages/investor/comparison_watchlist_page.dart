import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_profile_expanded_page.dart';

class ComparisonWatchlistPage extends StatefulWidget {
  const ComparisonWatchlistPage({super.key});

  @override
  State<ComparisonWatchlistPage> createState() => _ComparisonWatchlistPageState();
}

class _ComparisonWatchlistPageState extends State<ComparisonWatchlistPage> with SingleTickerProviderStateMixin {
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
      'risk': 'Low Risk',
      'revenue': '₦750K',
      'employees': '25',
      'liabilities': '₦200K',
      'paymentHistory': 'On Time ✓',
      'fundingStatus': 'Funded ✓',
    },
    {
      'id': '2',
      'name': 'TechStart',
      'industry': 'Technology',
      'growthSignal': '↑ 45% YoY',
      'isGrowthPositive': true,
      'score': 62,
      'scoreColor': AppColors.warningAmber,
      'risk': 'Medium Risk',
      'revenue': '₦500K',
      'employees': '12',
      'liabilities': '₦150K',
      'paymentHistory': 'On Time ✓',
      'fundingStatus': 'Funded ✓',
    },
    {
      'id': '3',
      'name': 'Retail Ltd',
      'industry': 'Retail',
      'growthSignal': '↓ 5% YoY',
      'isGrowthPositive': false,
      'score': 45,
      'scoreColor': AppColors.dangerRed,
      'risk': 'High Risk',
      'revenue': '₦300K',
      'employees': '8',
      'liabilities': '₦400K',
      'paymentHistory': 'Late',
      'fundingStatus': 'None',
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can only compare up to 3 SMEs at a time', style: AppTypography.textTheme.bodyMedium?.copyWith(color: Colors.white)),
              backgroundColor: AppColors.slate900,
              behavior: SnackBarBehavior.floating,
            ),
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
          sme: const SmeCardData(
            companyName: 'SME Profile',
            industry: 'Unknown',
            location: 'Nigeria',
            employees: 'N/A',
            revenue: 'N/A',
            growthSignal: 'N/A',
            isGrowthPositive: true,
            trustFunded: false,
            trustPayments: false,
            trustStable: false,
            score: 0,
            riskLevel: 'N/A',
            scoreColor: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  bool _isMetricBest(String key, String value, List<Map<String, dynamic>> comparedItems) {
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
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Watchlist & Compare',
          style: AppTypography.textTheme.headlineMedium?.copyWith(
             fontSize: 16,
             color: AppColors.slate900,
             fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
           preferredSize: const Size.fromHeight(48),
           child: Container(
             decoration: const BoxDecoration(
               border: Border(bottom: BorderSide(color: AppColors.slate200, width: 1)),
             ),
             child: TabBar(
               controller: _tabController,
               labelColor: AppColors.trustBlue,
               unselectedLabelColor: AppColors.slate600,
               indicatorColor: AppColors.trustBlue,
               indicatorWeight: 3,
               labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
          children: [
             _buildWatchlistView(),
             _buildComparisonView(),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistView() {
     if (_watchlist.isEmpty) {
        return _buildEmptyState();
     }

     return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
           Text(
             'Select up to 3 SMEs to compare side-by-side.',
             style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.slate600),
           ),
           const SizedBox(height: 16),
           ..._watchlist.map((sme) => _buildWatchlistCard(sme)),
        ],
     );
  }

  Widget _buildComparisonView() {
     final comparingItems = _watchlist.where((item) => _selectedForComparison.contains(item['id'])).toList();
     
     if (comparingItems.isEmpty) {
        return Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
                const Icon(LucideIcons.gitCompare, size: 64, color: AppColors.slate300),
                const SizedBox(height: 16),
                Text(
                  'No SMEs selected',
                  style: AppTypography.textTheme.headlineSmall?.copyWith(color: AppColors.slate900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select SMEs from your watchlist to compare',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.slate500),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                     _tabController.animateTo(0); // Switch to Watchlist tab
                  },
                  child: Text(
                    'Go to Watchlist',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                       color: AppColors.trustBlue,
                       fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
             ],
           ),
        );
     }

     return Column(
        children: [
           _buildComparisonHeader(),
           Expanded(
             child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                   _buildComparisonTable(comparingItems),
                ],
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
            const Icon(LucideIcons.heart, size: 64, color: AppColors.slate300),
            const SizedBox(height: 16),
            Text(
              'No companies yet',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.slate900,
              ),
            ),
             const SizedBox(height: 8),
            Text(
              'Start adding companies to your watchlist',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate500,
              ),
            ),
             const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Explore Companies',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                   color: AppColors.trustBlue,
                   fontWeight: FontWeight.w600,
                ),
              ),
            ),
         ],
       ),
     );
  }

  Widget _buildComparisonHeader() {
     return Container(
       color: Colors.white,
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
       decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.slate200, width: 1)),
       ),
       child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
             TextButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.share2, size: 16, color: AppColors.trustBlue),
                label: Text('Share', style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.trustBlue)),
             ),
             TextButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.download, size: 16, color: AppColors.trustBlue),
                label: Text('Export PDF', style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.trustBlue)),
             ),
          ],
       ),
     );
  }

  Widget _buildWatchlistCard(Map<String, dynamic> sme) {
    final isSelected = _selectedForComparison.contains(sme['id']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.slate200),
        boxShadow: const [
          BoxShadow(
             color: Color.fromRGBO(0, 0, 0, 0.02),
             blurRadius: 4,
             offset: Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToProfile, // Routing directly to correct component on entire card tap
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  // Explicit Checkbox for Comparison
                  SizedBox(
                     height: 24,
                     width: 24,
                     child: Checkbox(
                       value: isSelected,
                       activeColor: AppColors.trustBlue,
                       side: const BorderSide(color: AppColors.slate300, width: 1.5),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                       onChanged: (val) {
                          _toggleSelection(sme['id']);
                       },
                     ),
                  ),
                  const SizedBox(width: 12),
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
                                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColors.slate900,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                   icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.slate400),
                                   padding: EdgeInsets.zero,
                                   constraints: const BoxConstraints(),
                                   onPressed: () {
                                       setState(() {
                                          _watchlist.removeWhere((item) => item['id'] == sme['id']);
                                          _selectedForComparison.remove(sme['id']);
                                       });
                                   },
                                ),
                             ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sme['industry'],
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.slate600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                             children: [
                               Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                     color: sme['scoreColor'],
                                     borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    sme['score'].toString(),
                                    style: AppTypography.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                               ),
                               const SizedBox(width: 8),
                                Text(
                                  sme['growthSignal'],
                                  style: AppTypography.textTheme.bodySmall?.copyWith(
                                    color: (sme['isGrowthPositive'] as bool) ? AppColors.successGreen : AppColors.dangerRed,
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
      {'label': 'Score', 'key': 'score'},
      {'label': 'Risk Level', 'key': 'risk'},
      {'label': 'Revenue', 'key': 'revenue'},
      {'label': 'Employees', 'key': 'employees'},
      {'label': 'Growth', 'key': 'growthSignal'},
      {'label': 'Liabilities', 'key': 'liabilities'},
      {'label': 'Payment History', 'key': 'paymentHistory'},
      {'label': 'Funding Status', 'key': 'fundingStatus'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.slate200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
           columnSpacing: 24,
           headingRowColor: WidgetStateProperty.all(AppColors.slate50),
           columns: [
              const DataColumn(label: Text('')), 
              ...items.map((item) => DataColumn(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                          Text(
                            item['name'],
                            style: AppTypography.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.slate900),
                          ),
                          Container(
                             margin: const EdgeInsets.only(top: 4),
                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                             decoration: BoxDecoration(color: item['scoreColor'], borderRadius: BorderRadius.circular(4)),
                             child: Text(item['score'].toString(), style: AppTypography.textTheme.labelSmall?.copyWith(color: Colors.white)),
                          )
                       ],
                    ),
                  ),
              )),
           ],
           rows: metrics.map((metricDict) {
               return DataRow(
                  cells: [
                     DataCell(Text(
                        metricDict['label']!,
                        style: AppTypography.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.slate600),
                     )),
                     ...items.map((item) {
                        final valStr = item[metricDict['key']!].toString();
                        final isBest = _isMetricBest(metricDict['key']!, valStr, items);
                        return DataCell(
                            Container(
                               padding: const EdgeInsets.all(6),
                               decoration: isBest ? BoxDecoration(
                                  color: AppColors.successGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                               ) : null,
                               child: Text(
                                  valStr,
                                  style: AppTypography.textTheme.bodySmall?.copyWith(
                                     color: isBest ? AppColors.successGreen : AppColors.slate900,
                                     fontWeight: isBest ? FontWeight.w600 : FontWeight.w400,
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
