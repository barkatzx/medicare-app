import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/providers/notification_provider.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProviderNotifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(notificationProviderNotifier);
    final notifications = provider.notifications;
    final isLoading = provider.isLoading;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: _buildAppBar(provider, notifications),
      body: _buildBody(provider, notifications, isLoading),
    );
  }

  PreferredSizeWidget _buildAppBar(
    NotificationProvider provider,
    List notifications,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: CustomTheme.backgroundColor,
      scrolledUnderElevation: 0,
      leading: Container(
        margin: EdgeInsets.only(left: CustomTheme.spacingMD),
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: CustomTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
          splashRadius: 24,
        ),
      ),
      title: Text('Notifications', style: CustomTextStyle.heading2),
      actions: [
        if (notifications.isNotEmpty && provider.unreadCount > 0)
          Container(
            margin: EdgeInsets.only(right: CustomTheme.spacingMD),
            child: TextButton(
              // In the app bar actions, update the onPressed:
              onPressed: () async {
                try {
                  await ref.read(notificationProviderNotifier).markAllAsRead();
                  // Show success message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'All notifications marked as read',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: CustomTheme.successColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            CustomTheme.radiusMD,
                          ),
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  // Show error message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to mark all as read: ${e.toString()}',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: CustomTheme.errorColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            CustomTheme.radiusMD,
                          ),
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: CustomTheme.spacingMD,
                  vertical: CustomTheme.spacingSM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.done_all,
                    size: 18,
                    color: CustomTheme.primaryColor,
                  ),
                  SizedBox(width: CustomTheme.spacingSM),
                  Text(
                    'Mark all read',
                    style: CustomTextStyle.bodySmall.copyWith(
                      color: CustomTheme.primaryColor,
                      fontWeight: CustomTheme.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(
    NotificationProvider provider,
    List notifications,
    bool isLoading,
  ) {
    if (isLoading && notifications.isEmpty) {
      return _buildLoadingState();
    }

    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationProviderNotifier).loadNotifications();
      },
      color: CustomTheme.primaryColor,
      backgroundColor: CustomTheme.surfaceColor,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                CustomTheme.spacingMD,
                CustomTheme.spacingMD,
                CustomTheme.spacingMD,
                0,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: CustomTheme.spacingSM,
                      vertical: CustomTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: CustomTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        CustomTheme.radiusRound,
                      ),
                    ),
                    child: Text(
                      '${notifications.length} Total',
                      style: CustomTextStyle.caption.copyWith(
                        color: CustomTheme.primaryColor,
                        fontWeight: CustomTheme.fontWeightMedium,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (provider.unreadCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: CustomTheme.spacingSM,
                        vertical: CustomTheme.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: CustomTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          CustomTheme.radiusRound,
                        ),
                      ),
                      child: Text(
                        '${provider.unreadCount} Unread',
                        style: CustomTextStyle.caption.copyWith(
                          color: CustomTheme.warningColor,
                          fontWeight: CustomTheme.fontWeightMedium,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(CustomTheme.spacingMD),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              }, childCount: notifications.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          SizedBox(height: CustomTheme.spacingLG),
          Text('Loading notifications...', style: CustomTextStyle.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(CustomTheme.spacingXXL),
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: CustomTheme.textTertiary,
            ),
          ),
          SizedBox(height: CustomTheme.spacingXL),
          Text(
            'No notifications yet',
            style: CustomTextStyle.heading3.copyWith(
              color: CustomTheme.textSecondary,
            ),
          ),
          SizedBox(height: CustomTheme.spacingSM),
          Text(
            'We\'ll notify you when something arrives',
            style: CustomTextStyle.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notification) {
    final isRead = notification.isRead;

    return Container(
      margin: EdgeInsets.only(bottom: CustomTheme.spacingMD),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (!isRead) {
              await ref.read(notificationProviderNotifier).markAsRead(notification.id);
            }
          },
          borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
          child: Padding(
            padding: EdgeInsets.all(CustomTheme.spacingLG),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  padding: EdgeInsets.all(CustomTheme.spacingMD),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isRead
                          ? [
                              CustomTheme.borderLight,
                              CustomTheme.borderLight.withOpacity(0.5),
                            ]
                          : [
                              CustomTheme.primaryColor,
                              CustomTheme.primaryColor.withOpacity(0.7),
                            ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    size: 22,
                    color: isRead ? CustomTheme.textSecondary : Colors.white,
                  ),
                ),
                SizedBox(width: CustomTheme.spacingMD),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: CustomTextStyle.bodyMedium.copyWith(
                                fontWeight: isRead
                                    ? CustomTheme.fontWeightMedium
                                    : CustomTheme.fontWeightSemiBold,
                                color: isRead
                                    ? CustomTheme.textSecondary
                                    : CustomTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: CustomTheme.primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: CustomTheme.primaryColor.withOpacity(
                                      0.4,
                                    ),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: CustomTheme.spacingSM),
                      Text(
                        notification.message,
                        style: CustomTextStyle.bodySmall,
                      ),
                      SizedBox(height: CustomTheme.spacingSM),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: CustomTheme.textTertiary,
                          ),
                          SizedBox(width: CustomTheme.spacingXS),
                          Text(
                            notification.formattedDate,
                            style: CustomTextStyle.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'payment':
        return Icons.payment_outlined;
      case 'promotion':
        return Icons.local_offer_outlined;
      case 'alert':
        return Icons.notifications_active_outlined;
      case 'message':
        return Icons.message_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }
}
