import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_input_field.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/pages/signup_page.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/data/models/user_model.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/credibility_dashboard_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_discovery_feed_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/business_profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      // Dispatch the real LoginEvent to AuthBloc — this calls the backend API
      // and stores the JWT token via ApiAuthRepository.
      context.read<AuthBloc>().add(LoginEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          if (user.role == UserRole.investor) {
            uiService.replaceWith(const SmeDiscoveryFeedPage());
          } else {
            if (user.profileCompleted) {
              uiService.replaceWith(const CredibilityDashboardPage());
            } else {
              uiService.replaceWith(const BusinessProfilePage());
            }
          }
        } else if (state is AuthError) {
          if (state.message.contains('REGISTRATION_REDIRECT')) {
            final displayMsg = state.message.split('|')[0];
            uiService.showSnackBar(displayMsg);
            uiService.replaceWith(SignupPage(emailPrefill: _emailController.text.trim()));
          } else {
            uiService.showSnackBar(state.message, isError: true);
          }
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Scaffold(
            backgroundColor: AppColors.neutralWhite,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Center(
                      child: Text(
                        'Log In',
                        style: AppTypography.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  
                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                'Sign in to your Partnex account',
                                textAlign: TextAlign.center,
                                style: AppTypography.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.slate600,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xl),
                              
                              CustomInputField(
                                label: 'Email Address *',
                                placeholder: 'you@example.com',
                                controller: _emailController,
                                autofillHints: const [AutofillHints.email],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a valid email address';
                                  }
                                  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegExp.hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: AppSpacing.md),
                              
                              CustomInputField(
                                label: 'Password *',
                                placeholder: '········',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                autofillHints: const [AutofillHints.password],
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                    color: AppColors.slate400,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password.';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: AppSpacing.xl),
                              CustomButton(
                                text: 'Sign In',
                                isFullWidth: true,
                                onPressed: _handleSignIn,
                                isLoading: isLoading,
                              ),
                              SizedBox(height: AppSpacing.md),
                              Align(
                                alignment: Alignment.centerRight,
                                child: CustomButton(
                                  text: 'Forgot Password?',
                                  variant: ButtonVariant.tertiary,
                                  onPressed: () {
                                    // TODO: Navigate to Forgot Password
                                  },
                                ),
                              ),
                              SizedBox(height: AppSpacing.smd),
                              CustomButton(
                                text: "Don't have an account? Sign up",
                                variant: ButtonVariant.tertiary,
                                isFullWidth: true,
                                onPressed: () {
                                  uiService.replaceWith(const SignupPage());
                                },
                              ),
                              SizedBox(height: AppSpacing.xl),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
