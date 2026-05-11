import 'product_entity.dart';
import 'address_entity.dart';

class OrderEntity {
  final String id;
  final String userId;
  final String shippingAddressId;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final List<OrderItemEntity> items;
  final PaymentEntity? payment;
  final AddressEntity? shippingAddress;

  OrderEntity({
    required this.id,
    required this.userId,
    required this.shippingAddressId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
    this.payment,
    this.shippingAddress,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return OrderEntity(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      shippingAddressId: json['shippingAddressId']?.toString() ?? '',
      totalAmount: parseDouble(json['totalAmount']),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() 
          : DateTime.now(),
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItemEntity.fromJson(item))
          .toList(),
      payment: json['payment'] != null ? PaymentEntity.fromJson(json['payment']) : null,
      shippingAddress: json['shippingAddress'] != null ? AddressEntity.fromJson(json['shippingAddress']) : null,
    );
  }
}

class OrderItemEntity {
  final String id;
  final String productId;
  final int quantity;
  final double price;
  final ProductEntity? product;

  OrderItemEntity({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return OrderItemEntity(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      quantity: json['quantity'] != null ? int.tryParse(json['quantity'].toString()) ?? 0 : 0,
      price: parseDouble(json['price']),
      product: json['product'] != null ? ProductEntity.fromJson(json['product']) : null,
    );
  }
}

class PaymentEntity {
  final String id;
  final String method;
  final String status;
  final DateTime? paidAt;

  PaymentEntity({
    required this.id,
    required this.method,
    required this.status,
    this.paidAt,
  });

  factory PaymentEntity.fromJson(Map<String, dynamic> json) {
    return PaymentEntity(
      id: json['id']?.toString() ?? '',
      method: json['method']?.toString() ?? 'unknown',
      status: json['status']?.toString() ?? 'unknown',
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt'].toString()) : null,
    );
  }
}
