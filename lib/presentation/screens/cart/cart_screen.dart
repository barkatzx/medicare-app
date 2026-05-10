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
    return AppBar(
      elevation: 0,
      backgroundColor: CustomTheme.backgroundColor,
      scrolledUnderElevation: 0,
      leading: Container(
        margin: EdgeInsets.only(left: CustomTheme.spacingMD),
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: CustomTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
      ),
      title: Text('My Cart', style: CustomTextStyle.heading2),
      actions: [
        if (itemCount > 0)
          Container(
            margin: EdgeInsets.only(left: CustomTheme.spacingMD),
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: TextButton(
              onPressed: () {
                _showClearCartDialog(context, provider);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: CustomTheme.spacingSM,
                  vertical: CustomTheme.spacingSM,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: CustomTheme.errorColor,
                  ),
                  SizedBox(width: CustomTheme.spacingSM),
                  Text(
                    'Clear',
                    style: CustomTextStyle.bodySmall.copyWith(
                      color: CustomTheme.errorColor,
                      fontWeight: CustomTheme.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(
    CartProvider provider,
    List cartItems,
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
            onRefresh: () async {
              await provider.loadCart();
            },
            color: CustomTheme.primaryColor,
            backgroundColor: CustomTheme.surfaceColor,
            child: ListView.builder(
              padding: EdgeInsets.all(CustomTheme.spacingMD),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return _buildCartItem(item, index, provider);
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          SizedBox(height: CustomTheme.spacingLG),
          Text('Loading your cart...', style: CustomTextStyle.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(CustomTheme.spacingXXL),
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: CustomTheme.textTertiary,
            ),
          ),
          SizedBox(height: CustomTheme.spacingXL),
          Text(
            'Your cart is empty',
            style: CustomTextStyle.heading3.copyWith(
              color: CustomTheme.textSecondary,
            ),
          ),
          SizedBox(height: CustomTheme.spacingSM),
          Text(
            'Looks like you haven\'t added any items yet',
            style: CustomTextStyle.bodyMedium,
          ),
          SizedBox(height: CustomTheme.spacingXXL),
          Container(
            decoration: BoxDecoration(
              boxShadow: CustomTheme.boxShadowLight,
              borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: CustomTheme.spacingXXL,
                  vertical: CustomTheme.spacingMD,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
                ),
              ),
              child: Text('Start Shopping', style: CustomTextStyle.button),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemEntity item, int index, CartProvider provider) {
    return Container(
      margin: EdgeInsets.only(bottom: CustomTheme.spacingMD),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(CustomTheme.spacingMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: CustomTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                  child: item.productImage.isNotEmpty
                      ? Image.network(
                          item.productImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.medical_services,
                              size: 40,
                              color: CustomTheme.secondaryColor,
                            );
                          },
                        )
                      : Icon(
                          Icons.medical_services,
                          size: 40,
                          color: CustomTheme.secondaryColor,
                        ),
                ),
              ),
              SizedBox(width: CustomTheme.spacingMD),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: CustomTextStyle.bodyMedium.copyWith(
                        fontWeight: CustomTheme.fontWeightSemiBold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: CustomTheme.spacingXS),
                    Row(
                      children: [
                        Text(
                          '${item.finalPrice.toStringAsFixed(2)}৳',
                          style: CustomTextStyle.heading3.copyWith(
                            color: CustomTheme.primaryColor,
                          ),
                        ),
                        if (item.discountedPrice != null) ...[
                          SizedBox(width: CustomTheme.spacingSM),
                          Text(
                            '${item.price.toStringAsFixed(2)}৳',
                            style: CustomTextStyle.bodySmall.copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item.itemSavings > 0)
                      Container(
                        margin: EdgeInsets.only(top: CustomTheme.spacingXS),
                        padding: EdgeInsets.symmetric(
                          horizontal: CustomTheme.spacingXS,
                          vertical: CustomTheme.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: CustomTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            CustomTheme.radiusSM,
                          ),
                        ),
                        child: Text(
                          'Save ${item.itemSavings.toStringAsFixed(2)}৳',
                          style: TextStyle(
                            color: CustomTheme.errorColor,
                            fontSize: CustomTheme.fontSizeXS,
                            fontWeight: CustomTheme.fontWeightBold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Delete Icon at Top Right
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showRemoveItemDialog(
                        context,
                        provider,
                        item.id,
                        item.productName,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(CustomTheme.spacingSM),
                      decoration: BoxDecoration(
                        color: CustomTheme.secondaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: CustomTheme.errorColor,
                      ),
                    ),
                  ),
                  SizedBox(height: CustomTheme.spacingMD),

                  // Quantity Controls - Single Row
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: CustomTheme.spacingXS,
                      vertical: CustomTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: CustomTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(
                        CustomTheme.radiusRound,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Minus Button
                        GestureDetector(
                          onTap: () {
                            if (item.quantity > 1) {
                              provider.updateQuantity(
                                item.id,
                                item.quantity - 1,
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(CustomTheme.spacingSM),
                            decoration: BoxDecoration(
                              color: CustomTheme.surfaceColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: CustomTheme.textSecondary,
                            ),
                          ),
                        ),
                        // Quantity Number
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                            style: CustomTextStyle.bodyMedium.copyWith(
                              fontWeight: CustomTheme.fontWeightSemiBold,
                            ),
                          ),
                        ),
                        // Plus Button
                        GestureDetector(
                          onTap: () {
                            provider.updateQuantity(item.id, item.quantity + 1);
                          },
                          child: Container(
                            padding: EdgeInsets.all(CustomTheme.spacingSM),
                            decoration: BoxDecoration(
                              color: CustomTheme.surfaceColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: CustomTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildBottomBar(
    CartProvider provider,
    double subtotal,
    double total,
    double totalSavings,
  ) {
    final grandTotal = total;

    return Container(
      padding: EdgeInsets.all(CustomTheme.spacingLG),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(CustomTheme.radiusLG),
          topRight: Radius.circular(CustomTheme.radiusLG),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Subtotal Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: CustomTextStyle.bodyMedium),
              Text(
                '${subtotal.toStringAsFixed(2)}৳',
                style: CustomTextStyle.heading3.copyWith(
                  fontWeight: CustomTheme.fontWeightBold,
                ),
              ),
            ],
          ),
          SizedBox(height: CustomTheme.spacingSM),

          // Savings Row
          if (totalSavings > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Savings', style: CustomTextStyle.bodySmall),
                Text(
                  '-${totalSavings.toStringAsFixed(2)}৳',
                  style: CustomTextStyle.bodySmall.copyWith(
                    color: CustomTheme.successColor,
                    fontWeight: CustomTheme.fontWeightMedium,
                  ),
                ),
              ],
            ),

          // Shipping Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipping', style: CustomTextStyle.bodySmall),
              Text(
                'Free',
                style: CustomTextStyle.bodySmall.copyWith(
                  color: CustomTheme.successColor,
                  fontWeight: CustomTheme.fontWeightMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: CustomTheme.spacingSM),

          Divider(
            height: CustomTheme.spacingLG,
            color: CustomTheme.borderLight,
          ),

          // Total Row - FIXED: Added the total amount display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: CustomTextStyle.heading3.copyWith(
                  fontWeight: CustomTheme.fontWeightBold,
                ),
              ),
              Text(
                '${grandTotal.toStringAsFixed(2)}৳',
                style: CustomTextStyle.heading2.copyWith(
                  color: CustomTheme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: CustomTheme.spacingLG),

          // Checkout Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: CustomTheme.boxShadowLight,
              borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/checkout');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryColor,
                padding: EdgeInsets.symmetric(vertical: CustomTheme.spacingMD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
                ),
              ),
              child: Text('Proceed to Checkout', style: CustomTextStyle.button),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
        ),
        title: Text('Clear Cart', style: CustomTextStyle.heading3),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: CustomTextStyle.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: CustomTextStyle.bodyMedium.copyWith(
                color: CustomTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.clearCart();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cart cleared successfully'),
                    backgroundColor: CustomTheme.successColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              'Clear',
              style: CustomTextStyle.bodyMedium.copyWith(
                color: CustomTheme.errorColor,
                fontWeight: CustomTheme.fontWeightBold,
              ),
            ),
          ),
        ],
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
        ),
        title: Text('Remove Item', style: CustomTextStyle.heading3),
        content: Text(
          'Remove "$productName" from your cart?',
          style: CustomTextStyle.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: CustomTextStyle.bodyMedium.copyWith(
                color: CustomTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.removeFromCart(itemId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Item removed from cart'),
                    backgroundColor: CustomTheme.successColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              'Remove',
              style: CustomTextStyle.bodyMedium.copyWith(
                color: CustomTheme.errorColor,
                fontWeight: CustomTheme.fontWeightBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
