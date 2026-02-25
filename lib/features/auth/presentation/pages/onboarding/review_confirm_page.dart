import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnest/core/theme/app_colors.dart';
import 'package:partnest/core/theme/app_typography.dart';
import 'package:partnest/core/theme/widgets/custom_button.dart';
import 'package:partnest/core/theme/widgets/custom_progress_indicator.dart';
import 'package:partnest/features/auth/presentation/pages/onboarding/success_next_steps_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnest/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnest/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnest/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:partnest/features/auth/presentation/blocs/auth_event.dart';
import 'package:partnest/features/auth/presentation/blocs/auth_state.dart';

class ReviewConfirmPage extends StatefulWidget {
  const ReviewConfirmPage({super.key});

  @override
  State<ReviewConfirmPage> createState() => _ReviewConfirmPageState();
}

class _ReviewConfirmPageState extends State<ReviewConfirmPage> {
  bool _isConfirmed = false;
  void _submitData() {
    final state = context.read<SmeProfileCubit>().state;
    context.read<AuthBloc>().add(SubmitSmeProfileEvent(state.toMap()));
  }

  Widget _buildSummarySection({
    required String title,
    required Map<String, String> data,
    required VoidCallback onEdit,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    'Edit',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.trustBlue,
                      fontWeight: FontWeight.w500,
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
          // Inject the newly generated AI Score into our global Score Tracker
          context.read<ScoreCubit>().loadScore(state.score);
          
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SuccessNextStepsPage()),
          );
        } else if (state is SmeProfileSubmissionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, authState) {
        final profileState = context.watch<SmeProfileCubit>().state;
        final _isSubmitting = authState is SmeProfileSubmitting;

        return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
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
                  ProgressIndicatorWidget(progress: 0.80),
                  const SizedBox(height: 8),
                  Text(
                    'Step 4 of 5',
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
                    _buildSummarySection(
                      title: 'Business Profile',
                      data: {
                        'Business Name': profileState.businessName,
                        'Industry': profileState.industry,
                        'Location': profileState.location,
                        'Years of Operation': profileState.yearsOfOperation.toString(),
                        'Employees': profileState.numberOfEmployees.toString(),
                      },
                      onEdit: () {
                        // TODO: Navigate to Edit Business Profile
                        Navigator.popUntil(
                          context,
                          (route) =>
                              route.settings.name == '/business_profile' ||
                              route.isFirst,
                        );
                      },
                    ),

                    _buildSummarySection(
                      title: 'Revenue & Expenses',
                      data: {
                        'Annual Revenue (Year 1)': '₦${profileState.year1Revenue.toStringAsFixed(0)}',
                        'Annual Revenue (Year 2)': '₦${profileState.year2Revenue.toStringAsFixed(0)}',
                        'Annual Revenue (Year 3)': profileState.year3Revenue != null ? '₦${profileState.year3Revenue!.toStringAsFixed(0)}' : 'N/A',
                        'Monthly Revenue': '₦${profileState.monthlyAvgRevenue.toStringAsFixed(0)}',
                        'Monthly Expenses': '₦${profileState.monthlyAvgExpenses.toStringAsFixed(0)}',
                      },
                      onEdit: () {
                        // TODO: Navigate to Edit Revenue
                      },
                    ),

                    _buildSummarySection(
                      title: 'Liabilities & History',
                      data: {
                        'Existing Liabilities': '₦${profileState.existingLiabilities.toStringAsFixed(0)}',
                        'Liability Type': profileState.liabilityType ?? 'None',
                        'Prior Funding': profileState.hasPriorFunding == true ? 'Yes' : 'No',
                        'Prior Funding Amount': profileState.priorFundingAmount != null ? '₦${profileState.priorFundingAmount!.toStringAsFixed(0)}' : 'N/A',
                        'Funding Source': profileState.priorFundingSource ?? 'N/A',
                        'Funding Year': profileState.fundingYear?.toString() ?? 'N/A',
                        'Defaulted': profileState.hasDefaulted == true ? 'Yes' : 'No',
                        'Payment Timeliness': profileState.paymentTimeliness ?? 'N/A',
                      },
                      onEdit: () {
                        // TODO: Navigate to Edit Hub
                      },
                    ),

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
                            side: const BorderSide(color: AppColors.slate400),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _isConfirmed = !_isConfirmed),
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
                      isDisabled: _isSubmitting,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Generate Score',
                      variant: ButtonVariant.primary,
                      isDisabled: !_isConfirmed || _isSubmitting,
                      isLoading: _isSubmitting,
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
