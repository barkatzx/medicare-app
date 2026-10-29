import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/di/providers.dart';
import '../../core/theme/custom_theme.dart';

class NotificationDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const NotificationDetailScreen({super.key, required this.id});
  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(notificationProviderNotifier).loadDetail(widget.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(notificationProviderNotifier);
    final item = p.detail;
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Notification'),
        backgroundColor: CustomTheme.backgroundColor,
        foregroundColor: CustomTheme.textPrimary,
        elevation: 0,
      ),
      body: p.detailLoading
          ? const Center(
              child: CircularProgressIndicator(color: CustomTheme.primaryColor),
            )
          : p.detailError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: CustomTheme.errorColor,
                    ),
                    const SizedBox(height: 12),
                    Text(p.detailError!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => p.loadDetail(widget.id),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : item == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: CustomTheme.textPrimary,
                      ),
                    ),
                    if (item.createdAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 18),
                        child: Text(
                          DateFormat(
                            'MMMM d, yyyy • h:mm a',
                          ).format(item.createdAt!.toLocal()),
                          style: const TextStyle(
                            color: CustomTheme.textTertiary,
                          ),
                        ),
                      ),
                    if (item.photo != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.photo!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 160,
                                  width: double.infinity,
                                  color: CustomTheme.secondaryColor,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    size: 40,
                                    color: CustomTheme.textTertiary,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    Text(
                      item.message,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: CustomTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
