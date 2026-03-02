import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/partnex_logo.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_state.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_discovery_feed_page.dart';

import 'package:partnex/features/auth/presentation/pages/investor/investor_profile_page.dart';

class InvestorOnboardingPage extends StatefulWidget {
  final bool isEditing;

  const InvestorOnboardingPage({
    super.key,
    this.isEditing = false,
  });

  @override
  State<InvestorOnboardingPage> createState() => _InvestorOnboardingPageState();
}

class _InvestorOnboardingPageState extends State<InvestorOnboardingPage> {
  String _selectedRole = 'Individual Angel Investor';
  final Set<String> _selectedSectors = {};
  String? _selectedTicketSize;

  final List<Map<String, String>> _roles = [
    {
      'title': 'Individual Angel Investor',
      'description': 'I invest personal capital in promising SMEs',
    },
    {
      'title': 'Venture Capital Fund',
      'description': 'We manage a fund focused on SME investments',
    },
    {
      'title': 'Impact Fund',
      'description': 'We prioritize social or environmental impact',
    },
    {
      'title': 'Financial Institution',
      'description': 'We provide lending or financing services',
    },
    {
      'title': 'Corporate Investor',
      'description': 'We seek strategic partnerships with SMEs',
    },
  ];

  final List<String> _sectors = [
    'Manufacturing',
    'Technology & Software',
    'Retail & E-commerce',
    'Healthcare & Pharma',
    'Agriculture & Food',
    'Logistics & Transportation',
    'Financial Services',
    'Professional Services',
    'Education',
    'Other',
  ];

  final List<String> _ticketSizes = [
    'Less than ₦1M',
    '₦1M ‒ ₦10M',
    '₦10M ‒ ₦50M',
    '₦50M ‒ ₦100M',
    '₦100M+',
  ];

  void _navigateToFeed() {
    uiService.replaceWith(const SmeDiscoveryFeedPage());
  }

  void _submitProfile() {
    context.read<AuthBloc>().add(SubmitInvestorProfileEvent({
      'role': _selectedRole,
      'sectors': _selectedSectors.toList(),
      'ticketSize': _selectedTicketSize ?? 'Not Specified',
    }, isEditing: widget.isEditing));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is InvestorProfileSubmitting;
        return Scaffold(
          backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    
                    // Header Logo
                    // const Center(
                    //   child: PartnexLogo(size: 32, variant: PartnexLogoVariant.brandCombo),
                    // ),
                    // const SizedBox(height: 32),

                    // Hero Section
                    Text(
                      'Welcome to Partnex',
                      style: AppTypography.textTheme.headlineLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discover credible SMEs aligned with your investment criteria.',
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: AppColors.slate600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Role Selection
                    Text(
                      'What best describes your role?',
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        fontSize: 16,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._roles.map((role) {
                      final isSelected = _selectedRole == role['title'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: () => setState(() => _selectedRole = role['title']!),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.trustBlue : AppColors.slate100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? AppColors.trustBlue : Colors.transparent,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  role['title']!,
                                  style: AppTypography.textTheme.labelLarge?.copyWith(
                                    color: isSelected ? Colors.white : AppColors.slate900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  role['description']!,
                                  style: AppTypography.textTheme.bodySmall?.copyWith(
                                    color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.slate600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 32),

                    // Sectors Selection
                    Text(
                      'What sectors interest you? (Select all that apply)',
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        fontSize: 16,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sectors.map((sector) {
                        final isSelected = _selectedSectors.contains(sector);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedSectors.remove(sector);
                              } else {
                                _selectedSectors.add(sector);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.trustBlue : Colors.white,
                              border: Border.all(
                                color: isSelected ? AppColors.trustBlue : AppColors.slate200,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  const Icon(LucideIcons.check, size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  sector,
                                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                                    color: isSelected ? Colors.white : AppColors.slate700,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // Ticket Size Selection
                    Text(
                      'What\'s your typical investment size?',
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        fontSize: 16,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: _ticketSizes.map((size) {
                        return RadioListTile<String>(
                          title: Text(
                            size,
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.slate900,
                            ),
                          ),
                          value: size,
                          groupValue: _selectedTicketSize,
                          activeColor: AppColors.trustBlue,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            setState(() => _selectedTicketSize = value);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.slate200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: widget.isEditing ? 'Cancel' : 'Skip',
                      variant: ButtonVariant.secondary,
                      onPressed: widget.isEditing ? () => uiService.goBack() : _navigateToFeed,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: widget.isEditing ? 'Save Profile' : 'Continue',
                      variant: ButtonVariant.primary,
                      isLoading: isLoading,
                      onPressed: _submitProfile,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
