import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../features/entity/user_entity.dart';

class SharedPrefsHelper {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  final SharedPreferences _prefs;

  SharedPrefsHelper(this._prefs);

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
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
