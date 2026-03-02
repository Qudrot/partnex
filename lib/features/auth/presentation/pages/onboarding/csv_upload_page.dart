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
import 'package:partnex/features/auth/presentation/pages/onboarding/business_profile_page.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/analysis_state_page.dart';
import 'package:partnex/core/services/ui_service.dart';
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
        final file = result.files.single;
        setState(() => _fileName = file.name);

        String csvString = '';
        if (file.bytes != null) {
          csvString = utf8.decode(file.bytes!);
        } else if (file.path != null) {
          csvString = await File(file.path!).readAsString();
        } else {
          throw Exception("Could not read file data.");
        }

        if (mounted) {
          context.read<SmeProfileCubit>().processCsv(csvString, file.name);
          
          // We still want to parse locally ONLY for the preview table, 
          // but we do NOT wait for it to block navigation.
          final rows = CsvCodec().decoder.convert(csvString);
          setState(() {
            _parsedData = rows;
            _isSuccess = rows.isNotEmpty;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        uiService.showSnackBar('Error reading file: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
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
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step indicator for document upload flow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                child: Column(
                  children: [
                    ProgressIndicatorWidget(progress: 0.33),
                    const SizedBox(height: 6),
                    Text(
                      widget.isUpdatingRecord ? 'Step 1 of 1' : 'Step 1 of 3',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.slate600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Upload Your Financial Data',
                style: AppTypography.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a CSV file with your financial information. We\'ll parse and validate it for you.',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Upload Area
              GestureDetector(
                onTap: _isUploading ? null : _pickAndParseFile,
                child: DottedBorder(
                  options: const RoundedRectDottedBorderOptions(
                    radius: Radius.circular(8),
                    color: AppColors.slate300,
                    strokeWidth: 2,
                    dashPattern: [6, 6],
                  ),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    child: BlocBuilder<SmeProfileCubit, SmeProfileState>(
                        builder: (context, state) {
                          if (state.csvProcessingStatus == CsvProcessingStatus.processing) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: AppColors.trustBlue),
                                  SizedBox(height: 16),
                                  Text('Processing in background...',
                                      style: TextStyle(color: AppColors.slate600)),
                                ],
                              ),
                            );
                          }
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.uploadCloud,
                                size: 48,
                                color: AppColors.trustBlue,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tap to upload from your device',
                                style: AppTypography.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.slate900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
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
              const SizedBox(height: 16),

              // Template Download
              Row(
                children: [
                  const Icon(
                    LucideIcons.download,
                    size: 16,
                    color: AppColors.trustBlue,
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      // TODO: Download CSV template (link to external bucket or save local asset)
                      ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Downloading template... (Mock)'), behavior: SnackBarBehavior.floating),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Download CSV template',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.trustBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Validation Feedback
              if (_isSuccess)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
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
                      const SizedBox(width: 12),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
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
                      const SizedBox(width: 12),
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

              const SizedBox(height: 24),

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
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.slate200),
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
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
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        variant: ButtonVariant.secondary,
                        onPressed: () => uiService.goBack(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          return CustomButton(
                            text: widget.isUpdatingRecord ? 'Generate Score' : 'Continue',
                            variant: ButtonVariant.primary,
                            isLoading: authState is SmeProfileSubmitting,
                            isDisabled: !_isSuccess,
                            onPressed: () {
                              if (widget.isUpdatingRecord) {
                                // Instant navigation as per Step 2/3 architecture
                                uiService.navigateTo(const AnalysisStatePage());
                              } else {
                                uiService.navigateTo(const BusinessProfilePage(isDocumentUpload: true));
                              }
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
     final displayRows = _parsedData.length > 1 ? _parsedData.skip(1).take(5).toList() : <List<dynamic>>[];

     return DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 40,
        dataRowMaxHeight: 40,
        headingTextStyle: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600, fontWeight: FontWeight.w700),
        dataTextStyle: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.slate900),
        columns: headers.map((header) {
           return DataColumn(label: Text(header.toString()));
        }).toList(),
        rows: displayRows.asMap().entries.map((entry) {
            int idx = entry.key;
            List<dynamic> row = entry.value;

            return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
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
