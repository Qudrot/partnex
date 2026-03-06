import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_state.dart';
import 'package:partnex/features/auth/presentation/pages/login_page.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_onboarding_page.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';

class InvestorProfilePage extends StatefulWidget {
  const InvestorProfilePage({super.key});

  @override
  State<InvestorProfilePage> createState() => _InvestorProfilePageState();
}

class _InvestorProfilePageState extends State<InvestorProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isProfileCompleted = authState is AuthAuthenticated
        ? authState.user.profileCompleted
        : true; // default to true to hide if not authenticated

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: AppColors.neutralWhite,
        elevation: 1,
        shadowColor: AppColors.slate200,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
          onPressed: () => uiService.goBack(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            if (!isProfileCompleted)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: EmptyProfileCard(
                  variant: 'first-time',
                  completionPercentage: 0,
                  onComplete: () => uiService.navigateTo(
                    const InvestorOnboardingPage(isEditing: true),
                  ),
                ),
              ),
            if (isProfileCompleted)
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.neutralWhite,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.slate200),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.slate200.withValues(alpha: 0.5),
                      blurRadius: AppRadius.sm,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.smd),
                          decoration: BoxDecoration(
                            color: AppColors.trustBlue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.userCheck,
                            color: AppColors.trustBlue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verified Investor',
                                style: AppTypography.textTheme.headlineMedium
                                    ?.copyWith(
                                      color: AppColors.slate900,
                                      fontSize: 20,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Your submitted investment preferences are actively matching you with credible SMEs on the platform.',
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.slate600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Actions',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.slate600,
              ),
            ),
            const SizedBox(height: AppSpacing.smd),
            Container(
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      LucideIcons.edit2,
                      color: AppColors.slate600,
                      size: 20,
                    ),
                    title: Text(
                      'Update Investment Preferences',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: AppColors.slate400,
                    ),
                    onTap: () => uiService.navigateTo(
                      const InvestorOnboardingPage(isEditing: true),
                    ),
                  ),
                  Divider(height: 1, color: AppColors.slate200),
                  ListTile(
                    leading: const Icon(
                      LucideIcons.settings,
                      color: AppColors.slate600,
                      size: 20,
                    ),
                    title: Text(
                      'Account Settings',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: AppColors.slate400,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxxl),

            Center(
              child: CustomButton(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                  uiService.clearAndNavigateTo(const LoginPage());
                },
                variant: ButtonVariant.tertiary,
                icon: const Icon(
                  LucideIcons.logOut,
                  size: 16,
                  color: AppColors.dangerRed,
                ),
                text: 'Log Out',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyProfileCard extends StatefulWidget {
  final double? completionPercentage;
  final int totalSections;
  final int completedSections;
  final String variant; // 'first-time' | 'partial' | 'returning'
  final VoidCallback? onComplete;

  const EmptyProfileCard({
    super.key,
    this.completionPercentage,
    this.totalSections = 5,
    this.completedSections = 0,
    this.variant = 'first-time',
    this.onComplete,
  });

  @override
  State<EmptyProfileCard> createState() => _EmptyProfileCardState();
}

class _EmptyProfileCardState extends State<EmptyProfileCard> {
  bool _isLoading = false;

  Future<void> _handleCompleteProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (widget.onComplete != null) {
        // Adding a slight delay for visual feedback if desired
        await Future.delayed(const Duration(milliseconds: 300));
        widget.onComplete!();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String get _title {
    switch (widget.variant) {
      case 'partial':
        return "You're Almost There!";
      case 'returning':
        return 'Finish Your Profile';
      case 'first-time':
      default:
        return 'Complete Your Profile';
    }
  }

  String get _copyText {
    switch (widget.variant) {
      case 'partial':
        return 'Complete your profile to unlock full platform features and better matching.';
      case 'returning':
        return 'Finish your profile to increase visibility and attract more relevant SME opportunities.';
      case 'first-time':
      default:
        return 'Get started by completing your investor profile. This helps SMEs understand your investment strategy and experience.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.slate300,
          width: 2,
        ),
        // Alternatively, you could use a CustomPainter for dashed borders,
        // but solid borders convey the same visual hierarchy effectively.
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              const Icon(
                LucideIcons.clipboardList,
                size: AppSpacing.xl,
                color: AppColors.slate600,
              ),
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: Text(
                  _title,
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.slate900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.smd),
          Text(
            _copyText,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.6,
              color: AppColors.slate600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // CTA Section
          CustomButton(
            text: _isLoading ? 'Loading...' : 'Complete Profile',
            onPressed: _handleCompleteProfile,
            isLoading: _isLoading,
            icon: _isLoading
                ? null
                : const Icon(
                    LucideIcons.arrowRight,
                    size: AppSpacing.md,
                    color: AppColors.neutralWhite,
                  ),
          ),

          // Progress Section
          if (widget.completionPercentage != null &&
              widget.completionPercentage! > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.slate200,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (widget.completionPercentage! / 100).clamp(
                  0.0,
                  1.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.trustBlue,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${widget.completionPercentage!.toInt()}% Complete (${widget.completedSections} of ${widget.totalSections} sections)',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: AppColors.slate600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
