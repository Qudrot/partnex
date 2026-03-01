import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:partnex/core/network/api_client.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/partnex_logo.dart';
import 'package:partnex/features/auth/presentation/pages/login_page.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/credibility_dashboard_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_discovery_feed_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/input_method_selection_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  final _secureStorage = const FlutterSecureStorage();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Show splash for at least 5 seconds
    await Future.delayed(const Duration(milliseconds: 5000));

    if (!mounted) return;

    // Check for stored JWT token — if found, user is already logged in
    final storedToken = await _secureStorage.read(key: 'jwt_token');
    final storedRole = await _secureStorage.read(key: 'user_role');
    final storedProfileCompleted = await _secureStorage.read(key: 'profile_completed');
    final isProfileCompleted = storedProfileCompleted == 'true';

    if (storedToken != null && storedToken.isNotEmpty) {
      // Re-inject token into ApiClient for this session
      ApiClient.restoreToken(storedToken);
      if (kDebugMode) print('SPLASH: Token restored → navigating to Dashboard');

      Widget nextRoute;
      if (storedRole == 'investor') {
        nextRoute = const SmeDiscoveryFeedPage();
      } else {
        if (isProfileCompleted) {
          nextRoute = const CredibilityDashboardPage();
        } else {
          nextRoute = const InputMethodSelectionPage();
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                nextRoute,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } else {
      if (kDebugMode) print('SPLASH: No token → navigating to Login');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PartnexLogo(size: 48, variant: PartnexLogoVariant.brandCombo),
                const SizedBox(height: 4),
                Text(
                  'Your SME credibility platform',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.slate600,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
