import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_input_field.dart';
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
  final List<String> _activeFilters = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<DiscoveryCubit>().loadSmes();
  }

  void _navigateToProfile(SmeCardData sme) {
    context.read<DiscoveryCubit>().viewSmeProfile(sme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
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
              _buildFilterBar(),
              Expanded(
                child: BlocBuilder<DiscoveryCubit, DiscoveryState>(
                  builder: (context, state) {
                    if (state is DiscoveryLoading ||
                        state is DiscoveryInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.trustBlue,
                        ),
                      );
                    } else if (state is DiscoveryError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            state.message,
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.dangerRed,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    } else if (state is DiscoveryLoaded) {
                      final smes = state.smes;

                      if (smes.isEmpty) {
                        return Center(
                          child: Text(
                            'No businesses found matching your preferences.',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.slate600,
                            ),
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
                          separatorBuilder: (context, index) =>
                              SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            return _buildSmeCard(smes[index]);
                          },
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

  Widget _buildProfileStatusBanner() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated && !state.user.profileCompleted) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.smd),
            decoration: BoxDecoration(
              color: AppColors.trustBlue.withValues(alpha: 0.1),
              border: const Border(
                bottom: BorderSide(color: AppColors.trustBlue, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.userPlus,
                  size: 20,
                  color: AppColors.trustBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete your profile',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: AppColors.slate900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Set your investment preferences to find better SME matches.',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.slate600,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  text: 'Set Up',
                  variant: ButtonVariant.tertiary,
                  onPressed: () => uiService.navigateTo(
                    const InvestorOnboardingPage(isEditing: true),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.neutralWhite,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              LucideIcons.menu,
              size: 24,
              color: AppColors.slate900,
            ),
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated &&
                  !authState.user.profileCompleted) {
                uiService.navigateTo(
                  const InvestorOnboardingPage(isEditing: true),
                );
              } else {
                uiService.navigateTo(const InvestorProfilePage());
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomInputField(
              label: '',
              placeholder: 'Search by company name or industry...',
              onChanged: (val) {
                // Search logic
              },
              prefixIcon: const Icon(
                LucideIcons.search,
                size: 16,
                color: AppColors.slate400,
              ),
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildCompactFilterButton(),
        ],
      ),
    );
  }

  Widget _buildCompactFilterButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              const Icon(
                LucideIcons.filter,
                size: 16,
                color: AppColors.slate600,
              ),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.slate600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    if (_activeFilters.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8.0),
      decoration: const BoxDecoration(
        color: AppColors.neutralWhite,
        border: Border(bottom: BorderSide(color: AppColors.slate200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _activeFilters.map((filter) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.trustBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.trustBlue.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          filter,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.trustBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _activeFilters.remove(filter);
                            });
                          },
                          child: const Icon(
                            LucideIcons.x,
                            size: 14,
                            color: AppColors.trustBlue,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmeCard(SmeCardData sme) {
    return Container(
      // Removed fixed 64px height to prevent vertical overflow
      constraints: const BoxConstraints(minHeight: 64),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.slate200),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToProfile(sme),
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColors.slate50,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: AppSpacing.smd,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Section (Business Information) ~60%
                Expanded(
                  flex: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // Let column fit content
                    children: [
                      SizedBox(
                        height: 44, // Fixed height for 2 lines
                        child: Text(
                          sme.companyName,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.slate900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${sme.industry} · ',
                              style: AppTypography.textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.slate600,
                                    fontSize: 12,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Text(
                            sme.displayLocation,
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.slate600,
                              fontSize: 12,
                            ),
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
                // Center Section (Empty to maintain structure or can be removed if strictly 2 columns now)
                Expanded(
                  flex: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Stat moved to title row, keeping this flex empty to push score to the right
                      // or we could place revenue here if requested.
                    ],
                  ),
                ),
                // Right Section (Score Badge) ~10%
                // Score Badge (Clicking anywhere on card handles navigation)
                const SizedBox(width: 12),
                CircularScoreRing(
                  score: sme.score,
                  size: 64,
                  fontSizeOverride: 15,
                ),
                // Note: risk label is hidden on mobile per spec
                // to maintain strict 64px height and density.
              ],
            ),
          ),
        ),
      ),
    );
  }
}
