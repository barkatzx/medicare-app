import 'package:medicare_app/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getMyOrders();
  Future<OrderEntity> getOrderDetail(String orderId);
  Future<bool> cancelOrder(String orderId);
  Future<String> createOrder({
    required String shippingAddressId,
    required String paymentMethod,
    String? notes,
  });
}
