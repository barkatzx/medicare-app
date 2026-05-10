import 'package:flutter/material.dart';
import 'package:medicare_app/data/repositories/product_repository.dart';
import 'package:medicare_app/domain/entities/product_entity.dart';

enum ProductListType { trending, featured, newProduct }

class SpecialProductsProvider extends ChangeNotifier {
  final ProductRepository productRepository;

  SpecialProductsProvider({required this.productRepository});

  final Map<ProductListType, List<ProductEntity>> _products = {
    ProductListType.trending: [],
    ProductListType.featured: [],
    ProductListType.newProduct: [],
  };

  final Map<ProductListType, bool> _isLoading = {
    ProductListType.trending: false,
    ProductListType.featured: false,
    ProductListType.newProduct: false,
  };

  final Map<ProductListType, bool> _isLoadingMore = {
    ProductListType.trending: false,
    ProductListType.featured: false,
    ProductListType.newProduct: false,
  };

  final Map<ProductListType, int> _currentPage = {
    ProductListType.trending: 1,
    ProductListType.featured: 1,
    ProductListType.newProduct: 1,
  };

  final Map<ProductListType, bool> _hasNextPage = {
    ProductListType.trending: true,
    ProductListType.featured: true,
    ProductListType.newProduct: true,
  };

  final Map<ProductListType, String?> _errorMessages = {
    ProductListType.trending: null,
    ProductListType.featured: null,
    ProductListType.newProduct: null,
  };

  List<ProductEntity> getProducts(ProductListType type) => _products[type]!;
  bool isLoading(ProductListType type) => _isLoading[type]!;
  bool isLoadingMore(ProductListType type) => _isLoadingMore[type]!;
  bool hasNextPage(ProductListType type) => _hasNextPage[type]!;
  String? getErrorMessage(ProductListType type) => _errorMessages[type];

  Future<void> loadProducts(ProductListType type, {bool refresh = false}) async {
    if (refresh) {
      _currentPage[type] = 1;
      _hasNextPage[type] = true;
    }

    if (!_hasNextPage[type]!) return;
    if (_isLoading[type]! || _isLoadingMore[type]!) return;

    if (refresh || _products[type]!.isEmpty) {
      _isLoading[type] = true;
    } else {
      _isLoadingMore[type] = true;
    }
    _errorMessages[type] = null;
    notifyListeners();

    try {
      PaginatedProductResponse response;
      switch (type) {
        case ProductListType.trending:
          response = await productRepository.getTrendingProducts(page: _currentPage[type]!);
          break;
        case ProductListType.featured:
          response = await productRepository.getFeaturedProducts(page: _currentPage[type]!);
          break;
        case ProductListType.newProduct:
          response = await productRepository.getNewProducts(page: _currentPage[type]!);
          break;
      }

      if (refresh || _products[type]!.isEmpty) {
        _products[type] = response.products;
      } else {
        _products[type] = [..._products[type]!, ...response.products];
      }

      _hasNextPage[type] = response.hasNextPage;
      if (_hasNextPage[type]!) {
        _currentPage[type] = _currentPage[type]! + 1;
      }
    } catch (e) {
      _errorMessages[type] = e.toString();
    } finally {
      _isLoading[type] = false;
      _isLoadingMore[type] = false;
      notifyListeners();
    }
  }
}
