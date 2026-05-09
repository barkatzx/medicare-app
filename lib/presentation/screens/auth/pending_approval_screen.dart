import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/common/custom_button.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import '../../../routes/app_routes.dart';

class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = ref.watch(authProviderNotifier);

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(CustomTheme.spacingXXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: CustomTheme.spacingXXL * 2),

                // Animated Icon Container
                Container(
                  padding: EdgeInsets.all(CustomTheme.spacingXL),
                  decoration: BoxDecoration(
                    color: CustomTheme.warningColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pending_actions,
                    size: 80,
                    color: CustomTheme.warningColor,
                  ),
                ),

                SizedBox(height: CustomTheme.spacingXXL),

                // Title
                Text(
                  'Account Pending Approval',
                  style: CustomTextStyle.heading1.copyWith(
                    color: CustomTheme.warningColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: CustomTheme.spacingMD),

                // Subtitle
                Text(
                  'We\'re reviewing your account',
                  style: CustomTextStyle.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: CustomTheme.spacingXXL),

                // Info Card
                Container(
                  padding: EdgeInsets.all(CustomTheme.spacingLG),
                  decoration: BoxDecoration(
                    color: CustomTheme.warningColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
                    border: Border.all(
                      color: CustomTheme.warningColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 32,
                        color: CustomTheme.warningColor,
                      ),
                      SizedBox(height: CustomTheme.spacingMD),
                      Text(
                        authProvider.pendingApprovalMessage ??
                            'Your account is pending approval from the administrator. This process usually takes 24-48 hours.',
                        style: CustomTextStyle.bodyMedium.copyWith(
                          color: CustomTheme.warningColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: CustomTheme.spacingXXL),

                // Info Message
                Container(
                  padding: EdgeInsets.all(CustomTheme.spacingMD),
                  decoration: BoxDecoration(
                    color: CustomTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                    boxShadow: CustomTheme.boxShadowLight,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: CustomTheme.textSecondary,
                      ),
                      SizedBox(width: CustomTheme.spacingMD),
                      Expanded(
                        child: Text(
                          'You will be notified via email once your account is approved.',
                          style: CustomTextStyle.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: CustomTheme.spacingXXL * 2),

                // Check Status Button
                CustomButton(
                  text: 'Check Status',
                  onPressed: () async {
                    await ref.read(authProviderNotifier).initialize();
                    final currentAuthProvider = ref.read(authProviderNotifier);
                    if (currentAuthProvider.isLoggedIn && currentAuthProvider.isCustomer) {
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      }
                    }
                  },
                  isLoading: authProvider.isLoading,
                ),

                SizedBox(height: CustomTheme.spacingLG),

                // Back to Login Button
                GestureDetector(
                  onTap: () async {
                    await ref.read(authProviderNotifier).logout();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: CustomTheme.spacingMD,
                    ),
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
          ),
        ),
      ),
    );
  }
}
