import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_progress_indicator.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/business_profile_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/liabilities_history_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/revenue_expenses_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/success_next_steps_page.dart';

class ReviewConfirmPage extends StatefulWidget {
  final bool isDocumentUpload;

  const ReviewConfirmPage({
    super.key,
    this.isDocumentUpload = false,
  });

  @override
  State<ReviewConfirmPage> createState() => _ReviewConfirmPageState();
}

class _ReviewConfirmPageState extends State<ReviewConfirmPage> {
  bool _isConfirmed = false;
  String _uploadedFileName = 'Document Attached';

  void _submitData() {
    final state = context.read<SmeProfileCubit>().state;
    context.read<AuthBloc>().add(SubmitSmeProfileEvent(state.toMap()));
  }

  /// Re-opens file picker so the user can swap out their uploaded document.
  Future<void> _rePickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'pdf', 'xls', 'xlsx'],
        withData: true,
      );

      if (result != null) {
        final file = result.files.single;
        setState(() {
          _uploadedFileName = file.name;
        });

        // If CSV, auto-parse to update the profile cubit data
        if (file.name.toLowerCase().endsWith('.csv')) {
          String csvString = '';
          if (file.bytes != null) {
            csvString = utf8.decode(file.bytes!);
          } else if (file.path != null) {
            csvString = await File(file.path!).readAsString();
          }
          if (csvString.isNotEmpty) {
            // Parsed data is available if needed for future auto-fill
            CsvCodec().decoder.convert(csvString);
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File replaced: ${file.name}'),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error replacing file: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildSummarySection({
    required String title,
    required Map<String, String> data,
    required VoidCallback onEdit,
    String editLabel = 'Edit',
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  fontSize: 16,
                  color: AppColors.slate900,
                ),
              ),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    editLabel,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.trustBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...data.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.slate600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.value,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.slate900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SmeProfileSubmittedSuccess) {
          context.read<ScoreCubit>().loadScore(state.score);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SuccessNextStepsPage()),
          );
        } else if (state is SmeProfileSubmissionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.dangerRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, authState) {
        final profileState = context.watch<SmeProfileCubit>().state;
        final isSubmitting = authState is SmeProfileSubmitting;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                LucideIcons.chevronLeft,
                color: AppColors.slate900,
              ),
              onPressed: () => Navigator.pop(context),
            ),
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
                      Text(
                        'Review Your Information',
                        style: AppTypography.textTheme.displayMedium?.copyWith(
                          fontSize: 24,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ProgressIndicatorWidget(
                        progress: widget.isDocumentUpload ? 1.0 : 0.80,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isDocumentUpload
                            ? 'Step 3 of 3'
                            : 'Step 4 of 5',
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
                    child: Column(
                      children: [
                        // --- Business Profile Section ---
                        _buildSummarySection(
                          title: 'Business Profile',
                          data: {
                            'Business Name': profileState.businessName,
                            'Industry': profileState.industry,
                            'Location': profileState.location,
                            'Years of Operation':
                                profileState.yearsOfOperation.toString(),
                            'Employees':
                                profileState.numberOfEmployees.toString(),
                          },
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BusinessProfilePage(
                                  isDocumentUpload: widget.isDocumentUpload,
                                ),
                              ),
                            );
                          },
                        ),

                        // --- Manual Entry: Revenue & Expenses + Liabilities ---
                        if (!widget.isDocumentUpload) ...[
                          _buildSummarySection(
                            title: 'Revenue & Expenses',
                            data: {
                              'Annual Revenue':
                                  '₦${profileState.annualRevenue.toStringAsFixed(0)}',
                              'Annual Expenses':
                                  '₦${profileState.annualExpenses.toStringAsFixed(0)}',
                              'Monthly Revenue':
                                  '₦${profileState.monthlyAvgRevenue.toStringAsFixed(0)}',
                              'Monthly Expenses':
                                  '₦${profileState.monthlyAvgExpenses.toStringAsFixed(0)}',
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RevenueExpensesPage(),
                                ),
                              );
                            },
                          ),

                          _buildSummarySection(
                            title: 'Liabilities & History',
                            data: {
                              'Total Liabilities':
                                  '₦${profileState.totalLiabilities.toStringAsFixed(0)}',
                              'Outstanding Loans':
                                  '₦${profileState.outstandingLoans.toStringAsFixed(0)}',
                              'Prior Funding':
                                  profileState.hasPriorFunding == true
                                      ? 'Yes'
                                      : 'No',
                              'Prior Funding Amount':
                                  profileState.priorFundingAmount != null
                                      ? '₦${profileState.priorFundingAmount!.toStringAsFixed(0)}'
                                      : 'N/A',
                              'Funding Source':
                                  profileState.priorFundingSource ?? 'N/A',
                              'Funding Year':
                                  profileState.fundingYear?.toString() ?? 'N/A',
                              'On-Time Payment Rate':
                                  profileState.onTimePaymentRate != null
                                      ? '${profileState.onTimePaymentRate}%'
                                      : 'N/A',
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const LiabilitiesHistoryPage(),
                                ),
                              );
                            },
                          ),
                        ] else ...[
                          // --- Document Upload: show file summary + Change Upload ---
                          _buildSummarySection(
                            title: 'Financial Documents',
                            editLabel: 'Change',
                            data: {
                              'Uploaded File': _uploadedFileName,
                              'Status': 'Ready for Submission',
                            },
                            onEdit: _rePickDocument,
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Confirmation Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _isConfirmed,
                                onChanged: (val) {
                                  setState(() => _isConfirmed = val ?? false);
                                },
                                activeColor: AppColors.trustBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: const BorderSide(
                                  color: AppColors.slate400,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _isConfirmed = !_isConfirmed,
                                ),
                                child: Text(
                                  'I confirm this information is accurate and complete',
                                  style: AppTypography.textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.slate900),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
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
                          isDisabled: isSubmitting,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Generate Score',
                          variant: ButtonVariant.primary,
                          isDisabled: !_isConfirmed || isSubmitting,
                          isLoading: isSubmitting,
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
