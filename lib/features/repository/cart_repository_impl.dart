import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:medicare_app/features/repository/cart_repository.dart';
import '../../core/constants/api_constants.dart';
import '../entity/cart_entity.dart';
import '../../core/storage/shared_prefs_helper.dart';

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

    debugPrint('getCart status: ${response.statusCode}');

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
      debugPrint('getCartCount error: $e');
      return 0;
    }
  }

  @override
  Future<void> addToCart(String productId, int quantity) async {
    final token = await prefsHelper.getToken();
    if (token == null) throw Exception('User not authenticated');

    final body = {'productId': productId, 'quantity': quantity};
    final response = await client
        .post(
          Uri.parse(ApiConstants.addToCart),
          headers: ApiConstants.getHeaders(token: token),
          body: json.encode(body),
        )
        .timeout(ApiConstants.connectionTimeout);

    debugPrint('addToCart status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final errData = json.decode(response.body);
    throw Exception(
      errData['error'] ?? errData['message'] ?? 'Failed to add to cart',
    );
  }

  @override
  Future<void> updateCartItem(String itemId, int quantity) async {
    final token = await prefsHelper.getToken();
    if (token == null) throw Exception('User not authenticated');

    final url = ApiConstants.cartItem(itemId);
    debugPrint('updateCartItem PUT: $url, quantity: $quantity');

    final response = await client
        .put(
          Uri.parse(url),
          headers: ApiConstants.getHeaders(token: token),
          body: json.encode({'quantity': quantity}),
        )
        .timeout(ApiConstants.connectionTimeout);

    debugPrint('updateCartItem status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final errData = json.decode(response.body);
    throw Exception(
      errData['error'] ?? errData['message'] ?? 'Failed to update cart item',
    );
  }

  @override
  Future<void> removeFromCart(String itemId) async {
    final token = await prefsHelper.getToken();
    if (token == null) throw Exception('User not authenticated');

    final url = ApiConstants.removeFromCart(itemId);
    debugPrint('removeFromCart DELETE: $url');

    final response = await client
        .delete(Uri.parse(url), headers: ApiConstants.getHeaders(token: token))
        .timeout(ApiConstants.connectionTimeout);

    debugPrint('removeFromCart status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final errData = json.decode(response.body);
    throw Exception(
      errData['error'] ?? errData['message'] ?? 'Failed to remove from cart',
    );
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

    debugPrint('clearCart status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final errData = json.decode(response.body);
    throw Exception(
      errData['error'] ?? errData['message'] ?? 'Failed to clear cart',
    );
  }
}
