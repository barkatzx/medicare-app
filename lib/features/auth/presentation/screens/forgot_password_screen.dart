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
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Forgot Password', style: CustomTextStyle.heading3),
        backgroundColor: CustomTheme.surfaceColor,
        foregroundColor: CustomTheme.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: CustomTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(CustomTheme.spacingXXL),
            child: _isEmailSent ? _buildSuccessView() : _buildResetForm(),
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
          SizedBox(height: CustomTheme.spacingXXL),

          // Icon
          Container(
            padding: EdgeInsets.all(CustomTheme.spacingXL),
            decoration: BoxDecoration(
              color: CustomTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset,
              size: 80,
              color: CustomTheme.primaryColor,
            ),
          ),

          SizedBox(height: CustomTheme.spacingXXL),

          // Title
          Text(
            'Reset Password',
            style: CustomTextStyle.heading1,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: CustomTheme.spacingMD),

          // Subtitle
          Text(
            'Enter your email address and we will send you a link to reset your password',
            style: CustomTextStyle.bodyMedium,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: CustomTheme.spacingXXL),

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

          SizedBox(height: CustomTheme.spacingXXL),

          // Send Reset Link Button
          CustomButton(
            text: 'Send Reset Link',
            onPressed: _handleResetPassword,
            isLoading: _isLoading,
          ),

          SizedBox(height: CustomTheme.spacingLG),

          // Back to Login
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Back to Login',
                style: CustomTextStyle.bodyMedium.copyWith(
                  color: CustomTheme.primaryColor,
                  fontWeight: CustomTheme.fontWeightSemiBold,
                ),
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
        SizedBox(height: CustomTheme.spacingXXL * 2),

        // Success Icon
        Container(
          padding: EdgeInsets.all(CustomTheme.spacingXL),
          decoration: BoxDecoration(
            color: CustomTheme.successColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 80,
            color: CustomTheme.successColor,
          ),
        ),

        SizedBox(height: CustomTheme.spacingXXL),

        // Success Title
        Text(
          'Check Your Email',
          style: CustomTextStyle.heading1,
          textAlign: TextAlign.center,
        ),

        SizedBox(height: CustomTheme.spacingMD),

        // Success Message
        Text(
          'We have sent a password reset link to\n${_emailController.text}',
          style: CustomTextStyle.bodyMedium,
          textAlign: TextAlign.center,
        ),

        SizedBox(height: CustomTheme.spacingXXL),

        // Info Card
        Container(
          padding: EdgeInsets.all(CustomTheme.spacingLG),
          decoration: BoxDecoration(
            color: CustomTheme.successColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
            border: Border.all(
              color: CustomTheme.successColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: CustomTheme.successColor,
                size: 24,
              ),
              SizedBox(width: CustomTheme.spacingMD),
              Expanded(
                child: Text(
                  'Please check your spam folder if you don\'t see the email in your inbox.',
                  style: CustomTextStyle.bodySmall,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: CustomTheme.spacingXXL * 2),

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
