import 'dart:convert';

import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:medicare_app/core/constants/api_constants.dart';
import 'package:medicare_app/core/storage/shared_prefs_helper.dart';
import 'package:medicare_app/features/entity/user_entity.dart';
import 'package:medicare_app/features/repository/auth_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late FlutterSecureStoragePlatform originalStoragePlatform;
  late TestFlutterSecureStoragePlatform testStoragePlatform;
  late SharedPreferences preferences;
  late SharedPrefsHelper storage;

  setUp(() async {
    originalStoragePlatform = FlutterSecureStoragePlatform.instance;
    testStoragePlatform = TestFlutterSecureStoragePlatform({});
    FlutterSecureStoragePlatform.instance = testStoragePlatform;
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    storage = SharedPrefsHelper(preferences);
  });

  tearDown(() {
    FlutterSecureStoragePlatform.instance = originalStoragePlatform;
  });

  test('login saves an approved customer and token securely', () async {
    final client = MockClient((request) async {
      expect(request.url, Uri.parse(ApiConstants.login));
      expect(jsonDecode(request.body)['phone_number'], '01700000000');
      return http.Response(
        jsonEncode({
          'data': {'token': 'session-token', 'user': _userJson()},
        }),
        200,
      );
    });
    final repository = AuthRepositoryImpl(
      client: client,
      sharedPreferencesHelper: storage,
    );

    final user = await repository.login(
      phoneNumber: '01700000000',
      password: 'test-password',
    );

    expect(user.id, 'customer-1');
    expect(await storage.getToken(), 'session-token');
    expect(await storage.getUser(), isNotNull);
    expect(preferences.getString('auth_token'), isNull);
    client.close();
  });

  test(
    'expired authentication clears the secure token and cached user',
    () async {
      await storage.saveToken('expired-token');
      await storage.saveUser(_user());
      final client = MockClient(
        (_) async =>
            http.Response(jsonEncode({'message': 'Session expired'}), 401),
      );
      final repository = AuthRepositoryImpl(
        client: client,
        sharedPreferencesHelper: storage,
      );

      await expectLater(repository.verifyAuth(), throwsA(isA<Exception>()));

      expect(testStoragePlatform.data, isEmpty);
      expect(await storage.getUser(), isNull);
      client.close();
    },
  );
}

Map<String, dynamic> _userJson() => {
  'id': 'customer-1',
  'name': 'Test Customer',
  'email': 'customer@example.com',
  'phone_number': '01700000000',
  'role': 'customer',
  'isApproved': true,
  'createdAt': '2026-01-01T00:00:00.000Z',
};

UserEntity _user() => UserEntity.fromJson(_userJson());
