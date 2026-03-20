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
import 'package:partnex/features/auth/presentation/blocs/auth/auth_event.dart';
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
  bool _navigateToAnalysis = false;
  bool _impactScoreUpdated = false; // Tracks if a bracket was actually crossed

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _yearsController = TextEditingController();
  final _employeesController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otherIndustryController = TextEditingController();

  String? _selectedIndustry;

  late String _initialName;
  late String _initialLocation;
  late String _initialYears;
  late String _initialEmployees;
  late String _initialPhone;
  String? _initialSelectedIndustry;
  late String _initialOtherIndustry;

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

  bool get _hasChanges {
    return _nameController.text != _initialName ||
        _locationController.text != _initialLocation ||
        _yearsController.text != _initialYears ||
        _employeesController.text != _initialEmployees ||
        _phoneController.text != _initialPhone ||
        _selectedIndustry != _initialSelectedIndustry ||
        _otherIndustryController.text != _initialOtherIndustry;
  }

  bool get _isFormValid {
    // Basic validation to enable Next button
    final isValid = _nameController.text.length >= 2 &&
        _locationController.text.isNotEmpty &&
        _yearsController.text.isNotEmpty &&
        _employeesController.text.isNotEmpty &&
        (_selectedIndustry != 'Other' || _otherIndustryController.text.isNotEmpty);

    if (widget._inEditMode) return isValid && _hasChanges;
    return isValid;
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

    // Capture initial values for pristine checking in edit mode
    _initialName = _nameController.text;
    _initialLocation = _locationController.text;
    _initialYears = _yearsController.text;
    _initialEmployees = _employeesController.text;
    _initialPhone = _phoneController.text;
    _initialSelectedIndustry = _selectedIndustry;
    _initialOtherIndustry = _otherIndustryController.text;
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
                icon: const Icon(LucideIcons.x, color: AppColors.slate900),
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
            if (!ModalRoute.of(context)!.isCurrent) return;
            
            if (authState is SmeProfileSubmittedSuccess) {
              if (widget._inEditMode && !_navigateToAnalysis) {
                // Dynamic SnackBar based on what actually changed
                final message = _impactScoreUpdated 
                    ? 'Your Impact Score has been refreshed to reflect these profile changes. Keep growing! 🚀'
                    : 'Business profile details have been successfully updated.';

                uiService.showSnackBar(message);
                uiService.goBack();
              } else {
                // Major changes (Revenue/Brackets) from other screens. Route to full Analysis Loading Page.
                uiService.navigateTo(const AnalysisStatePage());
              }
            } else if (authState is SmeProfileSubmissionError) {
              uiService.showSnackBar(authState.message, isError: true);
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
                            label: 'Business Name *',
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
                            label: 'Industry/Sector *',
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
                              label: 'Specific Industry *',
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
                            label: 'Location *',
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
                            label: 'Years of Operation *',
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
                            label: 'Number of Employees *',
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
                      //The 'Previous' button block was completely removed from here!
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
                              final profileCubit = context.read<SmeProfileCubit>();
                              final oldState = profileCubit.state;
                              
                              final newYears = int.parse(_yearsController.text);
                              final newEmployees = int.parse(_employeesController.text);
                              final newIndustry = _selectedIndustry == 'Other' 
                                    ? _otherIndustryController.text.trim()
                                    : _selectedIndustry!;

                              // ---------------------------------------------------------
                              // THE SMART DIFF: Bracket Threshold Check
                              // ---------------------------------------------------------
                              int getEmpBracket(int emp) {
                                if (emp >= 50) return 3;
                                if (emp >= 20) return 2;
                                if (emp >= 5) return 1;
                                return 0;
                              }

                              int getSectorBracket(String s) {
                                final lower = s.toLowerCase();
                                final high = ['health', 'education', 'agriculture', 'farming', 'clean energy'];
                                final medium = ['manufacturing', 'technology', 'logistics', 'fintech'];
                                if (high.any((k) => lower.contains(k))) return 2;
                                if (medium.any((k) => lower.contains(k))) return 1;
                                return 0;
                              }

                              // Only trigger the AI if they cross an actual threshold!
                              final bool meaningfulChanged = 
                                  getEmpBracket(oldState.numberOfEmployees) != getEmpBracket(newEmployees) ||
                                  getSectorBracket(oldState.industry) != getSectorBracket(newIndustry);

                              profileCubit.updateBusinessProfile(
                                businessName: _nameController.text,
                                industry: newIndustry,
                                location: _locationController.text,
                                yearsOfOperation: newYears,
                                numberOfEmployees: newEmployees,
                                phoneNumber: _phoneController.text.trim(),
                              );

                              if (widget._inEditMode) {
                                // NEVER navigate to analysis from the edit screen!
                                _navigateToAnalysis = false; 
                                _impactScoreUpdated = meaningfulChanged;
                                
                                // Save to backend (AI triggered in background if meaningfulChanged is true)
                                final newState = profileCubit.state;
                                context.read<AuthBloc>().add(
                                  SubmitSmeProfileEvent(
                                    newState.toMap(), 
                                    shouldGenerateScore: meaningfulChanged,
                                  ),
                                );
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