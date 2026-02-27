import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_currency_field.dart';
import 'package:partnex/core/theme/widgets/custom_input_field.dart';
import 'package:partnex/core/theme/widgets/custom_progress_indicator.dart';
import 'package:partnex/core/theme/widgets/custom_yes_no_field.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/review_confirm_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';

class LiabilitiesHistoryPage extends StatefulWidget {
  const LiabilitiesHistoryPage({super.key});

  @override
  State<LiabilitiesHistoryPage> createState() => _LiabilitiesHistoryPageState();
}

class _LiabilitiesHistoryPageState extends State<LiabilitiesHistoryPage> {
  final _formKey = GlobalKey<FormState>();

  final _totalLiabilitiesController = TextEditingController();
  final _outstandingLoansController = TextEditingController();

  bool? _hasPriorFunding;
  final _fundingAmountController = TextEditingController();
  final _fundingSourceController = TextEditingController();
  final _fundingYearController = TextEditingController();

  final _onTimePaymentRateController = TextEditingController();

  bool get _validateLiabilities {
    final t = double.tryParse(_totalLiabilitiesController.text.replaceAll(',', ''));
    final o = double.tryParse(_outstandingLoansController.text.replaceAll(',', ''));
    if (t == null || o == null) return false;
    return true;
  }

  bool get _validateFunding {
    if (_hasPriorFunding == null) return false;
    if (_hasPriorFunding == true) {
      if (_fundingAmountController.text.isEmpty) return false;
      if (_fundingSourceController.text.isEmpty) return false;
      if (_fundingYearController.text.isEmpty) return false;
    }
    return true;
  }

  bool get _validateHistory {
    final r = double.tryParse(_onTimePaymentRateController.text);
    if (r == null || r < 0 || r > 100) return false;
    return true;
  }

  bool get _isFormValid {
    return _validateLiabilities && _validateFunding && _validateHistory;
  }

  void _onFieldChanged(String value) {
    setState(() {});
  }

  @override
  void dispose() {
    _totalLiabilitiesController.dispose();
    _outstandingLoansController.dispose();
    _fundingAmountController.dispose();
    _fundingSourceController.dispose();
    _fundingYearController.dispose();
    _onTimePaymentRateController.dispose();
    super.dispose();
  }

  Widget _buildConditionalField(Widget child, bool isVisible) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: isVisible
          ? Container(
              margin: const EdgeInsets.only(top: 20, left: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.slate200),
              ),
              child: child,
            )
          : const SizedBox.shrink(),
    );
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
          'Liabilities & History',
          style: AppTypography.textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Column(
                children: [
                  ProgressIndicatorWidget(progress: 0.60),
                  const SizedBox(height: 8),
                  Text(
                    'Step 3 of 5',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.slate600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section A
                      Text(
                        'Total Outstanding Liabilities',
                        style: AppTypography.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total amount owed to creditors',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.slate600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      CustomCurrencyField(
                        label: 'Total Outstanding Liabilities',
                        placeholder: 'e.g., 200,000',
                        controller: _totalLiabilitiesController,
                        onChanged: _onFieldChanged,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please enter a valid liability amount';
                          final num = double.tryParse(val.replaceAll(',', ''));
                          if (num == null || num < 0) return 'Please enter a valid liability amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      CustomCurrencyField(
                        label: 'Outstanding Loans',
                        placeholder: 'e.g., 100,000',
                        controller: _outstandingLoansController,
                        onChanged: _onFieldChanged,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please enter a valid loan amount';
                          final num = double.tryParse(val.replaceAll(',', ''));
                          if (num == null || num < 0) return 'Please enter a valid loan amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total amount of active loans',
                        style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.slate600),
                      ),
                      const SizedBox(height: 32),

                      // Section B
                      Text(
                        'Prior Funding History',
                        style: AppTypography.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Prior funding demonstrates investment confidence and capital access.',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.slate600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      CustomYesNoField(
                        label: 'Have you received prior funding?',
                        value: _hasPriorFunding,
                        onChanged: (val) {
                          setState(() => _hasPriorFunding = val);
                        },
                      ),

                      _buildConditionalField(
                        Column(
                          children: [
                            CustomCurrencyField(
                              label: 'Funding Amount',
                              placeholder: 'e.g., 100,000',
                              controller: _fundingAmountController,
                              onChanged: _onFieldChanged,
                              validator: (val) {
                                if (_hasPriorFunding == true) {
                                  if (val == null || val.isEmpty) return 'Please enter a valid funding amount';
                                  final num = double.tryParse(val.replaceAll(',', ''));
                                  if (num == null || num <= 0) return 'Please enter a valid funding amount';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            CustomInputField(
                              label: 'Funding Source',
                              placeholder: 'e.g., Venture Capital, Angel Investor',
                              controller: _fundingSourceController,
                              onChanged: _onFieldChanged,
                              validator: (val) {
                                if (_hasPriorFunding == true) {
                                  if (val == null || val.isEmpty || val.length > 100) return 'Please enter a valid funding source';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            CustomInputField(
                              label: 'Year of Funding',
                              placeholder: 'e.g., 2022',
                              controller: _fundingYearController,
                              onChanged: _onFieldChanged,
                              validator: (val) {
                                if (_hasPriorFunding == true) {
                                  if (val == null || val.isEmpty) return 'Please enter a valid year';
                                  final num = int.tryParse(val);
                                  final currentYear = DateTime.now().year;
                                  if (num == null || num < 2000 || num > currentYear) return 'Please enter a valid year';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        _hasPriorFunding == true,
                      ),
                      const SizedBox(height: 32),

                      // Section C
                      Text(
                        'Repayment Behavior',
                        style: AppTypography.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This helps us assess your reliability in meeting obligations.',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.slate600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      CustomInputField(
                        label: 'On-Time Payment Rate (%)',
                        placeholder: 'e.g., 95',
                        controller: _onTimePaymentRateController,
                        onChanged: _onFieldChanged,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          final num = double.tryParse(val);
                          if (num == null || num < 0 || num > 100) return 'Please enter a valid percentage between 0 and 100';
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Percentage of payments made on time',
                        style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.slate600),
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
                          context.read<SmeProfileCubit>().updateLiabilitiesHistory(
                            totalLiabilities: double.parse(_totalLiabilitiesController.text.replaceAll(',', '')),
                            outstandingLoans: double.parse(_outstandingLoansController.text.replaceAll(',', '')),
                            hasPriorFunding: _hasPriorFunding,
                            priorFundingAmount: _fundingAmountController.text.isEmpty ? null : double.parse(_fundingAmountController.text.replaceAll(',', '')),
                            priorFundingSource: _fundingSourceController.text.isEmpty ? null : _fundingSourceController.text,
                            fundingYear: _fundingYearController.text.isEmpty ? null : int.parse(_fundingYearController.text),
                            onTimePaymentRate: _onTimePaymentRateController.text.isEmpty ? null : int.parse(_onTimePaymentRateController.text),
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReviewConfirmPage(),
                            ),
                          );
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
