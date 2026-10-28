import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';
import '../../core/routes/app_routes.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(orderProviderNotifier).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = ref.watch(authProviderNotifier);
    final user = authProvider.currentUser;
    final orders = ref.watch(orderProviderNotifier).orders;
    final totalOrders = orders.length;
    final cancelledOrders = orders
        .where((o) => o.status.toLowerCase() == 'cancelled')
        .length;
    final totalProducts = orders
        .expand((o) => o.items.map((i) => i.productId))
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: CustomTheme.backgroundColor,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(user),
              const SizedBox(height: 15),
              _buildStatsRow(totalOrders, totalProducts, cancelledOrders),
              const SizedBox(height: 24),
              _buildSectionLabel('General'),
              const SizedBox(height: 10),
              _buildMenuCard([
                _MenuItemData(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile',
                  subtitle: 'Update your personal info',
                  iconColor: const Color(0xFF3B82F6),
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.editProfile),
                ),
                _MenuItemData(
                  icon: Icons.location_on_outlined,
                  title: 'Address',
                  subtitle: 'Your delivery location',
                  iconColor: const Color(0xFF10B981),
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.addresses),
                ),
                _MenuItemData(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order History',
                  subtitle: 'View past orders',
                  iconColor: const Color(0xFF8B5CF6),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.myOrders),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionLabel('Preferences'),
              const SizedBox(height: 10),
              _buildMenuCard([
                _MenuItemData(
                  icon: Icons.shield_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Password and account safety',
                  iconColor: const Color(0xFF14B8A6),
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.changePassword),
                ),
                _MenuItemData(
                  icon: Icons.info_outline_rounded,
                  title: 'App Info',
                  subtitle: 'App version and info',
                  iconColor: const Color(0xFF6366F1),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                ),
              ]),
              const SizedBox(height: 20),
              _buildLogoutButton(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(dynamic user) {
    final initials = user?.name?.isNotEmpty == true
        ? (user!.name as String)
              .trim()
              .split(' ')
              .map((e) => e[0])
              .take(2)
              .join()
              .toUpperCase()
        : 'G';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomTheme.primaryColor.withValues(alpha: 0.07),
              border: Border.all(
                color: CustomTheme.primaryColor.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontFamily: CustomTheme.primaryFontFamily,
                  fontSize: 25,
                  fontWeight: CustomTheme.fontWeightBold,
                  color: CustomTheme.primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Guest User',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: CustomTheme.primaryFontFamily,
                    fontSize: 20,
                    fontWeight: CustomTheme.fontWeightBold,
                    color: CustomTheme.primaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                if (user?.phoneNumber != null &&
                    (user!.phoneNumber as String).isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Phone: ${user.phoneNumber}',
                    style: TextStyle(
                      fontFamily: CustomTheme.primaryFontFamily,
                      fontSize: 15,
                      color: CustomTheme.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int orders, int products, int cancelled) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('$orders', 'Total Orders')),
        const SizedBox(width: 15),
        Expanded(child: _buildStatCard('$products', 'Products Ordered')),
        const SizedBox(width: 15),
        Expanded(child: _buildStatCard('$cancelled', 'Cancelled Orders')),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: CustomTheme.primaryFontFamily,
                fontSize: 20,
                fontWeight: CustomTheme.fontWeightBold,
                color: CustomTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: CustomTextStyle.bodySmall.copyWith(
              fontSize: 13,
              fontWeight: CustomTheme.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: CustomTheme.primaryFontFamily,
          fontSize: 13,
          fontWeight: CustomTheme.fontWeightBold,
          color: CustomTheme.textTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItemData> items) {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildMenuItem(item),
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  color: CustomTheme.borderLight,
                  indent: 62,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItemData item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: item.iconColor.withValues(alpha: 0.04),
        highlightColor: item.iconColor.withValues(alpha: 0.02),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 18, color: item.iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: CustomTextStyle.bodyMedium.copyWith(
                        fontWeight: CustomTheme.fontWeightBold,
                        color: CustomTheme.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: CustomTextStyle.caption.copyWith(
                        fontSize: 13,
                        color: CustomTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: CustomTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: CustomTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showLogoutDialog(context, ref),
          borderRadius: BorderRadius.circular(16),
          splashColor: CustomTheme.errorColor.withValues(alpha: 0.04),
          highlightColor: CustomTheme.errorColor.withValues(alpha: 0.02),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: CustomTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: CustomTheme.errorColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logout',
                        style: CustomTextStyle.bodyMedium.copyWith(
                          fontWeight: CustomTheme.fontWeightSemiBold,
                          color: CustomTheme.errorColor,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Sign out of your account',
                        style: CustomTextStyle.caption.copyWith(
                          fontSize: 13,
                          color: CustomTheme.errorColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: CustomTheme.errorColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: CustomTheme.errorColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: CustomTheme.surfaceColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: CustomTheme.errorColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: CustomTheme.errorColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Logout',
                style: CustomTextStyle.heading3.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to sign out of your account?',
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: CustomTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: CustomTextStyle.bodyMedium.copyWith(
                              color: CustomTheme.textSecondary,
                              fontWeight: CustomTheme.fontWeightMedium,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await ref.read(authProviderNotifier).logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        }
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: CustomTheme.errorColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Logout',
                            style: CustomTextStyle.button.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });
}
