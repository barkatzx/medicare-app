import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:medicare_app/presentation/widgets/common/custom_button.dart';
import '../../../routes/app_routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProvider = ref.watch(authProviderNotifier);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(user),
            SizedBox(height: CustomTheme.spacingMD),
            _buildStatsSection(user),
            SizedBox(height: CustomTheme.spacingMD),
            _buildMenuSection(context, ref),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: CustomTheme.backgroundColor,
      scrolledUnderElevation: 0,
      title: Text(
        'Profile',
        style: CustomTextStyle.heading2,
      ),
      centerTitle: false,
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      margin: EdgeInsets.all(CustomTheme.spacingMD),
      padding: EdgeInsets.all(CustomTheme.spacingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomTheme.primaryColor,
            CustomTheme.primaryColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
        boxShadow: CustomTheme.boxShadowMedium,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: CustomTheme.surfaceColor,
              child: Text(
                user?.name?.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : 'G',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: CustomTheme.fontWeightBold,
                  color: CustomTheme.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: CustomTheme.spacingLG),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Guest',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: CustomTheme.fontWeightBold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: CustomTheme.spacingXS),
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    SizedBox(width: CustomTheme.spacingXS),
                    Expanded(
                      child: Text(
                        user?.email ?? 'No email',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: CustomTheme.spacingXS),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    SizedBox(width: CustomTheme.spacingXS),
                    Text(
                      user?.phoneNumber ?? 'No phone',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                if (user?.pharmacyName != null) ...[
                  SizedBox(height: CustomTheme.spacingXS),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: CustomTheme.spacingSM,
                      vertical: CustomTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_pharmacy,
                          size: 12,
                          color: Colors.white,
                        ),
                        SizedBox(width: CustomTheme.spacingXS),
                        Text(
                          user!.pharmacyName!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: CustomTheme.fontWeightMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: CustomTheme.spacingSM),
                Wrap(
                  spacing: CustomTheme.spacingXS,
                  runSpacing: CustomTheme.spacingXS,
                  children: [
                    if (user != null)
                      _buildStatusChip(
                        user.role.toUpperCase(),
                        Icons.admin_panel_settings_outlined,
                      ),
                    if (user != null)
                      _buildStatusChip(
                        user.isApproved ? 'Approved' : 'Pending',
                        user.isApproved ? Icons.check_circle_outline : Icons.hourglass_empty,
                        color: user.isApproved ? Colors.green.shade400 : Colors.orange.shade400,
                      ),
                    if (user != null)
                      _buildStatusChip(
                        'Joined ${user.createdAt.year}',
                        Icons.calendar_today_outlined,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, IconData icon, {Color? color}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CustomTheme.spacingSM,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(0.15),
        borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
        border: Border.all(
          color: (color ?? Colors.white).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color ?? Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color ?? Colors.white,
              fontWeight: CustomTheme.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: CustomTheme.spacingMD),
      padding: EdgeInsets.all(CustomTheme.spacingLG),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
        boxShadow: CustomTheme.boxShadowLight,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.shopping_bag_outlined,
            value: '0',
            label: 'Orders',
          ),
          Container(
            width: 1,
            height: 40,
            color: CustomTheme.borderLight,
          ),
          _buildStatItem(
            icon: Icons.favorite_border,
            value: '0',
            label: 'Wishlist',
          ),
          Container(
            width: 1,
            height: 40,
            color: CustomTheme.borderLight,
          ),
          _buildStatItem(
            icon: Icons.star_border,
            value: '0',
            label: 'Reviews',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: CustomTheme.primaryColor,
        ),
        SizedBox(height: CustomTheme.spacingSM),
        Text(
          value,
          style: CustomTextStyle.heading3.copyWith(
            fontWeight: CustomTheme.fontWeightBold,
          ),
        ),
        SizedBox(height: CustomTheme.spacingXS),
        Text(
          label,
          style: CustomTextStyle.caption,
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    final authProvider = ref.watch(authProviderNotifier);
    final user = authProvider.currentUser;

    return Container(
      margin: EdgeInsets.all(CustomTheme.spacingMD),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
        boxShadow: CustomTheme.boxShadowLight,
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.editProfile);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Icons.location_on_outlined,
            title: 'My Addresses',
            subtitle: '${user?.addresses.length ?? 0} saved addresses',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.addresses);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            subtitle: 'Track your orders',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.myOrders);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.changePassword);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notifications',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.notifications);
            },
            showBadge: true,
            badgeCount: user?.notifications.length ?? 0,
          ),
          _buildDivider(),
          _buildLogoutMenuItem(context, ref),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(CustomTheme.spacingMD),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: CustomTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
              ),
              child: Icon(
                icon,
                size: 24,
                color: CustomTheme.primaryColor,
              ),
            ),
            SizedBox(width: CustomTheme.spacingMD),
            
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CustomTextStyle.bodyMedium.copyWith(
                      fontWeight: CustomTheme.fontWeightSemiBold,
                    ),
                  ),
                  SizedBox(height: CustomTheme.spacingXS),
                  Text(
                    subtitle,
                    style: CustomTextStyle.caption,
                  ),
                ],
              ),
            ),
            
            // Badge (if any)
            if (showBadge && badgeCount > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: CustomTheme.spacingSM,
                  vertical: CustomTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: CustomTheme.errorColor,
                  borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: CustomTheme.fontWeightBold,
                  ),
                ),
              ),
            
            SizedBox(width: CustomTheme.spacingSM),
            
            // Chevron Icon
            Icon(
              Icons.chevron_right,
              color: CustomTheme.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutMenuItem(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        _showLogoutDialog(context, ref);
      },
      child: Container(
        padding: EdgeInsets.all(CustomTheme.spacingMD),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: CustomTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
              ),
              child: Icon(
                Icons.logout,
                size: 24,
                color: CustomTheme.errorColor,
              ),
            ),
            SizedBox(width: CustomTheme.spacingMD),
            
            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logout',
                    style: CustomTextStyle.bodyMedium.copyWith(
                      fontWeight: CustomTheme.fontWeightSemiBold,
                      color: CustomTheme.errorColor,
                    ),
                  ),
                  SizedBox(height: CustomTheme.spacingXS),
                  Text(
                    'Sign out from your account',
                    style: CustomTextStyle.caption,
                  ),
                ],
              ),
            ),
            
            // Chevron Icon
            Icon(
              Icons.chevron_right,
              color: CustomTheme.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: CustomTheme.borderLight,
      margin: EdgeInsets.symmetric(horizontal: CustomTheme.spacingMD),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          margin: EdgeInsets.all(CustomTheme.spacingMD),
          padding: EdgeInsets.all(CustomTheme.spacingXL),
          decoration: BoxDecoration(
            color: CustomTheme.surfaceColor,
            borderRadius: BorderRadius.circular(CustomTheme.radiusXL),
            boxShadow: CustomTheme.boxShadowHeavy,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(CustomTheme.spacingLG),
                decoration: BoxDecoration(
                  color: CustomTheme.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  size: 50,
                  color: CustomTheme.errorColor,
                ),
              ),
              SizedBox(height: CustomTheme.spacingLG),
              Text(
                'Logout',
                style: CustomTextStyle.heading2,
              ),
              SizedBox(height: CustomTheme.spacingSM),
              Text(
                'Are you sure you want to logout?',
                style: CustomTextStyle.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: CustomTheme.spacingXL),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: CustomTheme.spacingMD),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                          border: Border.all(color: CustomTheme.borderMedium),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: CustomTextStyle.bodyMedium.copyWith(
                              color: CustomTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: CustomTheme.spacingMD),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await ref.read(authProviderNotifier).logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: CustomTheme.spacingMD),
                        decoration: BoxDecoration(
                          color: CustomTheme.errorColor,
                          borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                        ),
                        child: Center(
                          child: Text(
                            'Logout',
                            style: CustomTextStyle.button,
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