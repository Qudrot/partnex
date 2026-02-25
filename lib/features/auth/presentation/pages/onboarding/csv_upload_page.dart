import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnest/core/theme/app_colors.dart';
import 'package:partnest/core/theme/app_typography.dart';
import 'package:partnest/core/theme/widgets/custom_button.dart';
import 'package:partnest/features/auth/presentation/pages/onboarding/review_confirm_page.dart';

class CsvUploadPage extends StatefulWidget {
  const CsvUploadPage({super.key});

  @override
  State<CsvUploadPage> createState() => _CsvUploadPageState();
}

class _CsvUploadPageState extends State<CsvUploadPage> {
  bool _isUploading = false;
  bool _isSuccess = false;
  bool _isError = false;

  void _simulateUpload() async {
    setState(() {
      _isUploading = true;
      _isSuccess = false;
      _isError = false;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isUploading = false;
      _isSuccess = true;
    });
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
          'Upload Financial Data',
          style: AppTypography.textTheme.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.x, color: AppColors.slate900),
            onPressed: () {
              // TODO: Handle Close onboarding flow
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
              const SizedBox(height: 16),
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
                onTap: _isUploading ? null : _simulateUpload,
                child: DottedBorder(
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isUploading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.trustBlue,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.upload,
                                size: 32,
                                color: AppColors.slate600,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Drag and drop your CSV file here',
                                style: AppTypography.textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.slate900,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'or click to browse',
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.slate600),
                              ),
                              const SizedBox(height: 16),
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
                      // TODO: Download CSV template
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
                    color: AppColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.successGreen.withOpacity(0.5),
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
                          'File parsed successfully. 5 rows detected.',
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
                    color: AppColors.dangerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.dangerRed.withOpacity(0.5),
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
                          'Error parsing file. Please check the format and try again.',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.dangerRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Data Preview (Mock)
              if (_isSuccess)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Preview',
                        style: AppTypography.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.slate200),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowHeight: 40,
                                dataRowMinHeight: 40,
                                dataRowMaxHeight: 40,
                                headingTextStyle: AppTypography
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(color: AppColors.slate600),
                                dataTextStyle: AppTypography.textTheme.bodySmall
                                    ?.copyWith(color: AppColors.slate900),
                                columns: const [
                                  DataColumn(label: Text('Business Name')),
                                  DataColumn(label: Text('Industry')),
                                  DataColumn(label: Text('Rev (Y1)')),
                                  DataColumn(label: Text('Rev (Y2)')),
                                ],
                                rows: List.generate(
                                  3,
                                  (index) => DataRow(
                                    color:
                                        MaterialStateProperty.resolveWith<
                                          Color?
                                        >((Set<MaterialState> states) {
                                          return index.isEven
                                              ? AppColors.slate50
                                              : AppColors.neutralWhite;
                                        }),
                                    cells: const [
                                      DataCell(Text('Acme Mfg')),
                                      DataCell(Text('Manufacturing')),
                                      DataCell(Text('500,000')),
                                      DataCell(Text('600,000')),
                                    ],
                                  ),
                                ),
                              ),
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
                              builder: (_) => const ReviewConfirmPage(),
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
}
