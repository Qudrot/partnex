import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_currency_field.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/liabilities_history_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';

class RevenueExpensesPage extends StatefulWidget {
  final bool isEditing;
  final bool isUpdatingRecord;

  const RevenueExpensesPage({
    super.key,
    this.isEditing = false,
    this.isUpdatingRecord = false,
  });

  @override
  State<RevenueExpensesPage> createState() => _RevenueExpensesPageState();
}

class _RevenueExpensesPageState extends State<RevenueExpensesPage> {
  final _formKey = GlobalKey<FormState>();

  final _year1Controller = TextEditingController();
  final _amount1Controller = TextEditingController();
  final _year2Controller = TextEditingController();
  final _amount2Controller = TextEditingController();
  final _year3Controller = TextEditingController();
  final _amount3Controller = TextEditingController();

  final _monthlyRevController = TextEditingController();
  final _monthlyExpController = TextEditingController();

  bool get _isFormValid {
    return _year1Controller.text.isNotEmpty &&
        _amount1Controller.text.isNotEmpty &&
        _year2Controller.text.isNotEmpty &&
        _amount2Controller.text.isNotEmpty &&
        _monthlyExpController.text.isNotEmpty;
  }

  bool _showYear3 = false;

  String? _expenseWarning;
  double? _profitMargin;
  double? _expenseRatio;
  double? _annualProfit;

