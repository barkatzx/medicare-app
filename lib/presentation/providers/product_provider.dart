import 'package:flutter/material.dart';
import 'package:medicare_app/data/repositories/product_repository.dart';
import '../../domain/entities/product_entity.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository productRepository;

  ProductProvider({required this.productRepository});

  List<ProductEntity> _products = [];
  List<ProductEntity> _filteredProducts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  String? _errorMessage;

  int _currentPage = 1;
  bool _hasNextPage = true;

  int _searchCurrentPage = 1;
  bool _searchHasNextPage = true;

  List<ProductEntity> get products =>
      _searchQuery.isEmpty ? _products : _filteredProducts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get hasNextPage => _searchQuery.isEmpty ? _hasNextPage : _searchHasNextPage;

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasNextPage = true;
    }

    if (_searchQuery.isNotEmpty && !refresh) return;
    if (!_hasNextPage) return;
    if (_isLoading || _isLoadingMore) return;

    if (refresh || _products.isEmpty) {
      _setLoading(true);
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }
    _errorMessage = null;

    try {
      final paginatedResponse = await productRepository.getProducts(
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
      
      if (_searchQuery.isEmpty) {
        _filteredProducts = _products;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (refresh || _products.isEmpty) {
        _setLoading(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> searchProducts(String query, {bool refresh = false}) async {
    if (query != _searchQuery) {
      _searchQuery = query;
      refresh = true;
    }

    if (query.isEmpty) {
      _filteredProducts = _products;
      notifyListeners();
      return;
    }

    if (refresh) {
      _searchCurrentPage = 1;
      _searchHasNextPage = true;
    }

    if (!_searchHasNextPage) return;
    if (_isLoading || _isLoadingMore) return;

    if (refresh || _filteredProducts.isEmpty || _filteredProducts == _products) {
      _setLoading(true);
      if (refresh) _filteredProducts = [];
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }
    
    _errorMessage = null;

    try {
      final paginatedResponse = await productRepository.searchProducts(
        query,
        page: _searchCurrentPage,
        limit: 20,
      );
      
      final newProducts = paginatedResponse.products;

      if (refresh || _filteredProducts.isEmpty) {
        _filteredProducts = newProducts;
      } else {
        _filteredProducts = [..._filteredProducts, ...newProducts];
      }

      _searchHasNextPage = paginatedResponse.hasNextPage;
      if (_searchHasNextPage) {
        _searchCurrentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (refresh || _filteredProducts.isEmpty) {
        _setLoading(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredProducts = _products;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
