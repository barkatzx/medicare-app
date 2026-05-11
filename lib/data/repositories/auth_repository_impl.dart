import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicare_app/data/repositories/auth_repository.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/local/shared_prefs_helper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final http.Client client;
  final SharedPrefsHelper sharedPreferencesHelper;

  AuthRepositoryImpl({
    required this.client,
    required this.sharedPreferencesHelper,
  });

  @override
  Future<UserEntity> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'phone_number': phoneNumber?.trim(),
        'password': password,
      };

      final response = await client
          .post(
            Uri.parse(ApiConstants.login),
            headers: ApiConstants.getHeaders(),
            body: json.encode(requestBody),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection.',
              );
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Handle response structure
        UserEntity user;
        String token;

        if (responseData['data'] != null) {
          final userData = responseData['data']['user'];
          token = responseData['data']['token'];

          if (userData == null) {
            throw Exception('User data not found');
          }

          user = UserEntity.fromJson(userData);

          // Check if user is customer and approved
          if (user.role.toLowerCase() == 'customer') {
            if (!user.isApproved) {
              throw Exception(
                'Your account is pending approval. Please wait for admin approval.',
              );
            }
          } else {
            throw Exception(
              'Access denied. Only customer accounts can use this app.',
            );
          }

          // Save token and user data
          await sharedPreferencesHelper.saveToken(token);
          await sharedPreferencesHelper.saveUser(user);

          return user;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorBody = json.decode(response.body);
        throw (errorBody['message'] ??
            'Login failed. Check your password and try again.');
      }
    } catch (e) {
      throw ('$e');
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final requestBody = {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
      };

      final response = await client
          .post(
            Uri.parse(ApiConstants.register),
            headers: ApiConstants.getHeaders(),
            body: json.encode(requestBody),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection.',
              );
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // For registration, backend might not return token immediately
        // Instead, it returns success message and user data without token

        UserEntity? user;

        // Try to extract user data from different response formats
        if (responseData['data'] != null) {
          if (responseData['data']['user'] != null) {
            user = UserEntity.fromJson(responseData['data']['user']);
          }
        } else if (responseData['user'] != null) {
          user = UserEntity.fromJson(responseData['user']);
        }

        if (user != null) {
          // Save user data (no token yet since account needs approval)
          await sharedPreferencesHelper.saveUser(user);
          print('User registered successfully: ${user.email}');
          return user;
        } else {
          // Return a pending user object for approval
          final pendingUser = UserEntity(
            id: '',
            name: name,
            email: email,
            phoneNumber: phoneNumber,
            role: 'customer',
            isApproved: false,
            createdAt: DateTime.now(),
          );
          await sharedPreferencesHelper.saveUser(pendingUser);
          print('Registration successful but pending approval');
          return pendingUser;
        }
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
          errorBody['message'] ??
              'Registration failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Registration Error: $e');
    }
  }

  @override
  Future<UserEntity> verifyAuth() async {
    try {
      final token = await sharedPreferencesHelper.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await client
          .get(
            Uri.parse(ApiConstants.verifyAuth),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout. Working in offline mode.');
            },
          );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null && responseData['data']['user'] != null) {
          final user = UserEntity.fromJson(responseData['data']['user']);
          if (user.role.toLowerCase() == 'customer') {
            if (!user.isApproved) {
              await logout();
              throw Exception('Your account is pending approval.');
            }
            await sharedPreferencesHelper.saveUser(user);
            return user;
          } else {
            await logout();
            throw Exception('Access denied. Customer only.');
          }
        } else {
          throw Exception('Invalid user data');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await logout();
        throw Exception('Session expired. Please login again.');
      } else {
        // For other errors (500, etc.), try to use cached user if available
        final cachedUser = await sharedPreferencesHelper.getUser();
        if (cachedUser != null) return cachedUser;
        throw Exception('Server error and no cached user found.');
      }
    } catch (e) {
      // On network errors or other exceptions, try to return cached user
      final cachedUser = await sharedPreferencesHelper.getUser();
      if (cachedUser != null) return cachedUser;
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await sharedPreferencesHelper.clearToken();
    await sharedPreferencesHelper.clearUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await sharedPreferencesHelper.getToken();
    final user = await sharedPreferencesHelper.getUser();
    return token != null && token.isNotEmpty && user != null && user.isApproved;
  }

  @override
  Future<String?> getToken() async {
    return await sharedPreferencesHelper.getToken();
  }

  @override
  Future<void> saveToken(String token) async {
    await sharedPreferencesHelper.saveToken(token);
  }

  @override
  Future<void> clearToken() async {
    await sharedPreferencesHelper.clearToken();
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    await sharedPreferencesHelper.saveUser(user);
  }

  @override
  Future<UserEntity?> getUser() async {
    return await sharedPreferencesHelper.getUser();
  }

  @override
  Future<UserEntity> getProfile() async {
    try {
      final token = await sharedPreferencesHelper.getToken();
      if (token == null) throw Exception('Authentication token not found');

      final response = await client
          .get(
            Uri.parse(ApiConstants.profile),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final user = UserEntity.fromJson(responseData['data']);
          await sharedPreferencesHelper.saveUser(user);
          return user;
        } else {
          throw Exception('Profile data not found in response');
        }
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      print('Get profile error: $e');
      throw Exception('$e');
    }
  }

  @override
  Future<UserEntity> updateProfile({
    required String name,
    required String pharmacyName,
    required String phoneNumber,
  }) async {
    try {
      final token = await sharedPreferencesHelper.getToken();
      if (token == null) throw Exception('Authentication token not found');

      final requestBody = {
        'name': name,
        'pharmacy_name': pharmacyName,
        'phone_number': phoneNumber,
      };

      final response = await client
          .put(
            Uri.parse(ApiConstants.updateprofile),
            headers: ApiConstants.getHeaders(token: token),
            body: json.encode(requestBody),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final user = UserEntity.fromJson(responseData['data']);
          await sharedPreferencesHelper.saveUser(user);
          return user;
        } else {
          throw Exception('Updated profile data not found in response');
        }
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Update profile error: $e');
      throw Exception('$e');
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final token = await sharedPreferencesHelper.getToken();
      if (token == null) throw Exception('Authentication token not found');

      final requestBody = {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      };

      final response = await client
          .post(
            Uri.parse(ApiConstants.changePassword),
            headers: ApiConstants.getHeaders(token: token),
            body: json.encode(requestBody),
          )
          .timeout(ApiConstants.connectionTimeout);

      final responseData = json.decode(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(responseData['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      print('Change password error: $e');
      throw Exception('$e');
    }
  }
}
