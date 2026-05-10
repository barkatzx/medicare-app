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
    
    // Initial load
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
      case 0:
        return ProductListType.trending;
      case 1:
        return ProductListType.featured;
      case 2:
        return ProductListType.newProduct;
      default:
        return ProductListType.trending;
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
      appBar: AppBar(
        title: const Text('Discover'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: CustomTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: CustomTheme.primaryColor,
          tabs: const [
            Tab(text: 'Trending'),
            Tab(text: 'Featured'),
            Tab(text: 'New Product'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ProductList(type: ProductListType.trending),
          _ProductList(type: ProductListType.featured),
          _ProductList(type: ProductListType.newProduct),
        ],
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
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadProducts(type, refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadProducts(type, refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length + (provider.hasNextPage(type) ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == products.length) {
            // Trigger load more
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!provider.isLoadingMore(type)) {
                provider.loadProducts(type);
              }
            });
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return ProductCard(product: products[index]);
        },
      ),
    );
  }
}
