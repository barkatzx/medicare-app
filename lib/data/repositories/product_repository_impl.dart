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
      final url = '${ApiConstants.products}?page=$page&limit=$limit';
      print('getProducts URL: $url');
      final token = await prefsHelper.getToken();
      final response = await client
          .get(
            Uri.parse(url),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      print('getProducts response status: ${response.statusCode}');

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
        final responseData = json.decode(response.body);
        print('getProducts error response: ${response.body}');
        throw Exception(responseData['message'] ?? 'Failed to load products (${response.statusCode})');
      }
    } catch (e) {
      print('Get products error: $e');
      rethrow;
    }
  }

  @override
  Future<PaginatedProductResponse> searchProducts(String query, {int page = 1, int limit = 20}) async {
    try {
      final token = await prefsHelper.getToken();
      final encodedQuery = Uri.encodeComponent(query.trim());
      final url = '${ApiConstants.searchProducts}?q=$encodedQuery&page=$page&limit=$limit';
      
      final response = await client
          .get(
            Uri.parse(url),
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
    return _getPaginatedProducts(
      '${ApiConstants.categoryProducts(categoryId)}?page=$page&limit=$limit',
      'Get category products',
    );
  }

  @override
  Future<PaginatedProductResponse> getTrendingProducts({int page = 1, int limit = 20}) async {
    return _getPaginatedProducts(
      ApiConstants.trendingProducts,
      'Get trending products',
    );
  }

  @override
  Future<PaginatedProductResponse> getFeaturedProducts({int page = 1, int limit = 20}) async {
    return _getPaginatedProducts(
      ApiConstants.featuredProducts,
      'Get featured products',
    );
  }

  @override
  Future<PaginatedProductResponse> getNewProducts({int page = 1, int limit = 20}) async {
    return _getPaginatedProducts(
      '${ApiConstants.newProducts}?page=$page&limit=$limit',
      'Get new products',
      useToken: false,
    );
  }

  @override
  Future<ProductEntity> getProductDetail(String id) async {
    try {
      final token = await prefsHelper.getToken();
      final response = await client
          .get(
            Uri.parse(ApiConstants.productDetail(id)),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(ApiConstants.connectionTimeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true && responseData['data'] != null) {
          return ProductEntity.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load product detail');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Get product detail error: $e');
      rethrow;
    }
  }

  Future<PaginatedProductResponse> _getPaginatedProducts(String url, String errorMessagePrefix, {bool useToken = true}) async {
    try {
      final token = useToken ? await prefsHelper.getToken() : null;
      final response = await client
          .get(
            Uri.parse(url),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true && responseData['data'] != null) {
          List productsData;
          bool hasNextPage = false;

          // Handle both Map (paginated) and List (direct) responses
          if (responseData['data'] is List) {
            productsData = responseData['data'] as List;
            hasNextPage = false;
          } else if (responseData['data'] is Map) {
            productsData = responseData['data']['products'] as List? ?? [];
            final paginationData = responseData['data']['pagination'] ?? {};
            
            if (paginationData['hasNextPage'] != null) {
              hasNextPage = paginationData['hasNextPage'];
            } else if (paginationData['page'] != null && paginationData['totalPages'] != null) {
              hasNextPage = paginationData['page'] < paginationData['totalPages'];
            }
          } else {
            productsData = [];
          }
          
          final products = productsData
              .map((json) => ProductEntity.fromJson(json))
              .toList();

          return PaginatedProductResponse(
            products: products,
            hasNextPage: hasNextPage,
          );
        } else {
          throw Exception(responseData['message'] ?? 'Unknown API error');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('$errorMessagePrefix error: $e');
      rethrow;
    }
  }
}
