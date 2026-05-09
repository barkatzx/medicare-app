import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicare_app/data/repositories/product_repository.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/product_entity.dart';
import '../datasources/local/shared_prefs_helper.dart';

class ProductRepositoryImpl implements ProductRepository {
  final http.Client client;
  final SharedPrefsHelper prefsHelper;

  ProductRepositoryImpl({required this.client, required this.prefsHelper});

  @override
  Future<PaginatedProductResponse> getProducts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await prefsHelper.getToken();
      final response = await client
          .get(
            Uri.parse('${ApiConstants.products}?page=$page&limit=$limit'),
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
          final productsData = responseData['data']['products'] as List;
          final paginationData = responseData['data']['pagination'] ?? {};
          
          final products = productsData
              .map((json) => ProductEntity.fromJson(json))
              .toList();
              
          return PaginatedProductResponse(
            products: products,
            hasNextPage: paginationData['hasNextPage'] ?? false,
          );
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load products');
        }
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Get products error: $e');
      throw Exception('Error loading products: $e');
    }
  }

  @override
  Future<PaginatedProductResponse> searchProducts(String query, {int page = 1, int limit = 20}) async {
    try {
      final token = await prefsHelper.getToken();
      final response = await client
          .get(
            Uri.parse('${ApiConstants.searchProducts}?q=$query&page=$page&limit=$limit'),
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
          final productsData = responseData['data']['products'] as List;
          final paginationData = responseData['data']['pagination'] ?? {};
          
          final products = productsData
              .map((json) => ProductEntity.fromJson(json))
              .toList();

          bool hasNextPage = false;
          if (paginationData['hasNextPage'] != null) {
             hasNextPage = paginationData['hasNextPage'];
          } else if (paginationData['page'] != null && paginationData['totalPages'] != null) {
             hasNextPage = paginationData['page'] < paginationData['totalPages'];
          }

          return PaginatedProductResponse(
            products: products,
            hasNextPage: hasNextPage,
          );
        } else {
          return PaginatedProductResponse(products: [], hasNextPage: false);
        }
      } else {
        return PaginatedProductResponse(products: [], hasNextPage: false);
      }
    } catch (e) {
      print('Search products error: $e');
      return PaginatedProductResponse(products: [], hasNextPage: false);
    }
  }
  @override
  Future<PaginatedProductResponse> getCategoryProducts(String categoryId, {int page = 1, int limit = 20}) async {
    try {
      final token = await prefsHelper.getToken();
      final response = await client
          .get(
            Uri.parse('${ApiConstants.categoryProducts(categoryId)}?page=$page&limit=$limit'),
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
          final productsData = responseData['data']['products'] as List;
          final paginationData = responseData['data']['pagination'] ?? {};
          
          final products = productsData
              .map((json) => ProductEntity.fromJson(json))
              .toList();

          bool hasNextPage = false;
          if (paginationData['hasNextPage'] != null) {
             hasNextPage = paginationData['hasNextPage'];
          } else if (paginationData['page'] != null && paginationData['totalPages'] != null) {
             hasNextPage = paginationData['page'] < paginationData['totalPages'];
          }

          return PaginatedProductResponse(
            products: products,
            hasNextPage: hasNextPage,
          );
        } else {
          return PaginatedProductResponse(products: [], hasNextPage: false);
        }
      } else {
        return PaginatedProductResponse(products: [], hasNextPage: false);
      }
    } catch (e) {
      print('Get category products error: $e');
      return PaginatedProductResponse(products: [], hasNextPage: false);
    }
  }
}
