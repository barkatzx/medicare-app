import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomTheme.primaryColor.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomTheme.primaryColor.withOpacity(0.03),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: CustomTheme.spacingXXL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: size.height * 0.05),
                    SizedBox(height: CustomTheme.spacingXL),
                    Text(
                      'Join MediCarePLC',
                      style: CustomTextStyle.heading1.copyWith(
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: CustomTheme.spacingXS),
                    Text(
                      'Create an account to start ordering',
                      style: CustomTextStyle.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: CustomTheme.spacingXL * 1.5),

                    // Registration Form Card
                    Container(
                      padding: EdgeInsets.all(CustomTheme.spacingXXL),
                      decoration: BoxDecoration(
                        color: CustomTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(CustomTheme.radiusXL),
                        boxShadow: CustomTheme.boxShadowLight,
                      ),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hintText: 'John Doe',
                            prefixIcon: Icons.person_outline_rounded,
                            fontSize: 15,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Full name is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: CustomTheme.spacingLG),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hintText: 'example@mail.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            fontSize: 15,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!_isValidEmail(value)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: CustomTheme.spacingLG),
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hintText: '01XXXXXXXXX',
                            prefixIcon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                            fontSize: 15,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number is required';
                              }
                              if (value.length < 11) {
                                return 'Enter a valid 11-digit number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: CustomTheme.spacingLG),
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hintText: '••••••••',
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: CustomTheme.textTertiary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            obscureText: !_isPasswordVisible,
                            fontSize: 15,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Min. 6 characters required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: CustomTheme.spacingLG),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hintText: '••••••••',
                            prefixIcon: Icons.lock_reset_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: CustomTheme.textTertiary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            obscureText: !_isConfirmPasswordVisible,
                            fontSize: 15,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: CustomTheme.spacingXXL),

                          // Error Message
                          Consumer(
                            builder: (context, ref, child) {
                              final authProvider = ref.watch(authProviderNotifier);
                              if (authProvider.errorMessage != null) {
                                return Container(
                                  padding: EdgeInsets.all(CustomTheme.spacingMD),
                                  margin: EdgeInsets.only(bottom: CustomTheme.spacingLG),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.errorColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                                    border: Border.all(
                                      color: CustomTheme.errorColor.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: CustomTheme.errorColor, size: 18),
                                      SizedBox(width: CustomTheme.spacingSM),
                                      Expanded(
                                        child: Text(
                                          authProvider.errorMessage!,
                                          style: CustomTextStyle.bodySmall.copyWith(
                                            color: CustomTheme.errorColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          // Register Button
                          Consumer(
                            builder: (context, ref, child) {
                              final authProvider = ref.watch(authProviderNotifier);
                              return CustomButton(
                                text: 'Create Account',
                                isLoading: authProvider.isLoading,
                                onPressed: _handleRegister,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: CustomTheme.spacingXXL),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: CustomTextStyle.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, AppRoutes.login);
                          },
                          child: Text(
                            'Sign In',
                            style: CustomTextStyle.bodyMedium.copyWith(
                              color: CustomTheme.primaryColor,
                              fontWeight: CustomTheme.fontWeightBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: CustomTheme.spacingXXL),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = ref.read(authProviderNotifier);

      final success = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        if (authProvider.isPendingApproval) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.pendingApproval,
            (route) => false,
          );
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else if (authProvider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: CustomTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
            ),
          ),
        );
      }
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
