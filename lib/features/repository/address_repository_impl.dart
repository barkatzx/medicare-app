import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../entity/address_entity.dart';
import '../../core/storage/shared_prefs_helper.dart';
import 'address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final http.Client client;
  final SharedPrefsHelper prefsHelper;

  AddressRepositoryImpl({required this.client, required this.prefsHelper});

  @override
  Future<List<AddressEntity>> getAddresses() async {
    final token = await prefsHelper.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await client
        .get(
          Uri.parse(ApiConstants.addresses),
          headers: ApiConstants.getHeaders(token: token),
        )
        .timeout(ApiConstants.connectionTimeout);

    debugPrint('getAddresses status: ${response.statusCode}');
    debugPrint('getAddresses body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['data'] ?? [];
      return list.map((item) => AddressEntity.fromJson(item)).toList();
    }

    try {
      final data = json.decode(response.body);
      throw Exception(
        data['error'] ??
            data['message'] ??
            'Failed to fetch addresses: ${response.statusCode}',
      );
    } catch (_) {
      throw Exception('Failed to fetch addresses: ${response.statusCode}');
    }
  }

  @override
  Future<AddressEntity> addAddress(AddressEntity address) async {
    final token = await prefsHelper.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await client
        .post(
          Uri.parse(ApiConstants.addresses),
          headers: ApiConstants.getHeaders(token: token),
          body: json.encode(address.toJson()),
        )
        .timeout(ApiConstants.connectionTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      return AddressEntity.fromJson(data['data'] ?? data);
    }

    try {
      final data = json.decode(response.body);
      throw Exception(
        data['error'] ?? data['message'] ?? 'Failed to add address',
      );
    } catch (_) {
      throw Exception('Failed to add address');
    }
  }

  @override
  Future<AddressEntity> updateAddress(
    String id,
    Map<String, dynamic> data,
  ) async {
    final token = await prefsHelper.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await client
        .put(
          Uri.parse(ApiConstants.updateAddress(id)),
          headers: ApiConstants.getHeaders(token: token),
          body: json.encode(data),
        )
        .timeout(ApiConstants.connectionTimeout);

    debugPrint('updateAddress status: ${response.statusCode}');
    debugPrint('updateAddress body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseData = json.decode(response.body);
      return AddressEntity.fromJson(responseData['data'] ?? responseData);
    }

    try {
      final data = json.decode(response.body);
      throw Exception(
        data['error'] ?? data['message'] ?? 'Failed to update address',
      );
    } catch (_) {
      throw Exception('Failed to update address');
    }
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    final token = await prefsHelper.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await client
        .put(
          Uri.parse(ApiConstants.setDefaultAddress(id)),
          headers: ApiConstants.getHeaders(token: token),
          body: json.encode({'isDefault': true}),
        )
        .timeout(ApiConstants.connectionTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      try {
        final data = json.decode(response.body);
        throw Exception(
          data['error'] ?? data['message'] ?? 'Failed to set default address',
        );
      } catch (_) {
        throw Exception('Failed to set default address');
      }
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    final token = await prefsHelper.getToken();
    if (token == null) throw Exception('User not authenticated');

    try {
      final url = ApiConstants.deleteAddress(id);
      debugPrint('DEBUG: Calling DELETE: $url');

      final response = await client
          .delete(
            Uri.parse(url),
            headers: ApiConstants.getHeaders(
              token: token,
              includeContentType: false,
            ),
          )
          .timeout(ApiConstants.connectionTimeout);

      debugPrint('DEBUG: deleteAddress status: ${response.statusCode}');
      debugPrint('DEBUG: deleteAddress body: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final data = json.decode(response.body);
        throw Exception(
          data['error'] ??
              data['message'] ??
              'Failed to delete address: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('DEBUG: Error in deleteAddress: $e');
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }
}
