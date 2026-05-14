import 'package:flutter/material.dart';
import 'package:medicare_app/data/repositories/order_repository.dart';
import 'package:medicare_app/domain/entities/order_entity.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository orderRepository;

  OrderProvider({required this.orderRepository});

  List<OrderEntity> _orders = [];
  OrderEntity? _selectedOrder;
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderEntity> get orders => _orders;
  OrderEntity? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await orderRepository.getMyOrders();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderDetail(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    
    // Try to find in local list first for instant display
    final localOrder = _orders.cast<OrderEntity?>().firstWhere(
      (o) => o?.id == orderId, 
      orElse: () => null
    );
    
    if (localOrder != null) {
      _selectedOrder = localOrder;
    } else {
      _selectedOrder = null;
    }
    
    notifyListeners();

    try {
      final fetchedOrder = await orderRepository.getOrderDetail(orderId);
      _selectedOrder = fetchedOrder;
    } catch (e) {
      // If we already have it from local list, don't show error unless fetch was critical
      if (_selectedOrder == null) {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await orderRepository.cancelOrder(orderId);
      if (success) {
        await fetchOrders(); // Refresh orders list
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<String> placeOrder({
    required String shippingAddressId,
    required String paymentMethod,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final orderId = await orderRepository.createOrder(
        shippingAddressId: shippingAddressId,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      return orderId;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
