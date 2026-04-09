import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/core/theme/app_theme.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnex/features/auth/presentation/blocs/discovery_cubit/discovery_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/discovery_cubit/discovery_state.dart';
import 'package:partnex/features/auth/presentation/blocs/theme_cubit/theme_cubit.dart';
import 'package:partnex/features/auth/data/models/sme_profile_data.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';
import 'package:partnex/features/auth/data/models/financial_metrics.dart';
import 'package:partnex/features/auth/data/models/user_model.dart';

// Pages
import 'package:partnex/features/auth/presentation/pages/dashboard/business_insights_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_profile_expanded_page.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/credibility_dashboard_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_discovery_feed_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/review_confirm_page.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/profile_management_page.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/score_drivers_detail_page.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/bio_edit_page.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/analysis_state_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/input_method_selection_page.dart';

// Blocs/Cubits
import 'package:partnex/features/auth/presentation/blocs/analysis_cubit/analysis_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/analysis_cubit/analysis_state.dart';

// Data
import 'package:partnex/features/auth/data/repositories/mock_sme_data.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockSmeProfileCubit extends Mock implements SmeProfileCubit {}
class MockScoreCubit extends Mock implements ScoreCubit {}
class MockDiscoveryCubit extends Mock implements DiscoveryCubit {}
class MockThemeCubit extends Mock implements ThemeCubit {}
class MockAnalysisCubit extends Mock implements AnalysisCubit {}

