import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicare_app/data/repositories/cart_repository.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/cart_entity.dart';
import '../datasources/local/shared_prefs_helper.dart';

class CartRepositoryImpl implements CartRepository {
  final http.Client client;
  final SharedPrefsHelper prefsHelper;

  CartRepositoryImpl({required this.client, required this.prefsHelper});

  @override
  Future<CartEntity> getCart() async {
    final token = await prefsHelper.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await client
        .get(
          Uri.parse(ApiConstants.cart),
          headers: ApiConstants.getHeaders(token: token),
        )
        .timeout(ApiConstants.connectionTimeout);

    print('getCart status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return CartEntity.fromJson(data['data']);
      }
      return CartEntity.fromJson(data);
    }
    throw Exception('Failed to load cart');
  }

  @override
  Future<int> getCartCount() async {
    final token = await prefsHelper.getToken();
    if (token == null) return 0;

    try {
      final response = await client
          .get(
            Uri.parse(ApiConstants.cartCount),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Backend returns: { message: "...", data: { count: N } }
        return data['data']?['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('getCartCount error: $e');
      return 0;
    }
  }

  @override
  Future<void> addToCart(String productId, int quantity) async {
    final token = await prefsHelper.getToken();
    if (token == null) throw Exception('User not authenticated');

    final body = {'productId': productId, 'quantity': quantity};
    print('addToCart body: $body');

    final response = await client
        .post(
          Uri.parse(ApiConstants.addToCart),
          headers: ApiConstants.getHeaders(token: token),
          body: json.encode(body),
        )
        .timeout(ApiConstants.connectionTimeout);

    print('addToCart status: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final errData = json.decode(response.body);
    throw Exception(errData['error'] ?? errData['message'] ?? 'Failed to add to cart');
  }

  @override
  Future<void> updateCartItem(String itemId, int quantity) async {
    final token = await prefsHelper.getToken();
    if (token == null) throw Exception('User not authenticated');

    final url = ApiConstants.cartItem(itemId);
    print('updateCartItem PUT: $url, quantity: $quantity');

    final response = await client
        .put(
          Uri.parse(url),
          headers: ApiConstants.getHeaders(token: token),
          body: json.encode({'quantity': quantity}),
        )
        .timeout(ApiConstants.connectionTimeout);

    print('updateCartItem status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final errData = json.decode(response.body);
    throw Exception(errData['error'] ?? errData['message'] ?? 'Failed to update cart item');
  }

  @override
  Future<void> removeFromCart(String itemId) async {
    final token = await prefsHelper.getToken();
    if (token == null) throw Exception('User not authenticated');

    final url = ApiConstants.removeFromCart(itemId);
    print('removeFromCart DELETE: $url');

    final response = await client
        .delete(
          Uri.parse(url),
          headers: ApiConstants.getHeaders(token: token),
        )
        .timeout(ApiConstants.connectionTimeout);

    print('removeFromCart status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final errData = json.decode(response.body);
    throw Exception(errData['error'] ?? errData['message'] ?? 'Failed to remove from cart');
  }

  @override
  Future<void> clearCart() async {
    final token = await prefsHelper.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await client
        .delete(
          Uri.parse(ApiConstants.clearCart),
          headers: ApiConstants.getHeaders(token: token),
        )
        .timeout(ApiConstants.connectionTimeout);

    print('clearCart status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final errData = json.decode(response.body);
    throw Exception(errData['error'] ?? errData['message'] ?? 'Failed to clear cart');
  }
}
