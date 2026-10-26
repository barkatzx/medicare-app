import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
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
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(authProviderNotifier)
        .changePassword(
          oldPassword: _oldPasswordController.text,
          newPassword: _newPasswordController.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Password changed successfully',
                style: CustomTextStyle.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          backgroundColor: CustomTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // ─── Strength helpers (visual only) ───
  int _strengthOf(String v) {
    if (v.isEmpty) return 0;
    if (v.length < 6) return 1;
    int score = 2;
    if (v.length >= 10) score++;
    final hasMixedCase =
        RegExp(r'[A-Z]').hasMatch(v) && RegExp(r'[a-z]').hasMatch(v);
    final hasDigitAndSymbol =
        RegExp(r'[0-9]').hasMatch(v) && RegExp(r'[^A-Za-z0-9]').hasMatch(v);
    if (hasMixedCase && hasDigitAndSymbol) score++;
    return score.clamp(1, 4);
  }

  String _strengthLabel(int s) {
    switch (s) {
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }

  Color _strengthColor(int s) {
    switch (s) {
      case 1:
        return CustomTheme.errorColor;
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return CustomTheme.primaryColor;
      case 4:
        return CustomTheme.successColor;
      default:
        return CustomTheme.borderLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProviderNotifier).isLoading;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Form(
          key: _formKey,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                Text(
                  'Update Your Password',
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.heading2.copyWith(
                    fontSize: 22,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Keep your account secure with a strong password.',
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.bodyMedium.copyWith(
                    fontSize: 14,
                    color: CustomTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Password fields card ──
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: CustomTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: CustomTheme.borderLight),
                  ),
                  child: Column(
                    children: [
                      _buildPasswordField(
                        label: 'CURRENT PASSWORD',
                        controller: _oldPasswordController,
                        hint: 'Enter your current password',
                        obscure: _obscureOld,
                        onToggle: () =>
                            setState(() => _obscureOld = !_obscureOld),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: CustomTheme.borderLight,
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Icon(
                                Icons.south_rounded,
                                size: 16,
                                color: CustomTheme.textTertiary,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: CustomTheme.borderLight,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      _buildPasswordField(
                        label: 'NEW PASSWORD',
                        controller: _newPasswordController,
                        hint: 'Choose a new password',
                        obscure: _obscureNew,
                        onToggle: () =>
                            setState(() => _obscureNew = !_obscureNew),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'New password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      _buildStrengthMeter(),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        label: 'CONFIRM NEW PASSWORD',
                        controller: _confirmPasswordController,
                        hint: 'Repeat your new password',
                        obscure: _obscureConfirm,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tip card ──
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: CustomTheme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: CustomTheme.primaryColor.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: CustomTheme.primaryColor.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          Icons.tips_and_updates_outlined,
                          size: 16,
                          color: CustomTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Text(
                            'Use at least 6 characters. Mixing upper and lower case letters, numbers and symbols makes it stronger.',
                            style: CustomTextStyle.bodySmall.copyWith(
                              fontSize: 12,
                              color: CustomTheme.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Submit button ──
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: CustomTheme.primaryColor
                            .withValues(alpha: 0.5),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        surfaceTintColor: Colors.transparent,
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Save New Password',
                                    style: CustomTextStyle.button.copyWith(
                                      fontSize: 15,
                                      fontWeight: CustomTheme.fontWeightBold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.lock_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: CustomTheme.backgroundColor,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: CustomTheme.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: CustomTheme.textPrimary,
                size: 15,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        'Change Password',
        style: CustomTextStyle.heading2.copyWith(fontSize: 19),
      ),
    );
  }

  // ─── Strength meter ───
  Widget _buildStrengthMeter() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _newPasswordController,
      builder: (context, value, _) {
        final strength = _strengthOf(value.text);
        if (strength == 0) return const SizedBox(height: 0);
        final color = _strengthColor(strength);

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: List.generate(4, (i) {
                    final active = i < strength;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 4,
                        margin: EdgeInsets.only(right: i == 3 ? 0 : 5),
                        decoration: BoxDecoration(
                          color: active ? color : CustomTheme.borderLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 12),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontFamily: CustomTheme.primaryFontFamily,
                  fontSize: 11.5,
                  fontWeight: CustomTheme.fontWeightBold,
                  color: color,
                ),
                child: Text(_strengthLabel(strength)),
              ),
            ],
          ),
        );
      },
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
          style: CustomTextStyle.caption.copyWith(
            fontSize: 10,
            letterSpacing: 0.9,
            color: CustomTheme.textTertiary,
            fontWeight: CustomTheme.fontWeightSemiBold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator:
              validator ??
              (value) => value == null || value.isEmpty
                  ? 'This field is required'
                  : null,
          style: CustomTextStyle.bodyMedium.copyWith(
            fontWeight: CustomTheme.fontWeightMedium,
            color: CustomTheme.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: CustomTextStyle.bodySmall.copyWith(
              color: CustomTheme.textTertiary,
              fontSize: 13,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: CustomTheme.textTertiary,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 18,
                  color: CustomTheme.textSecondary,
                ),
                onPressed: onToggle,
                splashRadius: 20,
              ),
            ),
            filled: true,
            fillColor: CustomTheme.backgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: CustomTheme.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: CustomTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: CustomTheme.primaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: CustomTheme.errorColor,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: CustomTheme.errorColor,
                width: 1.5,
              ),
            ),
            errorStyle: CustomTextStyle.caption.copyWith(
              color: CustomTheme.errorColor,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
