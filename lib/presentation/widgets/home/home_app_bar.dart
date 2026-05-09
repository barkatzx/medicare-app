import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';

class HomeAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  ConsumerState<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends ConsumerState<HomeAppBar> {
  @override
  void initState() {
    super.initState();
    // Load notification counts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = ref.read(notificationProviderNotifier);
      final cartProvider = ref.read(cartProviderNotifier);
      notificationProvider.loadNotifications();
      cartProvider.loadCartCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProviderNotifier).currentUser;
    final notificationProvider = ref.watch(notificationProviderNotifier);

    final unreadCount = notificationProvider.unreadCount;

    return AppBar(
      elevation: 0,
      backgroundColor: CustomTheme.backgroundColor,
      foregroundColor: CustomTheme.primaryColor,
      titleSpacing: CustomTheme.spacingSM,
      title: Row(
        children: [
          // Default Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user?.name.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : 'G',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: CustomTheme.fontWeightSemiBold,
                  color: CustomTheme.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: CustomTheme.spacingMD),

          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.name ?? "Guest"}',
                  style: CustomTextStyle.bodyLarge.copyWith(
                    fontWeight: CustomTheme.fontWeightSemiBold,
                  ),
                ),
                Text('Welcome to MediCare', style: CustomTextStyle.bodySmall),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Search Icon
        Container(
          decoration: BoxDecoration(
            color: CustomTheme.surfaceColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.search,
              color: CustomTheme.textSecondary,
              size: 20,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
            splashRadius: 24,
          ),
        ),

        // Spacing between cart and notification icons
        SizedBox(width: CustomTheme.spacingSM),

        // Notification Icon with Badge
        Stack(
          children: [
            Container(
              margin: EdgeInsets.only(right: CustomTheme.spacingMD),
              decoration: BoxDecoration(
                color: CustomTheme.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: CustomTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
                splashRadius: 24,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: CustomTheme.errorColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CustomTheme.surfaceColor,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
