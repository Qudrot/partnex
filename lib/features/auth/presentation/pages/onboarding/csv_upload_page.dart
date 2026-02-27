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

class CsvUploadPage extends StatefulWidget {
  const CsvUploadPage({super.key});

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
        setState(() {
          _isUploading = true;
          _isSuccess = false;
          _isError = false;
          _errorMessage = '';
        });

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

        // Parse CSV
        List<List<dynamic>> rowsAsListOfValues = CsvCodec().decoder.convert(csvString);

        if (rowsAsListOfValues.isEmpty) {
          throw Exception("The CSV file is empty.");
        }

        // Simulate slight parsing delay for UX
        await Future.delayed(const Duration(milliseconds: 600));

        if (mounted) {
           setState(() {
             _parsedData = rowsAsListOfValues;
             _isUploading = false;
             _isSuccess = true;
           });
        }
      }
    } catch (e) {
      if (mounted) {
         setState(() {
           _isUploading = false;
           _isError = true;
           _errorMessage = 'Error parsing file. Please check the format. Details: ${e.toString()}';
           _isSuccess = false;
         });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upload Financial Data',
          style: AppTypography.textTheme.headlineMedium?.copyWith(
             fontSize: 16,
             color: AppColors.slate900,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.x, color: AppColors.slate900),
            onPressed: () {
              Navigator.pop(context);
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
                      'Step 1 of 3',
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
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isUploading
                        ? const Center(
                            child: Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                  CircularProgressIndicator(color: AppColors.trustBlue),
                                  SizedBox(height: 16),
                                  Text('Parsing data...', style: TextStyle(color: AppColors.slate600)),
                               ],
                            ),
                          )
                        : Column(
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
                                style: AppTypography.textTheme.bodyLarge
                                    ?.copyWith(
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
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Continue',
                        variant: ButtonVariant.primary,
                        isDisabled: !_isSuccess,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BusinessProfilePage(isDocumentUpload: true),
                            ),
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
                color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
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
