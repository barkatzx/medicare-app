import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/home/product_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
        appBar: AppBar(
          titleSpacing: 0,
          title: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: true,
            onChanged: (value) {
              if (value.isEmpty) {
                ref.read(productProviderNotifier).clearSearch();
              } else {
                ref.read(productProviderNotifier).searchProducts(value);
              }
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Search products...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey.shade400),
            ),
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  ref.read(productProviderNotifier).clearSearch();
                  setState(() {});
                },
              ),
          ],
        ),
        body: Builder(
          builder: (context) {
            if (productProvider.searchQuery.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search for medicines, health products...',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }

            if (productProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (productProvider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 16),
                    Text(productProvider.errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(productProviderNotifier).searchProducts(_searchController.text);
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
                      'No products found for "${productProvider.searchQuery}"',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: productProvider.products.length,
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                return ProductCard(product: product);
              },
            );
          },
        ),
      ),
    );
  }
}
