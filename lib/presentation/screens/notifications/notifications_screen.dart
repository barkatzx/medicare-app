import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/core/services/notification_service.dart';
import 'package:medicare_app/presentation/providers/notification_provider.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:medicare_app/presentation/widgets/common/loading_widget.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProviderNotifier).loadNotifications();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationProviderNotifier).loadMoreNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(notificationProviderNotifier);
    final notifications = provider.notifications;
    final isLoading = provider.isLoading;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: _buildAppBar(provider),
      body: _buildBody(provider, notifications, isLoading),
    );
  }

  PreferredSizeWidget _buildAppBar(NotificationProvider provider) {
    return AppBar(
      elevation: 0,
      backgroundColor: CustomTheme.backgroundColor,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: CustomTheme.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Notifications', style: CustomTextStyle.heading2),
      actions: [
        if (provider.unreadCount > 0)
          TextButton.icon(
            onPressed: () async {
              try {
                await provider.markAllAsRead();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('All marked as read'),
                      backgroundColor: CustomTheme.successColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed: $e'),
                      backgroundColor: CustomTheme.errorColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Mark all read'),
            style: TextButton.styleFrom(foregroundColor: CustomTheme.primaryColor),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(
    NotificationProvider provider,
    List notifications,
    bool isLoading,
  ) {
    return Column(
      children: [
        _buildFilters(provider),
        Expanded(
          child: isLoading && notifications.isEmpty
              ? const LoadingWidget(isOverlay: false)
              : notifications.isEmpty
                  ? _buildEmptyState(provider.unreadOnly)
                  : RefreshIndicator(
                      onRefresh: () => provider.loadNotifications(),
                      color: CustomTheme.primaryColor,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: notifications.length + (provider.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == notifications.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          }
                          return _buildNotificationCard(notifications[index]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilters(NotificationProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: !provider.unreadOnly,
            onTap: () {
              if (provider.unreadOnly) provider.toggleUnreadFilter();
            },
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: 'Unread',
            count: provider.unreadCount > 0 ? provider.unreadCount : null,
            isSelected: provider.unreadOnly,
            onTap: () {
              if (!provider.unreadOnly) provider.toggleUnreadFilter();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isUnreadOnly) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnreadOnly ? Icons.mark_chat_read_outlined : Icons.notifications_none_outlined,
            size: 80,
            color: CustomTheme.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isUnreadOnly ? 'No unread notifications' : 'No notifications yet',
            style: CustomTextStyle.heading3.copyWith(color: CustomTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            isUnreadOnly 
                ? 'You\'re all caught up!' 
                : 'We\'ll notify you when something important happens',
            style: CustomTextStyle.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notification) {
    final bool isRead = notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? CustomTheme.surfaceColor : CustomTheme.primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
        border: Border.all(
          color: isRead ? CustomTheme.borderLight : CustomTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: isRead ? null : [
          BoxShadow(
            color: CustomTheme.primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isRead) {
              ref.read(notificationProviderNotifier).markAsRead(notification.id);
            }
          },
          borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isRead ? CustomTheme.backgroundColor : CustomTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIcon(notification.type),
                    size: 20,
                    color: isRead ? CustomTheme.textSecondary : CustomTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: CustomTextStyle.bodyMedium.copyWith(
                                fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                color: isRead ? CustomTheme.textSecondary : CustomTheme.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            notification.formattedDate,
                            style: CustomTextStyle.caption.copyWith(
                              color: CustomTheme.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: CustomTextStyle.bodySmall.copyWith(
                          color: isRead ? CustomTheme.textTertiary : CustomTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  Container(
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: CustomTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'order': return Icons.shopping_bag_outlined;
      case 'payment': return Icons.account_balance_wallet_outlined;
      case 'promotion': return Icons.local_offer_outlined;
      case 'alert': return Icons.error_outline;
      default: return Icons.notifications_none_outlined;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CustomTheme.primaryColor : CustomTheme.surfaceColor,
          borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
          border: Border.all(
            color: isSelected ? CustomTheme.primaryColor : CustomTheme.borderLight,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: CustomTheme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: CustomTextStyle.bodyMedium.copyWith(
                color: isSelected ? Colors.white : CustomTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : CustomTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : CustomTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
