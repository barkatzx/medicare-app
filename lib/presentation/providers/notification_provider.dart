import 'package:flutter/material.dart';
import 'package:medicare_app/data/repositories/notification_repository.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository notificationRepository;

  NotificationProvider({required this.notificationRepository});

  List<NotificationEntity> _notifications = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
  int _unreadCount = 0;
  bool _unreadOnly = false;
  String? _errorMessage;

  List<NotificationEntity> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  int get unreadCount => _unreadCount;
  bool get unreadOnly => _unreadOnly;
  String? get errorMessage => _errorMessage;

  Future<void> loadNotifications() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newNotifications = await notificationRepository.getNotifications(
        page: 1,
        limit: 10,
        unreadOnly: _unreadOnly,
      );

      _notifications = newNotifications;
      _currentPage = 2;
      _hasMore = newNotifications.length == 10;

      await loadUnreadCount();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final newNotifications = await notificationRepository.getNotifications(
        page: _currentPage,
        limit: 10,
        unreadOnly: _unreadOnly,
      );

      _notifications.addAll(newNotifications);
      _hasMore = newNotifications.length == 10;
      if (_hasMore) _currentPage++;
    } catch (e) {
      print('Error loading more notifications: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await notificationRepository.getUnreadCount();
      notifyListeners();
    } catch (e) {
      print('Error loading unread count: $e');
    }
  }

  Future<void> toggleUnreadFilter() async {
    _unreadOnly = !_unreadOnly;
    _notifications.clear();
    _currentPage = 1;
    _hasMore = true;
    await loadNotifications();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await notificationRepository.markAsRead(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        if (_unreadOnly) {
          _notifications.removeAt(index);
        } else {
          _notifications[index] = NotificationEntity(
            id: _notifications[index].id,
            title: _notifications[index].title,
            message: _notifications[index].message,
            type: _notifications[index].type,
            isRead: true,
            data: _notifications[index].data,
            createdAt: _notifications[index].createdAt,
            readAt: DateTime.now(),
          );
        }
      }

      await loadUnreadCount();
      notifyListeners();
    } catch (e) {
      print('Error marking as read: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await notificationRepository.markAllAsRead();

      // Update local state - mark all as read
      if (_unreadOnly) {
        _notifications.clear();
      } else {
        _notifications = _notifications
            .map(
              (n) => NotificationEntity(
                id: n.id,
                title: n.title,
                message: n.message,
                type: n.type,
                isRead: true,
                data: n.data,
                createdAt: n.createdAt,
                readAt: DateTime.now(),
              ),
            )
            .toList();
      }

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('Error marking all as read: $e');
      rethrow;
    }
  }

  void clearNotifications() {
    _notifications.clear();
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
