import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_progress_indicator.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/review_confirm_page.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/analysis_state_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CsvUploadPage extends StatefulWidget {
  final bool isUpdatingRecord;
  const CsvUploadPage({super.key, this.isUpdatingRecord = false});

  @override
  State<CsvUploadPage> createState() => _CsvUploadPageState();
}

class _CsvUploadPageState extends State<CsvUploadPage> {
  bool _isUploading = false;
  bool _isSuccess = false;
  bool _isError = false;
  String _errorMessage = '';
  String _fileName = '';
  List<List<dynamic>> _parsedData = [];

  void _pickAndParseFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null) {
        // Start loading state and clear previous errors
        setState(() {
          _isUploading = true;
          _isError = false;
          _errorMessage = '';
          _isSuccess = false;
        });

        final file = result.files.single;
        setState(() => _fileName = file.name);

        String csvString = '';
        if (file.bytes != null) {
          csvString = utf8.decode(file.bytes!);
        } else if (file.path != null) {
          csvString = await File(file.path!).readAsString();
        } else {
          throw Exception("Unable to read the selected file. Please ensure it's a valid CSV.");
        }

        if (mounted) {
          final cubit = context.read<SmeProfileCubit>();
          
          // 1. FAIL FAST: Wait for the Cubit to validate the 24-month rule
          await cubit.processCsv(csvString, file.name);

          // 2. CHECK RESULT: Did it fail the 24-month check?
          if (cubit.state.csvProcessingStatus == CsvProcessingStatus.error) {
            setState(() {
              _isUploading = false;
              _isError = true;
              _errorMessage = cubit.state.csvErrorMessage ?? 'Invalid statement provided.';
              _isSuccess = false;
              _parsedData = []; // Clear any preview data
            });
            
            // Error is displayed inside the container directly, omitting redundant snackbar
            return; // Stop execution right here! Do not proceed.
          }

          // 3. SUCCESS: Only build the preview table if the 24-month check passed
          final rows = CsvCodec().decoder.convert(csvString);
          setState(() {
            _isUploading = false;
            _parsedData = rows;
            _isSuccess = rows.isNotEmpty;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _isError = true;
          _errorMessage = 'We couldn\'t read your financial statement. Please check the file format.';
        });
        uiService.showSnackBar(_errorMessage, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!ModalRoute.of(context)!.isCurrent) return;
        if (state is SmeProfileSubmittedSuccess) {
          context.read<ScoreCubit>().loadScore(state.score);
          uiService.navigateTo(const AnalysisStatePage());
        } else if (state is SmeProfileSubmissionError) {
          uiService.showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.neutralWhite,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              LucideIcons.chevronLeft,
              color: AppColors.slate900,
            ),
            onPressed: () => uiService.goBack(),
          ),
          title: Text(
            'Upload Financial Data',
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
            IconButton(
              icon: const Icon(LucideIcons.x, color: AppColors.slate900),
              onPressed: () {
                uiService.goBack();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step indicator for document upload flow
                if (!widget.isUpdatingRecord)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: AppSpacing.xs,
                    ),
                    child: ProgressIndicatorWidget(progress: 0.60),
                  ),
                if (!widget.isUpdatingRecord)
                  SizedBox(height: AppSpacing.xl),
                // Text(
                //   'Upload Your Financial Data',
                //   style: AppTypography.textTheme.displaySmall,
                //   textAlign: TextAlign.center,
                // ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Upload a CSV file with your financial information. We\'ll parse and validate it for you.',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.slate600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xxl),

                // Upload Area
                GestureDetector(
                  onTap: _isUploading ? null : _pickAndParseFile,
                  child: DottedBorder(
                    options: const RoundedRectDottedBorderOptions(
                      radius: Radius.circular(AppRadius.md),
                      color: AppColors.slate300,
                      strokeWidth: 2,
                      dashPattern: [6, 6],
                    ),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: BlocBuilder<SmeProfileCubit, SmeProfileState>(
                        builder: (context, state) {
                          if (state.csvProcessingStatus ==
                              CsvProcessingStatus.processing) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: AppColors.trustBlue,
                                  ),
                                  SizedBox(height: AppSpacing.md),
                                  Text(
                                    'Processing in background...',
                                    style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.slate600),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.uploadCloud,
                                size: AppSpacing.xxxxl,
                                color: AppColors.trustBlue,
                              ),
                              SizedBox(height: AppSpacing.md),
                              Text(
                                'Tap to upload from your device',
                                style: AppTypography.textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.slate900,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              SizedBox(height: AppSpacing.xs),
                              Text(
                                '.csv files only • Max 5 MB',
                                style: AppTypography.textTheme.bodySmall
                                    ?.copyWith(color: AppColors.slate400),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Template Download
                // Row(
                //   children: [
                //     const Icon(
                //       LucideIcons.download,
                //       size: 16,
                //       color: AppColors.trustBlue,
                //     ),
                //     const SizedBox(width: 8),
                //     TextButton(
                //       onPressed: () {
                //         // TODO: Download CSV template (link to external bucket or save local asset)
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           const SnackBar(
                //             content: Text('Downloading template... (Mock)'),
                //             behavior: SnackBarBehavior.floating,
                //           ),
                //         );
                //       },
                //       style: TextButton.styleFrom(
                //         padding: EdgeInsets.zero,
                //         minimumSize: Size.zero,
                //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //       ),
                //       child: Text(
                //         'Download CSV template',
                //         style: AppTypography.textTheme.bodyMedium?.copyWith(
                //           color: AppColors.trustBlue,
                //           fontWeight: FontWeight.w600,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(height: AppSpacing.xl),

                // Validation Feedback
                if (_isSuccess)
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.successGreen.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.checkCircle,
                          color: AppColors.successGreen,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.smd),
                        Expanded(
                          child: Text(
                            '$_fileName parsed successfully. ${_parsedData.length} total rows detected.',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.successGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_isError)
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.dangerRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.dangerRed.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.alertCircle,
                          color: AppColors.dangerRed,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.smd),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.dangerRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: AppSpacing.xl),

                // Data Preview (Dynamic)
                if (_isSuccess && _parsedData.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Preview (first few rows)',
                          style: AppTypography.textTheme.labelLarge,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.slate200),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              color: AppColors.neutralWhite,
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: _buildDynamicDataTable(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),

                // Navigation Buttons
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Cancel',
                          variant: ButtonVariant.secondary,
                          onPressed: () => uiService.goBack(),
                        ),
                      ),
                      SizedBox(width: AppSpacing.smd),
                      Expanded(
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            return CustomButton(
                              text: 'Continue',
                              variant: ButtonVariant.primary,
                              isLoading: authState is SmeProfileSubmitting,
                              isDisabled: !_isSuccess,
                              onPressed: () {
                                uiService.navigateTo(
                                  ReviewConfirmPage(
                                    isDocumentUpload: true,
                                    isUpdatingRecord: widget.isUpdatingRecord,
                                  ),
                                );
                              },
                            );
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
      ),
    );
  }

  Widget _buildDynamicDataTable() {
    if (_parsedData.isEmpty) return const SizedBox();

    final headers = _parsedData.first;
    final displayRows = _parsedData.length > 1
        ? _parsedData.skip(1).take(5).toList()
        : <List<dynamic>>[];

    return DataTable(
      headingRowHeight: 40,
      dataRowMinHeight: 40,
      dataRowMaxHeight: 40,
      headingTextStyle: AppTypography.textTheme.labelMedium?.copyWith(
        color: AppColors.slate600,
        fontWeight: FontWeight.w700,
      ),
      dataTextStyle: AppTypography.textTheme.bodySmall?.copyWith(
        color: AppColors.slate900,
      ),
      columns: headers.map((header) {
        return DataColumn(label: Text(header.toString()));
      }).toList(),
      rows: displayRows.asMap().entries.map((entry) {
        int idx = entry.key;
        List<dynamic> row = entry.value;

        return DataRow(
          color: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            return idx.isEven ? AppColors.slate50 : AppColors.neutralWhite;
          }),
          cells: List.generate(headers.length, (colIdx) {
            final cellValue = colIdx < row.length ? row[colIdx].toString() : '';
            return DataCell(Text(cellValue, overflow: TextOverflow.ellipsis));
          }),
        );
      }).toList(),
    );
  }
}
