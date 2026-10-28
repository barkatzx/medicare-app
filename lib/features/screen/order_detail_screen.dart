import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/features/entity/order_entity.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  String? _orderId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && _orderId == null) {
      _orderId = args;
      Future.microtask(() {
        ref.read(orderProviderNotifier).fetchOrderDetail(_orderId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = ref.watch(orderProviderNotifier);
    final order = orderProvider.selectedOrder;
    final isLoading = orderProvider.isLoading;
    final error = orderProvider.errorMessage;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(isLoading, order, error),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 50,
      elevation: 0,
      backgroundColor: CustomTheme.backgroundColor,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
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
      title: Text(
        'Order Details',
        style: CustomTextStyle.heading2.copyWith(fontSize: 20),
      ),
    );
  }

  Widget _buildBody(bool isLoading, OrderEntity? order, String? error) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: CustomTheme.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: CustomTheme.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading order details…',
              style: CustomTextStyle.bodySmall.copyWith(
                fontSize: 12,
                color: CustomTheme.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStateIcon(
                Icons.error_outline_rounded,
                CustomTheme.errorColor,
              ),
              const SizedBox(height: 18),
              Text(
                'Unable to Load Order',
                style: CustomTextStyle.heading3.copyWith(
                  fontSize: 16,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                error,
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (_orderId != null) {
                    ref.read(orderProviderNotifier).fetchOrderDetail(_orderId!);
                  }
                },
                child: _buildPrimaryPill('Try Again', Icons.refresh_rounded),
              ),
            ],
          ),
        ),
      );
    }

    if (order == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStateIcon(
                Icons.search_off_rounded,
                CustomTheme.textTertiary,
              ),
              const SizedBox(height: 18),
              Text(
                'Order Not Found',
                style: CustomTextStyle.heading3.copyWith(
                  fontSize: 16,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This order could not be found.\nPlease go back and try again.',
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: _buildPrimaryPill('Go Back', Icons.arrow_back_rounded),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(order),
            const SizedBox(height: 10),
            _buildItemsList(order),
            const SizedBox(height: 10),
            _buildInfoSection(order),
          ],
        ),
      ),
    );
  }

  Widget _buildStateIcon(IconData icon, Color color) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.07),
      ),
      child: Center(
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomTheme.surfaceColor,
          ),
          child: Icon(icon, size: 28, color: color),
        ),
      ),
    );
  }

  Widget _buildPrimaryPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
      decoration: BoxDecoration(
        color: CustomTheme.primaryColor,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: CustomTheme.primaryFontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Order header (unchanged design)
  // ─────────────────────────────────────────────────────────────
  Widget _buildOrderHeader(OrderEntity order) {
    final formattedDate = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(order.createdAt);
    final statusColor = _getStatusColor(order.status);
    final statusLabel = _getStatusLabel(order.status);
    final shortId = order.id.length >= 12
        ? order.id.substring(0, 12).toUpperCase()
        : order.id.toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#$shortId',
                        style: TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 15,
                          fontWeight: CustomTheme.fontWeightBold,
                          color: CustomTheme.textPrimary,
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: CustomTheme.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              formattedDate,
                              style: CustomTextStyle.bodySmall.copyWith(
                                color: CustomTheme.textSecondary,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _buildStatusBadge(statusLabel, statusColor),
              ],
            ),
          ),
          _buildStatusTracker(order.status),
        ],
      ),
    );
  }

  // ─── Status tracker ───
  Widget _buildStatusTracker(String status) {
    final s = status.toLowerCase();

    if (s == 'cancelled') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: CustomTheme.errorColor.withValues(alpha: 0.06),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cancel_outlined,
              size: 13,
              color: CustomTheme.errorColor,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'This order has been cancelled.',
                style: CustomTextStyle.bodySmall.copyWith(
                  color: CustomTheme.errorColor,
                  fontWeight: CustomTheme.fontWeightSemiBold,
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    const steps = ['pending', 'processing', 'shipped', 'delivered'];
    const labels = ['Placed', 'Processing', 'Shipped', 'Delivered'];
    final current = steps.indexOf(s);
    if (current < 0) return const SizedBox.shrink();

    final color = _getStatusColor(s);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
      decoration: BoxDecoration(
        color: CustomTheme.backgroundColor.withValues(alpha: 0.6),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final reached = i <= current;
          final isCurrent = i == current;
          final isDone = i < current;

          final leftActive = i <= current && i > 0;
          final rightActive = i < current;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: i == 0
                              ? Colors.transparent
                              : (leftActive ? color : CustomTheme.borderLight),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: reached ? color : CustomTheme.surfaceColor,
                        border: Border.all(
                          color: reached ? color : CustomTheme.borderMedium,
                          width: 1.6,
                        ),
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: Colors.white,
                              )
                            : (isCurrent
                                  ? Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: i == steps.length - 1
                              ? Colors.transparent
                              : (rightActive ? color : CustomTheme.borderLight),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: CustomTheme.primaryFontFamily,
                    fontSize: 10,
                    fontWeight: isCurrent
                        ? CustomTheme.fontWeightBold
                        : CustomTheme.fontWeightMedium,
                    color: reached
                        ? CustomTheme.textPrimary
                        : CustomTheme.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontFamily: CustomTheme.primaryFontFamily,
              fontSize: 12,
              fontWeight: CustomTheme.fontWeightBold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Order Items (compact) + Subtotal footer
  // ─────────────────────────────────────────────────────────────
  Widget _buildItemsList(OrderEntity order) {
    final subtotal = order.items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.5,
              color: CustomTheme.borderLight.withValues(alpha: 0.7),
              indent: 10,
              endIndent: 10,
            ),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: CustomTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: CustomTheme.borderLight,
                          width: 1,
                        ),
                      ),
                      child: item.product?.images.isNotEmpty == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.network(
                                item.product!.images.first.url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.medical_services_outlined,
                                  size: 15,
                                  color: CustomTheme.textTertiary,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.medical_services_outlined,
                              size: 15,
                              color: CustomTheme.textTertiary,
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.product?.name ?? 'Unknown Product',
                            style: CustomTextStyle.bodyMedium.copyWith(
                              fontWeight: CustomTheme.fontWeightSemiBold,
                              color: CustomTheme.textPrimary,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.price.toStringAsFixed(0)}৳ × ${item.quantity}',
                            style: CustomTextStyle.caption.copyWith(
                              fontSize: 10,
                              color: CustomTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${(item.price * item.quantity).toStringAsFixed(0)}৳',
                      style: TextStyle(
                        fontFamily: CustomTheme.primaryFontFamily,
                        fontSize: 12,
                        fontWeight: CustomTheme.fontWeightBold,
                        color: CustomTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ── Subtotal footer ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              border: Border(
                top: BorderSide(color: CustomTheme.borderLight, width: 0.7),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: TextStyle(
                    fontFamily: CustomTheme.primaryFontFamily,
                    fontSize: 13,
                    fontWeight: CustomTheme.fontWeightSemiBold,
                    color: CustomTheme.textSecondary,
                  ),
                ),
                Text(
                  '৳${subtotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: CustomTheme.primaryFontFamily,
                    fontSize: 13,
                    fontWeight: CustomTheme.fontWeightBold,
                    color: CustomTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Shipping & Payment (compact + colorful icons)
  // ─────────────────────────────────────────────────────────────
  Widget _buildInfoSection(OrderEntity order) {
    final addr = order.shippingAddress;
    final pay = order.payment;

    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // ── Shipping address ──
          if (addr != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildInfoIcon(
                    Icons.location_on_rounded,
                    const Color(0xFF10B981), // green
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          addr.street,
                          style: CustomTextStyle.bodyMedium.copyWith(
                            fontWeight: CustomTheme.fontWeightSemiBold,
                            color: CustomTheme.textPrimary,
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          [
                            addr.city,
                            addr.state,
                          ].where((e) => e.trim().isNotEmpty).join(', '),
                          style: CustomTextStyle.caption.copyWith(
                            fontSize: 10,
                            color: CustomTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (addr != null && pay != null)
            Divider(
              height: 1,
              thickness: 0.5,
              color: CustomTheme.borderLight.withValues(alpha: 0.7),
              indent: 12,
              endIndent: 12,
            ),

          // ── Payment method ──
          if (pay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoIcon(
                    pay.method.toLowerCase() == 'cod'
                        ? Icons.payments_rounded
                        : Icons.credit_card_rounded,
                    const Color(0xFF3B82F6), // blue
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Method',
                          style: CustomTextStyle.bodyMedium.copyWith(
                            fontWeight: CustomTheme.fontWeightSemiBold,
                            color: CustomTheme.textPrimary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pay.method == 'cod' ? 'Cash on Delivery' : pay.method,
                          style: CustomTextStyle.caption.copyWith(
                            color: CustomTheme.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildStatusBadge(
                    _getStatusLabel(pay.status),
                    _getStatusColor(pay.status),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon, Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 15, color: color),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Status helpers
  // ─────────────────────────────────────────────────────────────
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'processing':
        return const Color(0xFF3B82F6);
      case 'shipped':
        return const Color(0xFF8B5CF6);
      case 'delivered':
        return CustomTheme.successColor;
      case 'cancelled':
        return CustomTheme.errorColor;
      default:
        return CustomTheme.textTertiary;
    }
  }

  String _getStatusLabel(String status) {
    final Map<String, String> labels = {
      'pending': 'Pending',
      'processing': 'Processing',
      'shipped': 'Shipped',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
    };
    return labels[status.toLowerCase()] ?? status;
  }
}
