import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/domain/entities/order_entity.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:medicare_app/presentation/widgets/common/loading_widget.dart';

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
      appBar: AppBar(
        title: Text('Order Details', style: CustomTextStyle.heading3),
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
      body: _buildBody(isLoading, order, error),
    );
  }

  Widget _buildBody(bool isLoading, OrderEntity? order, String? error) {
    if (isLoading) return const LoadingWidget();
    
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: CustomTheme.errorColor),
              const SizedBox(height: 24),
              Text('Oops!', style: CustomTextStyle.heading2),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(color: CustomTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_orderId != null) {
                      ref.read(orderProviderNotifier).fetchOrderDetail(_orderId!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusRound)),
                    elevation: 0,
                  ),
                  child: Text('Retry Connection', style: CustomTextStyle.button),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (order == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: CustomTheme.textTertiary),
            const SizedBox(height: 16),
            Text('Order not found', style: CustomTextStyle.heading3),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(order),
          const SizedBox(height: 20),
          _buildSectionTitle('Order Items'),
          _buildItemsList(order),
          const SizedBox(height: 20),
          _buildSectionTitle('Shipping & Payment'),
          _buildInfoSection(order),
          const SizedBox(height: 20),
          _buildSectionTitle('Order Summary'),
          _buildOrderSummary(order),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom:10),
      child: Text(
        title.toUpperCase(),
        style: CustomTextStyle.caption.copyWith(
          color: CustomTheme.textTertiary,
          fontWeight: CustomTheme.fontWeightBold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildOrderHeader(OrderEntity order) {
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt);
    final statusColor = _getStatusColor(order.status);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER ID',
                    style: CustomTextStyle.caption.copyWith(
                      color: CustomTheme.textTertiary,
                      letterSpacing: 1.0,
                      fontSize: 9,
                      fontWeight: CustomTheme.fontWeightBold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${order.id.toUpperCase()}',
                    style: CustomTextStyle.bodyMedium.copyWith(fontWeight: CustomTheme.fontWeightBold),
                  ),
                ],
              ),
              _buildStatusChip(order.status, statusColor),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: CustomTheme.borderLight),
          ),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: CustomTheme.textTertiary),
              const SizedBox(width: 8),
              Text(
                formattedDate,
                style: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: CustomTextStyle.caption.copyWith(
              color: color,
              fontWeight: CustomTheme.fontWeightBold,
              fontSize: 9,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(OrderEntity order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: order.items.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: CustomTheme.borderLight),
        itemBuilder: (context, index) {
          final item = order.items[index];
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: CustomTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
                    border: Border.all(color: CustomTheme.borderLight, width: 0.5),
                  ),
                  child: item.product?.images.isNotEmpty == true
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(CustomTheme.radiusSM - 1),
                          child: Image.network(item.product!.images.first.url, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.shopping_bag_outlined, color: CustomTheme.textTertiary, size: 20),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product?.name ?? 'Unknown Product',
                        style: CustomTextStyle.bodySmall.copyWith(fontWeight: CustomTheme.fontWeightBold, color: CustomTheme.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: ${item.quantity}',
                        style: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.textTertiary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '৳${item.price.toStringAsFixed(0)}',
                  style: CustomTextStyle.bodySmall.copyWith(
                    fontWeight: CustomTheme.fontWeightBold,
                    color: CustomTheme.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(OrderEntity order) {
    final addr = order.shippingAddress;
    final pay = order.payment;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
      ),
      child: Column(
        children: [
          if (addr != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_rounded, size: 18, color: CustomTheme.primaryColor.withOpacity(0.5)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          addr.street,
                          style: CustomTextStyle.bodySmall.copyWith(fontWeight: CustomTheme.fontWeightSemiBold, color: CustomTheme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${addr.city}, ${addr.state} ${addr.postalCode}',
                          style: CustomTextStyle.caption.copyWith(color: CustomTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (addr != null && pay != null) const Divider(height: 1, color: CustomTheme.borderLight),
          if (pay != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        pay.method.toLowerCase() == 'cod' ? Icons.payments_rounded : Icons.credit_card_rounded,
                        size: 18,
                        color: CustomTheme.primaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        pay.method.toUpperCase(),
                        style: CustomTextStyle.bodySmall.copyWith(fontWeight: CustomTheme.fontWeightSemiBold, color: CustomTheme.textPrimary),
                      ),
                    ],
                  ),
                  _buildStatusChip(pay.status, _getStatusColor(pay.status)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', '৳${order.totalAmount.toStringAsFixed(0)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: CustomTheme.borderLight),
          ),
          _buildSummaryRow(
            'Grand Total',
            '৳${order.totalAmount.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal 
              ? CustomTextStyle.bodyLarge.copyWith(fontWeight: CustomTheme.fontWeightBold, color: CustomTheme.textPrimary)
              : CustomTextStyle.bodySmall.copyWith(color: CustomTheme.textSecondary),
        ),
        Text(
          value,
          style: isTotal 
              ? CustomTextStyle.heading4.copyWith(color: CustomTheme.primaryColor, fontWeight: CustomTheme.fontWeightBold)
              : CustomTextStyle.bodySmall.copyWith(fontWeight: CustomTheme.fontWeightBold, color: CustomTheme.textPrimary),
        ),
      ],
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
        return CustomTheme.successColor;
      case 'cancelled':
        return CustomTheme.errorColor;
      default:
        return CustomTheme.textTertiary;
    }
  }
}
