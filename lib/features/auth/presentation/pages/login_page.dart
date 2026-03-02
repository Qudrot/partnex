import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/custom_input_field.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_state.dart';
import 'package:partnex/features/auth/presentation/pages/signup_page.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/credibility_dashboard_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_discovery_feed_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/input_method_selection_page.dart';
import 'package:partnex/features/auth/data/models/user_model.dart';
import 'package:partnex/core/services/ui_service.dart';

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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: AppColors.neutralWhite,
          body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        // const PartnexLogo(size: 48, variant: PartnexLogoVariant.brandCombo),
                        // const SizedBox(height: 16),
                        Text(
                          'Sign in to your Partnex account',
                          textAlign: TextAlign.center,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.slate600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        CustomInputField(
                          label: 'Email Address',
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
                        const SizedBox(height: 16),
                        
                        CustomInputField(
                          label: 'Password',
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
                              return 'Incorrect email or password';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                      const SizedBox(height: 24),
                      
                      CustomButton(
                        text: 'Sign In',
                        onPressed: _handleSignIn,
                        isLoading: isLoading,
                      ),
                      
                      const SizedBox(height: 16),
                      
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
                      
                      const SizedBox(height: 12),
                      
                      CustomButton(
                        text: "Don't have an account? Sign up",
                        variant: ButtonVariant.tertiary,
                        onPressed: () {
                          uiService.replaceWith(const SignupPage());
                        },
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
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
