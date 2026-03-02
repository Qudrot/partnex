import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_event.dart';
import 'package:partnex/features/auth/presentation/pages/login_page.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_onboarding_page.dart';

class InvestorProfilePage extends StatelessWidget {
  const InvestorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.white,
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
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white,
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
                        child: const Icon(LucideIcons.userCheck, color: AppColors.trustBlue, size: 28),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verified Investor',
                              style: AppTypography.textTheme.headlineMedium?.copyWith(
                                color: AppColors.slate900,
                                fontSize: 20,
                              ),
                            ),
                  const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Your submitted investment criteria is actively matching you with credible SMEs on the platform.',
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: AppColors.slate600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Edit Profile Link
                  const SizedBox(height: AppSpacing.smd),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      onTap: () => uiService.navigateTo(const InvestorOnboardingPage(isEditing: true)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.pencil, size: 14, color: AppColors.trustBlue),
                            const SizedBox(width: AppSpacing.xs),
                            Text('Edit Profile', style: AppTypography.textTheme.labelSmall?.copyWith(color: AppColors.trustBlue, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.edit2, color: AppColors.slate600, size: 20),
                    title: Text(
                      'Update Investment Criteria',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.slate400),
                    onTap: () => uiService.navigateTo(const InvestorOnboardingPage(isEditing: true)),
                  ),
                  Divider(height: 1, color: AppColors.slate200),
                  ListTile(
                    leading: const Icon(LucideIcons.settings, color: AppColors.slate600, size: 20),
                    title: Text(
                      'Account Settings',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.slate400),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxxl),

            Center(
              child: TextButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                  uiService.clearAndNavigateTo(const LoginPage());
                },
                icon: const Icon(LucideIcons.logOut, size: 16, color: AppColors.dangerRed),
                label: Text(
                  'Log Out',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.dangerRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
