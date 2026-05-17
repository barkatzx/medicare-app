import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/screens/cart/cart_screen.dart';
import 'package:medicare_app/presentation/screens/home/categories_screen.dart';
import 'package:medicare_app/presentation/screens/profile/profile_screen.dart';
import 'package:medicare_app/presentation/widgets/home/home_app_bar.dart';
import 'package:medicare_app/presentation/widgets/home/product_card.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'trending_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  AnimationController? _navAnimController;

  @override
  void initState() {
    super.initState();
    _navAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartProviderNotifier).loadCart(silent: true);
    });
  }

  @override
  void dispose() {
    _navAnimController?.dispose();
    super.dispose();
  }

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
    final selectedIndex = ref.watch(navigationProvider).selectedIndex;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: _screens[selectedIndex],
      bottomNavigationBar: _buildBottomNav(selectedIndex, cartItemCount),
    );
  }

  Widget _buildBottomNav(int selectedIndex, int cartItemCount) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: CustomTheme.primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.primaryColor.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home', selectedIndex),
          _buildNavItem(1, Icons.add_box_outlined, 'Shortcuts', selectedIndex),
          _buildNavItem(
              2, Icons.medical_services_outlined, 'Company', selectedIndex),
          _buildNavItem(3, Icons.shopping_bag_outlined, 'Bag', selectedIndex,
              badgeCount: cartItemCount),
          _buildNavItem(4, Icons.person_outline, 'Profile', selectedIndex),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    int selectedIndex, {
    int? badgeCount,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => ref.read(navigationProvider).setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    key: ValueKey('$index-$isSelected'),
                    color: isSelected
                        ? CustomTheme.primaryColor
                        : Colors.white.withOpacity(0.65),
                    size: 22,
                  ),
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: CustomTheme.errorColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : CustomTheme.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Row(
                      children: [
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: CustomTheme.primaryFontFamily,
                            fontSize: 12,
                            fontWeight: CustomTheme.fontWeightBold,
                            color: CustomTheme.primaryColor,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Content ───────────────────────────────────────────────────────────

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
      ref.read(productProviderNotifier).loadProducts();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final p = ref.read(productProviderNotifier);
        if (!p.isLoading && !p.isLoadingMore && p.hasNextPage) {
          p.loadProducts();
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
      backgroundColor: CustomTheme.backgroundColor,
      appBar: const HomeAppBar(),
      body: _buildBody(productProvider),
    );
  }

  Widget _buildBody(dynamic productProvider) {
    // Initial loading
    if (productProvider.isLoading && productProvider.products.isEmpty) {
      return _buildLoadingState();
    }

    // Error with no products
    if (productProvider.errorMessage != null &&
        productProvider.products.isEmpty) {
      return _buildErrorState(productProvider);
    }

    // Empty
    if (productProvider.products.isEmpty) {
      return _buildEmptyState(productProvider);
    }

    return RefreshIndicator(
      onRefresh: () => productProvider.loadProducts(refresh: true),
      color: CustomTheme.primaryColor,
      backgroundColor: CustomTheme.surfaceColor,
      strokeWidth: 2,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: productProvider.products.length +
            (productProvider.isLoadingMore ? 1 : 0) +
            (productProvider.errorMessage != null &&
                    productProvider.products.isNotEmpty
                ? 1
                : 0),
        itemBuilder: (context, index) {
          // Inline error at bottom
          if (productProvider.errorMessage != null &&
              productProvider.products.isNotEmpty &&
              index ==
                  productProvider.products.length +
                      (productProvider.isLoadingMore ? 1 : 0)) {
            return _buildInlineError(productProvider);
          }

          // Load-more spinner
          if (productProvider.isLoadingMore &&
              index == productProvider.products.length) {
            return _buildLoadMoreSpinner();
          }

          final product = productProvider.products[index];
          return ProductCard(product: product);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: CustomTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading products…',
            style: CustomTextStyle.bodySmall.copyWith(
              fontSize: 13,
              color: CustomTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(dynamic productProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: CustomTheme.errorColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: CustomTheme.errorColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: CustomTextStyle.heading3.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 8),
            Text(
              productProvider.errorMessage ?? 'Unable to load products.',
              textAlign: TextAlign.center,
              style: CustomTextStyle.bodyMedium.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => productProvider.loadProducts(refresh: true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  'Try Again',
                  style: CustomTextStyle.button.copyWith(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(dynamic productProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: CustomTheme.surfaceColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                size: 40,
                color: CustomTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              productProvider.searchQuery.isEmpty
                  ? 'No products available'
                  : 'No results found',
              style: CustomTextStyle.heading3.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 8),
            Text(
              productProvider.searchQuery.isEmpty
                  ? 'Check back later for new products.'
                  : 'No products found for\n"${productProvider.searchQuery}"',
              textAlign: TextAlign.center,
              style: CustomTextStyle.bodyMedium.copyWith(
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineError(dynamic productProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CustomTheme.errorColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CustomTheme.errorColor.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: CustomTheme.errorColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              productProvider.errorMessage ?? 'Failed to load more.',
              style: CustomTextStyle.bodySmall.copyWith(
                fontSize: 12,
                color: CustomTheme.errorColor,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => productProvider.loadProducts(),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: CustomTheme.errorColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Retry',
                style: CustomTextStyle.caption.copyWith(
                  color: Colors.white,
                  fontWeight: CustomTheme.fontWeightSemiBold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreSpinner() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: CustomTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}