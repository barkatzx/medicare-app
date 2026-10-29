import 'package:flutter/foundation.dart';
import 'notification_entity.dart';
import 'notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository repository;
  NotificationProvider(this.repository);
  static const int pageSize = 20;
  final List<NotificationEntity> _items = [];
  List<NotificationEntity> get items => List.unmodifiable(_items);
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isActionLoading = false;
  String? _error;
  int _unreadCount = 0;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount < 0 ? 0 : _unreadCount;
  NotificationEntity? _detail;
  NotificationEntity? get detail => _detail;
  bool _detailLoading = false;
  bool get detailLoading => _detailLoading;
  String? _detailError;
  String? get detailError => _detailError;

  void _recount() {
    _unreadCount = _items.where((n) => !n.isRead).length;
  }

  Future<void> load({bool refresh = false}) async {
    if (_isLoading || _isLoadingMore) return;
    final first = refresh || _items.isEmpty;
    if (!first && !_hasMore) return;
    if (first) {
      _isLoading = true;
      _error = null;
      if (refresh) {
        _page = 1;
        _hasMore = true;
      }
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();
    try {
      final result = await repository.fetchPage(
        first ? 1 : _page + 1,
        pageSize,
      );
      if (first) {
        _items
          ..clear()
          ..addAll(result.items);
        _page = 1;
      } else {
        _items.addAll(result.items);
        _page++;
      }
      _hasMore = result.hasMore;
      _recount();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<NotificationEntity?> loadDetail(String id) async {
    _detailLoading = true;
    _detailError = null;
    _detail = null;
    notifyListeners();
    try {
      _detail = await repository.fetchDetail(id);
      final index = _items.indexWhere((n) => n.id == id);
      if (index >= 0) _items[index] = _detail!;
      _recount();
      return _detail;
    } catch (e) {
      _detailError = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _detailLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAllRead() async {
    _isActionLoading = true;
    notifyListeners();
    try {
      await repository.markAllRead();
      for (var i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(isRead: true);
      }
      _recount();
      await load(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAll() async {
    _isActionLoading = true;
    notifyListeners();
    try {
      await repository.deleteAll();
      _items.clear();
      _unreadCount = 0;
      _page = 1;
      _hasMore = true;
      _error = null;
      await load(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }
}
