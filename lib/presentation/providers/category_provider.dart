import 'package:flutter/material.dart';
import 'package:medicare_app/data/repositories/category_repository.dart';
import 'package:medicare_app/domain/entities/category_entity.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository categoryRepository;

  CategoryProvider({required this.categoryRepository});

  List<CategoryEntity> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryEntity> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
