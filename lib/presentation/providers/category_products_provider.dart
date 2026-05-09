import 'package:flutter/material.dart';
import 'package:medicare_app/data/repositories/product_repository.dart';
import 'package:medicare_app/domain/entities/product_entity.dart';

class CategoryProductsProvider extends ChangeNotifier {
  final ProductRepository productRepository;
  final String categoryId;

  CategoryProductsProvider({
    required this.productRepository,
    required this.categoryId,
  });

  List<ProductEntity> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _currentPage = 1;
  bool _hasNextPage = true;

  List<ProductEntity> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasNextPage => _hasNextPage;

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasNextPage = true;
    }

    if (!_hasNextPage) return;
    if (_isLoading || _isLoadingMore) return;

    if (refresh || _products.isEmpty) {
      _isLoading = true;
      notifyListeners();
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }
    
    _errorMessage = null;

    try {
      final paginatedResponse = await productRepository.getCategoryProducts(
        categoryId,
        page: _currentPage,
        limit: 20,
      );
      
      final newProducts = paginatedResponse.products;

      if (refresh || _products.isEmpty) {
        _products = newProducts;
      } else {
        _products = [..._products, ...newProducts];
      }

      _hasNextPage = paginatedResponse.hasNextPage;
      if (_hasNextPage) {
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (refresh || _products.isEmpty) {
        _isLoading = false;
      } else {
        _isLoadingMore = false;
      }
      notifyListeners();
    }
  }

  void retry() {
    loadProducts(refresh: true);
  }
}
