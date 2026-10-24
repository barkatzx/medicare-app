import 'package:medicare_app/features/repository/auth_repository.dart';

import '../entity/user_entity.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> execute({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    if (name.isEmpty) {
      throw Exception('Name is required');
    }

    if (email.isEmpty) {
      throw Exception('Email is required');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }

    if (phoneNumber.isEmpty) {
      throw Exception('Phone number is required');
    }

    if (password.isEmpty) {
      throw Exception('Password is required');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    return await repository.register(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
