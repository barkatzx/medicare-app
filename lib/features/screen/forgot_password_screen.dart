import 'package:flutter/material.dart';
import 'package:medicare_app/core/widgets/custom_button.dart';
import 'package:medicare_app/core/widgets/custom_textfield.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call - Replace with your actual API
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _isEmailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
                    (_isEmailSent
                            ? CustomTheme.successColor
                            : CustomTheme.primaryColor)
                        .withValues(alpha: 0.14),
                    (_isEmailSent
                            ? CustomTheme.successColor
                            : CustomTheme.primaryColor)
                        .withValues(alpha: 0.0),
                  ],
                ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // ── Back button ──
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: CustomTheme.surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: CustomTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.04),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _isEmailSent
                        ? KeyedSubtree(
                            key: const ValueKey('success'),
                            child: _buildSuccessView(),
                          )
                        : KeyedSubtree(
                            key: const ValueKey('form'),
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
                              child: _buildResetForm(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Icon with soft rings ───
  Widget _buildHeroIcon({required IconData icon, required Color color}) {
    return Center(
      child: Container(
        width: 148,
        height: 148,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.06),
        ),
        child: Center(
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.10),
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.75)],
                  ),
                ),
                child: Icon(icon, size: 38, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: CustomTheme.spacingXL),

          _buildHeroIcon(
            icon: Icons.lock_reset_rounded,
            color: CustomTheme.primaryColor,
          ),

          SizedBox(height: CustomTheme.spacingXL),

          // Title
          Text(
            'Reset Password',
            style: CustomTextStyle.heading1.copyWith(
              fontSize: 28,
              letterSpacing: -0.8,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: CustomTheme.spacingSM),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Enter your email address and we will send you a link to reset your password',
              style: CustomTextStyle.bodyMedium.copyWith(
                fontSize: 14.5,
                height: 1.6,
                color: CustomTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: CustomTheme.spacingXXL),

          // Form card
          Container(
            padding: EdgeInsets.all(CustomTheme.spacingXXL),
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              borderRadius: BorderRadius.circular(CustomTheme.radiusXL),
              border: Border.all(color: CustomTheme.borderLight, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'Enter your registered email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),

                SizedBox(height: CustomTheme.spacingXL),

                // Send Reset Link Button
                CustomButton(
                  text: 'Send Reset Link',
                  onPressed: _handleResetPassword,
                  isLoading: _isLoading,
                  fontSize: 16,
                  fontWeight: CustomTheme.fontWeightBold,
                ),
              ],
            ),
          ),

          SizedBox(height: CustomTheme.spacingXL),

          // Back to Login
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: CustomTheme.surfaceColor,
                borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                border: Border.all(
                  color: CustomTheme.primaryColor.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: CustomTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Back to Login',
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

          SizedBox(height: CustomTheme.spacingXXL),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: CustomTheme.spacingXL),

        _buildHeroIcon(
          icon: Icons.mark_email_read_rounded,
          color: CustomTheme.successColor,
        ),

        SizedBox(height: CustomTheme.spacingXL),

        // Success Title
        Text(
          'Check Your Email',
          style: CustomTextStyle.heading1.copyWith(
            fontSize: 28,
            letterSpacing: -0.8,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: CustomTheme.spacingSM),

        // Success Message
        Text(
          'We have sent a password reset link to',
          style: CustomTextStyle.bodyMedium.copyWith(
            fontSize: 14.5,
            color: CustomTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: CustomTheme.spacingMD),

        // Email chip
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: CustomTheme.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: CustomTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _emailController.text,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyle.bodyMedium.copyWith(
                      fontSize: 13.5,
                      color: CustomTheme.textPrimary,
                      fontWeight: CustomTheme.fontWeightSemiBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: CustomTheme.spacingXXL),

        // Info Card
        Container(
          padding: EdgeInsets.all(CustomTheme.spacingLG),
          decoration: BoxDecoration(
            color: CustomTheme.successColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
            border: Border.all(
              color: CustomTheme.successColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: CustomTheme.successColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: CustomTheme.successColor,
                  size: 18,
                ),
              ),
              SizedBox(width: CustomTheme.spacingMD),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Please check your spam folder if you don\'t see the email in your inbox.',
                    style: CustomTextStyle.bodySmall.copyWith(height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: CustomTheme.spacingXXL * 1.5),

        // Back to Login Button
        CustomButton(
          text: 'Back to Login',
          onPressed: () => Navigator.pop(context),
        ),

        SizedBox(height: CustomTheme.spacingXXL),
      ],
    );
  }
}
