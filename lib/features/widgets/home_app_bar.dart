import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';

class HomeAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  ConsumerState<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _HomeAppBarState extends ConsumerState<HomeAppBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProviderNotifier).getProfile();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProviderNotifier).currentUser;

    return AppBar(
      elevation: 0,
      toolbarHeight: 70,
      backgroundColor: CustomTheme.backgroundColor,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            // Premium Avatar with Gradient Border
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      CustomTheme.primaryColor,
                      CustomTheme.primaryColor.withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : 'G',
                      style: CustomTextStyle.heading3.copyWith(
                        fontSize: 18,
                        color: CustomTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // User Info & Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        _getGreeting(),
                        style: CustomTextStyle.bodySmall.copyWith(
                          color: CustomTheme.textSecondary,
                          fontWeight: CustomTheme.fontWeightMedium,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _getGreetingIcon(),
                        size: 14,
                        color: Colors.orangeAccent,
                      ),
                    ],
                  ),
                  Text(
                    user?.name ?? 'Guest User',
                    style: CustomTextStyle.heading4.copyWith(
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: CustomTheme.primaryColor.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          user?.hasAddress == true
                              ? '${user!.district!.name}, ${user.division!.name}'
                              : 'Add Location',
                          style: CustomTextStyle.caption.copyWith(
                            color: CustomTheme.textTertiary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        _buildActionButton(
          icon: Icons.search_rounded,
          onTap: () => Navigator.pushNamed(context, '/search'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_outlined;
    if (hour < 17) return Icons.wb_cloudy_outlined;
    return Icons.nightlight_round_outlined;
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: CustomTheme.borderLight.withValues(alpha: 0.5),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: CustomTheme.textPrimary, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
