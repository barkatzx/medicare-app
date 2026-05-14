import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:medicare_app/presentation/widgets/home/product_card.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final productProvider = ref.read(productProviderNotifier);
        if (!productProvider.isLoading &&
            !productProvider.isLoadingMore &&
            productProvider.hasNextPage &&
            productProvider.searchQuery.isNotEmpty) {
          productProvider.searchProducts(productProvider.searchQuery);
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().isEmpty) {
        ref.read(productProviderNotifier).clearSearch();
      } else {
        ref.read(productProviderNotifier).searchProducts(value);
      }
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = ref.watch(productProviderNotifier);

    return WillPopScope(
      onWillPop: () async {
        ref.read(productProviderNotifier).clearSearch();
        return true;
      },
      child: Scaffold(
        backgroundColor: CustomTheme.backgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(productProvider),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: CustomTheme.textPrimary),
        onPressed: () {
          ref.read(productProviderNotifier).clearSearch();
          Navigator.pop(context);
        },
      ),
      titleSpacing: 0,
      title: Container(
        height: 45,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: CustomTheme.secondaryColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
          border: Border.all(color: CustomTheme.borderLight),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search medicines, health products...',
            hintStyle: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.textTertiary),
            prefixIcon: Icon(Icons.search, size: 20, color: CustomTheme.primaryColor),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.cancel, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(productProviderNotifier).clearSearch();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          style: CustomTextStyle.bodyMedium,
          textInputAction: TextInputAction.search,
        ),
      ),
    );
  }

  Widget _buildBody(productProvider) {
    if (productProvider.searchQuery.isEmpty && _searchController.text.isEmpty) {
      return _buildInitialState();
    }

    if (productProvider.isLoading) {
      return _buildLoadingState();
    }

    if (productProvider.errorMessage != null) {
      return _buildErrorState(productProvider.errorMessage!);
    }

    if (productProvider.products.isEmpty) {
      return _buildNoResultsState(productProvider.searchQuery);
    }

    return _buildResultsList(productProvider);
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CustomTheme.primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_rounded, size: 48, color: CustomTheme.primaryColor.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            'Quick Search',
            style: CustomTextStyle.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Find medicines, health products, and more',
            style: CustomTextStyle.bodyMedium.copyWith(color: CustomTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => _buildShimmerItem(),
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
        ),
        child: Row(
          children: [
            Container(width: 60, height: 60, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: double.infinity, height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 100, height: 14, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: CustomTheme.textTertiary.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text('No results found', style: CustomTextStyle.heading3),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find anything for "$query". Check your spelling or try another term.',
              textAlign: TextAlign.center,
              style: CustomTextStyle.bodyMedium.copyWith(color: CustomTheme.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: CustomTheme.errorColor),
            const SizedBox(height: 24),
            Text('Something went wrong', style: CustomTextStyle.heading3),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: CustomTextStyle.bodySmall),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(productProviderNotifier).searchProducts(_searchController.text),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(productProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: productProvider.products.length + (productProvider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == productProvider.products.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final product = productProvider.products[index];
        return ProductCard(product: product);
      },
    );
  }
}
