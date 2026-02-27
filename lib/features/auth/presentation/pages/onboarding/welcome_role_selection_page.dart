import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/input_method_selection_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_onboarding_page.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';

class WelcomeRoleSelectionPage extends StatelessWidget {
  const WelcomeRoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Hero Section
              Text(
                'How will you use Partnex?',
                style: AppTypography.textTheme.displayMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to use Partnex.',
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.slate600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Role Selection
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _RoleCard(
                        title: 'I\'m an SME',
                        description: 'Get your credibility score and access funding opportunities',
                        ctaText: 'Continue as SME',
                        icon: LucideIcons.building,
                        isPrimary: true,
                        onTap: () {
                          // TODO: Save role as SME
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InputMethodSelectionPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _RoleCard(
                        title: 'I\'m an Investor',
                        description: 'Discover and evaluate credible SMEs',
                        ctaText: 'Continue as Investor',
                        icon: LucideIcons.briefcase,
                        isPrimary: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InvestorOnboardingPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
              //   child: Text.rich(
              //     TextSpan(
              //       text: 'By continuing, you agree to our ',
              //       style: AppTypography.textTheme.bodySmall?.copyWith(
              //         color: AppColors.slate600,
              //       ),
              //       children: [
              //         TextSpan(
              //           text: 'Terms of Service',
              //           style: AppTypography.textTheme.bodySmall?.copyWith(
              //             color: AppColors.trustBlue,
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //         const TextSpan(text: ' and '),
              //         TextSpan(
              //           text: 'Privacy Policy',
              //           style: AppTypography.textTheme.bodySmall?.copyWith(
              //             color: AppColors.trustBlue,
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //       ],
              //     ),
              //     textAlign: TextAlign.center,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String title;
  final String description;
  final String ctaText;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.ctaText,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isPrimary
        ? (_isHovered ? AppColors.slate50 : AppColors.neutralWhite)
        : (_isHovered ? AppColors.slate100 : AppColors.slate50);

    final borderColor = widget.isPrimary
        ? (_isHovered ? AppColors.trustBlue : AppColors.slate200)
        : Colors.transparent;

    final borderWidth = widget.isPrimary && _isHovered ? 2.0 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        onHighlightChanged: (isHighlighted) {
          setState(() => _isHovered = isHighlighted);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isPrimary
                      ? AppColors.trustBlue.withValues(alpha: 0.1)
                      : AppColors.slate200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isPrimary
                      ? AppColors.trustBlue
                      : AppColors.slate700,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate600,
                ),
              ),
              const SizedBox(height: 24),
              IgnorePointer(
                child: CustomButton(
                  text: widget.ctaText,
                  onPressed: () {},
                  variant: widget.isPrimary ? ButtonVariant.primary : ButtonVariant.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
