import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:partnex/core/network/api_client.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/partnex_logo.dart';
import 'package:partnex/features/auth/presentation/pages/login_page.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/credibility_dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.04).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Show splash for at least 2 seconds
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // Check for stored JWT token — if found, user is already logged in
    final storedToken = await _secureStorage.read(key: 'jwt_token');

    if (storedToken != null && storedToken.isNotEmpty) {
      // Re-inject token into ApiClient for this session
      ApiClient.restoreToken(storedToken);
      if (kDebugMode) print('SPLASH: Token restored → navigating to Dashboard');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const CredibilityDashboardPage(),
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: const PartnexLogo(size: 64, variant: PartnexLogoVariant.iconOnly),
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock SME Credibility',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate600,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
