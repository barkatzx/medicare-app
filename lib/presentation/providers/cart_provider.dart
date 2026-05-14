import 'package:flutter/material.dart';
import 'package:medicare_app/data/repositories/cart_repository.dart';
import 'package:medicare_app/core/utils/logger.dart';
import '../../domain/entities/cart_entity.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository cartRepository;

  CartProvider({required this.cartRepository});

  CartEntity? _cart;
  bool _isLoading = false;
  bool _isUpdating = false;
  int _cartItemCount = 0;

  CartEntity? get cart => _cart;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  int get cartItemCount => _cartItemCount;
  List<CartItemEntity> get cartItems => _cart?.items ?? [];
  double get subtotal => _cart?.subtotal ?? 0.0;
  double get total => _cart?.total ?? 0.0;
  double get totalSavings => _cart?.totalSavings ?? 0.0;

  Function(String message, {bool isError})? onShowMessage;

  Future<void> loadCart({bool silent = false}) async {
    if (_isLoading) return;

    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _cart = await cartRepository.getCart();
      _cartItemCount = _cart?.itemCount ?? 0;
      Logger.log('Cart loaded: ${_cart?.items.length} items');
    } catch (e) {
      Logger.error('Error loading cart', e);
      _cart = null;
      _cartItemCount = 0;
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> loadCartCount() async {
    try {
      _cartItemCount = await cartRepository.getCartCount();
      notifyListeners();
    } catch (e) {
      print('Error loading cart count: $e');
      _cartItemCount = 0;
    }
  }

  Future<bool> addToCart(String productId, int quantity) async {
    try {
      print('Adding to cart: productId=$productId, quantity=$quantity');

      // Optimistic increment
      _cartItemCount += quantity;
      notifyListeners();

      // Call API to add to cart
      await cartRepository.addToCart(productId, quantity);

      // Quietly reload cart to get updated items in the background
      loadCart(silent: true);

      // Show success message
      onShowMessage?.call('Product added to cart', isError: false);

      return true;
    } catch (e) {
      // Revert optimistic count
      _cartItemCount -= quantity;
      notifyListeners();
      
      Logger.error('Error adding to cart', e);
      onShowMessage?.call('Failed to add product to cart', isError: true);
      return false;
    }
  }

  // Optimistic update for quantity - NO LOADING SPINNER
  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (_isUpdating) return;

    // Find the item index
    final itemIndex =
        _cart?.items.indexWhere((item) => item.id == itemId) ?? -1;
    if (itemIndex == -1) return;

    // Create updated item
    final oldItem = _cart!.items[itemIndex];
    final updatedItem = CartItemEntity(
      id: oldItem.id,
      quantity: newQuantity,
      product: oldItem.product,
      itemTotal: oldItem.product.price * newQuantity, // Use regular price for subtotal
      itemSavings: oldItem.product.discountedPrice != null
          ? (oldItem.product.price - oldItem.product.finalPrice) * newQuantity
          : 0,
    );

    // Update local cart immediately (optimistic update)
    final updatedItems = List<CartItemEntity>.from(_cart!.items);
    updatedItems[itemIndex] = updatedItem;

    // Recalculate totals
    final newSubtotal = updatedItems.fold(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
    final newTotalSavings = updatedItems.fold(
      0.0,
      (sum, item) => sum + ((item.product.price - item.product.finalPrice) * item.quantity),
    );
    final newTotal = newSubtotal - newTotalSavings;
    final newItemCount = updatedItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );

    final updatedCart = CartEntity(
      items: updatedItems,
      subtotal: newSubtotal,
      totalSavings: newTotalSavings,
      total: newTotal,
      itemCount: newItemCount,
    );

    // Update UI immediately - NO LOADING SPINNER
    _cart = updatedCart;
    _cartItemCount = newItemCount;
    notifyListeners();

    // Send API request in background - NO UI BLOCKING
    _isUpdating = true;

    try {
      await cartRepository.updateCartItem(itemId, newQuantity);
      onShowMessage?.call('Quantity updated', isError: false);
    } catch (e) {
      // Rollback on failure
      loadCart(silent: true);
      onShowMessage?.call('Failed to update quantity', isError: true);
    } finally {
      _isUpdating = false;
    }
  }

  Future<void> removeFromCart(String itemId) async {
    if (_isUpdating) return;

    // Find the item
    final itemIndex =
        _cart?.items.indexWhere((item) => item.id == itemId) ?? -1;
    if (itemIndex == -1) return;

    // Optimistic remove
    final updatedItems = List<CartItemEntity>.from(_cart!.items);
    updatedItems.removeAt(itemIndex);

    final newSubtotal = updatedItems.fold(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
    final newTotalSavings = updatedItems.fold(
      0.0,
      (sum, item) => sum + ((item.product.price - item.product.finalPrice) * item.quantity),
    );
    final newTotal = newSubtotal - newTotalSavings;
    final newItemCount = updatedItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );

    _cart = CartEntity(
      items: updatedItems,
      subtotal: newSubtotal,
      totalSavings: newTotalSavings,
      total: newTotal,
      itemCount: newItemCount,
    );
    _cartItemCount = newItemCount;
    notifyListeners();

    // Send API request
    _isUpdating = true;

    try {
      await cartRepository.removeFromCart(itemId);
      onShowMessage?.call('Item removed from cart', isError: false);
    } catch (e) {
      loadCart(silent: true);
      onShowMessage?.call('Failed to remove item', isError: true);
    } finally {
      _isUpdating = false;
    }
  }

  Future<void> clearCart() async {
    if (_isUpdating) return;

    // Save old cart for rollback
    final oldCart = _cart;

    // Optimistic clear
    _cart = CartEntity(
      items: [],
      subtotal: 0,
      totalSavings: 0,
      total: 0,
      itemCount: 0,
    );
    _cartItemCount = 0;
    notifyListeners();

    _isUpdating = true;

    try {
      await cartRepository.clearCart();
      onShowMessage?.call('Cart cleared successfully', isError: false);
    } catch (e) {
      // Revert on failure
      _cart = oldCart;
      _cartItemCount = oldCart?.itemCount ?? 0;
      notifyListeners();

      onShowMessage?.call('Failed to clear cart', isError: true);
    } finally {
      _isUpdating = false;
    }
  }
}
