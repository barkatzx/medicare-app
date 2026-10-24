import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/domain/entities/order_entity.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';

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
      elevation: 0,
      backgroundColor: CustomTheme.backgroundColor,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: CustomTheme.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: CustomTheme.textPrimary,
                size: 15,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        'Order Details',
        style: CustomTextStyle.heading2.copyWith(fontSize: 19),
      ),
    );
  }

  Widget _buildBody(bool isLoading, OrderEntity? order, String? error) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: CustomTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Loading order details…',
              style: CustomTextStyle.bodySmall.copyWith(
                fontSize: 13,
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
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: CustomTheme.errorColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 36,
                  color: CustomTheme.errorColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Unable to Load Order',
                style: CustomTextStyle.heading3.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  if (_orderId != null) {
                    ref.read(orderProviderNotifier).fetchOrderDetail(_orderId!);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: CustomTheme.primaryColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    'Try Again',
                    style: CustomTextStyle.button.copyWith(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (order == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: CustomTheme.surfaceColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 36,
                  color: CustomTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Order Not Found',
                style: CustomTextStyle.heading3.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 8),
              Text(
                'This order could not be found.\nPlease go back and try again.',
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: CustomTheme.primaryColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    'Go Back',
                    style: CustomTextStyle.button.copyWith(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(order),
          const SizedBox(height: 20),
          _buildSectionTitle('Order Items'),
          const SizedBox(height: 10),
          _buildItemsList(order),
          const SizedBox(height: 20),
          _buildSectionTitle('Shipping & Payment'),
          const SizedBox(height: 10),
          _buildInfoSection(order),
          const SizedBox(height: 20),
          _buildSectionTitle('Order Summary'),
          const SizedBox(height: 10),
          _buildOrderSummary(order),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: CustomTheme.primaryFontFamily,
          fontSize: 11,
          fontWeight: CustomTheme.fontWeightBold,
          color: CustomTheme.textTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildOrderHeader(OrderEntity order) {
    final formattedDate = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(order.createdAt);
    final statusColor = _getStatusColor(order.status);
    final statusLabel = _getStatusLabel(order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER ID',
                      style: TextStyle(
                        fontFamily: CustomTheme.primaryFontFamily,
                        fontSize: 9,
                        fontWeight: CustomTheme.fontWeightBold,
                        color: CustomTheme.textTertiary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${order.id.substring(0, 12).toUpperCase()}',
                      style: CustomTextStyle.heading4.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(statusLabel, statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: CustomTheme.borderLight),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: CustomTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                formattedDate,
                style: CustomTextStyle.bodySmall.copyWith(
                  color: CustomTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
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
            status,
            style: TextStyle(
              fontFamily: CustomTheme.primaryFontFamily,
              fontSize: 10,
              fontWeight: CustomTheme.fontWeightSemiBold,
              color: color,
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
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: order.items.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: CustomTheme.borderLight,
          indent: 68,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final item = order.items[index];
          return Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: CustomTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: item.product?.images.isNotEmpty == true
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.network(
                            item.product!.images.first.url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.medical_services,
                              size: 22,
                              color: CustomTheme.textTertiary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.medical_services,
                          size: 22,
                          color: CustomTheme.textTertiary,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: CustomTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'x${item.quantity}',
                              style: TextStyle(
                                fontFamily: CustomTheme.primaryFontFamily,
                                fontSize: 11,
                                fontWeight: CustomTheme.fontWeightSemiBold,
                                color: CustomTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '৳${item.price.toStringAsFixed(0)} each',
                            style: CustomTextStyle.caption.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '৳${(item.price * item.quantity).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: CustomTheme.primaryFontFamily,
                    fontSize: 13,
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
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (addr != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CustomTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: CustomTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shipping Address',
                          style: TextStyle(
                            fontFamily: CustomTheme.primaryFontFamily,
                            fontSize: 10,
                            fontWeight: CustomTheme.fontWeightSemiBold,
                            color: CustomTheme.textTertiary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          addr.street,
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
                          '${addr.city}, ${addr.state} ${addr.postalCode}',
                          style: CustomTextStyle.caption.copyWith(fontSize: 11),
                        ),
                        Text(
                          addr.country,
                          style: CustomTextStyle.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (addr != null && pay != null)
            Divider(
              height: 1,
              color: CustomTheme.borderLight,
              indent: 16,
              endIndent: 16,
            ),
          if (pay != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CustomTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      pay.method.toLowerCase() == 'cod'
                          ? Icons.payments_outlined
                          : Icons.credit_card_outlined,
                      size: 20,
                      color: CustomTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Method',
                          style: TextStyle(
                            fontFamily: CustomTheme.primaryFontFamily,
                            fontSize: 10,
                            fontWeight: CustomTheme.fontWeightSemiBold,
                            color: CustomTheme.textTertiary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pay.method == 'cod' ? 'Cash on Delivery' : pay.method,
                          style: CustomTextStyle.bodyMedium.copyWith(
                            fontWeight: CustomTheme.fontWeightSemiBold,
                            color: CustomTheme.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(
                    _getStatusLabel(pay.status),
                    _getStatusColor(pay.status),
                  ),
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
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Subtotal',
            '৳${order.totalAmount.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: CustomTheme.borderLight),
          const SizedBox(height: 10),
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
              ? TextStyle(
                  fontFamily: CustomTheme.primaryFontFamily,
                  fontSize: 14,
                  fontWeight: CustomTheme.fontWeightSemiBold,
                  color: CustomTheme.textPrimary,
                )
              : CustomTextStyle.bodySmall.copyWith(
                  color: CustomTheme.textSecondary,
                  fontSize: 12,
                ),
        ),
        Text(
          value,
          style: isTotal
              ? TextStyle(
                  fontFamily: CustomTheme.primaryFontFamily,
                  fontSize: 18,
                  fontWeight: CustomTheme.fontWeightBold,
                  color: CustomTheme.primaryColor,
                  letterSpacing: -0.3,
                )
              : CustomTextStyle.bodySmall.copyWith(
                  fontWeight: CustomTheme.fontWeightSemiBold,
                  color: CustomTheme.textPrimary,
                  fontSize: 12,
                ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B); // Amber
      case 'processing':
        return const Color(0xFF3B82F6); // Blue
      case 'shipped':
        return const Color(0xFF8B5CF6); // Purple
      case 'delivered':
        return CustomTheme.successColor; // Green
      case 'cancelled':
        return CustomTheme.errorColor; // Red
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
