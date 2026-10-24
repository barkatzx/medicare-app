import 'package:medicare_app/features/entity/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getMyOrders();
  Future<OrderEntity> getOrderDetail(String orderId);
  Future<bool> cancelOrder(String orderId);
  Future<String> createOrder({required String paymentMethod, String? notes});
}
