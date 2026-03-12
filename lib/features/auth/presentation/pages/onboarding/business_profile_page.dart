import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_dropdown_field.dart';
import 'package:partnex/core/theme/widgets/custom_input_field.dart';
import 'package:partnex/core/theme/widgets/custom_progress_indicator.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/input_method_selection_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/review_confirm_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
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
  final _phoneController = TextEditingController();
  final _otherIndustryController = TextEditingController();

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
        _locationController.text.isNotEmpty &&
        _yearsController.text.isNotEmpty &&
        _employeesController.text.isNotEmpty &&
        (_selectedIndustry != 'Other' || _otherIndustryController.text.isNotEmpty);
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

      // Normalization: Ensure stored industry matches UI dropdown items
      String industry = profileState.industry;
      if (industry == 'Technology') industry = 'Technology & Software';
      if (industry == 'Agriculture') industry = 'Agriculture & Food';
      
      _selectedIndustry = _industries.contains(industry) ? industry : null;
    }

    // Load phone number from state if editing
    final phone = context.read<SmeProfileCubit>().state.phoneNumber;
    if (phone.isNotEmpty) {
      _phoneController.text = phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _yearsController.dispose();
    _employeesController.dispose();
    _phoneController.dispose();
    _otherIndustryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget._inEditMode
            ? IconButton(
                icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
                onPressed: () => uiService.goBack(),
              )
            : null,
        automaticallyImplyLeading: false,
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
                if (!widget._inEditMode)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: const ProgressIndicatorWidget(
                      progress: 0.20,
                    ),
                  ),
                if (!widget._inEditMode)
                  SizedBox(height: AppSpacing.xl),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
                              if (val == null ||
                                  val.length < 2 ||
                                  val.length > 100) {
                                return 'Business name must be between 2 and 100 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.lg),
                          CustomDropdownField(
                            label: 'Industry/Sector',
                            placeholder: 'Select industry...',
                            value: _selectedIndustry,
                            items: _industries,
                            onChanged: (val) {
                              setState(() {
                                _selectedIndustry = val;
                                if (val != 'Other') {
                                  _otherIndustryController.clear();
                                }
                              });
                            },
                          ),
                          if (_selectedIndustry == 'Other') ...[
                            SizedBox(height: AppSpacing.lg),
                            CustomInputField(
                              label: 'Specific Industry',
                              placeholder: 'e.g., Renewable Energy',
                              controller: _otherIndustryController,
                              onChanged: _onFieldChanged,
                              validator: (val) {
                                if (_selectedIndustry == 'Other' && (val == null || val.isEmpty)) {
                                  return 'Please specify your industry';
                                }
                                return null;
                              },
                            ),
                          ],
                          SizedBox(height: AppSpacing.lg),
                          CustomInputField(
                            label: 'Location',
                            placeholder: 'e.g., Lagos, Nigeria',
                            controller: _locationController,
                            onChanged: _onFieldChanged,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter a valid location';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.lg),
                          CustomInputField(
                            label: 'Years of Operation',
                            placeholder: 'e.g., 5',
                            controller: _yearsController,
                            onChanged: _onFieldChanged,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              final num = int.tryParse(val);
                              if (num == null || num < 0 || num > 100) {
                                return 'Please enter a valid number between 0 and 100';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.lg),
                          CustomInputField(
                            label: 'Number of Employees',
                            placeholder: 'e.g., 25',
                            controller: _employeesController,
                            onChanged: _onFieldChanged,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              final num = int.tryParse(val);
                              if (num == null || num < 0 || num > 10000) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.lg),
                          CustomInputField(
                            label: 'Phone Number',
                            placeholder: 'e.g., +234 805 678 9012',
                            controller: _phoneController,
                            onChanged: _onFieldChanged,
                            validator: (val) {
                              // Optional field
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ),
                ),

                // Navigation Buttons
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Previous',
                          variant: ButtonVariant.secondary,
                          onPressed: () => uiService.goBack(),
                        ),
                      ),
                      SizedBox(width: AppSpacing.smd),
                      Expanded(
                        child: CustomButton(
                          text: widget._inEditMode
                              ? 'Save Changes'
                              : (widget.isDocumentUpload ? 'Submit' : 'Next'),
                          variant: ButtonVariant.primary,
                          isDisabled: !_isFormValid || isSubmitting,
                          isLoading: isSubmitting,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context
                                  .read<SmeProfileCubit>()
                                  .updateBusinessProfile(
                                    businessName: _nameController.text,
                                    industry: _selectedIndustry == 'Other' 
                                        ? _otherIndustryController.text.trim()
                                        : _selectedIndustry!,
                                    location: _locationController.text,
                                    yearsOfOperation: int.parse(
                                      _yearsController.text,
                                    ),
                                    numberOfEmployees: int.parse(
                                      _employeesController.text,
                                    ),
                                    phoneNumber: _phoneController.text.trim(),
                                  );
                              if (widget._inEditMode) {
                                uiService.showSnackBar(
                                  'Your profile has been successfully updated.',
                                );
                                uiService.goBack();
                              } else if (widget.isDocumentUpload) {
                                uiService.navigateTo(
                                  const ReviewConfirmPage(
                                    isDocumentUpload: true,
                                  ),
                                );
                              } else {
                                // Direct to method selection (Step 2) after basic info
                                uiService.navigateTo(
                                  const InputMethodSelectionPage(),
                                );
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
