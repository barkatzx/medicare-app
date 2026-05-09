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

  List<ProductEntity> get products =>
      _searchQuery.isEmpty ? _products : _filteredProducts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get hasNextPage => _hasNextPage;

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasNextPage = true;
    }

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
      final newProducts = await productRepository.getProducts(
        page: _currentPage,
        limit: 20,
      );
      
      if (refresh || _products.isEmpty) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
      }
      
      if (newProducts.length < 20) {
        _hasNextPage = false;
      } else {
        _currentPage++;
      }
      
      _filteredProducts = _products;
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

  Future<void> searchProducts(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredProducts = _products;
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      _filteredProducts = await productRepository.searchProducts(query);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
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
