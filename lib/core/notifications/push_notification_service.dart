import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/shared_prefs_helper.dart';
import '../routes/app_routes.dart';

const androidNotificationChannel = AndroidNotificationChannel(
  'medicare_notifications',
  'MediCare notifications',
  description: 'Updates about your MediCare account and orders',
  importance: Importance.high,
);

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // System-rendered notification messages are displayed by Android while the
  // app is backgrounded. No local notification is posted here to avoid dupes.
}

class PushNotificationService {
  PushNotificationService({
    required http.Client client,
    required SharedPrefsHelper prefsHelper,
    required GlobalKey<NavigatorState> navigatorKey,
    FirebaseMessaging? messaging,
  }) : _client = client,
       _prefsHelper = prefsHelper,
       _navigatorKey = navigatorKey,
       _messaging = messaging ?? FirebaseMessaging.instance;

  final http.Client _client;
  final SharedPrefsHelper _prefsHelper;
  final GlobalKey<NavigatorState> _navigatorKey;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _authenticated = false;
  bool _notificationsAllowed = false;
  String? _currentFcmToken;
  String? _pendingNotificationId;

  Future<void> initialize({required bool authenticated}) async {
    if (_initialized || kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      _authenticated = authenticated;
      return;
    }
    _authenticated = authenticated;
    try {
      await _localNotifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_notification'),
        ),
        onDidReceiveNotificationResponse: (response) =>
            _openNotificationId(response.payload),
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidNotificationChannel);

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(_showForegroundNotification);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteTap);
      // The backend endpoint accepts an FCM registration token. In
      // firebase_messaging 17, onRegistered emits a Firebase Installation ID,
      // so use the deprecated FCM-token stream until the server contract changes.
      // ignore: deprecated_member_use
      _messaging.onTokenRefresh.listen((token) {
        _currentFcmToken = token;
        if (_authenticated && _notificationsAllowed) _registerToken(token);
      });

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) _handleRemoteTap(initialMessage);
      _initialized = true;
      if (authenticated) await registerCurrentToken();
    } catch (error, stackTrace) {
      debugPrint('Push notification setup failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> setAuthenticated(bool authenticated) async {
    _authenticated = authenticated;
    if (authenticated) {
      await registerCurrentToken();
      flushPendingNavigation();
    }
  }

  Future<void> registerCurrentToken() async {
    if (!_initialized || !_authenticated) return;
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        _notificationsAllowed = false;
        debugPrint('Notification permission denied; device token not registered.');
        return;
      }
      _notificationsAllowed =
          settings.authorizationStatus != AuthorizationStatus.notDetermined;
      if (!_notificationsAllowed) return;
      // Keep using the actual FCM token required by the existing server API.
      // ignore: deprecated_member_use
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      _currentFcmToken = token;
      await _registerToken(token);
    } catch (error) {
      debugPrint('Could not register FCM token: $error');
    }
  }

  Future<void> unregisterCurrentToken() async {
    try {
      // ignore: deprecated_member_use
      final token = _currentFcmToken ?? await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      final authToken = await _prefsHelper.getToken();
      if (authToken == null || authToken.isEmpty) return;
      await _client
          .delete(
            Uri.parse(ApiConstants.deviceNotificationToken),
            headers: ApiConstants.getHeaders(token: authToken),
            body: json.encode({'token': token}),
          )
          .timeout(ApiConstants.connectionTimeout);
    } catch (error) {
      // Logout must remain possible during network outages. The server can
      // remove stale tokens when a later authenticated registration occurs.
      debugPrint('Could not unregister FCM token: $error');
    } finally {
      _authenticated = false;
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      final authToken = await _prefsHelper.getToken();
      if (authToken == null || authToken.isEmpty) return;
      final response = await _client
          .post(
            Uri.parse(ApiConstants.deviceNotificationToken),
            headers: ApiConstants.getHeaders(token: authToken),
            body: json.encode({'token': token, 'platform': 'android'}),
          )
          .timeout(ApiConstants.connectionTimeout);
      if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('FCM token registration skipped: authenticated session expired.');
      } else if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('FCM token registration failed (${response.statusCode}).');
      }
    } catch (error) {
      debugPrint('FCM token registration failed: $error');
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) return;
    final id = _notificationId(message);
    await _localNotifications.show(
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title ?? 'MediCare',
      body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicare_notifications',
          'MediCare notifications',
          channelDescription: 'Updates about your MediCare account and orders',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_notification',
        ),
      ),
      payload: id,
    );
  }

  void _handleRemoteTap(RemoteMessage message) =>
      _openNotificationId(_notificationId(message));

  String? _notificationId(RemoteMessage message) =>
      message.data['notificationId']?.toString();

  void _openNotificationId(String? id) {
    if (id == null || id.trim().isEmpty) {
      debugPrint('Notification tap ignored: notificationId is missing.');
      return;
    }
    if (!_authenticated || _navigatorKey.currentState == null) {
      _pendingNotificationId = id;
      return;
    }
    _navigatorKey.currentState!.pushNamed(
      AppRoutes.notificationDetail,
      arguments: id,
    );
  }

  void flushPendingNavigation() {
    final id = _pendingNotificationId;
    if (id == null || !_authenticated || _navigatorKey.currentState == null) return;
    _pendingNotificationId = null;
    _openNotificationId(id);
  }
}
