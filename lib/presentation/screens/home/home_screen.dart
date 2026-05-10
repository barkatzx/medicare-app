import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/screens/cart/cart_screen.dart';
import 'package:medicare_app/presentation/screens/home/categories_screen.dart';
import 'package:medicare_app/presentation/screens/profile/profile_screen.dart';
import 'package:medicare_app/presentation/widgets/home/home_app_bar.dart';
import 'package:medicare_app/presentation/widgets/home/product_card.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
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
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: CustomTheme.primaryColor,
          borderRadius: BorderRadius.circular(CustomTheme.radiusXL),
          boxShadow: [
            BoxShadow(
              color: CustomTheme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(1, Icons.shortcut_outlined, Icons.shortcut_rounded, 'Shortcuts'),
            _buildNavItem(2, Icons.category_outlined, Icons.category, 'Categories'),
            _buildNavItem(3, Icons.shopping_cart_outlined, Icons.shopping_cart, 'Cart', badgeCount: cartItemCount),
            _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, {int? badgeCount}) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? CustomTheme.primaryColor : Colors.white.withOpacity(0.7),
                  size: 24,
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CustomTheme.errorColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: isSelected ? Colors.white : CustomTheme.primaryColor, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        badgeCount > 9 ? '9+' : badgeCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: CustomTextStyle.bodySmall.copyWith(
                  color: CustomTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
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
                        (productProvider.isLoadingMore ? 1 : 0) +
                        (productProvider.errorMessage != null &&
                                productProvider.products.isNotEmpty
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      // Error item at the bottom
                      if (productProvider.errorMessage != null &&
                          productProvider.products.isNotEmpty &&
                          index == productProvider.products.length + (productProvider.isLoadingMore ? 1 : 0)) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                productProvider.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              TextButton(
                                onPressed: () => productProvider.loadProducts(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      // Loading item at the bottom
                      if (productProvider.isLoadingMore &&
                          index == productProvider.products.length) {
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
