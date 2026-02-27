import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_dropdown_field.dart';
import 'package:partnex/core/theme/widgets/custom_input_field.dart';
import 'package:partnex/core/theme/widgets/custom_progress_indicator.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/revenue_expenses_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/review_confirm_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';

class BusinessProfilePage extends StatefulWidget {
  final bool isDocumentUpload;

  const BusinessProfilePage({
    super.key,
    this.isDocumentUpload = false,
  });

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Business Profile',
          style: AppTypography.textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Column(
                children: [
                  ProgressIndicatorWidget(progress: widget.isDocumentUpload ? 0.66 : 0.20),
                  const SizedBox(height: 8),
                  Text(
                    widget.isDocumentUpload ? 'Step 2 of 3' : 'Step 1 of 5',
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Previous',
                      variant: ButtonVariant.secondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Next',
                      variant: ButtonVariant.primary,
                      isDisabled: !_isFormValid,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Save state to Cubit
                          context.read<SmeProfileCubit>().updateBusinessProfile(
                            businessName: _nameController.text,
                            industry: _selectedIndustry!,
                            location: _locationController.text,
                            yearsOfOperation: int.parse(_yearsController.text),
                            numberOfEmployees: int.parse(_employeesController.text),
                          );
                          if (widget.isDocumentUpload) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReviewConfirmPage(isDocumentUpload: true),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RevenueExpensesPage(),
                              ),
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
        ),
      ),
    );
  }
}
