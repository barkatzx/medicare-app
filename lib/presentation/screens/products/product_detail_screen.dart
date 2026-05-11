import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:medicare_app/presentation/widgets/common/loading_widget.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
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
      return const Scaffold(body: LoadingWidget());
    }

    if (product == null) {
      return Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: CustomTheme.textTertiary),
              const SizedBox(height: 16),
              Text('Product not found', style: CustomTextStyle.heading3),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusRound)),
                ),
                child: const Text('Go Back', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: CustomTheme.textPrimary),
              ),
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(product),
                const SizedBox(height: 24),
                _buildProductHeader(product),
                const SizedBox(height: 24),
                _buildDescription(product),
                const SizedBox(height: 32),
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

  Widget _buildImageCarousel(product) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      decoration: BoxDecoration(
        color: CustomTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          PageView.builder(
            onPageChanged: (index) => setState(() => _currentImageIndex = index),
            itemCount: product.images.length,
            itemBuilder: (context, index) {
              return Hero(
                tag: 'product_${product.id}',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 80, 40, 40),
                  child: Image.network(
                    product.images[index].url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              );
            },
          ),
          if (product.images.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  product.images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentImageIndex == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentImageIndex == index ? CustomTheme.primaryColor : CustomTheme.primaryColor.withOpacity(0.15),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
                ),
                child: Text(
                  product.categoryName.toUpperCase(),
                  style: CustomTextStyle.caption.copyWith(
                    color: CustomTheme.primaryColor,
                    fontWeight: CustomTheme.fontWeightBold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              if (product.stock > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
                  ),
                  child: Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('IN STOCK', style: CustomTextStyle.caption.copyWith(color: Colors.green, fontWeight: CustomTheme.fontWeightBold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            product.name,
            style: CustomTextStyle.heading2.copyWith(fontSize: 26, letterSpacing: -0.5),
          ),
          const SizedBox(height: 20),
          _buildPriceSection(product),
        ],
      ),
    );
  }

  Widget _buildPriceSection(product) {
    final hasDiscount = product.discountPercent > 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomTheme.backgroundColor,
        borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
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
                      style: CustomTextStyle.bodyMedium.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: CustomTheme.textTertiary,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Text(
                      '৳${product.finalPrice.toStringAsFixed(0)}',
                      style: CustomTextStyle.heading1.copyWith(
                        color: CustomTheme.primaryColor,
                        fontSize: 32,
                      ),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CustomTheme.errorColor,
                          borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
                        ),
                        child: Text(
                          '${product.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (hasDiscount)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'You Save',
                    style: CustomTextStyle.caption.copyWith(color: CustomTheme.successColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '৳${product.savings.toStringAsFixed(0)}',
                    style: CustomTextStyle.bodyLarge.copyWith(
                      color: CustomTheme.successColor,
                      fontWeight: CustomTheme.fontWeightBold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescription(product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Description',
                style: CustomTextStyle.heading4.copyWith(fontWeight: CustomTheme.fontWeightBold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            product.description,
            style: CustomTextStyle.bodyMedium.copyWith(
              color: CustomTheme.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Quantity',
            style: CustomTextStyle.heading4.copyWith(fontWeight: CustomTheme.fontWeightBold),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: CustomTheme.backgroundColor,
              borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
            ),
            child: Row(
              children: [
                _buildQtyButton(Icons.remove, () {
                  if (_quantity > 1) setState(() => _quantity--);
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '$_quantity',
                    style: CustomTextStyle.bodyLarge.copyWith(fontWeight: CustomTheme.fontWeightBold),
                  ),
                ),
                _buildQtyButton(Icons.add, () {
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
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: CustomTheme.textPrimary),
      ),
    );
  }

  Widget _buildBottomAction(product) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Price', style: CustomTextStyle.caption.copyWith(color: CustomTheme.textTertiary)),
                  const SizedBox(height: 2),
                  Text(
                    '৳${(product.finalPrice * _quantity).toStringAsFixed(0)}',
                    style: CustomTextStyle.heading3.copyWith(color: CustomTheme.primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _addToCart(product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusRound)),
                  elevation: 0,
                ),
                child: Text('Add to Bag', style: CustomTextStyle.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(product) async {
    final cartProvider = ref.read(cartProviderNotifier);
    final success = await cartProvider.addToCart(product.id, _quantity);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(success ? Icons.check_circle_outline : Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text(success ? 'Added to bag successfully!' : 'Failed to add to bag', style: const TextStyle(color: Colors.white)),
            ],
          ),
          backgroundColor: success ? CustomTheme.successColor : CustomTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusMD)),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }
}
