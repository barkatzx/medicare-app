import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/domain/entities/cart_entity.dart';
import 'package:medicare_app/domain/entities/category_entity.dart';
import 'package:medicare_app/presentation/providers/cart_provider.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:medicare_app/routes/app_routes.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>
    with TickerProviderStateMixin {
  AnimationController? _listAnimController;

  @override
  void initState() {
    super.initState();
    _listAnimController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(cartProviderNotifier).loadCart();
      final categoryProv = ref.read(categoryProviderNotifier);
      if (categoryProv.categories.isEmpty) {
        print('CartScreen DEBUG: Fetching categories...');
        await categoryProv.fetchCategories();
        print('CartScreen DEBUG: Fetching categories complete. Error: ${categoryProv.errorMessage}. Count: ${categoryProv.categories.length}');
      } else {
        print('CartScreen DEBUG: Categories already loaded. Count: ${categoryProv.categories.length}');
      }
    });
  }

  @override
  void dispose() {
    _listAnimController?.dispose();
    super.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Shopping Bag',
              style: CustomTextStyle.heading2.copyWith(
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
            if (itemCount > 0)
              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                style: CustomTextStyle.caption.copyWith(
                  fontSize: 12,
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
                      context, ref.read(cartProviderNotifier)),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: CustomTheme.errorColor.withOpacity(0.08),
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
                final item = cartItems[index];
                final delay = index * 60;
                return AnimatedBuilder(
                  animation: _listAnimController ??
                      const AlwaysStoppedAnimation(1.0),
                  builder: (context, child) {
                    final anim = _listAnimController;
                    final progress = anim == null
                        ? 1.0
                        : CurvedAnimation(
                            parent: anim,
                            curve: Interval(
                              (delay / 500).clamp(0.0, 1.0),
                              ((delay + 300) / 500).clamp(0.0, 1.0),
                              curve: Curves.easeOut,
                            ),
                          ).value;
                    return Opacity(
                      opacity: progress,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - progress)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildCartItem(item, provider),
                );
              },
            ),
          ),
        ),
        _buildBottomBar(provider),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
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
              style: CustomTextStyle.heading3.copyWith(
                letterSpacing: -0.3,
              ),
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
                    context, AppRoutes.home, (route) => false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: CustomTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
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

    String? resolvedCategoryName;

    // 1. Try finding in loaded products first (highly reliable since they are loaded on Home screen)
    final products = ref.watch(productProviderNotifier).products;
    for (final prod in products) {
      if (prod.id == item.product.id && prod.categoryName.isNotEmpty && prod.categoryName != 'Uncategorized') {
        resolvedCategoryName = prod.categoryName;
        break;
      }
    }

    // 2. Try finding in categories list
    if (resolvedCategoryName == null) {
      final categories = ref.watch(categoryProviderNotifier).categories;
      for (final cat in categories) {
        if (cat.id == item.product.categoryId && cat.name.isNotEmpty) {
          resolvedCategoryName = cat.name;
          break;
        }
      }
    }

    final categoryNameText = resolvedCategoryName ?? 
        (item.categoryName.isEmpty || item.categoryName == 'Uncategorized' ? 'Uncategorized' : item.categoryName);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product Image ──
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: CustomTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: item.productImage.isNotEmpty
                        ? Image.network(
                            item.productImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
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
                if (hasSavings)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: const BoxDecoration(
                        color: CustomTheme.successColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                      child: Text(
                        '-৳${savings.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 8,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryNameText,
                              style: CustomTextStyle.caption.copyWith(
                                color: CustomTheme.primaryColor.withOpacity(0.5),
                                fontWeight: CustomTheme.fontWeightBold,
                                letterSpacing: 0.5,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.productName,
                              style: CustomTextStyle.bodyMedium.copyWith(
                                fontWeight: CustomTheme.fontWeightSemiBold,
                                color: CustomTheme.textPrimary,
                                fontSize: 12,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: CustomTheme.errorColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 13,
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
                        '৳${item.finalPrice.toStringAsFixed(0)}',
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
                          '৳${item.price.toStringAsFixed(0)}',
                          style: CustomTextStyle.caption.copyWith(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 10,
                            color: CustomTheme.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Quantity selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: CustomTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildQtyButton(
                              icon: Icons.remove_rounded,
                              onTap: () {
                                if (item.quantity > 1) {
                                  provider.updateQuantity(
                                      item.id, item.quantity - 1);
                                }
                              },
                              enabled: item.quantity > 1,
                            ),
                            SizedBox(
                              width: 24,
                              child: Text(
                                '${item.quantity}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: CustomTheme.primaryFontFamily,
                                  fontSize: 12,
                                  fontWeight: CustomTheme.fontWeightBold,
                                  color: CustomTheme.textPrimary,
                                ),
                              ),
                            ),
                            _buildQtyButton(
                              icon: Icons.add_rounded,
                              onTap: () => provider.updateQuantity(
                                  item.id, item.quantity + 1),
                              enabled: true,
                            ),
                          ],
                        ),
                      ),

                      // Item subtotal
                      Text(
                        '৳${item.itemTotal.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 12,
                          fontWeight: CustomTheme.fontWeightSemiBold,
                          color: CustomTheme.textSecondary,
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
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: enabled ? CustomTheme.surfaceColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 14,
          color: enabled ? CustomTheme.textPrimary : CustomTheme.textTertiary,
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
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: CustomTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Price breakdown
          Container(
            padding: const EdgeInsets.all(14),
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
                  const SizedBox(height: 8),
                  _buildPriceRow(
                    'You save',
                    '-৳${totalSavings.toStringAsFixed(0)}',
                    valueColor: CustomTheme.successColor,
                    isBold: true,
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
                        fontSize: 22,
                        fontWeight: CustomTheme.fontWeightBold,
                        color: CustomTheme.primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Checkout button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
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
            fontSize: 13,
            color: CustomTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: CustomTheme.primaryFontFamily,
            fontSize: 13,
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
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
                  color: CustomTheme.errorColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_sweep_outlined,
                    color: CustomTheme.errorColor, size: 26),
              ),
              const SizedBox(height: 16),
              Text('Clear Cart',
                  style: CustomTextStyle.heading3.copyWith(fontSize: 17)),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to remove all items from your cart?',
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(fontSize: 13),
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
                          child: Text('Cancel',
                              style: CustomTextStyle.bodyMedium.copyWith(
                                  color: CustomTheme.textSecondary,
                                  fontWeight: CustomTheme.fontWeightMedium,
                                  fontSize: 14)),
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
                          child: Text('Clear All',
                              style: CustomTextStyle.button.copyWith(
                                  fontSize: 14)),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
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
                  color: CustomTheme.errorColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove_shopping_cart_outlined,
                    color: CustomTheme.errorColor, size: 24),
              ),
              const SizedBox(height: 16),
              Text('Remove Item',
                  style: CustomTextStyle.heading3.copyWith(fontSize: 17)),
              const SizedBox(height: 8),
              Text(
                'Remove "$productName" from your cart?',
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(fontSize: 13),
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
                          child: Text('Keep It',
                              style: CustomTextStyle.bodyMedium.copyWith(
                                  color: CustomTheme.textSecondary,
                                  fontWeight: CustomTheme.fontWeightMedium,
                                  fontSize: 14)),
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
                          child: Text('Remove',
                              style: CustomTextStyle.button
                                  .copyWith(fontSize: 14)),
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