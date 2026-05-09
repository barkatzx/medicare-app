import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/screens/cart/cart_screen.dart';
import 'package:medicare_app/presentation/screens/home/categories_screen.dart';
import 'package:medicare_app/presentation/screens/profile/profile_screen.dart';
import 'package:medicare_app/presentation/widgets/home/home_app_bar.dart';
import 'package:medicare_app/presentation/widgets/home/product_card.dart';
import 'package:badges/badges.dart' as badges;
import 'trending_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContentScreen(),
    const TrendingScreen(),
    const CategoriesScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(cartProviderNotifier).cartItemCount;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Trending',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: cartItemCount > 0,
              badgeContent: Text(
                cartItemCount > 9 ? '9+' : '$cartItemCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: badges.Badge(
              showBadge: cartItemCount > 0,
              badgeContent: Text(
                cartItemCount > 9 ? '9+' : '$cartItemCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContentScreen extends ConsumerStatefulWidget {
  const HomeContentScreen({super.key});

  @override
  ConsumerState<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends ConsumerState<HomeContentScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = ref.read(productProviderNotifier);
      productProvider.loadProducts();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final productProvider = ref.read(productProviderNotifier);
        if (!productProvider.isLoading &&
            !productProvider.isLoadingMore &&
            productProvider.hasNextPage) {
          productProvider.loadProducts();
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
    final productProvider = ref.watch(productProviderNotifier);
    
    return Scaffold(
      appBar: const HomeAppBar(),
      body: Column(
        children: [
          // Products
          Expanded(
            child: Builder(
              builder: (context) {
                if (productProvider.isLoading &&
                    productProvider.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productProvider.errorMessage != null &&
                    productProvider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        Text(productProvider.errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            productProvider.loadProducts(refresh: true);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (productProvider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          productProvider.searchQuery.isEmpty
                              ? 'No products available'
                              : 'No products found for "${productProvider.searchQuery}"',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => productProvider.loadProducts(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: productProvider.products.length +
                        (productProvider.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == productProvider.products.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final product = productProvider.products[index];
                      return ProductCard(
                        product: product,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
