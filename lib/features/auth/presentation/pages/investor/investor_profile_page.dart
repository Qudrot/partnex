import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/theme_cubit/theme_cubit.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_onboarding_page.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/faq_page.dart';

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
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'My Profile',
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
        backgroundColor: AppColors.surface(context),
        elevation: 1,
        shadowColor: AppColors.border(context),
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary(context)),
          onPressed: () => uiService.goBack(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.xl),
          children: [
            if (!isProfileCompleted)
              Padding(
                padding: EdgeInsets.only(bottom: 24),
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
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border(context)),
                  boxShadow: [
                    BoxShadow(
                      color: context.isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (authState is AuthAuthenticated) ...[
                      if (authState.user.investorType != null)
                        _buildProfileDetail(
                          LucideIcons.briefcase, 
                          'Investor Type', 
                          authState.user.investorType!,
                        ),
                      if (authState.user.investorType != 'Individual Investor' && authState.user.company != null && authState.user.company!.isNotEmpty)
                        _buildProfileDetail(
                          LucideIcons.building2, 
                          'Company', 
                          authState.user.company!,
                        ),
                      if (authState.user.investmentRange != null)
                        _buildProfileDetail(
                          LucideIcons.dollarSign, 
                          'Investment Range', 
                          authState.user.investmentRange!,
                        ),
                      if (authState.user.sectors != null && authState.user.sectors!.isNotEmpty)
                        _buildProfileDetail(
                          LucideIcons.layoutGrid, 
                          'Interests', 
                          authState.user.sectors!.join(', '),
                        ),
                    ],
                  ],
                ),
              ),
            SizedBox(height: AppSpacing.xxl),
            Text(
              'Preferences',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            SizedBox(height: AppSpacing.smd),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: SwitchListTile(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (val) {
                  context.read<ThemeCubit>().toggleTheme();
                },
                title: Text(
                  'Turn on Dark Mode',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                secondary: Icon(
                  LucideIcons.moon,
                  color: AppColors.textSecondary(context),
                  size: 20,
                ),
                activeColor: AppColors.trustBlue,
              ),
            ),

            SizedBox(height: AppSpacing.xxl),
            Text(
              'Actions',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            SizedBox(height: AppSpacing.smd),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      LucideIcons.edit2,
                      color: AppColors.textSecondary(context),
                      size: 20,
                    ),
                    title: Text(
                      'Update Investment Preferences',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: AppColors.textSecondary(context),
                    ),
                    onTap: () => uiService.navigateTo(
                      const InvestorOnboardingPage(isEditing: true),
                    ),
                  ),
                    Divider(height: 1, color: AppColors.border(context)),
                    ListTile(
                      leading: Icon(
                      LucideIcons.helpCircle,
                      color: AppColors.textSecondary(context),
                      size: 20,
                    ),
                      title: Text(
                        'FAQ & Help',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: AppColors.textSecondary(context),
                      ),
                      onTap: () => uiService.navigateTo(
                        FaqPage(isInvestor: true),
                      ),
                    ),
                  ],
                ),
              ),


            SizedBox(height: AppSpacing.xxxxl),

            CustomButton(
              onPressed: () {
                context.read<AuthBloc>().add(LogoutEvent());
              },
              variant: ButtonVariant.primary,
              isFullWidth: true,
              icon: const Icon(
                LucideIcons.logOut,
                size: 16,
                color: AppColors.neutralWhite,
              ),
              text: 'Log Out',
            ),

            SizedBox(height: AppSpacing.xl),

            SizedBox(height: AppSpacing.xl),
                  
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary(context)),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
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
    return 'Your profile is incomplete!';
  }

  String get _copyText {
    return 'Tell us what you are looking for so we can recommend the best SMEs.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.border(context),
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
              Icon(
                LucideIcons.clipboardList,
                size: AppSpacing.xl,
                color: AppColors.textSecondary(context),
              ),
              SizedBox(width: AppSpacing.smd),
              Expanded(
                child: Text(
                  _title,
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.smd),
          Text(
            _copyText,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
               fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary(context),
            ),
          ),
          SizedBox(height: AppSpacing.md),

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
            SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.border(context),
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
            SizedBox(height: AppSpacing.sm),
            Text(
              '${widget.completionPercentage!.toInt()}% Complete (${widget.completedSections} of ${widget.totalSections} sections)',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
