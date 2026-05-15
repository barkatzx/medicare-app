import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import '../../../domain/entities/product_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                      ? CachedNetworkImage(
                          imageUrl: product.images.first.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => _buildImagePlaceholder(),
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
        if (product.stock <= 0) ...[
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: CustomTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Stock Out',
              style: TextStyle(
                color: CustomTheme.errorColor,
                fontSize: 15,
                fontWeight: CustomTheme.fontWeightBold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AddToCartButton extends ConsumerStatefulWidget {
  final ProductEntity product;

  const _AddToCartButton({required this.product});

  @override
  ConsumerState<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends ConsumerState<_AddToCartButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        // Fix: Ensure product has at least one valid price before adding to cart
        final bool hasPrice = widget.product.price > 0 || 
                             (widget.product.discountedPrice != null && widget.product.discountedPrice! > 0);
        
        if (!hasPrice) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Failed to add to cart: Product has no price',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: CustomTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(milliseconds: 1500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                ),
              ),
            );
          }
          return;
        }

        // Fix: Check for stock before adding to cart
        if (widget.product.stock <= 0) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Failed to add to cart: Stock Out',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: CustomTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(milliseconds: 1500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                ),
              ),
            );
          }
          return;
        }

        final cartProvider = ref.read(cartProviderNotifier);
        
        // Optimistic UI, instantaneous add to cart without blocking
        cartProvider.addToCart(widget.product.id, 1).then((success) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? '${widget.product.name} added to cart'
                      : 'Stock Out',
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isPressed 
              ? CustomTheme.primaryColor.withOpacity(0.2) 
              : CustomTheme.backgroundColor,
          borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
          border: Border.all(
            color: _isPressed ? CustomTheme.primaryColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: Icon(
          widget.product.stock <= 0 ? Icons.close : Icons.add,
          size: 20,
          color: widget.product.stock <= 0 
              ? CustomTheme.textTertiary 
              : CustomTheme.primaryColor,
        ),
      ),
    );
  }
}
