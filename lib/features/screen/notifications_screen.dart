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
      builder: (context) => AlertDialog(
        title: const Text('Delete all notifications?'),
        content: const Text(
          'This will permanently remove all your notifications.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: CustomTheme.errorColor),
            ),
          ),
        ],
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
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: CustomTheme.primaryFontFamily,
            fontWeight: FontWeight.w700,
            color: CustomTheme.textPrimary,
          ),
        ),
        backgroundColor: CustomTheme.backgroundColor,
        foregroundColor: CustomTheme.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (p.items.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'read') {
                  final ok = await p.markAllRead();
                  if (!ok && mounted) {
                    _message(p.error ?? 'Could not mark notifications as read');
                  }
                }
                if (value == 'delete') await _deleteAll();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'read', child: Text('Mark All as Read')),
                PopupMenuItem(value: 'delete', child: Text('Delete All')),
              ],
            ),
        ],
      ),
      body: _body(p),
    );
  }

  Widget _body(dynamic p) {
    if (p.isLoading && p.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: CustomTheme.primaryColor),
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
        onRefresh: () => p.load(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .27),
            const Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: CustomTheme.textTertiary,
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'You’re all caught up',
                style: TextStyle(
                  color: CustomTheme.textSecondary,
                  fontSize: 16,
                ),
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
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == p.items.length) {
            if (p.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: CustomTheme.primaryColor,
                  ),
                ),
              );
            }
            if (p.error != null) {
              return TextButton.icon(
                onPressed: () => p.load(),
                icon: const Icon(Icons.refresh),
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

  Widget _state(
    IconData icon,
    String title,
    String? detail, {
    required VoidCallback retry,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: CustomTheme.textTertiary),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (detail != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                detail,
                textAlign: TextAlign.center,
                style: const TextStyle(color: CustomTheme.textSecondary),
              ),
            ),
          const SizedBox(height: 8),
          FilledButton(onPressed: retry, child: const Text('Retry')),
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
  Widget build(BuildContext context) => Material(
    color: CustomTheme.surfaceColor,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.photo != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item.photo!,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _photoFallback(),
                  ),
                ),
              ),
            if (item.photo == null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: CustomTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: CustomTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CustomTheme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _date,
                    style: const TextStyle(
                      color: CustomTheme.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _photoFallback() => Container(
    width: 58,
    height: 58,
    decoration: BoxDecoration(
      color: CustomTheme.primaryColor.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(
      Icons.notifications_outlined,
      color: CustomTheme.primaryColor,
    ),
  );
}
