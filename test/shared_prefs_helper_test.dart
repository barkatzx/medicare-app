import 'dart:convert';

import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicare_app/core/storage/shared_prefs_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late FlutterSecureStoragePlatform originalStoragePlatform;
  late TestFlutterSecureStoragePlatform testStoragePlatform;

  setUp(() {
    originalStoragePlatform = FlutterSecureStoragePlatform.instance;
    testStoragePlatform = TestFlutterSecureStoragePlatform({});
    FlutterSecureStoragePlatform.instance = testStoragePlatform;
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    FlutterSecureStoragePlatform.instance = originalStoragePlatform;
  });

  test('migrates an existing token into secure storage', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('auth_token', 'legacy-token');
    final storage = SharedPrefsHelper(preferences);

    expect(await storage.getToken(), 'legacy-token');
    expect(testStoragePlatform.data['auth_token'], 'legacy-token');
    expect(preferences.getString('auth_token'), isNull);
  });

  test('saves and clears tokens only in secure storage', () async {
    final preferences = await SharedPreferences.getInstance();
    final storage = SharedPrefsHelper(preferences);

    await storage.saveToken('new-token');
    expect(testStoragePlatform.data['auth_token'], 'new-token');
    expect(preferences.getString('auth_token'), isNull);

    await storage.clearToken();
    expect(testStoragePlatform.data, isEmpty);
    expect(preferences.getString('auth_token'), isNull);
  });

  test('migrates cached user data into secure storage', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'user_data',
      jsonEncode({
        'id': 'customer-1',
        'name': 'Test Customer',
        'email': 'customer@example.com',
        'phone_number': '01700000000',
        'role': 'customer',
        'isApproved': true,
        'createdAt': '2026-01-01T00:00:00.000Z',
      }),
    );
    final storage = SharedPrefsHelper(preferences);

    final user = await storage.getUser();

    expect(user?.id, 'customer-1');
    expect(testStoragePlatform.data['user_data'], isNotNull);
    expect(preferences.getString('user_data'), isNull);
  });
}
