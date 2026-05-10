import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicare_app/data/repositories/notification_repository.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/notification_entity.dart';
import '../datasources/local/shared_prefs_helper.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final http.Client client;
  final SharedPrefsHelper prefsHelper;

  NotificationRepositoryImpl({required this.client, required this.prefsHelper});

  @override
  Future<List<NotificationEntity>> getNotifications({
    int page = 1,
    int limit = 10,
    bool unreadOnly = false,
  }) async {
    try {
      final token = await prefsHelper.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final uri = Uri.parse(ApiConstants.notifications).replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (unreadOnly) 'unreadOnly': 'true',
        },
      );

      final response = await client
          .get(
            uri,
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          final notificationsData =
              responseData['data']['notifications'] as List? ?? [];
          return notificationsData
              .map((json) => NotificationEntity.fromJson(json))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Error loading notifications: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final token = await prefsHelper.getToken();
      if (token == null) {
        return 0;
      }

      final uri = Uri.parse(ApiConstants.notifications).replace(
        queryParameters: {'unreadOnly': 'true'},
      );

      final response = await client
          .get(
            uri,
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          final totalCount = responseData['data']['totalCount'] ?? 0;
          if (totalCount > 0) return totalCount;
          
          final notifications =
              responseData['data']['notifications'] as List? ?? [];
          return notifications.length;
        }
        return 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final token = await prefsHelper.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .put(
            Uri.parse(ApiConstants.markNotificationRead(notificationId)),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorBody = json.decode(response.body);
        throw Exception(
          errorBody['message'] ?? 'Failed to mark notification as read',
        );
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final token = await prefsHelper.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .put(
            Uri.parse(ApiConstants.markAllRead),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to mark all as read');
      }
    } catch (e) {
      throw Exception('Error marking all notifications as read: $e');
    }
  }
}
