import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';
import 'package:medicare_app/core/routes/app_routes.dart';

class HomeAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  static const double height = 64;

  @override
  ConsumerState<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(height);
}

class _HomeAppBarState extends ConsumerState<HomeAppBar> {
  static const double _sidePadding = 16;
  static const double _avatarSize = 44;
  static const double _actionSize = 35;
  static const double _iconSize = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProviderNotifier).getProfile();
      ref.read(notificationProviderNotifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProviderNotifier).currentUser;
    final unreadCount = ref
        .watch(notificationProviderNotifier)
        .unreadCount
        .clamp(0, 999);
    final displayName = user?.name ?? 'Guest User';
    final nameParts = (user?.name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    final initials = nameParts.isEmpty
        ? 'G'
        : nameParts.take(2).map((part) => part[0].toUpperCase()).join();

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: HomeAppBar.height,
      backgroundColor: CustomTheme.backgroundColor,
      automaticallyImplyLeading: false,
      titleSpacing: _sidePadding,
      title: Row(
        children: [
          _buildAvatar(initials),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome Back 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.2,
                    color: CustomTheme.textTertiary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: CustomTheme.primaryFontFamily,
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: CustomTheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _buildActionButton(
          icon: Icons.search_rounded,
          label: 'Search',
          onTap: () => Navigator.pushNamed(context, '/search'),
        ),
        _buildActionButton(
          icon: Icons.notifications_none_rounded,
          label: 'Notifications',
          badgeCount: unreadCount,
          onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
        ),
        const SizedBox(width: _sidePadding - 4),
      ],
    );
  }

  // ── Avatar styled like the profile screen ──
  Widget _buildAvatar(String initials) {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CustomTheme.primaryColor.withValues(alpha: 0.07),
        border: Border.all(
          color: CustomTheme.primaryColor.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: CustomTheme.primaryFontFamily,
          fontSize: 19,
          height: 1,
          fontWeight: CustomTheme.fontWeightBold,
          color: CustomTheme.primaryColor,
        ),
      ),
    );
  }

  // ── Action button ──
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Center(
        child: Semantics(
          button: true,
          label: label,
          child: Container(
            width: _actionSize,
            height: _actionSize,
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CustomTheme.borderLight.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: _actionSize,
                  height: _actionSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        icon,
                        color: CustomTheme.textPrimary,
                        size: _iconSize,
                      ),
                      if (badgeCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 15,
                              minHeight: 15,
                            ),
                            decoration: const BoxDecoration(
                              color: CustomTheme.errorColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              badgeCount > 99 ? '99+' : '$badgeCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
