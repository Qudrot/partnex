import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_input_field.dart';
import 'package:partnex/core/theme/widgets/custom_dropdown_field.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_discovery_feed_page.dart';

class InvestorOnboardingPage extends StatefulWidget {
  final bool isEditing;

  const InvestorOnboardingPage({super.key, this.isEditing = false});

  @override
  State<InvestorOnboardingPage> createState() => _InvestorOnboardingPageState();
}

class _InvestorOnboardingPageState extends State<InvestorOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();

  String? _investorType;
  String? _investmentRange;
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

  final List<String> _investmentRanges = [
    'Under \$10K',
    '\$10K - \$50K',
    '\$50K - \$100K',
    '\$100K - \$500K',
    '\$500K - \$1M',
    '\$1M - \$5M',
    '\$5M+',
  ];

  @override
  void dispose() {
    _companyController.dispose();
    super.dispose();
  }

  void _navigateToFeed() {
    uiService.replaceWith(const SmeDiscoveryFeedPage());
  }

  bool get _isFormValid {
    if (_investorType == null || _investmentRange == null) return false;
    if ((_investorType == 'Fund / Institution' || _investorType == 'Corporate') && 
        _companyController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SubmitInvestorProfileEvent({
          'investorType': _investorType,
          'company': (_investorType == 'Fund / Institution' || _investorType == 'Corporate') 
              ? _companyController.text.trim() 
              : null,
          'investmentRange': _investmentRange,
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
        if (state is InvestorProfileSubmittedSuccess) {
           _navigateToFeed();
        }
      },
      builder: (context, state) {
        final isLoading = state is InvestorProfileSubmitting;
        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: AppColors.surface(context),
            elevation: 0,
            leading: widget.isEditing
                ? IconButton(
                    icon: Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary(context)),
                    onPressed: () => uiService.goBack(),
                  )
                : null,
            automaticallyImplyLeading: false,
            title: Text(
              widget.isEditing ? 'Update Profile' : 'Complete Your Profile',
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            titleSpacing: widget.isEditing ? 0 : AppSpacing.md,
            centerTitle: false,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Question 1: Investor Type
                          Text(
                            'What type of investor are you? *',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.smd),
                          _buildInvestorTypeOption('Individual Investor'),
                          _buildInvestorTypeOption('Fund / Institution'),
                          _buildInvestorTypeOption('Corporate', isLast: true),

                          if (_investorType == 'Fund / Institution' || _investorType == 'Corporate') ...[
                            const SizedBox(height: AppSpacing.md),
                            CustomInputField(
                              label: 'Company Name *',
                              controller: _companyController,
                              placeholder: 'e.g., Acme Ventures',
                              onChanged: (_) => setState(() {}),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Company name is required';
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: AppSpacing.xl),

                          // Question 2: Investment Range
                          Text(
                            "What's your investment range? *",
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.smd),
                          CustomDropdownField(
                            label: '',
                            placeholder: 'Select range...',
                            value: _investmentRange,
                            items: _investmentRanges,
                            onChanged: (val) {
                              setState(() {
                                _investmentRange = val;
                              });
                            },
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          Text(
                            'Investment Interests (Optional)',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Select sectors...',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                               color: AppColors.textSecondary(context),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
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
                                borderRadius: BorderRadius.circular(AppRadius.xxl),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.trustBlue : AppColors.surface(context),
                                    border: Border.all(
                                      color: isSelected ? AppColors.trustBlue : AppColors.border(context),
                                    ),
                                    borderRadius: BorderRadius.circular(AppRadius.xxl),
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
                                        const SizedBox(width: AppSpacing.xs),
                                      ],
                                      Text(
                                        sector,
                                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                                          color: isSelected ? AppColors.neutralWhite : AppColors.textPrimary(context),
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Action Bar
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    boxShadow: [
                      BoxShadow(
                        color: context.isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CustomButton(
                        text: widget.isEditing ? 'Save Changes' : 'Complete Profile',
                        variant: ButtonVariant.primary,
                        isFullWidth: true,
                        isDisabled: !_isFormValid || isLoading,
                        isLoading: isLoading,
                        onPressed: _submitProfile,
                      ),
                      if (!widget.isEditing) ...[
                        const SizedBox(height: AppSpacing.md),
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

  Widget _buildInvestorTypeOption(String type, {bool isLast = false}) {
    final isSelected = _investorType == type;
    return GestureDetector(
      onTap: () => setState(() => _investorType = type),
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.smd),
        padding: const EdgeInsets.all(AppSpacing.smd),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.trustBlue.withValues(alpha: 0.05) : AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.trustBlue : AppColors.border(context),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.trustBlue : AppColors.textSecondary(context),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.trustBlue,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.smd),
            Text(
              type,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
