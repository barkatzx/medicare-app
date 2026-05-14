import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicare_app/core/constants/api_constants.dart';
import 'package:medicare_app/data/repositories/order_repository.dart';
import 'package:medicare_app/domain/entities/order_entity.dart';
import 'package:medicare_app/data/datasources/local/shared_prefs_helper.dart';

class OrderRepositoryImpl implements OrderRepository {
  final http.Client client;
  final SharedPrefsHelper prefsHelper;

  OrderRepositoryImpl({required this.client, required this.prefsHelper});

  @override
  Future<List<OrderEntity>> getMyOrders() async {
    try {
      final token = await prefsHelper.getToken();
      final response = await client
          .get(
            Uri.parse(ApiConstants.myOrders),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(ApiConstants.connectionTimeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true && responseData['data'] != null) {
          final ordersData = responseData['data']['orders'] as List;
          return ordersData.map((json) => OrderEntity.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load orders');
      }
    } catch (e) {
      print('Get my orders error: $e');
      rethrow;
    }
  }

  @override
  Future<OrderEntity> getOrderDetail(String orderId) async {
    try {
      final token = await prefsHelper.getToken();
      final response = await client
          .get(
            Uri.parse(ApiConstants.myOrderDetail(orderId)),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(ApiConstants.connectionTimeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          // Handle both direct data object and nested { order: { ... } }
          if (data['id'] != null) {
            return OrderEntity.fromJson(data);
          } else if (data['order'] != null) {
            return OrderEntity.fromJson(data['order']);
          } else {
            throw Exception('Order details data format not recognized');
          }
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load order details');
        }
      } else {
        throw Exception('Server Error: ${response.statusCode} - ${responseData['message'] ?? 'Unable to fetch details'}');
      }
    } catch (e) {
      print('Get order detail error: $e');
      throw Exception('Network or Data Error: $e');
    }
  }

  @override
  Future<bool> cancelOrder(String orderId) async {
    try {
      final token = await prefsHelper.getToken();
      final response = await client
          .post(
            Uri.parse(ApiConstants.cancelOrder(orderId)),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(ApiConstants.connectionTimeout);

      final responseData = json.decode(response.body);
      return response.statusCode == 200 && responseData['success'] == true;
    } catch (e) {
      print('Cancel order error: $e');
      return false;
    }
  }
  @override
  Future<String> createOrder({
    required String shippingAddressId,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final token = await prefsHelper.getToken();
      final body = {
        'shippingAddressId': shippingAddressId,
        'paymentMethod': paymentMethod,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await client
          .post(
            Uri.parse(ApiConstants.createOrder),
            headers: ApiConstants.getHeaders(token: token),
            body: json.encode(body),
          )
          .timeout(ApiConstants.connectionTimeout);

      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true && responseData['data'] != null) {
          final id = responseData['data']['id']?.toString() ??
              responseData['data']['_id']?.toString();
          if (id == null) throw Exception('Order created but ID not returned');
          return id;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to place order');
        }
      } else {
        throw Exception(
            responseData['message'] ?? 'Server error (${response.statusCode})');
      }
    } catch (e) {
      print('Create order error: $e');
      if (e is http.ClientException) {
        throw Exception('Network error: Please check your internet connection');
      }
      rethrow;
    }
  }
}
