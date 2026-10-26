import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';
import 'package:medicare_app/features/entity/product_entity.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productId = ModalRoute.of(context)?.settings.arguments as String?;
      if (productId != null) {
        ref.read(productProviderNotifier).loadProductDetail(productId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = ref.watch(productProviderNotifier);
    final product = productProvider.selectedProduct;
    final isLoading = productProvider.isLoading;

    if (isLoading) {
      return Scaffold(
        backgroundColor: CustomTheme.backgroundColor,
        appBar: _buildSimpleAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: CustomTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading product…',
                style: CustomTextStyle.bodySmall.copyWith(
                  fontSize: 12,
                  color: CustomTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (product == null) return _buildNotFound();

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: _buildSimpleAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Compact header: image left, info right ──
                _buildCompactHeader(product),
                const SizedBox(height: 12),

                // ── Trust badges ──
                _buildHighlightsStrip(),
                const SizedBox(height: 10),

                // ── Description ──
                _buildDescription(product),
                const SizedBox(height: 10),

                // ── Quantity ──
                _buildQuantitySection(product),
                const SizedBox(height: 130),
              ],
            ),
          ),
          _buildBottomAction(product),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Simple app bar
  // ─────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildSimpleAppBar() {
    return AppBar(
      toolbarHeight: 52,
      elevation: 0,
      backgroundColor: CustomTheme.backgroundColor,
      scrolledUnderElevation: 0.5,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: _buildCircleIconButton(
            Icons.arrow_back_ios_new_rounded,
            () => Navigator.pop(context),
          ),
        ),
      ),
      title: Text(
        'Product Details',
        style: TextStyle(
          fontFamily: CustomTheme.primaryFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: CustomTheme.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            child: _buildCircleIconButton(Icons.share_outlined, () {}),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: CustomTheme.textPrimary, size: 13),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // COMPACT HEADER: image left | category/name/price right
  // ─────────────────────────────────────────────────────────────
  Widget _buildCompactHeader(ProductEntity product) {
    final hasDiscount = product.discountPercent > 0;
    final isInStock = product.stock > 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── LEFT: Image carousel ──
          _buildImageBox(product),

          const SizedBox(width: 10),

          // ── RIGHT: category / name / price ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category + stock row
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: CustomTheme.primaryColor.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.categoryName.toUpperCase(),
                          style: TextStyle(
                            fontFamily: CustomTheme.primaryFontFamily,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: CustomTheme.primaryColor,
                            letterSpacing: 0.6,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isInStock
                            ? CustomTheme.successColor
                            : CustomTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      isInStock ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                        fontFamily: CustomTheme.primaryFontFamily,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: isInStock
                            ? CustomTheme.successColor
                            : CustomTheme.errorColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Product name
                Text(
                  product.name,
                  style: TextStyle(
                    fontFamily: CustomTheme.primaryFontFamily,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: CustomTheme.textPrimary,
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Price row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '৳${product.finalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontFamily: CustomTheme.primaryFontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: CustomTheme.primaryColor,
                        letterSpacing: -0.5,
                        height: 1,
                      ),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text(
                        '৳${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: CustomTheme.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CustomTheme.errorColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: TextStyle(
                            fontFamily: CustomTheme.primaryFontFamily,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                if (hasDiscount) ...[
                  const SizedBox(height: 3),
                  Text(
                    'You save ৳${product.savings.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontFamily: CustomTheme.secondaryFontFamily,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: CustomTheme.successColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Image box with mini carousel + dots ──
  Widget _buildImageBox(ProductEntity product) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: CustomTheme.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: CustomTheme.borderLight.withValues(alpha: 0.5),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: product.images.isEmpty
                  ? Icon(
                      Icons.medical_services,
                      size: 28,
                      color: CustomTheme.textTertiary,
                    )
                  : PageView.builder(
                      onPageChanged: (index) =>
                          setState(() => _currentImageIndex = index),
                      itemCount: product.images.length,
                      itemBuilder: (context, index) {
                        return Hero(
                          tag: 'product_${product.id}',
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Image.network(
                              product.images[index].url,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.medical_services,
                                size: 28,
                                color: CustomTheme.textTertiary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Dots
          if (product.images.length > 1)
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  product.images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _currentImageIndex == index ? 10 : 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: _currentImageIndex == index
                          ? CustomTheme.primaryColor
                          : CustomTheme.primaryColor.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Trust highlights (compact)
  // ─────────────────────────────────────────────────────────────
  Widget _buildHighlightsStrip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildHighlightItem(
              Icons.verified_outlined,
              'Genuine Product',
              const Color(0xFF10B981),
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildHighlightItem(
              Icons.local_shipping_outlined,
              'Fast Delivery',
              const Color(0xFF3B82F6),
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildHighlightItem(
              Icons.refresh_rounded,
              'Easy Order',
              const Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: CustomTheme.primaryFontFamily,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: CustomTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 24,
      color: CustomTheme.borderLight.withValues(alpha: 0.5),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Description (compact, expandable)
  // ─────────────────────────────────────────────────────────────
  Widget _buildDescription(ProductEntity product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 12,
                  color: CustomTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'Generic',
                style: TextStyle(
                  fontFamily: CustomTheme.primaryFontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CustomTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: TextStyle(
              fontFamily: CustomTheme.secondaryFontFamily,
              color: CustomTheme.textSecondary,
              fontSize: 11.5,
              height: 1.55,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Quantity (compact)
  // ─────────────────────────────────────────────────────────────
  Widget _buildQuantitySection(ProductEntity product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  Icons.shopping_basket_outlined,
                  size: 12,
                  color: CustomTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'Quantity',
                style: TextStyle(
                  fontFamily: CustomTheme.primaryFontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CustomTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: CustomTheme.backgroundColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                _buildQtyButton(Icons.remove_rounded, () {
                  if (_quantity > 1) setState(() => _quantity--);
                }, isEnabled: _quantity > 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    '$_quantity',
                    style: TextStyle(
                      fontFamily: CustomTheme.primaryFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: CustomTheme.textPrimary,
                    ),
                  ),
                ),
                _buildQtyButton(
                  Icons.add_rounded,
                  () {
                    final maxStock = product.stock > 0 ? product.stock : 99;
                    if (_quantity < maxStock) {
                      setState(() => _quantity++);
                    }
                  },
                  isEnabled:
                      _quantity < (product.stock > 0 ? product.stock : 99),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(
    IconData icon,
    VoidCallback onTap, {
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: CustomTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 13,
          color: isEnabled
              ? CustomTheme.surfaceColor
              : CustomTheme.surfaceColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Bottom action
  // ─────────────────────────────────────────────────────────────
  Widget _buildBottomAction(ProductEntity product) {
    final total = product.finalPrice * _quantity;
    final isAvailable = product.stock > 0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          12,
          12,
          12,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '৳${total.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontFamily: CustomTheme.primaryFontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: CustomTheme.primaryColor,
                      letterSpacing: -0.4,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: isAvailable ? () => _addToCart(product) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: CustomTheme.textTertiary
                        .withValues(alpha: 0.3),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    surfaceTintColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAvailable
                            ? Icons.shopping_bag_outlined
                            : Icons.block_rounded,
                        size: 15,
                        color: isAvailable ? Colors.white : Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAvailable ? 'Add to Bag' : 'Out of Stock',
                        style: TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isAvailable ? Colors.white : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Not found
  // ─────────────────────────────────────────────────────────────
  Widget _buildNotFound() {
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: _buildSimpleAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: CustomTheme.surfaceColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 28,
                  color: CustomTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Product Not Found',
                style: TextStyle(
                  fontFamily: CustomTheme.primaryFontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CustomTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This product could not be loaded.\nPlease go back and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: CustomTheme.secondaryFontFamily,
                  fontSize: 12,
                  color: CustomTheme.textTertiary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: CustomTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Go Back',
                    style: TextStyle(
                      fontFamily: CustomTheme.primaryFontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Add to cart
  // ─────────────────────────────────────────────────────────────
  void _addToCart(ProductEntity product) async {
    final bool hasPrice =
        product.price > 0 ||
        (product.discountedPrice != null && product.discountedPrice! > 0);

    if (!hasPrice) {
      _showSnackBar('Failed to add: Product has no price', isError: true);
      return;
    }

    if (product.stock <= 0) {
      _showSnackBar('Out of Stock', isError: true);
      return;
    }

    final cartProvider = ref.read(cartProviderNotifier);
    final success = await cartProvider.addToCart(product.id, _quantity);

    if (mounted) {
      _showSnackBar(
        success ? 'Added to bag successfully!' : 'Stock Out',
        isError: !success,
      );
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? CustomTheme.errorColor
            : CustomTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
