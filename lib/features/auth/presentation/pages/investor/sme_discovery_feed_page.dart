import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/features/auth/presentation/blocs/discovery_cubit/discovery_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/discovery_cubit/discovery_state.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_profile_page.dart';
import 'package:partnex/features/auth/presentation/pages/login_page.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_onboarding_page.dart';
import 'package:partnex/features/auth/data/models/sme_profile_data.dart';
import 'package:partnex/core/theme/widgets/circular_score_ring.dart';

class SmeDiscoveryFeedPage extends StatefulWidget {
  const SmeDiscoveryFeedPage({super.key});

  @override
  State<SmeDiscoveryFeedPage> createState() => _SmeDiscoveryFeedPageState();
}

class _SmeDiscoveryFeedPageState extends State<SmeDiscoveryFeedPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter state
  String? _filterRiskLevel;   // e.g. 'Low', 'Medium', 'High'
  String? _filterSector;      // e.g. 'Technology'
  String? _filterYoy;         // e.g. 'Growing', 'Declining'

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() => context.read<DiscoveryCubit>().loadSmes();

  void _navigateToProfile(SmeCardData sme) =>
      context.read<DiscoveryCubit>().viewSmeProfile(sme);

  // ─── Filter helpers ─────────────────────────────────────────────────────────
  bool _matchesFilters(SmeCardData sme) {
    // Risk
    if (_filterRiskLevel != null) {
      if (!sme.riskLevel.toLowerCase().contains(_filterRiskLevel!.toLowerCase())) return false;
    }
    // Sector
    if (_filterSector != null) {
      if (!sme.industry.toLowerCase().contains(_filterSector!.toLowerCase())) return false;
    }
    // YoY
    if (_filterYoy != null) {
      if (_filterYoy == 'Growing' && sme.yoyGrowth < 0) return false;
      if (_filterYoy == 'Declining' && sme.yoyGrowth >= 0) return false;
    }
    return true;
  }

  List<SmeCardData> _applyFilters(List<SmeCardData> all) {
    // 1. Search
    var result = all.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.companyName.toLowerCase().contains(_searchQuery) ||
          s.industry.toLowerCase().contains(_searchQuery);
    }).toList();
    // 2. Filters
    result = result.where(_matchesFilters).toList();
    // 3. Sort newest first (uses generatedAt as proxy for creation date)
    result.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return result;
  }

  // ─── Get unique sectors from loaded state ────────────────────────────────────
  List<String> _getSectors(List<SmeCardData> smes) =>
      smes.map((e) => e.industry).toSet().toList()..sort();

  bool get _hasActiveFilters =>
      _filterRiskLevel != null || _filterSector != null || _filterYoy != null;

  int get _activeFilterCount => [_filterRiskLevel, _filterSector, _filterYoy]
      .where((e) => e != null)
      .length;

  void _clearFilters() => setState(() {
        _filterRiskLevel = null;
        _filterSector = null;
        _filterYoy = null;
      });

  // ─── Filter bottom sheet ─────────────────────────────────────────────────────
  void _openFilterSheet(List<SmeCardData> allSmes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        allSmes: allSmes,
        sectors: _getSectors(allSmes),
        currentRisk: _filterRiskLevel,
        currentSector: _filterSector,
        currentYoy: _filterYoy,
        onApply: (risk, sector, yoy) {
          setState(() {
            _filterRiskLevel = risk;
            _filterSector = sector;
            _filterYoy = yoy;
          });
        },
        onClear: _clearFilters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            uiService.clearAndNavigateTo(const LoginPage());
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProfileStatusBanner(),
              if (_hasActiveFilters) _buildActiveFilterBar(),
              Expanded(
                child: BlocBuilder<DiscoveryCubit, DiscoveryState>(
                  builder: (context, state) {
                    if (state is DiscoveryLoading || state is DiscoveryInitial) {
                      return const Center(
                          child: CircularProgressIndicator(color: AppColors.trustBlue));
                    }
                    if (state is DiscoveryError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            state.message,
                            style: AppTypography.textTheme.bodyMedium
                                ?.copyWith(color: AppColors.dangerRed),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    if (state is DiscoveryLoaded) {
                      final smes = _applyFilters(state.smes);
                      if (smes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.searchX, size: 40, color: AppColors.textSecondary(context)),
                              const SizedBox(height: 12),
                              Text(
                                'No businesses match your search${_hasActiveFilters ? ' or filters' : ''}.',
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary(context)),
                                textAlign: TextAlign.center,
                              ),
                              if (_hasActiveFilters) ...[
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _clearFilters,
                                  child: const Text('Clear Filters'),
                                ),
                              ],
                            ],
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async => _loadData(),
                        color: AppColors.trustBlue,
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                          itemCount: smes.length,
                          separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) => _buildSmeCard(smes[index]),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return BlocBuilder<DiscoveryCubit, DiscoveryState>(
      builder: (context, state) {
        final allSmes = state is DiscoveryLoaded ? state.smes : <SmeCardData>[];
        return Container(
          color: AppColors.surface(context),
          padding:
              EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(LucideIcons.menu, size: 24, color: AppColors.textPrimary(context)),
                onPressed: () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated && !authState.user.profileCompleted) {
                    uiService.navigateTo(const InvestorOnboardingPage(isEditing: true));
                  } else {
                    uiService.navigateTo(const InvestorProfilePage());
                  }
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.background(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search by company name or industry...',
                      hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                      prefixIcon: Icon(LucideIcons.search, size: 16, color: AppColors.textSecondary(context)),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Filter button
              GestureDetector(
                onTap: () => _openFilterSheet(allSmes),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _hasActiveFilters
                        ? AppColors.trustBlue.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: _hasActiveFilters
                        ? Border.all(color: AppColors.trustBlue.withValues(alpha: 0.4))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.filter,
                        size: 16,
                        color: _hasActiveFilters ? AppColors.trustBlue : AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _hasActiveFilters ? 'Filters ($_activeFilterCount)' : 'Filters',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: _hasActiveFilters ? AppColors.trustBlue : AppColors.textSecondary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Active filter bar ────────────────────────────────────────────────────────
  Widget _buildActiveFilterBar() {
    final chips = <Widget>[];
    if (_filterRiskLevel != null) {
      chips.add(_filterChip('Risk: $_filterRiskLevel', () => setState(() => _filterRiskLevel = null)));
    }
    if (_filterSector != null) {
      chips.add(_filterChip('Sector: $_filterSector', () => setState(() => _filterSector = null)));
    }
    if (_filterYoy != null) {
      chips.add(_filterChip('YoY: $_filterYoy', () => setState(() => _filterYoy = null)));
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8.0),
      color: AppColors.surface(context),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.trustBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.trustBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.trustBlue,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(LucideIcons.x, size: 12, color: AppColors.trustBlue),
          ),
        ],
      ),
    );
  }

  // ─── Profile banner ───────────────────────────────────────────────────────────
  Widget _buildProfileStatusBanner() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated && !state.user.profileCompleted) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.smd),
            decoration: BoxDecoration(
              color: AppColors.trustBlue.withValues(alpha: 0.1),
              border: const Border(bottom: BorderSide(color: AppColors.trustBlue, width: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.userPlus, size: 20, color: AppColors.trustBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete your profile',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: AppColors.textPrimary(context), fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Set your investment preferences to find better SME matches.',
                        style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  text: 'Set Up',
                  variant: ButtonVariant.tertiary,
                  onPressed: () =>
                      uiService.navigateTo(const InvestorOnboardingPage(isEditing: true)),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ─── SME Card ─────────────────────────────────────────────────────────────────
  Widget _buildSmeCard(SmeCardData sme) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode ? Colors.black.withValues(alpha: 0.2) : const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToProfile(sme),
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColors.background(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: AppSpacing.smd),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sme.companyName,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary(context)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${sme.industry} · ',
                              style: AppTypography.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary(context), fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Text(
                            sme.displayLocation,
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary(context), fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sme.growthSignal,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: sme.isGrowthPositive
                              ? AppColors.successGreen
                              : AppColors.dangerRed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CircularScoreRing(score: sme.score, size: 64, fontSizeOverride: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Filter Sheet ─────────────────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final List<SmeCardData> allSmes;
  final List<String> sectors;
  final String? currentRisk;
  final String? currentSector;
  final String? currentYoy;
  final void Function(String? risk, String? sector, String? yoy) onApply;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.allSmes,
    required this.sectors,
    required this.currentRisk,
    required this.currentSector,
    required this.currentYoy,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _risk;
  String? _sector;
  String? _yoy;

  @override
  void initState() {
    super.initState();
    _risk = widget.currentRisk;
    _sector = widget.currentSector;
    _yoy = widget.currentYoy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter SMEs', style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: () {
                  setState(() { _risk = null; _sector = null; _yoy = null; });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionLabel('Risk Level'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: ['Low', 'Medium', 'High'].map((r) {
            final selected = _risk == r;
            return _chip(r, selected, () => setState(() => _risk = selected ? null : r));
          }).toList()),
          const SizedBox(height: 16),
          _sectionLabel('YoY Growth'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: ['Growing', 'Declining'].map((y) {
            final selected = _yoy == y;
            return _chip(y, selected, () => setState(() => _yoy = selected ? null : y));
          }).toList()),
          if (widget.sectors.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionLabel('Sector'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 6,
              children: widget.sectors.map((s) {
                final selected = _sector == s;
                return _chip(s, selected, () => setState(() => _sector = selected ? null : s));
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.trustBlue,
                foregroundColor: AppColors.neutralWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                widget.onApply(_risk, _sector, _yoy);
                Navigator.pop(context);
              },
              child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: AppTypography.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600, color: AppColors.textPrimary(context)),
  );

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.trustBlue : AppColors.background(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.trustBlue : AppColors.border(context)),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: selected ? AppColors.neutralWhite : AppColors.textPrimary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
