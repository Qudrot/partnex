import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_currency_field.dart';
import 'package:partnex/core/theme/widgets/custom_progress_indicator.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/liabilities_history_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';

class RevenueExpensesPage extends StatefulWidget {
  const RevenueExpensesPage({super.key});

  @override
  State<RevenueExpensesPage> createState() => _RevenueExpensesPageState();
}

class _RevenueExpensesPageState extends State<RevenueExpensesPage> {
  final _formKey = GlobalKey<FormState>();

  final _annualRevController = TextEditingController();
  final _annualExpController = TextEditingController();

  final _monthlyRevController = TextEditingController();
  final _monthlyExpController = TextEditingController();

  bool get _isFormValid {
    return _annualRevController.text.isNotEmpty &&
        _annualExpController.text.isNotEmpty &&
        _monthlyRevController.text.isNotEmpty &&
        _monthlyExpController.text.isNotEmpty;
  }

  String? _expenseWarning;
  double? _profitMargin;
  double? _expenseRatio;
  double? _annualProfit;

  void _onFieldChanged(String value) {
    if (_monthlyRevController.text.isNotEmpty &&
        _monthlyExpController.text.isNotEmpty) {
      final mRev = double.tryParse(_monthlyRevController.text.replaceAll(',', ''));
      final mExp = double.tryParse(_monthlyExpController.text.replaceAll(',', ''));
      
      if (mRev != null && mExp != null) {
        if (mExp > mRev) {
          _expenseWarning = 'Your expenses exceed your revenue. Please verify this is correct.';
        } else {
          _expenseWarning = null;
        }

        if (mRev > 0) {
          _profitMargin = ((mRev - mExp) / mRev) * 100;
          _expenseRatio = (mExp / mRev) * 100;
        } else {
          _profitMargin = null;
          _expenseRatio = null;
        }
      } else {
        _expenseWarning = null;
        _profitMargin = null;
        _expenseRatio = null;
      }
    } else {
      _expenseWarning = null;
      _profitMargin = null;
      _expenseRatio = null;
    }

    if (_annualRevController.text.isNotEmpty && _annualExpController.text.isNotEmpty) {
      final aRev = double.tryParse(_annualRevController.text.replaceAll(',', ''));
      final aExp = double.tryParse(_annualExpController.text.replaceAll(',', ''));
      if (aRev != null && aExp != null) {
        _annualProfit = aRev - aExp;
      } else {
        _annualProfit = null;
      }
    } else {
      _annualProfit = null;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _annualRevController.dispose();
    _annualExpController.dispose();
    _monthlyRevController.dispose();
    _monthlyExpController.dispose();
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
          'Revenue & Expenses',
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
                  ProgressIndicatorWidget(progress: 0.40),
                  const SizedBox(height: 8),
                  Text(
                    'Step 2 of 5',
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
                      // Section: Annual
                      Text(
                        'Annual Financials',
                        style: AppTypography.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),

                      CustomCurrencyField(
                        label: 'Annual Revenue',
                        placeholder: 'e.g., 500,000',
                        controller: _annualRevController,
                        onChanged: _onFieldChanged,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please enter a valid revenue amount';
                          final num = double.tryParse(val.replaceAll(',', ''));
                          if (num == null || num < 0) return 'Please enter a valid revenue amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total revenue for the last 12 months',
                        style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.slate600),
                      ),
                      const SizedBox(height: 20),
                      
                      CustomCurrencyField(
                        label: 'Annual Expenses',
                        placeholder: 'e.g., 300,000',
                        controller: _annualExpController,
                        onChanged: _onFieldChanged,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please enter a valid expense amount';
                          final num = double.tryParse(val.replaceAll(',', ''));
                          if (num == null || num < 0) return 'Please enter a valid expense amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total operating expenses for the last 12 months',
                        style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.slate600),
                      ),
                      const SizedBox(height: 32),

                      // Section: Monthly
                      Text(
                        'Monthly Financials (Average)',
                        style: AppTypography.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),

                      CustomCurrencyField(
                        label: 'Monthly Revenue (Average)',
                        placeholder: 'e.g., 50,000',
                        controller: _monthlyRevController,
                        onChanged: _onFieldChanged,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please enter a valid revenue amount';
                          final num = double.tryParse(val.replaceAll(',', ''));
                          if (num == null || num < 0) return 'Please enter a valid revenue amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Average monthly revenue',
                        style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.slate600),
                      ),
                      const SizedBox(height: 20),
                      
                      CustomCurrencyField(
                        label: 'Monthly Expenses (Average)',
                        placeholder: 'e.g., 30,000',
                        controller: _monthlyExpController,
                        onChanged: _onFieldChanged,
                        warningText: _expenseWarning,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please enter a valid expense amount';
                          final num = double.tryParse(val.replaceAll(',', ''));
                          if (num == null || num < 0) return 'Please enter a valid expense amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Average monthly operating expenses',
                        style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.slate600),
                      ),

                      // Real-time Calculations
                      if (_profitMargin != null || _annualProfit != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Real-Time Calculations',
                                style: AppTypography.textTheme.labelLarge?.copyWith(
                                  color: AppColors.slate900,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_profitMargin != null) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Profit Margin', style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.slate600)),
                                    Text('${_profitMargin!.toStringAsFixed(1)}%', style: AppTypography.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.slate900)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Expense Ratio', style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.slate600)),
                                    Text('${_expenseRatio!.toStringAsFixed(1)}%', style: AppTypography.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.slate900)),
                                  ],
                                ),
                              ],
                              if (_annualProfit != null && _profitMargin != null) const SizedBox(height: 8),
                              if (_annualProfit != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Estimated Annual Profit', style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.slate600)),
                                    Text('NGN ${_annualProfit!.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',')}', style: AppTypography.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.slate900)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],

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
                          context.read<SmeProfileCubit>().updateRevenueExpenses(
                            annualRevenue: double.parse(_annualRevController.text.replaceAll(',', '')),
                            annualExpenses: double.parse(_annualExpController.text.replaceAll(',', '')),
                            monthlyAvgRevenue: double.parse(_monthlyRevController.text.replaceAll(',', '')),
                            monthlyAvgExpenses: double.parse(_monthlyExpController.text.replaceAll(',', '')),
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LiabilitiesHistoryPage(),
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
