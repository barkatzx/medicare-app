import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
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
                    SizedBox(height: size.height * 0.08),
                    SizedBox(height: CustomTheme.spacingXXL),
                    Text(
                      'Welcome Back',
                      style: CustomTextStyle.heading1.copyWith(
                        fontSize: 32,
                        letterSpacing: -1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: CustomTheme.spacingXS),
                    Text(
                      'Sign in to your MediCarePLC account',
                      style: CustomTextStyle.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: CustomTheme.spacingXXL * 1.5),

                    // Login Form Card
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
                            fontSize: 18,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: CustomTheme.spacingMD),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.forgotPassword);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: CustomTextStyle.bodySmall.copyWith(
                                  color: CustomTheme.primaryColor,
                                  fontWeight: CustomTheme.fontWeightSemiBold,
                                ),
                              ),
                            ),
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

                          // Login Button
                          Consumer(
                            builder: (context, ref, child) {
                              final authProvider = ref.watch(authProviderNotifier);
                              return CustomButton(
                                text: 'Sign In',
                                isLoading: authProvider.isLoading,
                                onPressed: _handleLogin,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: CustomTheme.spacingXXL),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,


                      children: [
                        Text(
                          "Don't have an account? ",
                          style: CustomTextStyle.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: Text(
                            'Create Account',
                            style: CustomTextStyle.bodyMedium.copyWith(
                              color: CustomTheme.primaryColor,
                              fontWeight: CustomTheme.fontWeightBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: CustomTheme.spacingXL),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = ref.read(authProviderNotifier);

      String phoneInput = _phoneController.text.trim();
      bool success = await authProvider.login(
        phoneNumber: phoneInput,
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      } else if (authProvider.pendingApprovalMessage != null && mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.pendingApproval,
          (route) => false,
        );
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
}
