import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';

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
  bool _isExitDialogOpen = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: Stack(
        children: [
          // ── Background decoration ──
          Positioned(
            top: -size.height * 0.12,
            right: -size.width * 0.25,
            child: Container(
              width: size.width * 0.85,
              height: size.width * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    CustomTheme.primaryColor.withValues(alpha: 0.14),
                    CustomTheme.primaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.28,
            left: -size.width * 0.18,
            child: Container(
              width: size.width * 0.4,
              height: size.width * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomTheme.primaryColor.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    CustomTheme.primaryColor.withValues(alpha: 0.10),
                    CustomTheme.primaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: CustomTheme.spacingMD),
              child: Form(
                key: _formKey,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 24 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: size.height * 0.07),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: CustomTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/MediCarePLC.png',
                                fit: BoxFit.contain,
                                semanticLabel: 'MediCarePLC logo',
                              ),
                            ),
                          ),
                          SizedBox(width: CustomTheme.spacingMD),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'MediCarePLC',
                                style: CustomTextStyle.heading1.copyWith(
                                  fontSize: 30,
                                  color: CustomTheme.primaryColor,
                                  fontWeight: CustomTheme.fontWeightBold,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              Text(
                                'Welcome back! Sign in to continue',
                                style: CustomTextStyle.bodyMedium.copyWith(
                                  fontSize: 15,
                                  fontWeight: CustomTheme.fontWeightBold,
                                  color: CustomTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: CustomTheme.spacingXXL * 1.4),

                      // ── Login Form Card ──
                      Container(
                        padding: EdgeInsets.all(CustomTheme.spacingXXL),
                        decoration: BoxDecoration(
                          color: CustomTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(
                            CustomTheme.radiusXL,
                          ),
                          border: Border.all(
                            color: CustomTheme.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Sign In',
                              style: CustomTextStyle.heading2.copyWith(
                                fontSize: 20,
                                fontWeight: CustomTheme.fontWeightBold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Enter your phone number and password',
                              style: CustomTextStyle.caption.copyWith(
                                fontSize: 15,
                                color: CustomTheme.textTertiary,
                              ),
                            ),
                            SizedBox(height: CustomTheme.spacingXL),

                            CustomTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hintText: '01XXXXXXXXX',
                              prefixIcon: Icons.phone_android_rounded,
                              keyboardType: TextInputType.phone,
                              fontSize: 18,
                              labelFontSize: 15,
                              labelFontWeight: CustomTheme.fontWeightBold,
                              inputFontWeight: CustomTheme.fontWeightBold,
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
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                  width: 40,
                                  height: 40,
                                ),
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
                              labelFontSize: 15,
                              labelFontWeight: CustomTheme.fontWeightBold,
                              inputFontWeight: CustomTheme.fontWeightBold,
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
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.forgotPassword,
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  backgroundColor: CustomTheme.primaryColor
                                      .withValues(alpha: 0.07),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
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
                            SizedBox(height: CustomTheme.spacingXL),

                            // Error Message
                            Consumer(
                              builder: (context, ref, child) {
                                final authProvider = ref.watch(
                                  authProviderNotifier,
                                );
                                if (authProvider.errorMessage != null) {
                                  return Container(
                                    padding: EdgeInsets.all(
                                      CustomTheme.spacingMD,
                                    ),
                                    margin: EdgeInsets.only(
                                      bottom: CustomTheme.spacingLG,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CustomTheme.errorColor.withValues(
                                        alpha: 0.07,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        CustomTheme.radiusMD,
                                      ),
                                      border: Border.all(
                                        color: CustomTheme.errorColor
                                            .withValues(alpha: 0.18),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: CustomTheme.errorColor
                                                .withValues(alpha: 0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.error_outline_rounded,
                                            color: CustomTheme.errorColor,
                                            size: 16,
                                          ),
                                        ),
                                        SizedBox(width: CustomTheme.spacingSM),
                                        Expanded(
                                          child: Text(
                                            authProvider.errorMessage!,
                                            style: CustomTextStyle.bodySmall
                                                .copyWith(
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
                                final authProvider = ref.watch(
                                  authProviderNotifier,
                                );
                                return CustomButton(
                                  text: 'Sign In',
                                  isLoading: authProvider.isLoading,
                                  onPressed: _handleLogin,
                                  fontSize: 18,
                                  fontWeight: CustomTheme.fontWeightBold,
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: CustomTheme.spacingXXL),

                      // ── Divider ──
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: CustomTheme.borderLight,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'NEW HERE?',
                              style: CustomTextStyle.caption.copyWith(
                                fontSize: 12,
                                letterSpacing: 1.2,
                                fontWeight: CustomTheme.fontWeightSemiBold,
                                color: CustomTheme.textTertiary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: CustomTheme.borderLight,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: CustomTheme.spacingLG),

                      // ── Create account ──
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: CustomTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(
                              CustomTheme.radiusMD,
                            ),
                            border: Border.all(
                              color: CustomTheme.primaryColor.withValues(
                                alpha: 0.35,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: CustomTextStyle.bodyMedium.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Create Account',
                                style: CustomTextStyle.bodyMedium.copyWith(
                                  fontSize: 15,
                                  color: CustomTheme.primaryColor,
                                  fontWeight: CustomTheme.fontWeightBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: CustomTheme.spacingXL),

                      // ── Secure note ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 14,
                            color: CustomTheme.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Secure & encrypted login',
                            style: CustomTextStyle.caption.copyWith(
                              fontSize: 11.5,
                              color: CustomTheme.textTertiary,
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
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    if (_isExitDialogOpen) return;
    _isExitDialogOpen = true;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exit app?'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    _isExitDialogOpen = false;
    if (shouldExit == true && mounted) {
      await SystemNavigator.pop();
    }
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
