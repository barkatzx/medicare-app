import 'package:flutter/material.dart';
import 'package:medicare_app/data/repositories/category_repository.dart';
import 'package:medicare_app/domain/entities/category_entity.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository categoryRepository;

  CategoryProvider({required this.categoryRepository});

  List<CategoryEntity> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<CategoryEntity> get categories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories.where((cat) => 
      cat.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  void searchCategories(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await categoryRepository.getCategories();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
