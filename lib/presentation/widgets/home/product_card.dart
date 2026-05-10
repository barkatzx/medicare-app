import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import '../../../domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product-detail', arguments: product.id);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: CustomTheme.spacingSM),
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // Left Side - Product Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                  color: CustomTheme.backgroundColor,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                  child: product.images.isNotEmpty
                      ? Image.network(
                          product.images.first.url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
              const SizedBox(width: 20),

              // Middle - Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.categoryName,
                      style: CustomTextStyle.caption.copyWith(
                        color: CustomTheme.primaryColor.withOpacity(0.5),
                        fontWeight: CustomTheme.fontWeightBold,
                        letterSpacing: 0.5,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.name,
                      style: CustomTextStyle.bodyMedium.copyWith(
                        fontWeight: CustomTheme.fontWeightSemiBold,
                        color: CustomTheme.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    _buildPriceSection(),
                  ],
                ),
              ),

              // Right Side - Add Icon
              _AddToCartButton(product: product),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.medical_services_outlined,
        size: 30,
        color: CustomTheme.primaryColor.withOpacity(0.1),
      ),
    );
  }

  Widget _buildPriceSection() {
    final hasDiscount = product.discountedPrice != null;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5,
      children: [
        Text(
          '৳${product.finalPrice.toStringAsFixed(0)}',
          style: CustomTextStyle.heading4.copyWith(
            color: CustomTheme.primaryColor,
            fontWeight: CustomTheme.fontWeightBold,
          ),
        ),
        if (hasDiscount) ...[
          Text(
            '৳${product.price.toStringAsFixed(0)}',
            style: CustomTextStyle.heading4.copyWith(
              decoration: TextDecoration.lineThrough,
              color: CustomTheme.textTertiary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: CustomTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${product.discountPercent}% OFF',
              style: TextStyle(
                color: CustomTheme.errorColor,
                fontSize: 12,
                fontWeight: CustomTheme.fontWeightBold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AddToCartButton extends ConsumerWidget {
  final ProductEntity product;

  const _AddToCartButton({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final cartProvider = ref.read(cartProviderNotifier);
        
        // Optimistic UI, instantaneous add to cart without blocking
        cartProvider.addToCart(product.id, 1).then((success) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? '${product.name} added to cart'
                      : 'Failed to add to cart',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: success
                    ? CustomTheme.successColor
                    : CustomTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(milliseconds: 800),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                ),
              ),
            );
          }
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: CustomTheme.backgroundColor,
          borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
        ),
        child: Icon(
          Icons.add,
          size: 20,
          color: CustomTheme.primaryColor,
        ),
      ),
    );
  }
}
