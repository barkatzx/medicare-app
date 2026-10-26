import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../features/entity/user_entity.dart';

class SharedPrefsHelper {
  static const String _tokenKey = 'auth_token';
  static const String _secureTokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  SharedPrefsHelper(
    this._prefs, {
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
  }) : _secureStorage = secureStorage;

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _secureTokenKey, value: token);
    await _prefs.remove(_tokenKey);
  }

  Future<String?> getToken() async {
    final secureToken = await _secureStorage.read(key: _secureTokenKey);
    if (secureToken != null && secureToken.isNotEmpty) return secureToken;

    // Migrate existing sessions from plain preferences without logging users out.
    final legacyToken = _prefs.getString(_tokenKey);
    if (legacyToken == null || legacyToken.isEmpty) return null;

    await _secureStorage.write(key: _secureTokenKey, value: legacyToken);
    await _prefs.remove(_tokenKey);
    return legacyToken;
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _secureTokenKey);
    await _prefs.remove(_tokenKey);
  }

  Future<void> saveUser(UserEntity user) async {
    await _prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<UserEntity?> getUser() async {
    final userString = _prefs.getString(_userKey);
    if (userString != null) {
      final userData = json.decode(userString);
      return UserEntity.fromJson(userData);
    }
    return null;
  }

  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
