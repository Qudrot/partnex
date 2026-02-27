import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_state.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/welcome_role_selection_page.dart';

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
          // Navigate to welcome page and clear navigation stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const WelcomeRoleSelectionPage(),
            ),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: AppColors.slate200,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile Management',
          style: AppTypography.textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          children: [
            // Profile Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.slate200),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.slate200.withValues(alpha: 0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '85',
                            style: AppTypography.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
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
                              'Acme Manufacturing',
                              style: AppTypography.textTheme.headlineMedium?.copyWith(
                                color: AppColors.slate900,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Industry: Manufacturing',
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: AppColors.slate600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.successGreen.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    'Low Risk',
                                    style: AppTypography.textTheme.labelSmall?.copyWith(
                                      color: AppColors.successGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Updated Feb 24',
                                  style: AppTypography.textTheme.bodySmall?.copyWith(
                                    color: AppColors.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Actions Section
            Text(
              'Actions',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.slate600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                children: [
                  _ActionTile(
                    title: 'Edit Profile Information',
                    icon: LucideIcons.edit2,
                    onTap: () {},
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

            const SizedBox(height: 32),

            // Settings Section
            Text(
              'Settings',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.slate600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                children: [
                  _ToggleTile(
                    title: 'Data Sharing with Investors',
                    subtitle: 'Allow verified investors to view your score',
                    icon: LucideIcons.shield,
                    value: _dataPrivacyEnabled,
                    onChanged: (val) => setState(() => _dataPrivacyEnabled = val),
                  ),
                  Divider(height: 1, color: AppColors.slate200),
                  _ToggleTile(
                    title: 'Score Update Notifications',
                    subtitle: 'Receive alerts when your credibility score changes',
                    icon: LucideIcons.bellRing,
                    value: _notificationsEnabled,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
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

            const SizedBox(height: 48),

            // Danger Zone
            CustomButton(
              text: 'Delete Account',
              variant: ButtonVariant.tertiary,
              onPressed: () {},
              // Customizing styling for danger isn't directly supported by our generic variant, 
              // but we can use text style overrides inside the button or a custom widget.
            ),

            const SizedBox(height: 24),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                },
                icon: const Icon(LucideIcons.logOut, size: 16, color: AppColors.slate600),
                label: Text(
                  'Log Out',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.slate600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
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
      trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.slate400),
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
