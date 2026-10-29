import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/storage/shared_prefs_helper.dart';
import 'notification_entity.dart';

class NotificationPage {
  final List<NotificationEntity> items;
  final bool hasMore;
  const NotificationPage(this.items, this.hasMore);
}

class NotificationRepository {
  final http.Client client;
  final SharedPrefsHelper prefsHelper;
  NotificationRepository({required this.client, required this.prefsHelper});

  Future<Map<String, String>> _headers() async {
    final token = await prefsHelper.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }
    return ApiConstants.getHeaders(token: token);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = json.decode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected server response');
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['success'] == false) {
      throw Exception(
        body['message'] ?? 'Request failed (${response.statusCode})',
      );
    }
    return body;
  }

  Future<NotificationPage> fetchPage(int page, int limit) async {
    final uri = Uri.parse(
      ApiConstants.notifications,
    ).replace(queryParameters: {'page': '$page', 'limit': '$limit'});
    final body = _decode(
      await client
          .get(uri, headers: await _headers())
          .timeout(ApiConstants.connectionTimeout),
    );
    final data = body['data'];
    final list = data is List
        ? data
        : data is Map
        ? (data['notifications'] ?? data['items'] ?? [])
        : [];
    final pagination = data is Map
        ? (data['pagination'] ?? body['pagination'] ?? {})
        : (body['pagination'] ?? {});
    final items = list is List
        ? list
              .whereType<Map>()
              .map(
                (item) => NotificationEntity.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <NotificationEntity>[];
    final hasMore = pagination is Map && pagination['hasMore'] == true;
    return NotificationPage(items, hasMore);
  }

  Future<NotificationEntity> fetchDetail(String id) async {
    final body = _decode(
      await client
          .get(
            Uri.parse(ApiConstants.notificationDetail(Uri.encodeComponent(id))),
            headers: await _headers(),
          )
          .timeout(ApiConstants.connectionTimeout),
    );
    final data = body['data'];
    final notification = data is Map && data['notification'] is Map
        ? data['notification']
        : data;
    if (notification is! Map) {
      throw Exception('Notification details were not returned');
    }
    return NotificationEntity.fromJson(Map<String, dynamic>.from(notification));
  }

  Future<void> markAllRead() async {
    _decode(
      await client
          .post(
            Uri.parse(ApiConstants.markAllNotificationsRead),
            headers: await _headers(),
          )
          .timeout(ApiConstants.connectionTimeout),
    );
  }

  Future<void> deleteAll() async {
    _decode(
      await client
          .delete(
            Uri.parse(ApiConstants.deleteAllNotifications),
            headers: await _headers(),
          )
          .timeout(ApiConstants.connectionTimeout),
    );
  }
}
