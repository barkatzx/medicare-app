import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';

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
  static const double _actionSize = 40;
  static const double _iconSize = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProviderNotifier).getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProviderNotifier).currentUser;
    final hasName = user?.name.isNotEmpty == true;
    final displayName = user?.name ?? 'Guest User';
    final initial = hasName ? user!.name[0].toUpperCase() : 'G';

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
          _buildAvatar(initial),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome back 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
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
        const SizedBox(width: _sidePadding - 4),
      ],
    );
  }

  // ── Avatar with gradient ring ──
  Widget _buildAvatar(String initial) {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomTheme.primaryColor,
            CustomTheme.primaryColor.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: TextStyle(
            fontFamily: CustomTheme.primaryFontFamily,
            fontSize: 17,
            height: 1,
            fontWeight: FontWeight.w800,
            color: CustomTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  // ── Action button ──
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
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
              shape: BoxShape.circle,
              border: Border.all(
                color: CustomTheme.borderLight.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: Center(
                  child: Icon(
                    icon,
                    color: CustomTheme.textPrimary,
                    size: _iconSize,
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