  void _onFieldChanged(String value) {
    double? totalValidYearsRev;
    int validYearCount = 0;

    final a1 = double.tryParse(_amount1Controller.text.replaceAll(',', ''));
    if (a1 != null) { totalValidYearsRev = (totalValidYearsRev ?? 0) + a1; validYearCount++; }

    final a2 = double.tryParse(_amount2Controller.text.replaceAll(',', ''));
    if (a2 != null) { totalValidYearsRev = (totalValidYearsRev ?? 0) + a2; validYearCount++; }

    final a3 = double.tryParse(_amount3Controller.text.replaceAll(',', ''));
    if (a3 != null) { totalValidYearsRev = (totalValidYearsRev ?? 0) + a3; validYearCount++; }

    final mExp = double.tryParse(_monthlyExpController.text.replaceAll(',', ''));
    final mRev = double.tryParse(_monthlyRevController.text.replaceAll(',', ''));

    if (mExp != null) {
      if (mRev != null) {
        if (mExp > mRev) {
          _expenseWarning = 'Your expenses exceed your revenue. Please verify this is correct.';
        } else {
          _expenseWarning = null;
        }
      } else {
        _expenseWarning = null;
      }

      // Calculate aggregated annual metrics
      if (validYearCount > 0) {
        final avgAnnualRev = totalValidYearsRev! / validYearCount;
        final annualExp = mExp * 12;

        _annualProfit = avgAnnualRev - annualExp;
        if (avgAnnualRev > 0) {
          _profitMargin = ((avgAnnualRev - annualExp) / avgAnnualRev) * 100;
          _expenseRatio = (annualExp / avgAnnualRev) * 100;
        } else {
          _profitMargin = null;
          _expenseRatio = null;
        }
      } else {
        _annualProfit = null;
        _profitMargin = null;
        _expenseRatio = null;
      }
    } else {
      _expenseWarning = null;
      _annualProfit = null;
      _profitMargin = null;
      _expenseRatio = null;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final profileState = context.read<SmeProfileCubit>().state;
    if (profileState.annualRevenueYear1 > 0) {
      _year1Controller.text = profileState.annualRevenueYear1.toString();
      _amount1Controller.text = profileState.annualRevenueAmount1.toStringAsFixed(0);
      _year2Controller.text = profileState.annualRevenueYear2.toString();
      _amount2Controller.text = profileState.annualRevenueAmount2.toStringAsFixed(0);
      
      if (profileState.annualRevenueYear3 != null) {
        _year3Controller.text = profileState.annualRevenueYear3.toString();
        _amount3Controller.text = profileState.annualRevenueAmount3?.toStringAsFixed(0) ?? '';
        _showYear3 = true;
      }

      if (profileState.monthlyAvgRevenue != null) {
        _monthlyRevController.text = profileState.monthlyAvgRevenue!.toStringAsFixed(0);
      }
      _monthlyExpController.text = profileState.monthlyAvgExpenses.toStringAsFixed(0);

      // Trigger initial calculation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onFieldChanged('');
      });
    } else {
      // Auto-fill recent years
      final currentYear = DateTime.now().year;
      _year1Controller.text = (currentYear - 2).toString();
      _year2Controller.text = (currentYear - 1).toString();
      _year3Controller.text = currentYear.toString();
    }
  }

  @override
  void dispose() {
    _year1Controller.dispose();
    _amount1Controller.dispose();
    _year2Controller.dispose();
    _amount2Controller.dispose();
    _year3Controller.dispose();
    _amount3Controller.dispose();
    _monthlyRevController.dispose();
    _monthlyExpController.dispose();
    super.dispose();
  }

  Widget _buildRevenueRow({
    required TextEditingController yearCtrl,
    required TextEditingController amountCtrl,
    required String helperText,
    bool isMobile = false,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isMobile ? 40 : 45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Year', style: AppTypography.textTheme.labelLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate900)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: yearCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    onChanged: _onFieldChanged,
                    validator: (val) {
                      if (isOptional && yearCtrl.text.isEmpty && amountCtrl.text.isEmpty) return null;
                      if (val == null || val.isEmpty || val.length != 4) return 'Valid year';
                      return null;
                    },
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppColors.slate900,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: 'e.g., 2024',
                      hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.slate400),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.slate200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.slate200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.trustBlue, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.dangerRed, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: isMobile ? 60 : 55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue', style: AppTypography.textTheme.labelLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate900)),
                  const SizedBox(height: 4),
                  CustomCurrencyField(
                    label: '',
                    placeholder: 'e.g., 5,000,000',
                    controller: amountCtrl,
                    onChanged: _onFieldChanged,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    validator: (val) {
                      if (isOptional && yearCtrl.text.isEmpty && amountCtrl.text.isEmpty) return null;
                      if (val == null || val.isEmpty) return 'Valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(helperText, style: AppTypography.textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.slate600)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 640;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
          iconSize: 20,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Revenue & Expenses',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.slate900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Step 2 of 5',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.slate600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            width: double.infinity,
            height: 4,
            color: AppColors.slate100,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.40,
              child: Container(color: AppColors.trustBlue),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Annual Revenue History
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              'Annual Revenue History',
                              style: AppTypography.textTheme.headlineSmall?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(Required)',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: AppColors.dangerRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Provide at least 2 years of revenue data',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.slate600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildRevenueRow(
                        yearCtrl: _year1Controller,
                        amountCtrl: _amount1Controller,
                        helperText: 'Annual revenue for ${_year1Controller.text}',
                        isMobile: isMobile,
                      ),
                      const SizedBox(height: 12),

                      _buildRevenueRow(
                        yearCtrl: _year2Controller,
                        amountCtrl: _amount2Controller,
                        helperText: 'Annual revenue for ${_year2Controller.text}',
                        isMobile: isMobile,
                      ),
                      const SizedBox(height: 12),

                      if (_showYear3) ...[
                        _buildRevenueRow(
                          yearCtrl: _year3Controller,
                          amountCtrl: _amount3Controller,
                          helperText: 'Annual revenue for ${_year3Controller.text}',
                          isMobile: isMobile,
                          isOptional: true,
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showYear3 = true;
                              _year3Controller.text = (DateTime.now().year).toString();
                            });
                          },
                          icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.trustBlue),
                          label: Text(
                            'Add Another Year',
                            style: AppTypography.textTheme.labelLarge?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.trustBlue,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppColors.trustBlue, width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            minimumSize: const Size(0, 40),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Section 2: Monthly Financials (Average)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              'Monthly Financials (Average)',
                              style: AppTypography.textTheme.headlineSmall?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(Optional)',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: AppColors.slate600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Average monthly figures for the last 12 months',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.slate600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text('Monthly Revenue', style: AppTypography.textTheme.labelLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate900)),
                      const SizedBox(height: 4),
                      CustomCurrencyField(
                        label: '',
                        placeholder: 'e.g., 500,000',
                        controller: _monthlyRevController,
                        onChanged: _onFieldChanged,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      const SizedBox(height: 4),
                      Text('Average monthly revenue for the last 12 months', style: AppTypography.textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.slate600)),
                      const SizedBox(height: 16),
                      
                      Text('Monthly Expenses', style: AppTypography.textTheme.labelLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate900)),
                      const SizedBox(height: 4),
                      CustomCurrencyField(
                        label: '',
                        placeholder: 'e.g., 300,000',
                        controller: _monthlyExpController,
                        onChanged: _onFieldChanged,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        warningText: _expenseWarning,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please enter a valid expense amount';
                          final num = double.tryParse(val.replaceAll(',', ''));
                          if (num == null || num < 0) return 'Please enter a valid expense amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Text('Average monthly operating expenses for the last 12 months', style: AppTypography.textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.slate600)),

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
                      text: widget.isEditing ? 'Save Changes' : 'Next',
                      variant: ButtonVariant.primary,
                      isDisabled: !_isFormValid,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<SmeProfileCubit>().updateRevenueExpenses(
                            annualRevenueYear1: int.parse(_year1Controller.text),
                            annualRevenueAmount1: double.parse(_amount1Controller.text.replaceAll(',', '')),
                            annualRevenueYear2: int.parse(_year2Controller.text),
                            annualRevenueAmount2: double.parse(_amount2Controller.text.replaceAll(',', '')),
                            annualRevenueYear3: _year3Controller.text.isNotEmpty ? int.parse(_year3Controller.text) : null,
                            annualRevenueAmount3: _amount3Controller.text.isNotEmpty ? double.parse(_amount3Controller.text.replaceAll(',', '')) : null,
                            monthlyAvgRevenue: _monthlyRevController.text.isNotEmpty ? double.parse(_monthlyRevController.text.replaceAll(',', '')) : null,
                            monthlyAvgExpenses: double.parse(_monthlyExpController.text.replaceAll(',', '')),
                          );

                          if (widget.isEditing) {
                            Navigator.pop(context);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LiabilitiesHistoryPage(isUpdatingRecord: widget.isUpdatingRecord),
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
