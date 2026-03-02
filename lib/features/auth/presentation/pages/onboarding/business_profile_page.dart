import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_dropdown_field.dart';
import 'package:partnex/core/theme/widgets/custom_input_field.dart';
import 'package:partnex/core/theme/widgets/custom_progress_indicator.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/revenue_expenses_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/review_confirm_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_state.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/analysis_state_page.dart';
import 'package:partnex/core/services/ui_service.dart';

class BusinessProfilePage extends StatefulWidget {
  final bool isDocumentUpload;
  final bool isEditing;
  /// Alias accepted from ProfileManagementPage for clarity
  final bool isEditMode;

  const BusinessProfilePage({
    super.key,
    this.isDocumentUpload = false,
    this.isEditing = false,
    this.isEditMode = false,
  });

  /// Combined flag — true if either `isEditing` or `isEditMode` are set
  bool get _inEditMode => isEditing || isEditMode;

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _yearsController = TextEditingController();
  final _employeesController = TextEditingController();

  String? _selectedIndustry;

  final List<String> _industries = [
    'Manufacturing',
    'Retail & E-commerce',
    'Technology & Software',
    'Healthcare & Pharma',
    'Agriculture & Food',
    'Logistics & Transportation',
    'Financial Services',
    'Professional Services',
    'Education',
    'Other',
  ];

  bool get _isFormValid {
    // Basic validation to enable Next button
    return _nameController.text.length >= 2 &&
        _selectedIndustry != null &&
        _locationController.text.isNotEmpty &&
        _yearsController.text.isNotEmpty &&
        _employeesController.text.isNotEmpty;
  }

  void _onFieldChanged(String value) {
    // Only rebuild to update button state
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final profileState = context.read<SmeProfileCubit>().state;
    if (profileState.businessName.isNotEmpty) {
      _nameController.text = profileState.businessName;
      _locationController.text = profileState.location;
      if (profileState.yearsOfOperation > 0) {
        _yearsController.text = profileState.yearsOfOperation.toString();
      }
      if (profileState.numberOfEmployees > 0) {
        _employeesController.text = profileState.numberOfEmployees.toString();
      }
      _selectedIndustry = profileState.industry.isNotEmpty ? profileState.industry : null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _yearsController.dispose();
    _employeesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
          onPressed: () => uiService.goBack(),
        ),
        title: Text(
          'Business Profile',
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
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState is SmeProfileSubmittedSuccess) {
              uiService.navigateTo(const AnalysisStatePage());
            }
          },
          builder: (context, authState) {
            final isSubmitting = authState is SmeProfileSubmitting;
            
            return Column(
              children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                children: [
                  ProgressIndicatorWidget(progress: widget.isDocumentUpload ? 0.66 : 0.20),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget._inEditMode ? 'Edit Mode' : (widget.isDocumentUpload ? 'Step 2 of 3' : 'Step 1 of 5'),
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.slate600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomInputField(
                        label: 'Business Name',
                        placeholder: 'e.g., Acme Manufacturing',
                        controller: _nameController,
                        onChanged: _onFieldChanged,
                        validator: (val) {
                          if (val == null || val.length < 2 || val.length > 100)
                            return 'Business name must be between 2 and 100 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomDropdownField(
                        label: 'Industry/Sector',
                        placeholder: 'Select industry...',
                        value: _selectedIndustry,
                        items: _industries,
                        onChanged: (val) {
                          setState(() {
                            _selectedIndustry = val;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomInputField(
                        label: 'Location',
                        placeholder: 'e.g., Lagos, Nigeria',
                        controller: _locationController,
                        onChanged: _onFieldChanged,
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Please enter a valid location';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomInputField(
                        label: 'Years of Operation',
                        placeholder: 'e.g., 5',
                        controller: _yearsController,
                        onChanged: _onFieldChanged,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          final num = int.tryParse(val);
                          if (num == null || num < 0 || num > 100)
                            return 'Please enter a valid number between 0 and 100';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomInputField(
                        label: 'Number of Employees',
                        placeholder: 'e.g., 25',
                        controller: _employeesController,
                        onChanged: _onFieldChanged,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          final num = int.tryParse(val);
                          if (num == null || num < 0 || num > 10000)
                            return 'Please enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Previous',
                      variant: ButtonVariant.secondary,
                      onPressed: () => uiService.goBack(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.smd),
                  Expanded(
                    child: CustomButton(
                      text: widget._inEditMode ? 'Save Changes' : (widget.isDocumentUpload ? 'Submit' : 'Next'),
                      variant: ButtonVariant.primary,
                      isDisabled: !_isFormValid || isSubmitting,
                      isLoading: isSubmitting,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<SmeProfileCubit>().updateBusinessProfile(
                            businessName: _nameController.text,
                            industry: _selectedIndustry!,
                            location: _locationController.text,
                            yearsOfOperation: int.parse(_yearsController.text),
                            numberOfEmployees: int.parse(_employeesController.text),
                          );
                          if (widget._inEditMode) {
                            uiService.goBack();
                          } else if (widget.isDocumentUpload) {
                            uiService.navigateTo(const ReviewConfirmPage(isDocumentUpload: true));
                          } else {
                            uiService.navigateTo(const RevenueExpensesPage());
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
              ],
            );
          },
        ),
      ),
    );
  }
}
