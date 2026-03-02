import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/business_profile_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/csv_upload_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/revenue_expenses_page.dart';

class InputMethodSelectionPage extends StatelessWidget {
  final bool isUpdatingRecord;
  const InputMethodSelectionPage({super.key, this.isUpdatingRecord = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Input Method',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
          onPressed: () => Navigator.pop(context),
        ),
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
                'Choose the method that works best for you. You can always edit your information later.',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _MethodCard(
                        title: 'Manual Entry',
                        description:
                            'Fill out a step-by-step form with guided prompts',
                        icon: LucideIcons.edit3,
                        benefits: const [
                          'Guided process',
                          'Real-time validation',
                          'Save progress',
                        ],
                        ctaText: 'Start Manual Entry',
                        isPrimary: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => isUpdatingRecord ? const RevenueExpensesPage(isUpdatingRecord: true) : const BusinessProfilePage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _MethodCard(
                        title: 'CSV Upload',
                        description:
                            'Upload a structured CSV file with your financial data',
                        icon: LucideIcons.upload,
                        benefits: const [
                          'Faster for large datasets',
                          'Batch processing',
                          'Download template',
                        ],
                        ctaText: 'Upload CSV',
                        isPrimary: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CsvUploadPage(
                                isUpdatingRecord: isUpdatingRecord,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          // TODO: handle help/support
                        },
                        child: Text(
                          'Need help? Contact support',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.trustBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<String> benefits;
  final String ctaText;
  final bool isPrimary;
  final VoidCallback onTap;

  const _MethodCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.benefits,
    required this.ctaText,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_MethodCard> createState() => _MethodCardState();
}

class _MethodCardState extends State<_MethodCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isPrimary
        ? (AppColors.neutralWhite)
        : (_isHovered ? AppColors.slate100 : AppColors.slate50);

    final borderColor = widget.isPrimary
        ? (_isHovered ? AppColors.trustBlue : AppColors.slate200)
        : Colors.transparent;

    final borderWidth = widget.isPrimary && _isHovered ? 2.0 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: AppColors.slate700, size: 24),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    color: AppColors.slate900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.description,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate600,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.benefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.check,
                      color: AppColors.successGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      benefit,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.slate600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: widget.ctaText,
                onPressed: widget.onTap,
                variant: widget.isPrimary
                    ? ButtonVariant.primary
                    : ButtonVariant.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
