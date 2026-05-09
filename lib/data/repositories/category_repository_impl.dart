import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicare_app/core/constants/api_constants.dart';
import 'package:medicare_app/data/datasources/local/shared_prefs_helper.dart';
import 'package:medicare_app/data/repositories/category_repository.dart';
import 'package:medicare_app/domain/entities/category_entity.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final http.Client client;
  final SharedPrefsHelper prefsHelper;

  CategoryRepositoryImpl({required this.client, required this.prefsHelper});

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      final token = await prefsHelper.getToken();
      final response = await client
          .get(
            Uri.parse(ApiConstants.categories),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final categoriesData = responseData['data'] as List;
          return categoriesData
              .map((json) => CategoryEntity.fromJson(json))
              .toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load categories');
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error loading categories: $e');
    }
  }
}
