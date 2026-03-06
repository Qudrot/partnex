import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_input_field.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_state.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_discovery_feed_page.dart';

class InvestorOnboardingPage extends StatefulWidget {
  final bool isEditing;

  const InvestorOnboardingPage({super.key, this.isEditing = false});

  @override
  State<InvestorOnboardingPage> createState() => _InvestorOnboardingPageState();
}

class _InvestorOnboardingPageState extends State<InvestorOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();

  final Set<String> _selectedSectors = {};

  final List<String> _sectors = [
    'Manufacturing',
    'Technology',
    'Retail',
    'Healthcare',
    'Agriculture',
    'Logistics',
    'Financial Services',
    'Professional Services',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _navigateToFeed() {
    uiService.replaceWith(const SmeDiscoveryFeedPage());
  }

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SubmitInvestorProfileEvent({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'company': _companyController.text.trim(),
          'sectors': _selectedSectors.toList(),
        }, isEditing: widget.isEditing),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is InvestorProfileSubmissionError) {
          uiService.showSnackBar(state.message, isError: true);
        }
      },
      builder: (context, state) {
        final isLoading = state is InvestorProfileSubmitting;
        return Scaffold(
          backgroundColor: AppColors.neutralWhite,
          appBar: AppBar(
            backgroundColor: AppColors.neutralWhite,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                LucideIcons.arrowLeft,
                color: AppColors.slate900,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  uiService.goBack();
                } else {
                  _navigateToFeed();
                }
              },
            ),
            title: Text(
              'Complete Your Profile',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.slate900,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomInputField(
                            label: 'Full Name',
                            controller: _nameController,
                            placeholder: 'John Doe',
                            validator: (val) {
                              if (val == null || val.trim().length < 2) {
                                return 'Please enter at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          CustomInputField(
                            label: 'Email',
                            controller: _emailController,
                            placeholder: 'you@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                              ).hasMatch(val)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          CustomInputField(
                            label: 'Company (Optional)',
                            controller: _companyController,
                            placeholder: 'e.g., Acme Ventures',
                            validator: (val) {
                              if (val != null &&
                                  val.isNotEmpty &&
                                  val.length < 2) {
                                return 'Please enter at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          Text(
                            'Investment Interests (Optional)',
                            style: AppTypography.textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.slate900,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select sectors...',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.slate600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _sectors.map((sector) {
                              final isSelected = _selectedSectors.contains(
                                sector,
                              );
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.trustBlue
                                        : AppColors.neutralWhite,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.trustBlue
                                          : AppColors.slate300,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSelected) ...[
                                        const Icon(
                                          LucideIcons.check,
                                          size: 14,
                                          color: AppColors.neutralWhite,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        sector,
                                        style: AppTypography
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: isSelected
                                                  ? AppColors.neutralWhite
                                                  : AppColors.slate700,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Action Bar
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.neutralWhite,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Complete Profile',
                          variant: ButtonVariant.primary,
                          isLoading: isLoading,
                          onPressed: _submitProfile,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _navigateToFeed,
                        child: Text(
                          'Skip for Now',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.trustBlue,
                            fontWeight: FontWeight.w600,
                          ),
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
