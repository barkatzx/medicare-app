import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/core/widgets/custom_button.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';
import '../../core/routes/app_routes.dart';

class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() =>
      _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = ref.watch(authProviderNotifier);
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
                    CustomTheme.warningColor.withValues(alpha: 0.16),
                    CustomTheme.warningColor.withValues(alpha: 0.0),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: CustomTheme.spacingXL,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: CustomTheme.spacingLG),

                            // ── Compact header: icon left, text right ──
                            _buildHeader(),

                            SizedBox(height: CustomTheme.spacingXL),

                            // ── Status card ──
                            Container(
                              padding: EdgeInsets.all(CustomTheme.spacingLG),
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
                                children: [
                                  // Message
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(
                                      CustomTheme.spacingMD,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CustomTheme.warningColor
                                          .withValues(alpha: 0.07),
                                      borderRadius: BorderRadius.circular(
                                        CustomTheme.radiusLG,
                                      ),
                                      border: Border.all(
                                        color: CustomTheme.warningColor
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: CustomTheme.warningColor
                                                .withValues(alpha: 0.16),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.info_outline_rounded,
                                            size: 20,
                                            color: CustomTheme.warningColor,
                                          ),
                                        ),
                                        SizedBox(width: CustomTheme.spacingMD),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 1,
                                            ),
                                            child: Text(
                                              'Your account is pending approval from the administrator. This process usually takes 24-48 hours.',
                                              style: CustomTextStyle.bodyMedium
                                                  .copyWith(
                                                    fontSize: 13,
                                                    height: 1.5,
                                                    color:
                                                        CustomTheme.textPrimary,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: CustomTheme.spacingLG),

                                  // Progress steps
                                  _buildStep(
                                    icon: Icons.check_rounded,
                                    title: 'Account created',
                                    subtitle: 'Your registration was received',
                                    state: _StepState.done,
                                    isLast: false,
                                  ),
                                  _buildStep(
                                    icon: Icons.hourglass_top_rounded,
                                    title: 'Under review',
                                    subtitle:
                                        'Our team is verifying your details',
                                    state: _StepState.current,
                                    isLast: false,
                                  ),
                                  _buildStep(
                                    icon: Icons.verified_rounded,
                                    title: 'Approved',
                                    subtitle: 'You can start ordering',
                                    state: _StepState.upcoming,
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: CustomTheme.spacingMD),

                            // ── Notify message ──
                            Container(
                              padding: EdgeInsets.all(CustomTheme.spacingMD),
                              decoration: BoxDecoration(
                                color: CustomTheme.primaryColor.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(
                                  CustomTheme.radiusMD,
                                ),
                                border: Border.all(
                                  color: CustomTheme.primaryColor.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: CustomTheme.primaryColor
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.mark_email_unread_outlined,
                                      size: 17,
                                      color: CustomTheme.primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: CustomTheme.spacingMD),
                                  Expanded(
                                    child: Text(
                                      'You will be notified via email once your account is approved.',
                                      style: CustomTextStyle.bodySmall.copyWith(
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: CustomTheme.spacingXL),

                            // Check Status Button
                            CustomButton(
                              text: 'Check Status',
                              onPressed: () async {
                                await ref
                                    .read(authProviderNotifier)
                                    .initialize();
                                final currentAuthProvider = ref.read(
                                  authProviderNotifier,
                                );
                                if (currentAuthProvider.isLoggedIn &&
                                    currentAuthProvider.isCustomer) {
                                  if (context.mounted) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.home,
                                    );
                                  }
                                }
                              },
                              isLoading: authProvider.isLoading,
                            ),

                            SizedBox(height: CustomTheme.spacingMD),

                            // Back to Login Button
                            GestureDetector(
                              onTap: () async {
                                await ref.read(authProviderNotifier).logout();
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  );
                                }
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: CustomTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(
                                    CustomTheme.radiusMD,
                                  ),
                                  border: Border.all(
                                    color: CustomTheme.primaryColor.withValues(
                                      alpha: 0.35,
                                    ),
                                    width: 1.5,
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
                                      style: CustomTextStyle.bodyMedium
                                          .copyWith(
                                            fontSize: 14,
                                            color: CustomTheme.primaryColor,
                                            fontWeight:
                                                CustomTheme.fontWeightBold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: CustomTheme.spacingLG),

                            // ── Inquiry / support ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.support_agent_rounded,
                                  size: 18,
                                  color: CustomTheme.textTertiary,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                      style: CustomTextStyle.caption.copyWith(
                                        fontSize: 12,
                                        height: 1.5,
                                        color: CustomTheme.textTertiary,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'For any inquiry, contact ',
                                        ),
                                        TextSpan(
                                          text: 'support@medicareplc.com',
                                          style: TextStyle(
                                            color: CustomTheme.primaryColor,
                                            fontWeight:
                                                CustomTheme.fontWeightBold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: CustomTheme.spacingLG),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Compact header: icon left, text group right ───
  Widget _buildHeader() {
    final color = CustomTheme.warningColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: pending icon
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.75)],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.pending_actions_rounded,
            size: 36,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 16),

        // Right: Under Review button, title, subtitle
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Under Review chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'UNDER REVIEW',
                      style: TextStyle(
                        fontFamily: CustomTheme.primaryFontFamily,
                        fontSize: 10,
                        fontWeight: CustomTheme.fontWeightBold,
                        color: color,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Title
              Text(
                'Account Pending Approval',
                style: CustomTextStyle.heading1.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 4),

              // Subtitle
              Text(
                'We\'re reviewing your account',
                style: CustomTextStyle.bodyMedium.copyWith(
                  fontSize: 13,
                  color: CustomTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Progress step ───
  Widget _buildStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required _StepState state,
    required bool isLast,
  }) {
    final Color color;
    switch (state) {
      case _StepState.done:
        color = CustomTheme.successColor;
        break;
      case _StepState.current:
        color = CustomTheme.warningColor;
        break;
      case _StepState.upcoming:
        color = CustomTheme.textTertiary;
        break;
    }

    final isUpcoming = state == _StepState.upcoming;
    final isCurrent = state == _StepState.current;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUpcoming
                        ? CustomTheme.backgroundColor
                        : color.withValues(alpha: 0.14),
                    border: Border.all(
                      color: isUpcoming
                          ? CustomTheme.borderMedium
                          : color.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: state == _StepState.done
                            ? CustomTheme.successColor.withValues(alpha: 0.5)
                            : CustomTheme.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 1, bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: CustomTheme.primaryFontFamily,
                      fontSize: 13.5,
                      fontWeight: isUpcoming
                          ? CustomTheme.fontWeightMedium
                          : CustomTheme.fontWeightBold,
                      color: isUpcoming
                          ? CustomTheme.textTertiary
                          : CustomTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: CustomTextStyle.caption.copyWith(
                      fontSize: 11.5,
                      color: CustomTheme.textTertiary,
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
}

enum _StepState { done, current, upcoming }
