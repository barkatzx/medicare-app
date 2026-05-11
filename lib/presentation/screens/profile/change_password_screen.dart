import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProviderNotifier).changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text('Password changed successfully', style: CustomTextStyle.bodyMedium.copyWith(color: Colors.white)),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusMD)),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      final error = ref.read(authProviderNotifier).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to change password'),
          backgroundColor: CustomTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProviderNotifier).isLoading;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Change Password', style: CustomTextStyle.heading3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: CustomTheme.textPrimary, size: 16),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'Update Your Password',
                style: CustomTextStyle.heading2.copyWith(
                  fontWeight: CustomTheme.fontWeightBold,
                  color: CustomTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep your account secure with a strong password.',
                style: CustomTextStyle.bodyMedium.copyWith(color: CustomTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPasswordField(
                      label: 'Current Password',
                      controller: _oldPasswordController,
                      hint: 'Enter your current password',
                      obscure: _obscureOld,
                      onToggle: () => setState(() => _obscureOld = !_obscureOld),
                    ),
                    const SizedBox(height: 24),
                    _buildPasswordField(
                      label: 'New Password',
                      controller: _newPasswordController,
                      hint: 'Choose a new password',
                      obscure: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'New password is required';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildPasswordField(
                      label: 'Confirm New Password',
                      controller: _confirmPasswordController,
                      hint: 'Repeat your new password',
                      obscure: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please confirm your new password';
                        if (value != _newPasswordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Save New Password', style: CustomTextStyle.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CustomTextStyle.bodySmall.copyWith(
            fontWeight: CustomTheme.fontWeightBold,
            color: CustomTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator ?? (value) => value == null || value.isEmpty ? 'This field is required' : null,
          style: CustomTextStyle.bodyMedium.copyWith(fontWeight: CustomTheme.fontWeightSemiBold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.textTertiary),
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: CustomTheme.primaryColor),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: CustomTheme.textTertiary,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: CustomTheme.backgroundColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
              borderSide: const BorderSide(color: CustomTheme.primaryColor, width: 1.5),
            ),
            errorStyle: CustomTextStyle.caption.copyWith(color: CustomTheme.errorColor),
          ),
        ),
      ],
    );
  }
}
