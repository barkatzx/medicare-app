import 'dart:convert';

import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:medicare_app/core/storage/shared_prefs_helper.dart';
import 'package:medicare_app/features/repository/product_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late FlutterSecureStoragePlatform originalStoragePlatform;
  late TestFlutterSecureStoragePlatform testStoragePlatform;
  late SharedPrefsHelper prefsHelper;

  setUp(() async {
    originalStoragePlatform = FlutterSecureStoragePlatform.instance;
    testStoragePlatform = TestFlutterSecureStoragePlatform({});
    FlutterSecureStoragePlatform.instance = testStoragePlatform;
    SharedPreferences.setMockInitialValues({});
    prefsHelper = SharedPrefsHelper(await SharedPreferences.getInstance());
  });

  tearDown(() {
    FlutterSecureStoragePlatform.instance = originalStoragePlatform;
  });

  for (final endpoint in ['trending', 'featured']) {
    test('$endpoint requests the requested page and limit', () async {
      final client = MockClient((request) async {
        expect(request.url.path, endsWith('/products/$endpoint'));
        expect(request.url.queryParameters, {'page': '2', 'limit': '20'});
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'products': [],
              'pagination': {
                'page': 2,
                'limit': 20,
                'total': 40,
                'totalPages': 2,
                'hasNextPage': false,
                'hasPrevPage': true,
              },
            },
          }),
          200,
        );
      });
      final repository = ProductRepositoryImpl(
        client: client,
        prefsHelper: prefsHelper,
      );

      final result = endpoint == 'trending'
          ? await repository.getTrendingProducts(page: 2, limit: 20)
          : await repository.getFeaturedProducts(page: 2, limit: 20);

      expect(result.products, isEmpty);
      expect(result.hasNextPage, isFalse);
      client.close();
    });
  }
}
