import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/providers/special_products_provider.dart';
import 'package:medicare_app/presentation/widgets/home/product_card.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';

class TrendingScreen extends ConsumerStatefulWidget {
  const TrendingScreen({super.key});

  @override
  ConsumerState<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends ConsumerState<TrendingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentTab();
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadCurrentTab();
      }
    });
  }

  void _loadCurrentTab() {
    final provider = ref.read(specialProductsProviderNotifier);
    final type = _getTypeForIndex(_tabController.index);
    if (provider.getProducts(type).isEmpty) {
      provider.loadProducts(type);
    }
  }

  ProductListType _getTypeForIndex(int index) {
    switch (index) {
      case 0: return ProductListType.trending;
      case 1: return ProductListType.featured;
      case 2: return ProductListType.newProduct;
      default: return ProductListType.trending;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Small Premium TabBar with Icons
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: 40,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: CustomTheme.textTertiary,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: CustomTheme.primaryColor,
                  borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
                ),
                labelPadding: EdgeInsets.zero,
                labelStyle: CustomTextStyle.bodySmall.copyWith(
                  fontWeight: CustomTheme.fontWeightBold,
                  fontSize: 10,
                ),
                unselectedLabelStyle: CustomTextStyle.bodySmall.copyWith(
                  fontSize: 10,
                ),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_fire_department_rounded, size: 14),
                        SizedBox(width: 4),
                        Text('Most Discount'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_rounded, size: 14),
                        SizedBox(width: 4),
                        Text('Flash Sales'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fiber_new_rounded, size: 14),
                        SizedBox(width: 4),
                        Text('New'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ProductList(type: ProductListType.trending),
                  _ProductList(type: ProductListType.featured),
                  _ProductList(type: ProductListType.newProduct),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductList extends ConsumerWidget {
  final ProductListType type;
  const _ProductList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(specialProductsProviderNotifier);
    final products = provider.getProducts(type);
    final isLoading = provider.isLoading(type);
    final errorMessage = provider.getErrorMessage(type);

    if (isLoading && products.isEmpty) {
      return _buildLoadingState();
    }

    if (errorMessage != null && products.isEmpty) {
      return _buildErrorState(errorMessage, () => provider.loadProducts(type, refresh: true));
    }

    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: CustomTheme.primaryColor,
      onRefresh: () => provider.loadProducts(type, refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: products.length + (provider.hasNextPage(type) ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == products.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!provider.isLoadingMore(type)) {
                provider.loadProducts(type);
              }
            });
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            );
          }
          return ProductCard(product: products[index]);
        },
      ),
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
            'Fetching products...',
            style: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CustomTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 40, color: CustomTheme.errorColor),
            ),
            const SizedBox(height: 24),
            Text('Oops! Something went wrong', style: CustomTextStyle.heading4),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: CustomTextStyle.bodyMedium.copyWith(color: CustomTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusRound)),
              ),
              child: const Text('Retry Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CustomTheme.primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined, size: 40, color: CustomTheme.primaryColor.withOpacity(0.4)),
          ),
          const SizedBox(height: 24),
          Text('No products found', style: CustomTextStyle.heading4),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find any products in this category.',
            style: CustomTextStyle.bodyMedium.copyWith(color: CustomTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
