import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_progress_indicator.dart';
import 'package:partnex/core/theme/widgets/custom_currency_field.dart';
import 'package:partnex/core/theme/widgets/custom_input_field.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/liabilities_history_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/analysis_state_page.dart';

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
    if (a1 != null && a1 > 0) {
      totalValidYearsRev = (totalValidYearsRev ?? 0) + a1;
      validYearCount++;
    }

    final a2 = double.tryParse(_amount2Controller.text.replaceAll(',', ''));
    if (a2 != null && a2 > 0) {
      totalValidYearsRev = (totalValidYearsRev ?? 0) + a2;
      validYearCount++;
    }

    // ONLY count Year 3 if it is visible AND greater than 0
    final a3 = double.tryParse(_amount3Controller.text.replaceAll(',', ''));
    if (a3 != null && a3 > 0 && _showYear3) {
      totalValidYearsRev = (totalValidYearsRev ?? 0) + a3;
      validYearCount++;
    }

    final mExp = double.tryParse(
      _monthlyExpController.text.replaceAll(',', ''),
    );
    final mRev = double.tryParse(
      _monthlyRevController.text.replaceAll(',', ''),
    );

    if (mExp != null) {
      if (mRev != null) {
        if (mExp > mRev) {
          _expenseWarning =
              'Your expenses exceed your revenue. Please verify this is correct.';
        } else {
          _expenseWarning = null;
        }
      } else {
        _expenseWarning = null;
      }

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
    
    // If it's a completely new blank record, we leave inputs completely blank
    final bool isBlankNewRecord = !widget.isEditing && widget.isUpdatingRecord;

    if (!isBlankNewRecord && profileState.annualRevenueYear1 > 0) {
      _year1Controller.text = profileState.annualRevenueYear1.toString();
      _amount1Controller.text = profileState.annualRevenueAmount1
          .toStringAsFixed(0);
      _year2Controller.text = profileState.annualRevenueYear2.toString();
      _amount2Controller.text = profileState.annualRevenueAmount2
          .toStringAsFixed(0);

      if (profileState.annualRevenueYear3 != null) {
        _year3Controller.text = profileState.annualRevenueYear3.toString();
        _amount3Controller.text =
            profileState.annualRevenueAmount3?.toStringAsFixed(0) ?? '';
        _showYear3 = true;
      }

      if (profileState.monthlyAvgRevenue != null && profileState.monthlyAvgRevenue! > 0) {
        _monthlyRevController.text = profileState.monthlyAvgRevenue!
            .toStringAsFixed(0);
      }
      if (profileState.monthlyAvgExpenses > 0) {
        _monthlyExpController.text = profileState.monthlyAvgExpenses
            .toStringAsFixed(0);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onFieldChanged('');
      });
    } else if (isBlankNewRecord) {
      final currentYear = DateTime.now().year;
      _year1Controller.text = (currentYear - 2).toString();
      _year2Controller.text = (currentYear - 1).toString();
      _year3Controller.text = currentYear.toString();
      // Everything else remains empty strings natively
    } else {
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
                  Text(
                    isOptional ? 'Year' : 'Year *',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  CustomInputField(
                    label: '',
                    controller: yearCtrl,
                    placeholder: 'e.g., 2024',
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    onChanged: _onFieldChanged,
                    validator: (val) {
                      if (isOptional &&
                          (amountCtrl.text.isEmpty || amountCtrl.text == '0')) {
                        return null;
                      }
                      if (val == null || val.isEmpty || val.length != 4) {
                        return 'Valid year';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: isMobile ? 60 : 55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOptional ? 'Revenue' : 'Revenue *',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  CustomCurrencyField(
                    label: '',
                    placeholder: 'e.g., 5,000,000',
                    controller: amountCtrl,
                    onChanged: _onFieldChanged,
                    fillColor: AppColors.surface(context),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.smd,
                      vertical: AppSpacing.sm,
                    ),
                    validator: (val) {
                      if (isOptional &&
                          (val == null || val.isEmpty || val == '0')) {
                        return null;
                      }
                      if (val == null || val.isEmpty) return 'Valid amount';
                      return null;
                    },
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    helperText,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
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

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (!ModalRoute.of(context)!.isCurrent) return;
        if (authState is SmeProfileSubmittedSuccess && widget.isEditing) {
          // If we were editing, we move to analysis page because everything here is meaningful
          uiService.navigateTo(const AnalysisStatePage());
        } else if (authState is SmeProfileSubmissionError) {
          uiService.showSnackBar(authState.message, isError: true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.surface(context),
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
          leading: IconButton(
            icon: Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary(context)),
            iconSize: 20,
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Revenue & Expenses',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: AppColors.textPrimary(context),
            ),
          ),
          titleSpacing: 0,
          centerTitle: false,
        ),
        backgroundColor: AppColors.background(context),
        body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!widget.isEditing && !widget.isUpdatingRecord)
                        Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.xl),
                          child: ProgressIndicatorWidget(progress: 0.60),
                        ),
                      Text(
                        'Annual Revenue History',
                        style: AppTypography.textTheme.headlineSmall?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Provide at least 2 years of revenue data',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),

                      _buildRevenueRow(
                        yearCtrl: _year1Controller,
                        amountCtrl: _amount1Controller,
                        helperText:
                            'Annual revenue for ${_year1Controller.text}',
                        isMobile: isMobile,
                      ),
                      SizedBox(height: AppSpacing.smd),

                      _buildRevenueRow(
                        yearCtrl: _year2Controller,
                        amountCtrl: _amount2Controller,
                        helperText:
                            'Annual revenue for ${_year2Controller.text}',
                        isMobile: isMobile,
                      ),
                      SizedBox(height: AppSpacing.smd),

                      // YEAR 3 LOGIC (UPDATED WITH DELETE BUTTON)
                      if (_showYear3) ...[
                        Text(
                          'Year 3 (Optional)',
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        _buildRevenueRow(
                          yearCtrl: _year3Controller,
                          amountCtrl: _amount3Controller,
                          helperText:
                              'Annual revenue for ${_year3Controller.text}',
                          isMobile: isMobile,
                          isOptional: true,
                        ),

                        // NEW DELETE BUTTON AT THE BOTTOM
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CustomButton(
                            text: 'Delete Year 3',
                            variant: ButtonVariant.dangerOutline,
                            icon: const Icon(
                              LucideIcons.trash2,
                              size: AppSpacing.md,
                              color: AppColors.dangerRed,
                            ),
                            onPressed: () {
                              setState(() {
                                _showYear3 = false;
                                _year3Controller.clear();
                                _amount3Controller.clear();
                                _onFieldChanged('');
                              });
                            },
                          ),
                        ),
                        SizedBox(height: AppSpacing.smd),
                      ] else ...[
                        CustomButton(
                          text: 'Add Another Year',
                          variant: ButtonVariant.secondary,
                          icon: const Icon(
                            LucideIcons.plus,
                            size: AppSpacing.md,
                            color: AppColors.trustBlue,
                          ),
                          onPressed: () {
                            setState(() {
                              _showYear3 = true;
                              _year3Controller.text = (DateTime.now().year)
                                  .toString();
                            });
                          },
                        ),
                      ],
                      SizedBox(height: AppSpacing.xl),

                      Text(
                        'Monthly Financials (Average)',
                        style: AppTypography.textTheme.headlineSmall?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Average monthly figures for the last 12 months',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),

                      Text(
                        'Monthly Revenue',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      CustomCurrencyField(
                        label: '',
                        placeholder: 'e.g., 500,000',
                        controller: _monthlyRevController,
                        onChanged: _onFieldChanged,
                        fillColor: AppColors.surface(context),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.smd,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),

                      Text(
                        'Monthly Expenses *',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      CustomCurrencyField(
                        label: '',
                        placeholder: 'e.g., 300,000',
                        controller: _monthlyExpController,
                        onChanged: _onFieldChanged,
                        fillColor: AppColors.surface(context),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.smd,
                          vertical: AppSpacing.sm,
                        ),
                        warningText: _expenseWarning,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter a valid expense amount';
                          }
                          return null;
                        },
                      ),

                      if (_profitMargin != null || _annualProfit != null) ...[
                        SizedBox(height: AppSpacing.xl),
                        Container(
                          padding: EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface(context),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.border(context)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Real-Time Calculations',
                                style: AppTypography.textTheme.labelLarge
                                    ?.copyWith(color: AppColors.textPrimary(context)),
                              ),
                              SizedBox(height: AppSpacing.smd),
                              if (_profitMargin != null) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Profit Margin',
                                      style: AppTypography.textTheme.bodyMedium
                                          ?.copyWith(color: AppColors.textSecondary(context)),
                                    ),
                                    Text(
                                      '${_profitMargin!.toStringAsFixed(_profitMargin! % 1 == 0 ? 0 : 1)}%',
                                      style: AppTypography.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary(context),
                                          ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppSpacing.sm),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Expense Ratio',
                                      style: AppTypography.textTheme.bodyMedium
                                          ?.copyWith(color: AppColors.textSecondary(context)),
                                    ),
                                    Text(
                                      '${_expenseRatio!.toStringAsFixed(_expenseRatio! % 1 == 0 ? 0 : 1)}%',
                                      style: AppTypography.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary(context),
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                              if (_annualProfit != null &&
                                  _profitMargin != null)
                                SizedBox(height: AppSpacing.sm),
                              if (_annualProfit != null)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Estimated Annual Profit',
                                      style: AppTypography.textTheme.bodyMedium
                                          ?.copyWith(color: AppColors.textSecondary(context)),
                                    ),
                                    Text(
                                      'NGN ${_annualProfit!.toStringAsFixed(_annualProfit! % 1 == 0 ? 0 : 1).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',')}',
                                      style: AppTypography.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary(context),
                                          ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Previous',
                      variant: ButtonVariant.secondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: AppSpacing.smd),
                  Expanded(
                    child: CustomButton(
                      text: widget.isEditing ? 'Save Changes' : 'Next',
                      variant: ButtonVariant.primary,
                      isDisabled: !_isFormValid,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // SAFE EXTRACTION: If year 3 is hidden or 0, we completely nullify it
                          double? val3 = _amount3Controller.text.isNotEmpty
                              ? double.tryParse(
                                  _amount3Controller.text.replaceAll(',', ''),
                                )
                              : null;
                          if (!_showYear3 || val3 == null || val3 <= 0) {
                            val3 = null;
                          }
                          int? year3 =
                              (_showYear3 &&
                                  val3 != null &&
                                  _year3Controller.text.isNotEmpty)
                              ? int.tryParse(_year3Controller.text)
                              : null;

                          context.read<SmeProfileCubit>().updateRevenueExpenses(
                            annualRevenueYear1: int.parse(
                              _year1Controller.text,
                            ),
                            annualRevenueAmount1: double.parse(
                              _amount1Controller.text.replaceAll(',', ''),
                            ),
                            annualRevenueYear2: int.parse(
                              _year2Controller.text,
                            ),
                            annualRevenueAmount2: double.parse(
                              _amount2Controller.text.replaceAll(',', ''),
                            ),
                            annualRevenueYear3: year3,
                            annualRevenueAmount3: val3, // Fully sanitized!
                            monthlyAvgRevenue:
                                _monthlyRevController.text.isNotEmpty
                                ? double.parse(
                                    _monthlyRevController.text.replaceAll(
                                      ',',
                                      '',
                                    ),
                                  )
                                : null,
                            monthlyAvgExpenses: double.parse(
                              _monthlyExpController.text.replaceAll(',', ''),
                            ),
                          );

                          if (widget.isEditing) {
                            // Save to backend and re-score (everything here is meaningful)
                            final state = context.read<SmeProfileCubit>().state;
                            context.read<AuthBloc>().add(SubmitSmeProfileEvent(state.toMap(), shouldGenerateScore: true));
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LiabilitiesHistoryPage(
                                  isUpdatingRecord: widget.isUpdatingRecord,
                                ),
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
    ),
  );
}
}
