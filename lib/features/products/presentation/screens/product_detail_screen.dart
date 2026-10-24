import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';

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
        body: Center(
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
                'Loading product…',
                style: CustomTextStyle.bodySmall.copyWith(
                  fontSize: 13,
                  color: CustomTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (product == null) {
      return Scaffold(
        backgroundColor: CustomTheme.backgroundColor,
        appBar: _buildAppBar(),
        body: Center(
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
                  'Product Not Found',
                  style: CustomTextStyle.heading3.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 8),
                Text(
                  'This product could not be loaded.\nPlease go back and try again.',
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
        ),
      );
    }

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: _buildAppBar(),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(product),
                const SizedBox(height: 20),
                _buildProductHeader(product),
                const SizedBox(height: 20),
                _buildPriceSection(product),
                const SizedBox(height: 20),
                _buildDescription(product),
                const SizedBox(height: 20),
                _buildQuantitySection(),
                const SizedBox(height: 140),
              ],
            ),
          ),
          _buildBottomAction(product),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
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
    );
  }

  Widget _buildImageCarousel(product) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          PageView.builder(
            onPageChanged: (index) =>
                setState(() => _currentImageIndex = index),
            itemCount: product.images.length,
            itemBuilder: (context, index) {
              return Hero(
                tag: 'product_${product.id}',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 80, 40, 40),
                  child: Image.network(
                    product.images[index].url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.medical_services,
                      size: 48,
                      color: CustomTheme.textTertiary,
                    ),
                  ),
                ),
              );
            },
          ),
          if (product.images.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  product.images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentImageIndex == index ? 22 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.5),
                      color: _currentImageIndex == index
                          ? CustomTheme.primaryColor
                          : CustomTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductHeader(product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  product.categoryName.toUpperCase(),
                  style: TextStyle(
                    fontFamily: CustomTheme.primaryFontFamily,
                    fontSize: 9,
                    fontWeight: CustomTheme.fontWeightBold,
                    color: CustomTheme.primaryColor,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (product.stock > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: CustomTheme.successColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: CustomTheme.successColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'In Stock',
                        style: TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 9,
                          fontWeight: CustomTheme.fontWeightBold,
                          color: CustomTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: CustomTheme.errorColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: CustomTheme.errorColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Out of Stock',
                        style: TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 9,
                          fontWeight: CustomTheme.fontWeightBold,
                          color: CustomTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: CustomTextStyle.heading2.copyWith(
              fontSize: 22,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(product) {
    final hasDiscount = product.discountPercent > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasDiscount)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '৳${product.price.toStringAsFixed(0)}',
                        style: CustomTextStyle.bodySmall.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: CustomTheme.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '৳${product.finalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 28,
                          fontWeight: CustomTheme.fontWeightBold,
                          color: CustomTheme.primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: CustomTheme.errorColor,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            '-${product.discountPercent}%',
                            style: TextStyle(
                              fontFamily: CustomTheme.primaryFontFamily,
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: CustomTheme.fontWeightBold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: CustomTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: CustomTheme.secondaryFontFamily,
                        fontSize: 10,
                        color: CustomTheme.textTertiary,
                        fontWeight: CustomTheme.fontWeightMedium,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '৳${product.savings.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontFamily: CustomTheme.primaryFontFamily,
                        fontSize: 13,
                        fontWeight: CustomTheme.fontWeightBold,
                        color: CustomTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: CustomTheme.primaryColor,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Description',
                  style: CustomTextStyle.heading4.copyWith(
                    fontSize: 14,
                    fontWeight: CustomTheme.fontWeightSemiBold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              product.description,
              style: CustomTextStyle.bodyMedium.copyWith(
                color: CustomTheme.textSecondary,
                fontSize: 13,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Quantity',
            style: CustomTextStyle.heading4.copyWith(
              fontSize: 14,
              fontWeight: CustomTheme.fontWeightSemiBold,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: CustomTheme.backgroundColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                _buildQtyButton(Icons.remove_rounded, () {
                  if (_quantity > 1) setState(() => _quantity--);
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    '$_quantity',
                    style: TextStyle(
                      fontFamily: CustomTheme.primaryFontFamily,
                      fontSize: 15,
                      fontWeight: CustomTheme.fontWeightBold,
                      color: CustomTheme.textPrimary,
                    ),
                  ),
                ),
                _buildQtyButton(Icons.add_rounded, () {
                  setState(() => _quantity++);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 15, color: CustomTheme.textPrimary),
      ),
    );
  }

  Widget _buildBottomAction(product) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
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
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: CustomTextStyle.caption.copyWith(
                      fontSize: 11,
                      color: CustomTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '৳${(product.finalPrice * _quantity).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontFamily: CustomTheme.primaryFontFamily,
                      fontSize: 20,
                      fontWeight: CustomTheme.fontWeightBold,
                      color: CustomTheme.primaryColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: product.stock > 0
                      ? () => _addToCart(product)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: product.stock > 0
                        ? CustomTheme.primaryColor
                        : CustomTheme.primaryColor.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: CustomTheme.primaryColor
                        .withValues(alpha: 0.5),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: product.stock > 0
                          ? const LinearGradient(
                              colors: [Color(0xFF2A2A2A), Color(0xFF010101)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        product.stock > 0 ? 'Add to Bag' : 'Out of Stock',
                        style: CustomTextStyle.button.copyWith(
                          fontSize: 14,
                          fontWeight: CustomTheme.fontWeightBold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(product) async {
    final bool hasPrice =
        product.price > 0 ||
        (product.discountedPrice != null && product.discountedPrice! > 0);

    if (!hasPrice) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text(
                  'Failed to add: Product has no price',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: CustomTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      return;
    }

    if (product.stock <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text(
                  'Out of Stock',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: CustomTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      return;
    }

    final cartProvider = ref.read(cartProviderNotifier);
    final success = await cartProvider.addToCart(product.id, _quantity);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                success ? 'Added to bag successfully!' : 'Stock Out',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: success
              ? CustomTheme.successColor
              : CustomTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