void main() {
  group('Pages Golden Tests', () {
    late MockAuthBloc mockAuthBloc;
    late MockSmeProfileCubit mockSmeProfileCubit;
    late MockScoreCubit mockScoreCubit;
    late MockDiscoveryCubit mockDiscoveryCubit;
    late MockThemeCubit mockThemeCubit;
    late MockAnalysisCubit mockAnalysisCubit;

    final mockSme = SmeCardData(
      id: 'sme_1',
      companyName: 'TechNova Solutions',
      industry: 'Software Development',
      location: 'Lagos, Nigeria',
      yearsOfOperation: 5,
      numberOfEmployees: 25,
      annualRevenue: 50000000,
      previousAnnualRevenue: 35000000,
      annualRevenueYear1: 2023,
      annualRevenueYear2: 2022,
      monthlyExpenses: 2500000,
      liabilities: 15000000,
      fundingHistory: 'Seed funded in 2021',
      score: 82,
      riskLevel: 'Low',
      generatedAt: DateTime(2024, 3, 24, 10, 30),
      bio: 'TechNova is a high-growth software agency in Lagos specialized in enterprise fintech solutions.',
      email: 'info@technova.com',
      phoneNumber: '+234 801 234 5678',
      website: 'www.technova.com',
    );

    final List<SmeCardData> actualSmeList = MockSmeData.getMockSmes()
        .map((map) => SmeCardData.fromMap(map))
        .toList();

    final mockScore = CredibilityScore(
      id: 'score_1',
      organisationId: 'sme_1',
      totalScore: 82.0,
      riskLevel: RiskLevel.low,
      topContributingFactors: const ['Revenue Growth', 'Stable Margins'],
      modelVersion: '1.0.0',
      calculatedAt: DateTime(2024, 3, 24, 10, 30),
      impactScore: 0.82,
    );

    final mockFinancialMetrics = FinancialMetrics(
      yoyGrowth: 42.8,
      cagr: 35.0,
      revenuePerEmployee: 2000000,
      expenseRatio: 60.0,
      profitMargin: 25.0,
      monthlyProfit: 1000000,
      liabilitiesToRevenueRatio: 30.0,
      debtServiceRatio: 15.0,
      liabilitiesPerEmployee: 500000,
      liabilitiesCoverageRatio: 2.0,
      yearsOfOperation: 5,
      employeesPerYear: 5.0,
      revenueGrowthPerEmployee: 500000,
      rankedDrivers: [
        const ScoreDriver(
          name: 'Revenue Growth & Stability',
          scoreValue: 85,
          rawDisplayValue: '+42.8% YoY',
          status: MetricStatus.positive,
          weight: 0.3,
        ),
        const ScoreDriver(
          name: 'Profitability & Efficiency',
          scoreValue: 75,
          rawDisplayValue: '25% Margin',
          status: MetricStatus.positive,
          weight: 0.25,
        ),
        const ScoreDriver(
          name: 'Debt Management',
          scoreValue: 65,
          rawDisplayValue: '30% Lib/Rev',
          status: MetricStatus.moderate,
          weight: 0.2,
        ),
      ],
    );

    setUpAll(() {
      registerFallbackValue(mockScore);
    });

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      mockSmeProfileCubit = MockSmeProfileCubit();
      mockScoreCubit = MockScoreCubit();
      mockDiscoveryCubit = MockDiscoveryCubit();
      mockThemeCubit = MockThemeCubit();
      mockAnalysisCubit = MockAnalysisCubit();

      // Default stubbing
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        UserModel(
          id: 'user_1',
          email: 'user@example.com',
          name: 'John Doe',
          role: UserRole.sme,
          profileCompleted: true,
        ),
      ));
      when(() => mockSmeProfileCubit.state).thenReturn(const SmeProfileState(
        businessName: 'TechNova Solutions',
        industry: 'Software Development',
        location: 'Lagos, Nigeria',
      ));
      when(() => mockScoreCubit.state).thenReturn(ScoreLoadedSuccess(
        score: mockScore,
        smeProfile: {},
        financialMetrics: mockFinancialMetrics,
      ));
      when(() => mockDiscoveryCubit.state).thenReturn(DiscoveryLoaded(smes: [mockSme, mockSme, mockSme]));
      when(() => mockThemeCubit.state).thenReturn(ThemeMode.light);
      when(() => mockAnalysisCubit.state).thenReturn(const AnalysisState(
        step: 2,
        totalSteps: 3,
        progress: 65.0,
      ));

      when(() => mockDiscoveryCubit.loadSmes()).thenAnswer((_) async {});
      when(() => mockScoreCubit.loadScore(any())).thenAnswer((_) async {});

      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(mockAuthBloc.state));
      when(() => mockSmeProfileCubit.stream).thenAnswer((_) => Stream.value(mockSmeProfileCubit.state));
      when(() => mockScoreCubit.stream).thenAnswer((_) => Stream.value(mockScoreCubit.state));
      when(() => mockDiscoveryCubit.stream).thenAnswer((_) => Stream.value(mockDiscoveryCubit.state));
      when(() => mockThemeCubit.stream).thenAnswer((_) => Stream.value(ThemeMode.light));
      when(() => mockAnalysisCubit.stream).thenAnswer((_) => Stream.value(mockAnalysisCubit.state));
    });

    Widget createTestWidget(Widget child, {ThemeMode mode = ThemeMode.light}) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          BlocProvider<SmeProfileCubit>.value(value: mockSmeProfileCubit),
          BlocProvider<ScoreCubit>.value(value: mockScoreCubit),
          BlocProvider<DiscoveryCubit>.value(value: mockDiscoveryCubit),
          BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
          BlocProvider<AnalysisCubit>.value(value: mockAnalysisCubit),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: child,
        ),
      );
    }

    final devices = [
      Device.iphone11,
    ];

    testGoldens('business_insights_page renders in light and dark mode', (tester) async {
      final page = BusinessInsightsPage(sme: mockSme, isSmeView: true);
      
      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.light), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'business_insights_page_light');

      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.dark), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'business_insights_page_dark');
    });

    testGoldens('sme_profile_expanded_page renders in light and dark mode', (tester) async {
      final page = SmeProfileExpandedPage(sme: mockSme);
      
      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.light), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'sme_profile_expanded_page_light');

      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.dark), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'sme_profile_expanded_page_dark');
    });

    testGoldens('credibility_dashboard_page renders in light and dark mode', (tester) async {
      const page = CredibilityDashboardPage();
      
      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.light), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'credibility_dashboard_page_light');

      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.dark), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'credibility_dashboard_page_dark');
    });

    testGoldens('sme_discovery_feed_page renders with actual SME data in light and dark mode', (tester) async {
      when(() => mockDiscoveryCubit.state).thenReturn(DiscoveryLoaded(smes: actualSmeList));
      
      const page = SmeDiscoveryFeedPage();
      
      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.light), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'sme_discovery_feed_page_light');

      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.dark), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'sme_discovery_feed_page_dark');
    });

    testGoldens('review_confirm_page for file upload renders in light and dark mode', (tester) async {
      when(() => mockSmeProfileCubit.state).thenReturn(const SmeProfileState(
        businessName: 'TechNova Solutions',
        industry: 'Software Development',
        location: 'Lagos, Nigeria',
        documentFileName: 'statement_2024.csv',
        annualRevenueAmount1: 50000000,
        annualRevenueYear1: 2023,
        annualRevenueAmount2: 35000000,
        annualRevenueYear2: 2022,
        monthlyAvgExpenses: 2500000,
        totalLiabilities: 15000000,
      ));
      
      const page = ReviewConfirmPage(isDocumentUpload: true);
      
      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.light), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'review_confirm_page_light');

      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.dark), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'review_confirm_page_dark');
    });

    testGoldens('profile_management_page renders in light and dark mode', (tester) async {
      const page = ProfileManagementPage();
      
      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.light), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'profile_management_page_light');

      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.dark), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'profile_management_page_dark');
    });

    testGoldens('score_driver_detail_page renders in light and dark mode', (tester) async {
      final page = ScoreDriversDetailPage(sme: mockSme);
      
      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.light), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'score_driver_detail_page_light');

      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.dark), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'score_driver_detail_page_dark');
    });

    testGoldens('bio_edit_page with long bio renders in light and dark mode', (tester) async {
      final String realisticLongBio = ('''
Partnex is a revolutionary financial technology platform dedicated to bridging the significant funding gap faced by small and medium-sized enterprises (SMEs) in emerging markets, with a primary focus on Nigeria. Our mission is to empower business owners by providing them with the tools and data-driven insights they need to establish credibility and access institutional capital. At the heart of Partnex is our advanced, AI-powered credibility scoring engine. This engine analyzes a wide array of financial and non-financial data points, including revenue trends, expense ratios, liability management, and operational maturity, to generate a comprehensive and transparent score for each business.
''' * 2).trim(); 
      final finalBio = realisticLongBio.split(' ').take(659).join(' ');

      final page = BioEditPage(
        initialBio: finalBio,
        initialWebsite: 'https://technova.com',
        initialWhatsapp: '+234 801 234 5678',
        initialLinkedin: 'linkedin.com/company/technova',
        initialTwitter: '@technova',
      );
      
      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.light), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'bio_edit_page_light');

      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.dark), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'bio_edit_page_dark');
    });

    testGoldens('analysis_state_page renders in light and dark mode', (tester) async {
      final page = AnalysisStatePage(isDocumentUpload: false, analysisCubit: mockAnalysisCubit);
      
      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.light), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'analysis_state_page_light');

      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.dark), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'analysis_state_page_dark');
    });

    testGoldens('input_method_selection_page renders in light and dark mode', (tester) async {
      const page = InputMethodSelectionPage();
      
      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.light), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'input_method_selection_page_light');

      await tester.pumpWidgetBuilder(createTestWidget(page, mode: ThemeMode.dark), surfaceSize: devices[0].size);
      await screenMatchesGolden(tester, 'input_method_selection_page_dark');
    });
  });
}

extension on SmeCardData {
  SmeCardData copyWith({
    String? id,
    String? companyName,
  }) {
    return SmeCardData(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      industry: industry,
      location: location,
      yearsOfOperation: yearsOfOperation,
      numberOfEmployees: numberOfEmployees,
      annualRevenue: annualRevenue,
      previousAnnualRevenue: previousAnnualRevenue,
      annualRevenueYear1: annualRevenueYear1,
      annualRevenueYear2: annualRevenueYear2,
      monthlyExpenses: monthlyExpenses,
      liabilities: liabilities,
      fundingHistory: fundingHistory,
      score: score,
      riskLevel: riskLevel,
      generatedAt: generatedAt,
      bio: bio,
      email: email,
      phoneNumber: phoneNumber,
      website: website,
    );
  }
}
