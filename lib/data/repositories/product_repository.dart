import 'package:medicare_app/domain/entities/product_entity.dart';

class PaginatedProductResponse {
  final List<ProductEntity> products;
  final bool hasNextPage;

  PaginatedProductResponse({
    required this.products,
    required this.hasNextPage,
  });
}

abstract class ProductRepository {
  Future<PaginatedProductResponse> getProducts({int page = 1, int limit = 20});
  Future<PaginatedProductResponse> searchProducts(String query, {int page = 1, int limit = 20});
  Future<PaginatedProductResponse> getCategoryProducts(String categoryId, {int page = 1, int limit = 20});
}
