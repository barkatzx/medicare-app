import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/domain/entities/order_entity.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:medicare_app/presentation/widgets/common/loading_widget.dart';
import 'package:medicare_app/routes/app_routes.dart';

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
      appBar: AppBar(
        title: Text('My Orders', style: CustomTextStyle.heading3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: CustomTheme.textPrimary, size: 16),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(isLoading, orders),
    );
  }

  Widget _buildBody(bool isLoading, List<OrderEntity> orders) {
    if (isLoading && orders.isEmpty) {
      return const LoadingWidget();
    }

    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: CustomTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 32),
              Text('No Orders Yet', style: CustomTextStyle.heading2),
              const SizedBox(height: 12),
              Text(
                'Looks like you haven\'t placed any orders yet. Start your healthcare journey today!',
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(color: CustomTheme.textSecondary),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusRound)),
                    elevation: 0,
                  ),
                  child: Text('Start Shopping', style: CustomTextStyle.button),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(orderProviderNotifier).fetchOrders(),
      color: CustomTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildOrderCard(orders[index]),
      ),
    );
  }

  Widget _buildOrderCard(OrderEntity order) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(order.createdAt);
    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: order.id),
          borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 8).toUpperCase()}',
                          style: CustomTextStyle.bodyMedium.copyWith(fontWeight: CustomTheme.fontWeightBold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: CustomTextStyle.caption.copyWith(color: CustomTheme.textTertiary),
                        ),
                      ],
                    ),
                    _buildStatusChip(order.status, statusColor),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, color: CustomTheme.borderLight),
                ),
                Row(
                  children: [
                    _buildItemsPreview(order),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order.items.length} ${order.items.length == 1 ? 'Item' : 'Items'}',
                            style: CustomTextStyle.bodySmall.copyWith(
                              fontWeight: CustomTheme.fontWeightSemiBold,
                              color: CustomTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Amount',
                            style: CustomTextStyle.caption.copyWith(color: CustomTheme.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '৳${order.totalAmount.toStringAsFixed(0)}',
                      style: CustomTextStyle.heading4.copyWith(
                        color: CustomTheme.primaryColor,
                        fontWeight: CustomTheme.fontWeightBold,
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

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: CustomTextStyle.caption.copyWith(
              color: color,
              fontWeight: CustomTheme.fontWeightBold,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsPreview(OrderEntity order) {
    if (order.items.isEmpty) return const SizedBox.shrink();
    
    final firstItemImage = order.items.first.product?.images.first.url;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: CustomTheme.backgroundColor,
        borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
        border: Border.all(color: CustomTheme.borderLight, width: 0.5),
      ),
      child: firstItemImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD - 1),
              child: Image.network(firstItemImage, fit: BoxFit.cover),
            )
          : const Icon(Icons.shopping_bag_outlined, color: CustomTheme.textTertiary, size: 24),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade700;
      case 'processing':
        return Colors.blue.shade700;
      case 'shipped':
        return Colors.purple.shade700;
      case 'delivered':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
