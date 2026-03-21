import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:partnex/core/network/api_client.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/partnex_logo.dart';
import 'package:partnex/features/auth/presentation/pages/login_page.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/credibility_dashboard_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_discovery_feed_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/business_profile_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // 1. Force the splash screen to hold for exactly 5 seconds
    await Future.delayed(const Duration(seconds: 3));

    // 2. Perform authentication checks while the user waits
    final storedToken = await _secureStorage.read(key: 'jwt_token');
    final storedRole = await _secureStorage.read(key: 'user_role');
    final storedProfileCompleted = await _secureStorage.read(key: 'profile_completed');
    final isProfileCompleted = storedProfileCompleted == 'true';

    Widget nextRoute = const LoginPage(); // Default to login page

    if (storedToken != null && storedToken.isNotEmpty) {
      // Re-inject token into ApiClient for this session
      ApiClient.restoreToken(storedToken);
      if (mounted) {
        context.read<AuthBloc>().add(RestoreSessionEvent());
      }
      if (kDebugMode) print('SPLASH: Token restored → navigating to Dashboard');

      if (storedRole == 'investor') {
        nextRoute = const SmeDiscoveryFeedPage();
      } else {
        if (isProfileCompleted) {
          nextRoute = const CredibilityDashboardPage();
        } else {
          nextRoute = const BusinessProfilePage();
        }
      }
    } else {
      if (kDebugMode) print('SPLASH: No token → navigating to Login');
    }

    // 3. Smoothly transition to the determined route
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextRoute,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Smooth fade transition
            return FadeTransition(opacity: animation, child: child);
          },
          // Increased duration for a smoother, more elegant fade
          transitionDuration: const Duration(milliseconds: 600), 
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.98, end: 1.02),
          duration: const Duration(seconds: 5),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PartnexLogo(size: 48, variant: PartnexLogoVariant.brandCombo),
              const SizedBox(height: 4),
              Text(
                'Your SME credibility platform',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.slate600,
                  fontSize: AppSpacing.smd,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}