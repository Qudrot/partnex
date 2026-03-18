import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/pages/login_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/business_profile_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_onboarding_page.dart';
import 'package:partnex/features/auth/data/models/user_model.dart';
import 'package:partnex/core/theme/widgets/sme_about_section.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/bio_edit_page.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/faq_page.dart';

class ProfileManagementPage extends StatefulWidget {
  const ProfileManagementPage({super.key});

  @override
  State<ProfileManagementPage> createState() => _ProfileManagementPageState();
}

class _ProfileManagementPageState extends State<ProfileManagementPage> {
  bool _dataPrivacyEnabled = true;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          uiService.clearAndNavigateTo(const LoginPage());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.slate50,
        appBar: AppBar(
          backgroundColor: AppColors.neutralWhite,
          elevation: 1,
          shadowColor: AppColors.slate200,
          leading: IconButton(
            icon: const Icon(
              LucideIcons.chevronLeft,
              color: AppColors.slate900,
            ),
            onPressed: () => uiService.goBack(),
          ),
          title: Text(
            'Profile Management',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: AppColors.slate900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              final profileState = context.watch<SmeProfileCubit>().state;
              final scoreState = context.watch<ScoreCubit>().state;

              int scoreValue = 0;
              String riskLevelString = 'High Risk';
              Color riskColor = AppColors.dangerRed;

              if (scoreState is ScoreLoadedSuccess) {
                final scoreData = scoreState.score;
                scoreValue = scoreData.totalScore.toInt();

                if (scoreData.riskLevel == RiskLevel.low) {
                  riskLevelString = 'Low Risk';
                  riskColor = AppColors.successGreen;
                } else if (scoreData.riskLevel == RiskLevel.medium) {
                  riskLevelString = 'Medium Risk';
                  riskColor = AppColors.warningAmber;
                }
              }

              final authState = context.watch<AuthBloc>().state;
              final userRole = (authState is AuthAuthenticated)
                  ? authState.user.role
                  : UserRole.sme;
              final isInvestor = userRole == UserRole.investor;

              return ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xl,
                ),
                children: [
                  // Profile Summary Card
                  Container(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.neutralWhite,
                      borderRadius: BorderRadius.circular(AppRadius.md),
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
                      children: [
                        Row(
                          children: [
                            Container(
                              width: AppSpacing.avatar,
                              height: AppSpacing.avatar,
                              decoration: BoxDecoration(
                                color: riskColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$scoreValue',
                                  style: AppTypography.textTheme.headlineMedium
                                      ?.copyWith(
                                        color: AppColors.neutralWhite,
                                        fontSize: 24,
                                      ),
                                ),
                              ),
                            ),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isInvestor
                                        ? 'Investor Profile'
                                        : (profileState.businessName.isNotEmpty
                                              ? profileState.businessName
                                              : 'Your Business'),
                                    style: AppTypography
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: AppColors.slate900,
                                          fontSize: 20,
                                        ),
                                  ),
                                  SizedBox(height: AppSpacing.xs),
                                  Text(
                                    isInvestor
                                        ? 'Verified Angel'
                                        : 'Industry: ${profileState.industry.isNotEmpty ? profileState.industry : 'N/A'}',
                                    style: AppTypography.textTheme.bodyMedium
                                        ?.copyWith(color: AppColors.slate600),
                                  ),
                                  SizedBox(height: AppSpacing.sm),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: riskColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                      border: Border.all(
                                        color: riskColor.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      riskLevelString,
                                      style: AppTypography.textTheme.labelSmall
                                          ?.copyWith(
                                            color: riskColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.smd),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.md),

                  // About Section (SME only)
                  if (!isInvestor)
                    SmeAboutSection(
                      bio: profileState.bio.isNotEmpty ? profileState.bio : null,
                      onEditBio: () => uiService.navigateTo(
                        BioEditPage(
                          initialBio: profileState.bio,
                          initialWebsite: profileState.websiteUrl,
                          initialWhatsapp: profileState.whatsappNumber,
                          initialLinkedin: profileState.linkedinUrl,
                          initialTwitter: profileState.twitterHandle,
                        ),
                      ),
                    ),

                  SizedBox(height: AppSpacing.xxl),

                  // Actions Section
                  Text(
                    'Actions',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.slate600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.smd),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.neutralWhite,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      children: [
                        _ActionTile(
                          title: isInvestor
                              ? 'Update Investment Preferences'
                              : 'Edit Profile Information',
                          icon: LucideIcons.edit2,
                          onTap: () => uiService.navigateTo(
                            isInvestor
                                ? const InvestorOnboardingPage(isEditing: true)
                                : const BusinessProfilePage(isEditMode: true),
                          ),
                        ),
                        Divider(height: 1, color: AppColors.slate200),
                        _ActionTile(
                          title: 'View Score History',
                          icon: LucideIcons.history,
                          onTap: () {},
                        ),
                        Divider(height: 1, color: AppColors.slate200),
                        _ActionTile(
                          title: 'Download All Reports',
                          icon: LucideIcons.download,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.xxl),

                  // Settings Section
                  Text(
                    'Settings',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.slate600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.smd),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.neutralWhite,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      children: [
                        _ToggleTile(
                          title: 'Data Sharing with Investors',
                          subtitle:
                              'Allow verified investors to view and download your uploaded bank statements',
                          icon: LucideIcons.shield,
                          value: profileState.allowSharing,
                          onChanged: (val) => context
                              .read<SmeProfileCubit>()
                              .updateSharingPolicy(val),
                        ),
                        Divider(height: 1, color: AppColors.slate200),
                        _ToggleTile(
                          title: 'Score Update Notifications',
                          subtitle:
                              'Receive alerts when your credibility score changes',
                          icon: LucideIcons.bellRing,
                          value: _notificationsEnabled,
                          onChanged: (val) =>
                              setState(() => _notificationsEnabled = val),
                        ),
                        Divider(height: 1, color: AppColors.slate200),
                        _ActionTile(
                          title: 'FAQ & Help',
                          icon: LucideIcons.helpCircle,
                          onTap: () => uiService.navigateTo(
                            const FaqPage(),
                          ),
                        ),
                        Divider(height: 1, color: AppColors.slate200),
                        _ActionTile(
                          title: 'Email Preferences',
                          icon: LucideIcons.mail,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.xxxxl),

                  CustomButton(
                    text: 'Log Out',
                    variant: ButtonVariant.primary,
                    icon: const Icon(
                      LucideIcons.logOut,
                      size: 16,
                      color: AppColors.neutralWhite,
                    ),
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutEvent());
                    },
                  ),

                  SizedBox(height: AppSpacing.xl),

                    // Danger Zone
                  CustomButton(
                    text: 'Delete Account',
                    variant: ButtonVariant.dangerTertiary,
                    icon: const Icon(
                      LucideIcons.trash,
                      size: 16,
                      color: AppColors.dangerRed,),
                    onPressed: () {},
                  ),
                  
                  SizedBox(height: AppSpacing.xxl),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.slate600, size: 20),
      title: Text(
        title,
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
      onTap: onTap,
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.trustBlue,
      title: Text(
        title,
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.slate900,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.slate500,
        ),
      ),
      secondary: Icon(icon, color: AppColors.slate600, size: 20),
    );
  }
}
