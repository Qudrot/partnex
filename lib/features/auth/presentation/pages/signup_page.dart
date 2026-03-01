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
import 'package:partnex/features/auth/presentation/pages/login_page.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/data/models/user_model.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_onboarding_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/input_method_selection_page.dart';

class SignupPage extends StatefulWidget {
  final String? emailPrefill;

  const SignupPage({super.key, this.emailPrefill});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
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
                      'Create Account',
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                
                // Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          // const PartnexLogo(size: 48, variant: PartnexLogoVariant.brandCombo),
                          // const SizedBox(height: 16),
                          Text(
                            'Join Africa\'s leading SME credibility platform',
                            textAlign: TextAlign.center,
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.slate600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          CustomInputField(
                            label: 'Full Name',
                            placeholder: 'John Doe',
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.trim().length < 2) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          CustomInputField(
                            label: 'Email Address',
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
                          const SizedBox(height: 16),
                          
                          CustomInputField(
                            label: 'Password',
                            placeholder: '········',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            onChanged: _checkPasswordStrength,
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
                              if (value == null || _passwordStrength < 0.75) {
                                return 'Password must be at least 8 characters with 1 uppercase letter and 1 number';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 8),
                          // Password Strength Indicator
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: _passwordStrength,
                                    backgroundColor: AppColors.slate200,
                                    color: _passwordStrengthColor,
                                    minHeight: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _passwordStrengthText,
                                style: AppTypography.textTheme.bodySmall?.copyWith(
                                  color: _passwordStrengthColor,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                        
                          CustomInputField(
                            label: 'Confirm Password',
                            placeholder: '········',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                color: AppColors.slate400,
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
                        
                          const SizedBox(height: 24),

                          // Role Toggle
                          Text(
                            'I am signing up as an:',
                            style: AppTypography.textTheme.labelLarge?.copyWith(
                              color: AppColors.slate900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedRole = 'sme'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedRole == 'sme' ? AppColors.trustBlue : AppColors.slate50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _selectedRole == 'sme' ? AppColors.trustBlue : AppColors.slate200,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          LucideIcons.building,
                                          size: 18,
                                          color: _selectedRole == 'sme' ? Colors.white : AppColors.slate600,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'SME',
                                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                                            color: _selectedRole == 'sme' ? Colors.white : AppColors.slate600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedRole = 'investor'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedRole == 'investor' ? AppColors.trustBlue : AppColors.slate50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _selectedRole == 'investor' ? AppColors.trustBlue : AppColors.slate200,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          LucideIcons.briefcase,
                                          size: 18,
                                          color: _selectedRole == 'investor' ? Colors.white : AppColors.slate600,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Investor',
                                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                                            color: _selectedRole == 'investor' ? Colors.white : AppColors.slate600,
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
                          
                          const SizedBox(height: 24),
                          
                          CustomButton(
                            text: 'Create Account',
                            onPressed: _handleSignUp,
                            isLoading: isLoading,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          CustomButton(
                            text: 'Already have an account? Sign in',
                            variant: ButtonVariant.tertiary,
                            onPressed: () {
                              uiService.replaceWith(const LoginPage());
                            },
                          ),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Shared Footer matching WelcomeRoleSelectionPage
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, top: 16.0, left: 16.0, right: 16.0),
                  child: Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our ',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.slate600,
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
    );
  }
}
