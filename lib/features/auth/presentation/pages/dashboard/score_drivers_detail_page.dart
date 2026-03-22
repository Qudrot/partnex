import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/driver_card.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnex/features/auth/data/models/financial_metrics.dart';

import 'package:partnex/features/auth/data/models/sme_profile_data.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/discovery_cubit/discovery_cubit.dart';
import 'package:partnex/core/theme/widgets/message_sme_bottom_sheet.dart';

class ScoreDriversDetailPage extends StatelessWidget {
  final SmeCardData? sme;
  const ScoreDriversDetailPage({super.key, this.sme});

  DriverRiskLevel _mapRiskLevel(MetricStatus status) {
    switch (status) {
      case MetricStatus.positive:
        return DriverRiskLevel.excellent;
      case MetricStatus.moderate:
        return DriverRiskLevel.moderate;
      case MetricStatus.concerning:
        return DriverRiskLevel.needsWork;
      case MetricStatus.critical:
        return DriverRiskLevel.critical;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Score Breakdown',
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
      body: BlocBuilder<ScoreCubit, ScoreState>(
        builder: (context, state) {
          final sc = sme?.score ?? (state is ScoreLoadedSuccess ? state.score.totalScore : 0);
          final rLevel = sme?.riskLevel.toUpperCase() ?? (state is ScoreLoadedSuccess ? state.score.riskLevel.name.toUpperCase() : 'UNKNOWN');
          final rankedDrivers = sme?.drivers ?? (state is ScoreLoadedSuccess ? state.financialMetrics?.rankedDrivers ?? [] : []);

          if (sme == null && (state is! ScoreLoadedSuccess || state.financialMetrics == null)) {
            return const Center(child: CircularProgressIndicator(color: AppColors.trustBlue));
          }

          return SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xl,
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Score: ${sc.toInt()}',
                      style: AppTypography.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                        fontSize: 28,
                      ),
                    ),
                    SizedBox(width: AppSpacing.smd),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (rLevel == 'LOW')
                            ? AppColors.successGreen
                            : (rLevel == 'MEDIUM' ? AppColors.warningOrange : AppColors.dangerRed),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '$rLevel RISK',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutralWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Text(
                  'Primary Drivers (Top Impact)',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                ...rankedDrivers.take(3).map((driver) {
                  final String name = (driver is DriverMetric)
                      ? driver.name
                      : (driver as ScoreDriver).name;
                  final DriverRiskLevel risk = (driver is DriverMetric)
                      ? driver.riskLevel
                      : _mapRiskLevel((driver as ScoreDriver).status);
                  final double pct = (driver is DriverMetric)
                      ? driver.percentage
                      : (driver as ScoreDriver).scoreValue;
                  final double impact = (driver is DriverMetric)
                      ? driver.impactPoints
                      : (driver as ScoreDriver).impactPoints;
                  final String desc = (driver is DriverMetric)
                      ? driver.description
                      : (state as ScoreLoadedSuccess).financialMetrics!.getDriverExplanation((driver as ScoreDriver).name);

                  return DriverCard(
                    driverName: name,
                    riskLevel: risk,
                    percentage: pct,
                    impactPoints: impact,
                    description: desc,
                    initiallyExpanded: rankedDrivers.indexOf(driver) == 0,
                  );
                }),

                const SizedBox(height: 24),

                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      'Secondary Drivers',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    children: rankedDrivers.skip(3).map((driver) {
                      final String name = (driver is DriverMetric)
                          ? driver.name
                          : (driver as ScoreDriver).name;
                      final DriverRiskLevel risk = (driver is DriverMetric)
                          ? driver.riskLevel
                          : _mapRiskLevel((driver as ScoreDriver).status);
                      final double pct = (driver is DriverMetric)
                          ? driver.percentage
                          : (driver as ScoreDriver).scoreValue;
                      final double impact = (driver is DriverMetric)
                          ? driver.impactPoints
                          : (driver as ScoreDriver).impactPoints;
                      final String desc = (driver is DriverMetric)
                          ? driver.description
                          : (state as ScoreLoadedSuccess).financialMetrics!.getDriverExplanation((driver as ScoreDriver).name);

                      return DriverCard(
                        driverName: name,
                        riskLevel: risk,
                        percentage: pct,
                        impactPoints: impact,
                        description: desc,
                        initiallyExpanded: false,
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 32),
                Text(
                  'Improvement Recommendations',
                  style: AppTypography.textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                if (sme == null) ..._generateRecommendations(context, (state as ScoreLoadedSuccess).financialMetrics!),

                const SizedBox(height: 32),
                if (sme != null) ...[
                  CustomButton(
                    text: 'Contact SME',
                    variant: ButtonVariant.primary,
                    isFullWidth: true,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => MessageSmeBottomSheet(
                          companyName: sme!.companyName,
                          email: sme!.email,
                          phoneNumber: sme!.phoneNumber,
                          website: sme!.website,
                          whatsappNumber: sme!.whatsappNumber,
                          linkedinUrl: sme!.linkedinUrl,
                          twitterHandle: sme!.twitterHandle,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'View Insights',
                    variant: ButtonVariant.secondary,
                    isFullWidth: true,
                    onPressed: () => context
                        .read<DiscoveryCubit>()
                        .viewBusinessInsights(sme!),
                  ),
                ] else ...[
                  CustomButton(
                    text: 'View Insights',
                    variant: ButtonVariant.primary,
                    isFullWidth: true,
                    onPressed: () {
                      final profileState = context.read<SmeProfileCubit>().state;
                      final ownSme = profileState.toSmeCardData(sc.toInt(), rLevel);
                      context.read<DiscoveryCubit>().viewBusinessInsights(ownSme, isSmeView: true);
                    },
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationSection(
    BuildContext context, {
    required String title,
    required List<String> items,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Text(
                item,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.trustBlue,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _generateRecommendations(BuildContext context, FinancialMetrics metrics) {
    List<Widget> sections = [];
    final recommendationsMap = metrics.getImprovementRecommendations();

    for (var entry in recommendationsMap.entries) {
      sections.add(
        _buildRecommendationSection(context, title: '${entry.key}:', items: entry.value),
      );
    }

    if (sections.isEmpty) {
      sections.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
          child: Text(
            'You have it figured out! Keep rising and growing—you are on an exceptional path of financial stability and credibility.',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.successGreen,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return sections;
  }
}
