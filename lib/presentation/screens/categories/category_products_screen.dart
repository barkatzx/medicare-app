import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:medicare_app/presentation/widgets/home/product_card.dart';

class CategoryProductsScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends ConsumerState<CategoryProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProductsProviderFamily(widget.categoryId)).loadProducts(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final provider = ref.read(categoryProductsProviderFamily(widget.categoryId));
        if (!provider.isLoading && !provider.isLoadingMore && provider.hasNextPage) {
          provider.loadProducts();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(categoryProductsProviderFamily(widget.categoryId));

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: CustomTheme.surfaceColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: CustomTheme.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          widget.categoryName,
          style: CustomTextStyle.heading2,
        ),
        backgroundColor: CustomTheme.backgroundColor,
        foregroundColor: CustomTheme.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(provider) {
    if (provider.isLoading && provider.products.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: CustomTheme.primaryColor,
        ),
      );
    }

    if (provider.errorMessage != null && provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: CustomTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: CustomTheme.errorColor,
              ),
            ),
            SizedBox(height: CustomTheme.spacingLG),
            Text(
              provider.errorMessage!,
              style: CustomTextStyle.bodyMedium.copyWith(
                color: CustomTheme.errorColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: CustomTheme.spacingLG),
            ElevatedButton(
              onPressed: () {
                provider.retry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: CustomTheme.spacingXL,
                  vertical: CustomTheme.spacingMD,
                ),
              ),
              child: Text(
                'Retry',
                style: CustomTextStyle.button,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: CustomTheme.textTertiary,
            ),
            SizedBox(height: CustomTheme.spacingMD),
            Text(
              'No products found',
              style: CustomTextStyle.bodyLarge.copyWith(
                color: CustomTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadProducts(refresh: true),
      color: CustomTheme.primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(CustomTheme.spacingMD),
        itemCount: provider.products.length + (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (provider.isLoadingMore && index == provider.products.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: CustomTheme.spacingMD),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final product = provider.products[index];
          return ProductCard(product: product);
        },
      ),
    );
  }
}
