import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/features/entity/cart_entity.dart';
import 'package:medicare_app/features/provider/cart_provider.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';
import 'package:medicare_app/core/routes/app_routes.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartProviderNotifier).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(cartProviderNotifier);
    final cartItems = provider.cartItems;
    final isLoading = provider.isLoading;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: _buildAppBar(provider, provider.cartItemCount),
      body: _buildBody(provider, cartItems, isLoading),
    );
  }

  PreferredSizeWidget _buildAppBar(CartProvider provider, int itemCount) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: CustomTheme.backgroundColor,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Bag Products ',
              style: CustomTextStyle.heading2.copyWith(
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              ' ($itemCount)',
              style: CustomTextStyle.heading2.copyWith(
                fontSize: 16,
                letterSpacing: -0.3,
                color: CustomTheme.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          if (itemCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: GestureDetector(
                  onTap: () => _showClearCartDialog(
                    context,
                    ref.read(cartProviderNotifier),
                  ),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: CustomTheme.errorColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.delete_sweep_outlined,
                      color: CustomTheme.errorColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    CartProvider provider,
    List<CartItemEntity> cartItems,
    bool isLoading,
  ) {
    if (isLoading && cartItems.isEmpty) return _buildLoadingState();
    if (cartItems.isEmpty) return _buildEmptyState();

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => provider.loadCart(),
            color: CustomTheme.primaryColor,
            backgroundColor: CustomTheme.surfaceColor,
            strokeWidth: 2,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return _buildCartItem(cartItems[index], provider);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 68),
          child: _buildBottomBar(provider),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: CustomTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your cart…',
            style: CustomTextStyle.bodySmall.copyWith(
              color: CustomTheme.textTertiary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: CustomTheme.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 46,
                color: CustomTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: CustomTextStyle.heading3.copyWith(letterSpacing: -0.3),
            ),
            const SizedBox(height: 8),
            Text(
              "You haven't added any items yet.\nStart exploring our products!",
              textAlign: TextAlign.center,
              style: CustomTextStyle.bodyMedium.copyWith(
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                ref.read(navigationProvider).setIndex(0);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Explore Products',
                  style: CustomTextStyle.button.copyWith(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItemEntity item, CartProvider provider) {
    final hasSavings = item.price > item.finalPrice;
    final savings = item.price - item.finalPrice;
    final discountPercent = item.product.discountPercent > 0
        ? item.product.discountPercent
        : (item.price > 0
              ? ((item.price - item.finalPrice) / item.price * 100).round()
              : 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Product Image ──
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: CustomTheme.backgroundColor,
                    border: Border.all(
                      color: CustomTheme.borderLight,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: item.productImage.isNotEmpty
                        ? Image.network(
                            item.productImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.medical_services_outlined,
                              color: CustomTheme.textTertiary,
                              size: 24,
                            ),
                          )
                        : const Icon(
                            Icons.medical_services_outlined,
                            color: CustomTheme.textTertiary,
                            size: 24,
                          ),
                  ),
                ),
                if (hasSavings && discountPercent > 0)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: CustomTheme.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                      child: Text(
                        '-$discountPercent%',
                        style: const TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),

            // ── Details ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + delete
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.productName,
                          style: CustomTextStyle.bodyMedium.copyWith(
                            fontWeight: CustomTheme.fontWeightSemiBold,
                            color: CustomTheme.textPrimary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _showRemoveItemDialog(
                          context,
                          provider,
                          item.id,
                          item.productName,
                        ),
                        child: Container(
                          width: 20,
                          decoration: BoxDecoration(
                            color: CustomTheme.errorColor.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: CustomTheme.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${item.finalPrice.toStringAsFixed(0)} ৳',
                        style: TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 15,
                          fontWeight: CustomTheme.fontWeightBold,
                          color: CustomTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (hasSavings) ...[
                        const SizedBox(width: 5),
                        Text(
                          '${item.price.toStringAsFixed(0)} ৳',
                          style: CustomTextStyle.caption.copyWith(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                            color: CustomTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 0,
                          ),
                          decoration: BoxDecoration(
                            color: CustomTheme.successColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Save ${savings.toStringAsFixed(0)} ৳',
                            style: const TextStyle(
                              fontFamily: CustomTheme.primaryFontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Quantity selector
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: CustomTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: CustomTheme.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildQtyButton(
                              icon: Icons.remove_rounded,
                              onTap: () {
                                if (item.quantity > 1) {
                                  provider.updateQuantity(
                                    item.id,
                                    item.quantity - 1,
                                  );
                                }
                              },
                              enabled: item.quantity > 1,
                              filled: false,
                            ),
                            SizedBox(
                              width: 35,
                              child: Text(
                                '${item.quantity}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: CustomTheme.primaryFontFamily,
                                  fontSize: 15,
                                  fontWeight: CustomTheme.fontWeightBold,
                                  color: CustomTheme.textPrimary,
                                ),
                              ),
                            ),
                            _buildQtyButton(
                              icon: Icons.add_rounded,
                              onTap: () => provider.updateQuantity(
                                item.id,
                                item.quantity + 1,
                              ),
                              enabled: true,
                              filled: true,
                            ),
                          ],
                        ),
                      ),

                      // Item subtotal
                      Text(
                        '${item.itemTotal.toStringAsFixed(0)}৳',
                        style: TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 16,
                          fontWeight: CustomTheme.fontWeightSemiBold,
                          color: CustomTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
    required bool filled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: filled ? CustomTheme.primaryColor : CustomTheme.surfaceColor,
          shape: BoxShape.circle,
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: CustomTheme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? (filled ? Colors.white : CustomTheme.textPrimary)
              : CustomTheme.textTertiary,
        ),
      ),
    );
  }

  Widget _buildBottomBar(CartProvider provider) {
    final subtotal = provider.subtotal;
    final totalSavings = provider.totalSavings;
    final total = provider.total;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: CustomTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Price breakdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: CustomTheme.backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _buildPriceRow(
                  'Subtotal',
                  '৳${subtotal.toStringAsFixed(0)}',
                  valueColor: CustomTheme.textPrimary,
                ),
                if (totalSavings > 0) ...[
                  const SizedBox(height: 4),
                  _buildPriceRow(
                    'Your savings',
                    '-৳${totalSavings.toStringAsFixed(0)}',
                    valueColor: CustomTheme.successColor,
                    isBold: true,
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Divider(height: 1, color: CustomTheme.borderLight),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Payable',
                      style: TextStyle(
                        fontFamily: CustomTheme.primaryFontFamily,
                        fontSize: 14,
                        fontWeight: CustomTheme.fontWeightSemiBold,
                        color: CustomTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '৳${total.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontFamily: CustomTheme.primaryFontFamily,
                        fontSize: 19,
                        fontWeight: CustomTheme.fontWeightBold,
                        color: CustomTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Checkout button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed to Checkout',
                    style: CustomTextStyle.button.copyWith(
                      fontSize: 15,
                      fontWeight: CustomTheme.fontWeightBold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    required Color valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: CustomTextStyle.bodyMedium.copyWith(
            fontSize: 15,
            color: CustomTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: CustomTheme.primaryFontFamily,
            fontSize: 15,
            fontWeight: isBold
                ? CustomTheme.fontWeightSemiBold
                : CustomTheme.fontWeightMedium,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider provider) {
    showDialog(
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
                'Clear Cart',
                style: CustomTextStyle.heading3.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to remove all items from your cart?',
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                      onTap: () async {
                        Navigator.pop(context);
                        await provider.clearCart();
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: CustomTheme.errorColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Clear All',
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
  }

  void _showRemoveItemDialog(
    BuildContext context,
    CartProvider provider,
    String itemId,
    String productName,
  ) {
    showDialog(
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
                  Icons.remove_shopping_cart_outlined,
                  color: CustomTheme.errorColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Remove Item',
                style: CustomTextStyle.heading3.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Remove "$productName" from your cart?',
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: CustomTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Keep It',
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
                      onTap: () async {
                        Navigator.pop(context);
                        await provider.removeFromCart(itemId);
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: CustomTheme.errorColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Remove',
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
  }
}
