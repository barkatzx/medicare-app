import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/domain/entities/cart_entity.dart';
import 'package:medicare_app/presentation/providers/cart_provider.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';

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
    final subtotal = provider.subtotal;
    final total = provider.total;
    final totalSavings = provider.totalSavings;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: _buildAppBar(provider, cartItems.length),
      body: _buildBody(
        provider,
        cartItems,
        isLoading,
        subtotal,
        total,
        totalSavings,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(CartProvider provider, int itemCount) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: CustomTheme.backgroundColor,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Text(
          'My Shopping Bag',
          style: CustomTextStyle.heading3.copyWith(
            fontWeight: CustomTheme.fontWeightBold,
            color: CustomTheme.textPrimary,
          ),
        ),
        actions: [
          if (itemCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Center(
                child: GestureDetector(
                  onTap: () => _showClearCartDialog(context, provider),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CustomTheme.errorColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
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
    double subtotal,
    double total,
    double totalSavings,
  ) {
    if (isLoading && cartItems.isEmpty) {
      return _buildLoadingState();
    }

    if (cartItems.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => await provider.loadCart(),
            color: CustomTheme.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return _buildCartItem(cartItems[index], provider);
              },
            ),
          ),
        ),
        _buildBottomBar(provider, subtotal, total, totalSavings),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your cart...',
            style: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.textTertiary),
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
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: CustomTheme.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_cart_outlined, size: 64, color: CustomTheme.primaryColor.withOpacity(0.3)),
            ),
            const SizedBox(height: 32),
            Text('Your cart is empty', style: CustomTextStyle.heading2),
            const SizedBox(height: 12),
            Text(
              'Looks like you haven\'t added any items to your cart yet.',
              textAlign: TextAlign.center,
              style: CustomTextStyle.bodyMedium.copyWith(color: CustomTheme.textSecondary),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusRound)),
                ),
                child: Text('Explore Products', style: CustomTextStyle.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItemEntity item, CartProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: CustomTheme.spacingSM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: CustomTheme.backgroundColor,
                borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                child: item.productImage.isNotEmpty
                    ? Image.network(item.productImage, fit: BoxFit.cover)
                    : const Icon(Icons.medical_services_outlined, color: CustomTheme.textTertiary),
              ),
            ),
            const SizedBox(width: 20),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: CustomTextStyle.bodyMedium.copyWith(fontWeight: CustomTheme.fontWeightSemiBold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '৳${item.finalPrice.toStringAsFixed(0)}',
                        style: CustomTextStyle.heading4.copyWith(color: CustomTheme.primaryColor),
                      ),
                      if (item.discountedPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '৳${item.price.toStringAsFixed(0)}',
                          style: CustomTextStyle.caption.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: CustomTheme.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Small Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: CustomTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
                        ),
                        child: Row(
                          children: [
                            _buildSmallQtyBtn(Icons.remove, () {
                              if (item.quantity > 1) provider.updateQuantity(item.id, item.quantity - 1);
                            }),
                            SizedBox(
                              width: 24,
                              child: Text(
                                '${item.quantity}',
                                textAlign: TextAlign.center,
                                style: CustomTextStyle.bodySmall.copyWith(
                                  fontWeight: CustomTheme.fontWeightBold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            _buildSmallQtyBtn(Icons.add, () => provider.updateQuantity(item.id, item.quantity + 1)),
                          ],
                        ),
                      ),
                      Container(
  padding: const EdgeInsets.all(6),
  decoration: BoxDecoration(
    color: CustomTheme.errorColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
  ),
  child: IconButton(
    onPressed: () => _showRemoveItemDialog(
      context,
      provider,
      item.id,
      item.productName,
    ),
    icon: const Icon(
      Icons.delete_outline_rounded,
      color: CustomTheme.errorColor,
      size: 16,
    ),
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(),
    splashRadius: 20,
  ),
)
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

  Widget _buildSmallQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: CustomTheme.textPrimary),
      ),
    );
  }

  Widget _buildBottomBar(CartProvider provider, double subtotal, double total, double totalSavings) {
    // Math adjustment now handled by provider:
    // subtotal = Regular Price (sum of original prices)
    // totalSavings = Total Discount
    // total = Final Payable amount
    final regularPrice = subtotal;
    final discount = totalSavings;
    final finalTotal = total;

    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPriceRow('Subtotal', '৳${regularPrice.toStringAsFixed(0)}'),
          if (discount > 0)
            _buildPriceRow('Discount', '-৳${discount.toStringAsFixed(0)}', isDiscount: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: CustomTheme.borderLight),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Payable', style: CustomTextStyle.heading4),
              Text(
                '৳${finalTotal.toStringAsFixed(0)}',
                style: CustomTextStyle.heading2.copyWith(color: CustomTheme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusRound)),
                elevation: 0,
              ),
              child: Text('Checkout Now', style: CustomTextStyle.button),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false, bool isFree = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: CustomTextStyle.bodyMedium.copyWith(color: CustomTheme.textSecondary)),
          Text(
            value,
            style: CustomTextStyle.bodyMedium.copyWith(
              color: isDiscount || isFree ? CustomTheme.successColor : CustomTheme.textPrimary,
              fontWeight: isDiscount || isFree ? CustomTheme.fontWeightBold : CustomTheme.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusLG)),
        title: Text('Clear Cart', style: CustomTextStyle.heading3),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: CustomTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.clearCart();
            },
            child: const Text('Clear All', style: TextStyle(color: CustomTheme.errorColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRemoveItemDialog(BuildContext context, CartProvider provider, String itemId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusLG)),
        title: Text('Remove Item', style: CustomTextStyle.heading3),
        content: Text('Remove "$productName" from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: CustomTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.removeFromCart(itemId);
            },
            child: const Text('Remove', style: TextStyle(color: CustomTheme.errorColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
