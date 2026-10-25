import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';

class HomeAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  // 64dp is the standard comfortable app bar height for a two-line header.
  static const double height = 64;

  @override
  ConsumerState<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(height);
}

class _HomeAppBarState extends ConsumerState<HomeAppBar> {
  // ── Sizing (Material standard) ──
  static const double _sidePadding = 16; // screen edge gutter
  static const double _avatarSize = 48; // visual avatar
  static const double _avatarRing = 1; // border thickness
  static const double _touchTarget = 48; // minimum touch target (48dp)
  static const double _actionSize = 44; // visual action button
  static const double _iconSize = 22;

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
          _buildAvatar(hasName ? user!.name[0].toUpperCase() : 'G'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome Back,',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyle.bodySmall.copyWith(
                    fontSize: 12,
                    height: 1.2,
                    color: CustomTheme.textSecondary,
                    fontWeight: CustomTheme.fontWeightMedium,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyle.heading4.copyWith(
                    fontSize: 16,
                    height: 1.25,
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
        // Right gutter matches the left gutter (16dp total with the 48dp slot).
        const SizedBox(width: _sidePadding - 2),
      ],
    );
  }

  Widget _buildAvatar(String initial) {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      padding: const EdgeInsets.all(_avatarRing),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: CustomTheme.secondaryColor,
          width: _avatarRing,
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
          style: CustomTextStyle.heading3.copyWith(
            fontSize: 20,
            height: 1,
            color: CustomTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    // Outer SizedBox gives a full 48dp touch area around the 44dp visual.
    return SizedBox(
      width: _touchTarget,
      height: _touchTarget,
      child: Center(
        child: Semantics(
          button: true,
          label: label,
          child: Container(
            width: _actionSize,
            height: _actionSize,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
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
