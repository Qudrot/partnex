import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_progress_indicator.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/business_profile_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/liabilities_history_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/revenue_expenses_page.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/analysis_state_page.dart';
import 'package:partnex/core/services/ui_service.dart';

class ReviewConfirmPage extends StatefulWidget {
  final bool isDocumentUpload;
  final bool isUpdatingRecord;

  const ReviewConfirmPage({
    super.key,
    this.isDocumentUpload = false,
    this.isUpdatingRecord = false,
  });

  @override
  State<ReviewConfirmPage> createState() => _ReviewConfirmPageState();
}

class _ReviewConfirmPageState extends State<ReviewConfirmPage> {
  bool _isConfirmed = false;

  void _submitData() {
    final state = context.read<SmeProfileCubit>().state;
    context.read<AuthBloc>().add(SubmitSmeProfileEvent(state.toMap()));
  }

  Future<void> _rePickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null) {
        final file = result.files.single;
        String csvString = '';
        if (file.bytes != null) {
          csvString = utf8.decode(file.bytes!);
        } else if (file.path != null) {
          csvString = await File(file.path!).readAsString();
        }
        if (csvString.isNotEmpty && mounted) {
          context.read<SmeProfileCubit>().processCsv(csvString, file.name);
          uiService.showSnackBar('Successfully updated file: ${file.name}');
        }
      }
    } catch (e) {
      if (mounted) {
        uiService.showSnackBar('We couldn\'t update the file. Please try again.', isError: true);
      }
    }
  }

  Widget _buildSummarySection({
    required String title,
    required Map<String, dynamic> data,
    VoidCallback? onEdit,
    String editLabel = 'Edit',
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.textTheme.headlineSmall?.copyWith(fontSize: 16, color: AppColors.slate900)),
              if (onEdit != null)
                CustomButton(
                  text: editLabel,
                  variant: ButtonVariant.tertiary,
                  onPressed: onEdit,
                ),
            ],
          ),
          SizedBox(height: AppSpacing.smd),
          ...data.entries.map((entry) {
            bool isMissingError = entry.value.toString().contains('MISSING');
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.smd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key, style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    entry.value.toString(),
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: isMissingError ? AppColors.dangerRed : AppColors.slate900,
                      fontWeight: isMissingError ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!ModalRoute.of(context)!.isCurrent) return;
        if (state is SmeProfileSubmittedSuccess) {
          context.read<ScoreCubit>().loadScore(state.score);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalysisStatePage()));
        } else if (state is SmeProfileSubmissionError) {
          uiService.showSnackBar(state.message, isError: true);
        }
      },
      builder: (context, authState) {
        final profileState = context.watch<SmeProfileCubit>().state;
        final isSubmitting = authState is SmeProfileSubmitting;
        
        // Critical validation: Did the CSV fail to provide Year 2?
        final bool missingYear2 = profileState.annualRevenueAmount2 <= 0;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900), onPressed: () => Navigator.pop(context)),
            title: Text(
              'Review Your Information',
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppColors.slate900,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                if (!widget.isUpdatingRecord)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    child: Column(
                      children: [
                        const ProgressIndicatorWidget(progress: 1.0),
                      ],
                    ),
                  ),
                SizedBox(height: AppSpacing.md),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Column(
                      children: [
                        if (missingYear2 && widget.isDocumentUpload)
                          Container(
                            padding: EdgeInsets.all(AppSpacing.smd),
                            margin: EdgeInsets.only(bottom: AppSpacing.md),
                            decoration: BoxDecoration(color: AppColors.warningAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.warningAmber)),
                            child: Row(children: [
                              const Icon(LucideIcons.alertTriangle, color: AppColors.warningAmber, size: 20),
                              SizedBox(width: AppSpacing.smd),
                              Expanded(child: Text("Your statement only contained 1 year of data. The AI requires at least 2 years. Please tap 'Edit' below to add your previous year's revenue.", style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.warningAmber, fontSize: 13, fontWeight: FontWeight.w600))),
                            ]),
                          ),

                        if (widget.isDocumentUpload)
                          Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.md, top: AppSpacing.xs),
                            child: Container(
                              padding: EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.trustBlue.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: AppColors.trustBlue.withValues(alpha: 0.3), width: AppSizes.borderThin),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    LucideIcons.fileText,
                                    color: AppColors.trustBlue,
                                    size: AppSizes.iconSmd,
                                  ),
                                  SizedBox(width: AppSpacing.smd),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Extracted Financial Profile',
                                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.slate900,
                                          ),
                                        ),
                                        SizedBox(height: AppSpacing.xs),
                                        Text(
                                          'The financial values below were intelligently extracted directly from your document.',
                                          style: AppTypography.textTheme.bodySmall?.copyWith(
                                            color: AppColors.slate600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      LucideIcons.info,
                                      color: AppColors.trustBlue,
                                      size: AppSizes.iconSmd,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text('Extraction Details', style: AppTypography.textTheme.headlineMedium),
                                          content: Text(
                                            'Source File: ${profileState.documentFileName ?? "Attached Statement"}\n\n'
                                            'Calculation logic:\n'
                                            'Our engine parses every isolated credit/debit row to compute your explicit 12-month trailing windows. Note that the system strictly filters and anchors your data down to the most recent 24 or 36 months to guarantee comparative consistency across the platform.',
                                            style: AppTypography.textTheme.bodyMedium?.copyWith(height: 1.5),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: const Text('Understood'),
                                            ),
                                          ],
                                          backgroundColor: AppColors.neutralWhite,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(AppRadius.xl),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (!widget.isUpdatingRecord)
                          _buildSummarySection(
                            title: 'Business Profile',
                            data: {
                              'Business Name': profileState.businessName,
                              'Industry': profileState.industry,
                              'Location': profileState.location,
                              'Years of Operation': profileState.yearsOfOperation.toString(),
                              'Employees': profileState.numberOfEmployees.toString(),
                            },
                            onEdit: widget.isDocumentUpload ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => BusinessProfilePage(isDocumentUpload: widget.isDocumentUpload, isEditing: true))),
                          ),

                        // Build sorted revenue data for display
                        () {
                          final revHistory = [
                            {'year': profileState.annualRevenueYear1, 'amount': profileState.annualRevenueAmount1},
                            {'year': profileState.annualRevenueYear2, 'amount': profileState.annualRevenueAmount2, 'isYear2': true},
                            if (profileState.annualRevenueYear3 != null && (profileState.annualRevenueAmount3 ?? 0) > 0)
                              {'year': profileState.annualRevenueYear3!, 'amount': profileState.annualRevenueAmount3!},
                          ];
                          // Sort DESC (most recent first)
                          revHistory.sort((a, b) => (b['year'] as int).compareTo(a['year'] as int));
                          
                          final Map<String, dynamic> revSummary = {};
                          for (var item in revHistory) {
                            final year = item['year'] as int;
                            final amount = item['amount'] as double;
                            final isYear2 = item['isYear2'] == true;
                            
                            String amountStr = '₦${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1)}';
                            if (isYear2 && amount <= 0) {
                              amountStr = 'MISSING (Required for AI)';
                            }
                            revSummary['Year $year Revenue'] = amountStr;
                          }
                          revSummary['Monthly Expenses'] = '₦${profileState.monthlyAvgExpenses.toStringAsFixed(profileState.monthlyAvgExpenses % 1 == 0 ? 0 : 1)}';

                          return _buildSummarySection(
                            title: 'Revenue & Expenses',
                            data: revSummary,
                            onEdit: widget.isDocumentUpload ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueExpensesPage(isEditing: true))),
                          );
                        }(),

                        // Only show Liabilities block if it was Manual Entry (or if we extracted liabilities)
                        if (!widget.isDocumentUpload || profileState.totalLiabilities > 0)
                          _buildSummarySection(
                            title: 'Liabilities & History',
                            data: {
                              'Total Liabilities': '₦${profileState.totalLiabilities.toStringAsFixed(0)}',
                              'Outstanding Loans': '₦${profileState.outstandingLoans.toStringAsFixed(0)}',
                              'Prior Funding': profileState.hasPriorFunding == true ? 'Yes' : 'No',
                            },
                            onEdit: widget.isDocumentUpload ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiabilitiesHistoryPage(isEditing: true))),
                          ),

                        if (widget.isDocumentUpload)
                          _buildSummarySection(
                            title: 'Financial Documents',
                            editLabel: 'Replace File',
                            data: {
                              'Uploaded File': profileState.documentFileName ?? 'Document Attached',
                              'Status': 'Ready for Submission',
                            },
                            onEdit: _rePickDocument,
                          ),

                        SizedBox(height: AppSpacing.xl),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: AppSpacing.xl, width: AppSpacing.xl,
                              child: Checkbox(
                                value: _isConfirmed,
                                onChanged: (val) => setState(() => _isConfirmed = val ?? false),
                                activeColor: AppColors.trustBlue,
                              ),
                            ),
                            SizedBox(width: AppSpacing.smd),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isConfirmed = !_isConfirmed),
                                child: Text('I confirm this information is accurate and complete', style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.slate900)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(child: CustomButton(text: 'Previous', variant: ButtonVariant.secondary, isDisabled: isSubmitting, onPressed: () => Navigator.pop(context))),
                      SizedBox(width: AppSpacing.smd),
                      Expanded(
                        child: CustomButton(
                          text: widget.isUpdatingRecord ? 'Generate Score' : 'Generate Score',
                          variant: ButtonVariant.primary,
                          isLoading: isSubmitting || profileState.csvProcessingStatus == CsvProcessingStatus.processing,
                          // Lock the button if Year 2 is 0!
                          isDisabled: !_isConfirmed || isSubmitting || missingYear2 || profileState.csvProcessingStatus == CsvProcessingStatus.processing,
                          onPressed: _submitData,
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