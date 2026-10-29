import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        backgroundColor: CustomTheme.backgroundColor,
        foregroundColor: CustomTheme.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: Padding(
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
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            fontFamily: CustomTheme.primaryFontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.4,
            color: CustomTheme.textPrimary,
          ),
        ),
      ),
      body: p.detailLoading
          ? _buildLoading()
          : p.detailError != null
          ? _buildError(p.detailError!, () => p.loadDetail(widget.id))
          : item == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 550),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 18 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CustomTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        CustomTheme.primaryColor,
                                        CustomTheme.primaryColor.withValues(
                                          alpha: 0.75,
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active_outlined,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (item.createdAt != null)
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: CustomTheme.backgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: CustomTheme.borderLight,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.schedule_rounded,
                                            size: 13,
                                            color: CustomTheme.textTertiary,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              DateFormat(
                                                'MMM d, yyyy • h:mm a',
                                              ).format(
                                                item.createdAt!.toLocal(),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    CustomTheme.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontFamily: CustomTheme.primaryFontFamily,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                                letterSpacing: -0.5,
                                color: CustomTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Photo ──
                      if (item.photo != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              item.photo!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 160,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: CustomTheme.backgroundColor,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
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

                      // ── Divider ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Divider(
                          height: 1,
                          color: CustomTheme.borderLight,
                        ),
                      ),

                      // ── Message ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                        child: Text(
                          item.message,
                          style: const TextStyle(
                            fontFamily: CustomTheme.primaryFontFamily,
                            fontSize: 15.5,
                            height: 1.7,
                            color: CustomTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoading() {
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
            'Loading notification…',
            style: CustomTextStyle.bodySmall.copyWith(
              fontSize: 13,
              color: CustomTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message, VoidCallback retry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomTheme.errorColor.withValues(alpha: 0.07),
              ),
              child: Center(
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CustomTheme.surfaceColor,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 36,
                    color: CustomTheme.errorColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load',
              style: CustomTextStyle.heading3.copyWith(
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: CustomTextStyle.bodyMedium.copyWith(
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: retry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
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
}
