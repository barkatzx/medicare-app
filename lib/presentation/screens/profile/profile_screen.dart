import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import '../../../routes/app_routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProvider = ref.watch(authProviderNotifier);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        title: Text('My Profile', style: CustomTextStyle.heading3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileCard(user),
            const SizedBox(height: 24),
            _buildMenuSection(context, ref),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(user) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(CustomTheme.radiusXL),
      ),
      child: Row(
        children: [
          // Initials Image Box (Left)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: CustomTheme.primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: CustomTheme.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user?.name?.isNotEmpty == true ? user!.name[0].toUpperCase() : 'G',
                  style: CustomTextStyle.heading1.copyWith(
                    color: CustomTheme.primaryColor,
                    fontSize: 32,
                    fontWeight: CustomTheme.fontWeightBold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // User Info (Right)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Guest User',
                  style: CustomTextStyle.heading3.copyWith(
                    fontWeight: CustomTheme.fontWeightBold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.phoneNumber ?? 'Join our community',
                  style: CustomTextStyle.bodyMedium.copyWith(
                    color: CustomTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'Join our community',
                  style: CustomTextStyle.bodyMedium.copyWith(
                    color: CustomTheme.textSecondary,
                  ),
                ),
                if (user?.pharmacyName != null && user!.pharmacyName!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: CustomTheme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
                    ),
                    child: Text(
                      user!.pharmacyName!,
                      style: CustomTextStyle.caption.copyWith(
                        color: CustomTheme.primaryColor,
                        fontWeight: CustomTheme.fontWeightSemiBold,
                        fontSize: 11,
                      ),
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

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GENERAL SETTINGS', style: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.textTertiary, letterSpacing: 1.2, fontWeight: CustomTheme.fontWeightBold)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
              
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'My Addresses',
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.addresses),
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.history_rounded,
                  title: 'Order History',
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.myOrders),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('PREFERENCES', style: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.textTertiary, letterSpacing: 1.2, fontWeight: CustomTheme.fontWeightBold)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  color: Colors.amber,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.security_rounded,
                  title: 'Privacy & Security',
                  color: Colors.teal,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  color: Colors.indigo,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildLogoutButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(title, style: CustomTextStyle.bodyMedium.copyWith(fontWeight: CustomTheme.fontWeightSemiBold)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: CustomTheme.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
      ),
      child: ListTile(
        onTap: () => _showLogoutDialog(context, ref),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.logout_rounded, size: 20, color: Colors.red),
        ),
        title: Text('Logout', style: CustomTextStyle.bodyMedium.copyWith(fontWeight: CustomTheme.fontWeightSemiBold, color: Colors.red)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.red),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: CustomTheme.borderLight, indent: 64, endIndent: 16);
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusXL)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: CustomTheme.textTertiary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProviderNotifier).logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}