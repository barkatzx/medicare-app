import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicare_app/core/constants/api_constants.dart';
import 'package:medicare_app/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final http.Client client;

  ApiService({required this.client});

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Save token after login
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Save user data
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  // Get user data
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Remove token on logout
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // GET Request
  Future<http.Response> get(String url) async {
    final token = await getToken();
    final response = await client.get(
      Uri.parse(url),
      headers: ApiConstants.getHeaders(token: token),
    ).timeout(ApiConstants.connectionTimeout);
    return response;
  }

  // POST Request
  Future<http.Response> post(String url, {dynamic body}) async {
    final token = await getToken();
    final response = await client.post(
      Uri.parse(url),
      headers: ApiConstants.getHeaders(token: token),
      body: jsonEncode(body),
    ).timeout(ApiConstants.connectionTimeout);
    return response;
  }

  // PUT Request
  Future<http.Response> put(String url, {dynamic body}) async {
    final token = await getToken();
    final response = await client.put(
      Uri.parse(url),
      headers: ApiConstants.getHeaders(token: token),
      body: jsonEncode(body),
    ).timeout(ApiConstants.connectionTimeout);
    return response;
  }

  // DELETE Request
  Future<http.Response> delete(String url) async {
    final token = await getToken();
    final response = await client.delete(
      Uri.parse(url),
      headers: ApiConstants.getHeaders(token: token),
    ).timeout(ApiConstants.connectionTimeout);
    return response;
  }
}
