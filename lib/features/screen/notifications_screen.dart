import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/di/providers.dart';
import '../../core/theme/custom_theme.dart';
import '../notifications/notification_entity.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(notificationProviderNotifier).load(),
    );
    _scroll.addListener(() {
      final p = ref.read(notificationProviderNotifier);
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 180 &&
          p.hasMore &&
          !p.isLoading &&
          !p.isLoadingMore) {
        p.load();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _deleteAll() async {
    final yes = await showDialog<bool>(
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
                  Icons.delete_sweep_outlined,
                  color: CustomTheme.errorColor,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete all notifications?',
                textAlign: TextAlign.center,
                style: CustomTextStyle.heading3.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 8),
              Text(
                'This will permanently remove all your notifications.',
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
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
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: CustomTheme.errorColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Delete',
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
    if (yes != true || !mounted) return;
    final ok = await ref.read(notificationProviderNotifier).deleteAll();
    if (mounted && !ok) {
      _message(
        ref.read(notificationProviderNotifier).error ??
            'Could not delete notifications',
      );
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(notificationProviderNotifier);
    final unread = p.items.where((e) => !e.isRead).length;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: CustomTheme.backgroundColor,
        foregroundColor: CustomTheme.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: CustomTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: CustomTheme.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              )
            : null,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontFamily: CustomTheme.primaryFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                letterSpacing: -0.4,
                color: CustomTheme.textPrimary,
              ),
            ),
            if (unread > 0)
              Text(
                '$unread unread',
                style: CustomTextStyle.caption.copyWith(
                  fontSize: 12,
                  color: CustomTheme.primaryColor,
                  fontWeight: CustomTheme.fontWeightSemiBold,
                ),
              ),
          ],
        ),
        actions: [
          if (p.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  color: CustomTheme.surfaceColor,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (value) async {
                    if (value == 'read') {
                      final ok = await p.markAllRead();
                      if (!ok && mounted) {
                        _message(
                          p.error ?? 'Could not mark notifications as read',
                        );
                      }
                    }
                    if (value == 'delete') await _deleteAll();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'read',
                      child: Row(
                        children: [
                          Icon(
                            Icons.done_all_rounded,
                            size: 18,
                            color: CustomTheme.primaryColor,
                          ),
                          const SizedBox(width: 10),
                          const Text('Mark All as Read'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: const [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: CustomTheme.errorColor,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Delete All',
                            style: TextStyle(color: CustomTheme.errorColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: CustomTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.more_horiz_rounded,
                      color: CustomTheme.textPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _body(p),
    );
  }

  Widget _body(dynamic p) {
    if (p.isLoading && p.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: CustomTheme.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: CustomTheme.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading notifications…',
              style: CustomTextStyle.bodySmall.copyWith(
                fontSize: 13,
                color: CustomTheme.textTertiary,
              ),
            ),
          ],
        ),
      );
    }
    if (p.error != null && p.items.isEmpty) {
      return _state(
        Icons.wifi_off_rounded,
        'Could not load notifications',
        p.error,
        retry: () => p.load(refresh: true),
      );
    }
    if (p.items.isEmpty) {
      return RefreshIndicator(
        color: CustomTheme.primaryColor,
        onRefresh: () => p.load(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .2),
            Center(child: _iconBadge(Icons.notifications_none_rounded)),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'You’re all caught up',
                style: CustomTextStyle.heading3.copyWith(
                  fontSize: 18,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'New notifications will show up here.',
                style: CustomTextStyle.bodyMedium.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: CustomTheme.primaryColor,
      onRefresh: () => p.load(refresh: true),
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount:
            p.items.length +
            (p.isLoadingMore || p.error != null || p.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == p.items.length) {
            if (p.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: CustomTheme.primaryColor,
                    ),
                  ),
                ),
              );
            }
            if (p.error != null) {
              return TextButton.icon(
                onPressed: () => p.load(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Could not load more. Retry'),
              );
            }
            return const SizedBox(height: 8);
          }
          final item = p.items[index] as NotificationEntity;
          return _NotificationTile(
            item: item,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationDetailScreen(id: item.id),
                ),
              );
              if (mounted) {
                ref.read(notificationProviderNotifier).load(refresh: true);
              }
            },
          );
        },
      ),
    );
  }

  Widget _iconBadge(IconData icon, {Color? color}) {
    final c = color ?? CustomTheme.textTertiary;
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.withValues(alpha: 0.07),
      ),
      child: Center(
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomTheme.surfaceColor,
          ),
          child: Icon(icon, size: 36, color: c),
        ),
      ),
    );
  }

  Widget _state(
    IconData icon,
    String title,
    String? detail, {
    required VoidCallback retry,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconBadge(icon),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: CustomTextStyle.heading3.copyWith(
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),
          if (detail != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                detail,
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: retry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: CustomTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.refresh_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Retry',
                    style: CustomTextStyle.button.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity item;
  final VoidCallback onTap;
  const _NotificationTile({required this.item, required this.onTap});

  String get _date => item.createdAt == null
      ? ''
      : DateFormat('MMM d, yyyy • h:mm a').format(item.createdAt!.toLocal());

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;

    return Container(
      decoration: BoxDecoration(
        color: unread
            ? Color.alphaBlend(
                CustomTheme.primaryColor.withValues(alpha: 0.04),
                CustomTheme.surfaceColor,
              )
            : CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (item.photo != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.photo!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _photoFallback(),
                      ),
                    ),
                  ),
                if (item.photo == null)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _photoFallback(),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title.isEmpty ? 'Notification' : item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: CustomTheme.primaryFontFamily,
                                fontSize: 14,
                                fontWeight: unread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: CustomTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (unread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: CustomTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 12,
                          color: unread
                              ? CustomTheme.textSecondary
                              : CustomTheme.textTertiary,
                          height: 1.4,
                        ),
                      ),
                      if (_date.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 11,
                              color: CustomTheme.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _date,
                              style: const TextStyle(
                                color: CustomTheme.textTertiary,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _photoFallback() => Container(
    width: 48,
    height: 48,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          CustomTheme.primaryColor.withValues(alpha: 0.16),
          CustomTheme.primaryColor.withValues(alpha: 0.06),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(
      Icons.notifications_outlined,
      color: CustomTheme.primaryColor,
    ),
  );
}
