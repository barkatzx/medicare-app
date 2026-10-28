import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/features/entity/order_entity.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';
import 'package:medicare_app/core/routes/app_routes.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProviderNotifier).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = ref.watch(orderProviderNotifier);
    final orders = orderProvider.orders;
    final isLoading = orderProvider.isLoading;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(isLoading, orders),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // AppBar
  // ─────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 52,
      title: Text(
        'Order History',
        style: CustomTextStyle.heading2.copyWith(fontSize: 20),
      ),
      backgroundColor: CustomTheme.backgroundColor,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10.0),
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
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Body router
  // ─────────────────────────────────────────────────────────────
  Widget _buildBody(bool isLoading, List<OrderEntity> orders) {
    if (isLoading && orders.isEmpty) {
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
              'Loading orders…',
              style: CustomTextStyle.bodySmall.copyWith(
                fontSize: 12,
                color: CustomTheme.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(orderProviderNotifier).fetchOrders(),
      color: CustomTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildOrderCard(orders[index]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Empty state
  // ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CustomTheme.primaryColor.withValues(alpha: 0.12),
                    CustomTheme.primaryColor.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 44,
                color: CustomTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Orders Yet',
              style: CustomTextStyle.heading2.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t placed any orders yet.\nStart your healthcare journey today!',
              textAlign: TextAlign.center,
              style: CustomTextStyle.bodyMedium.copyWith(
                fontSize: 13,
                color: CustomTheme.textTertiary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  textStyle: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Start Shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Order card (compact)
  // ─────────────────────────────────────────────────────────────
  Widget _buildOrderCard(OrderEntity order) {
    final formattedDate = DateFormat(
      'MMM dd, yy • hh:mm a',
    ).format(order.createdAt);
    final statusColor = _getStatusColor(order.status);
    final statusIcon = _getStatusIcon(order.status);
    final shortId = order.id.length >= 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.orderDetail,
            arguments: order.id,
          ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: ID + Status ─────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: CustomTheme.primaryColor.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            size: 13,
                            color: CustomTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#$shortId',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: CustomTheme.fontWeightBold,
                                color: CustomTheme.textPrimary,
                                letterSpacing: 0.3,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildStatusChip(order.status, statusColor, statusIcon),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Divider ─────────────────────────────────
                Container(
                  height: 1,
                  color: CustomTheme.borderLight.withValues(alpha: 0.5),
                ),

                const SizedBox(height: 8),

                // ── Footer: Date + Items + Total ────────────
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: CustomTheme.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: CustomTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 11,
                          color: CustomTheme.textTertiary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: CustomTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${order.totalAmount.toStringAsFixed(0)}৳',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: CustomTheme.textPrimary,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Status chip (compact)
  // ─────────────────────────────────────────────────────────────
  Widget _buildStatusChip(String status, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 8.5,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Status helpers
  // ─────────────────────────────────────────────────────────────
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade700;
      case 'processing':
        return Colors.blue.shade700;
      case 'shipped':
        return Colors.purple.shade700;
      case 'delivered':
        return CustomTheme.successColor;
      case 'cancelled':
        return CustomTheme.errorColor;
      default:
        return CustomTheme.textTertiary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'processing':
        return Icons.autorenew_rounded;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.check_circle_outline_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
