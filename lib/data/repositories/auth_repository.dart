import 'package:medicare_app/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    String? email,
    String? phoneNumber,
    required String password,
  });

  Future<UserEntity> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<UserEntity> verifyAuth();

  Future<void> logout();

  Future<bool> isLoggedIn();

  Future<String?> getToken();

  Future<void> saveToken(String token);

  Future<void> clearToken();

  Future<void> saveUser(UserEntity user);

  Future<UserEntity?> getUser();

  Future<UserEntity> getProfile();

  Future<UserEntity> updateProfile({
    required String name,
    required String pharmacyName,
    required String phoneNumber,
  });

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
