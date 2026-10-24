import 'package:medicare_app/features/cart/domain/entities/cart_entity.dart';

abstract class CartRepository {
  Future<CartEntity> getCart();
  Future<int> getCartCount();
  Future<void> addToCart(String productId, int quantity);
  Future<void> updateCartItem(String itemId, int quantity);
  Future<void> removeFromCart(String itemId);
  Future<void> clearCart();
}
