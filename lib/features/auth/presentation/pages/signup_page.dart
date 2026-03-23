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
import 'package:partnex/features/auth/presentation/pages/login_page.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_onboarding_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/business_profile_page.dart';
import 'package:partnex/features/auth/data/models/user_model.dart';

class SignupPage extends StatefulWidget {
  final String? emailPrefill;

  const SignupPage({super.key, this.emailPrefill});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Role Selection
  String _selectedRole = 'sme';

  // Password Strength
  double _passwordStrength = 0;
  String _passwordStrengthText = 'Weak';
  Color _passwordStrengthColor = AppColors.dangerRed;

  @override
  void initState() {
    super.initState();
    if (widget.emailPrefill != null) {
      _emailController.text = widget.emailPrefill!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordStrength = 0;
        _passwordStrengthText = 'Too short';
        _passwordStrengthColor = AppColors.dangerRed;
      });
      return;
    }
    
    double strength = 0;
    if (value.length >= 8) strength += 0.25;
    if (value.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (value.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (value.contains(RegExp(r'[!@#\$&*~]'))) strength += 0.25;

    setState(() {
      _passwordStrength = strength;
      if (strength <= 0.25) {
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = AppColors.dangerRed;
      } else if (strength <= 0.5) {
        _passwordStrengthText = 'Fair';
        _passwordStrengthColor = AppColors.warningAmber;
      } else if (strength <= 0.75) {
        _passwordStrengthText = 'Good';
        _passwordStrengthColor = AppColors.trustBlue;
      } else {
        _passwordStrengthText = 'Strong';
        _passwordStrengthColor = AppColors.successGreen;
      }
    });
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      // Dispatch the real SignupEvent to AuthBloc — calls the backend API
      // and stores the JWT token via ApiAuthRepository.
      context.read<AuthBloc>().add(SignupEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _selectedRole,
        position: _positionController.text.trim(),
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
            uiService.replaceWith(const InvestorOnboardingPage());
          } else {
            // Direct to Business Profile (Step 1) first
            uiService.replaceWith(const BusinessProfilePage());
          }
        } else if (state is AuthError) {
          uiService.showSnackBar(state.message, isError: true);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Scaffold(
            backgroundColor: AppColors.background(context),
            body: SafeArea(
              child: Column(
                children: [
                       SizedBox(height: AppSpacing.xl),
                  // Header
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Create Account',
                         style: AppTypography.textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary(context),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  
                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // SizedBox(height: AppSpacing.sm),
                            Text(
                              'Join Africa\'s leading SME credibility platform',
                              textAlign: TextAlign.left,
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                            SizedBox(height: AppSpacing.xl),
                            
                            CustomInputField(
                              label: 'Full Name *',
                              placeholder: 'John Doe',
                              controller: _nameController,
                              validator: (value) {
                                if (value == null || value.trim().length < 2) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: AppSpacing.md),
    
                            CustomInputField(
                              label: 'Position / Title',
                              placeholder: 'e.g., CEO, CTO, Founder',
                              controller: _positionController,
                              validator: (value) {
                                // Optional field, no validation needed
                                return null;
                              },
                            ),
                            SizedBox(height: AppSpacing.md),
                            
                            CustomInputField(
                              label: 'Email Address *',
                              placeholder: 'you@example.com',
                              controller: _emailController,
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
                              onChanged: _checkPasswordStrength,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                  color: AppColors.textSecondary(context),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || _passwordStrength < 0.75) {
                                  return 'Password must be at least 8 characters, include 1 uppercase letter and 1 number.';
                                }
                                return null;
                              },
                            ),
                            
                            SizedBox(height: AppSpacing.sm),
                            // Password Strength Indicator
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                    child: LinearProgressIndicator(
                                      value: _passwordStrength,
                                      backgroundColor: AppColors.border(context),
                                      color: _passwordStrengthColor,
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  _passwordStrengthText,
                                  style: AppTypography.textTheme.bodySmall?.copyWith(
                                    color: _passwordStrengthColor,
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: AppSpacing.md),
                          
                            CustomInputField(
                              label: 'Confirm Password *',
                              placeholder: '········',
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                  color: AppColors.textSecondary(context),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          
                            SizedBox(height: AppSpacing.xl),
    
                            // Role Toggle
                            Text(
                              'I am signing up as an:',
                              style: AppTypography.textTheme.labelLarge?.copyWith(
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            SizedBox(height: AppSpacing.smd),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedRole = 'sme'),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: AppSpacing.smd),
                                      decoration: BoxDecoration(
                                        color: _selectedRole == 'sme' ? AppColors.surface(context) : AppColors.background(context),
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                        border: Border.all(
                                          color: _selectedRole == 'sme' ? AppColors.trustBlue : AppColors.border(context),
                                          width: _selectedRole == 'sme' ? 2.5 : 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            LucideIcons.building,
                                            size: 18,
                                            color: _selectedRole == 'sme' ? AppColors.trustBlue : AppColors.textSecondary(context),
                                          ),
                                          SizedBox(width: AppSpacing.sm),
                                          Text(
                                            'SME',
                                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                                              color: _selectedRole == 'sme' ? AppColors.trustBlue : AppColors.textSecondary(context),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppSpacing.smd),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedRole = 'investor'),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: AppSpacing.smd),
                                      decoration: BoxDecoration(
                                        color: _selectedRole == 'investor' ? AppColors.surface(context) : AppColors.background(context),
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                        border: Border.all(
                                          color: _selectedRole == 'investor' ? AppColors.trustBlue : AppColors.border(context),
                                          width: _selectedRole == 'investor' ? 2.5 : 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            LucideIcons.briefcase,
                                            size: 18,
                                            color: _selectedRole == 'investor' ? AppColors.trustBlue : AppColors.textSecondary(context),
                                          ),
                                          SizedBox(width: AppSpacing.sm),
                                          Text(
                                            'Investor',
                                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                                              color: _selectedRole == 'investor' ? AppColors.trustBlue : AppColors.textSecondary(context),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: AppSpacing.xl),
                            
                            CustomButton(
                              text: 'Create Account',
                              isFullWidth: true,
                              onPressed: _handleSignUp,
                              isLoading: isLoading,
                            ),
                            
                            SizedBox(height: AppSpacing.md),
                            
                            Align(
                              alignment: Alignment.centerLeft,
                              child: CustomButton(
                                text: 'Already have an account? Sign in',
                                variant: ButtonVariant.tertiary,
                                onPressed: () {
                                  uiService.replaceWith(const LoginPage());
                                },
                              ),
                            ),
                            
                            SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Shared Footer matching WelcomeRoleSelectionPage
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xl, top: AppSpacing.md, left: AppSpacing.md, right: AppSpacing.md),
                    child: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to our ',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.trustBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.trustBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
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
